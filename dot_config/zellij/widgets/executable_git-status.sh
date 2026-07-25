#!/bin/sh
# zjstatus git widget -- branch name plus a dirty marker for the focused pane's cwd.
#
# zjstatus reruns this command on every focused-cwd change (pane switch, cd) on top
# of the poll interval, and re-spawns it on each render until the result lands --
# measured at ~18 invocations per pane switch at three switches per second. It
# therefore has to be cheap enough to survive a held-down navigation key.
#
# Measured cost of the obvious implementation, on a 40k-file worktree:
#
#   git symbolic-ref / rev-parse    ~4 ms   O(1)
#   git diff-index --quiet HEAD    ~30 ms   O(worktree), lstats every tracked file
#
# So there are two tiers of memo. A one-slot memo of the last rendered output keyed
# by cwd absorbs the re-spawn burst (zjstatus only ever asks about the focused pane,
# so one slot suffices) and leaves no git process on that path at all. Behind it, the
# dirty check is memoised per repository in $GIT_DIR/zjstatus-dirty, and the branch
# is read straight out of HEAD with builtins, leaving one git process on a full
# recompute. Zsh's precmd/chpwd hooks delete both, so interactive commands and
# directory changes still reach the bar at once; the TTLs are only a backstop for
# changes made outside this shell.
#
# Caveat inherited from the read-only index policy (core.fsmonitor/untrackedCache off,
# --no-optional-locks everywhere): diff-index trusts the index stat cache, so a tree
# whose files were re-stamped without an index write -- a worktree copy, an external
# checkout -- can read as dirty until any ordinary git command refreshes the index.

set -u

ttl=${ZJSTATUS_GIT_DIRTY_TTL:-3}
git="git --no-optional-locks"

# zjstatus re-spawns this command on every render between invalidating a
# focused-cwd widget and receiving its result, and throws away results that land
# after the cwd moved on again. One pane switch therefore costs ~18 invocations at
# a human switching rate, all for the same directory. Collapse that burst with a
# single-entry memo -- a session only ever has one focused pane, so one slot is all
# the cache that is needed. Zsh's precmd hook deletes it, so the memo never stands
# between an interactive command and the bar.
#
# The slot MUST be per session. A shared slot makes concurrent sessions invalidate
# each other's entry on every render, and with the repaint kick below that becomes
# a feedback loop between their status bars.
memo=${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/zjstatus-git-memo.${ZELLIJ_SESSION_NAME:-nosession}

memo_cwd=''
memo_out=''

if [ -f "$memo" ]; then
	IFS='	' read -r memo_cwd memo_out <"$memo" 2>/dev/null || { memo_cwd=''; memo_out=''; }
	if [ "$memo_cwd" = "$PWD" ] &&
		[ -n "$(find "$memo" -newermt '-1 seconds' 2>/dev/null)" ]; then
		printf '%s\n' "$memo_out"
		exit 0
	fi
fi

# Every exit path goes through emit so that leaving a repository is memoised too,
# otherwise non-repo directories would storm on every render.
emit() {
	printf '%s\t%s\n' "$PWD" "$1" >"$memo" 2>/dev/null
	printf '%s\n' "$1"

	# A zjstatus that stores a command result without scheduling a repaint leaves
	# a changed value invisible until the next render tick -- measured at a median
	# of 784 ms after a pane switch. Any recognised pipe message forces a render,
	# and a pipe name no format string references has no other effect, so we kick
	# one.
	#
	# ZJSTATUS_AUTORENDER is set by the layout for a locally built zjstatus, which
	# carries the patch that repaints as soon as a command result changes. The kick
	# is pure overhead there, so it switches itself off; on a release build of
	# zjstatus the marker is absent and we keep it.
	#
	# Fire only when the value or the directory actually moved, which is at most
	# once per pane switch and nothing at all on a settled bar. The cwd clause also
	# covers results zjstatus discards as stale, where the memo has advanced but
	# the plugin never stored anything.
	#
	# `zellij pipe` is a streaming client, not a fire-and-forget one: it exits once
	# the plugin has handled the message (~40 ms measured), but blocks indefinitely
	# when the session it targets is gone or its server is wedged, and each blocked
	# client holds a socket. Unbounded, that turns a stalled server into file
	# descriptor exhaustion. Give it /dev/null on stdin and cap it with a plain-sh
	# watchdog -- macOS has no timeout(1) -- so no kick can outlive two seconds.
	if [ -z "${ZJSTATUS_AUTORENDER:-}" ] &&
		{ [ "$1" != "$memo_out" ] || [ "$memo_cwd" != "$PWD" ]; }; then
		# The watchdog must not inherit our stdout: zellij reads the command's
		# output to EOF, so a grandchild holding that pipe open would stall the
		# result -- and the whole point of this branch -- for the full two seconds.
		(
			zellij pipe "zjstatus::pipe::zjs_render_kick::-" \
				</dev/null >/dev/null 2>&1 &
			kicker=$!
			sleep 2
			kill "$kicker" 2>/dev/null
		) </dev/null >/dev/null 2>&1 &
	fi

	exit 0
}

# The single git call. --absolute-git-dir resolves from subdirectories, linked
# worktrees and submodules alike, and each of those owns the HEAD we then read.
gitdir=$($git rev-parse --absolute-git-dir 2>/dev/null) || emit ''

IFS= read -r head <"$gitdir/HEAD" 2>/dev/null || emit ''

case $head in
	'ref: refs/heads/'*) branch=${head#ref: refs/heads/} ;;
	'ref: '*) branch=${head#ref: } ;;
	# Detached HEAD holds a raw object name; show the conventional short form.
	*) branch=${head%"${head#???????}"} ;;
esac

[ -n "$branch" ] || emit ''

cache=$gitdir/zjstatus-dirty

# Recompute when the cache is missing or older than the TTL. A find that lacks
# -newermt yields empty here, which degrades to recomputing on every call.
if [ ! -f "$cache" ] || [ -z "$(find "$cache" -newermt "-$ttl seconds" 2>/dev/null)" ]; then
	# diff-index exits 0 clean, 1 with differences, 128 when HEAD is unborn or
	# unreadable. Only 1 means dirty; anything else renders as clean.
	$git diff-index --quiet HEAD -- 2>/dev/null
	if [ $? -eq 1 ]; then
		printf ' ●' >"$cache" 2>/dev/null
	else
		: >"$cache" 2>/dev/null
	fi
fi

marker=''
[ -r "$cache" ] && IFS= read -r marker <"$cache"

emit "$branch$marker"
