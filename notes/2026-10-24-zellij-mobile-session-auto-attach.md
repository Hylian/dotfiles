# Zellij Mobile Session Auto-Attach via $ZELLIJ_MOBILE_SESSION

*Date: 2026-10-24*
*Host: `midnight-future` (macOS Apple Silicon Client)*

## Context & Motivation
When connecting from mobile SSH clients (e.g. phones or tablets over SSH/Mosh), starting an anonymous Zellij session on every shell connection results in ephemeral sessions and orphaned state when the mobile connection drops or the client disconnects. Rachel requested modifying the Zsh shell startup so that when a client connects with `$ZELLIJ_MOBILE_SESSION` set in the environment, it automatically attaches to or creates a persistent `mobile` session with force-close detachment:
```zsh
zellij a -c mobile options --on-force-close detach
```
instead of launching the normal anonymous Zellij session.

## Implementation Details
1. **Interactive Shell Auto-Start Guard in [dot_zshrc.tmpl](../dot_zshrc.tmpl):**
   - Wrapped the Zellij auto-start sequence behind `if [[ -z "$ZELLIJ_NO_AUTOSTART" && -z "$ZELLIJ" ]]; then`.
   - Checked for `_mobile_session="${ZELLIJ_MOBILE_SESSION:-${LC_ZELLIJ_MOBILE_SESSION:-${LC_ZELLIJ_MOBILE:-}}}"`:
     - OpenSSH client (`ssh`) only forwards `LANG` and `LC_*` by default via `SendEnv`, and OpenSSH server (`sshd`) discards all incoming environment variables except `LANG` and `LC_*` unless explicitly listed in `/etc/ssh/sshd_config` (`AcceptEnv`).
     - By accepting `LC_ZELLIJ_MOBILE_SESSION` (and `LC_ZELLIJ_MOBILE`) alongside `ZELLIJ_MOBILE_SESSION`, clients can tunnel the environment variable directly through standard OpenSSH connections (e.g. `LC_ZELLIJ_MOBILE_SESSION=1 ssh host`) without requiring root access or sshd configuration.
     - Automatically exports canonical `ZELLIJ_MOBILE_SESSION` in the shell environment.
     - When set, launches `zellij a -c mobile options --on-force-close detach`.
     - Invokes the `zellij()` shell wrapper in `.zshrc`, ensuring `_zellij_sync_client_env` records the client SSH status into `$env_dir/mobile` and updates `zjstatus` (`command_host`).
     - Respects `$ZELLIJ_AUTO_EXIT == "true"` to cleanly exit the outer shell if configured when Zellij exits.
     - When unset, falls back to sourcing `$ZSH_CACHE_DIR/zellij.zsh` for the default anonymous session.
2. **Verification & Wordcode Compilation:**
   - Validated template rendering via `chezmoi execute-template < dot_zshrc.tmpl | zsh -n`.
   - Applied cleanly to `~/.zshrc` via `chezmoi apply --no-pager`.
   - Recompiled Zsh wordcode bundle via `zsh -c "zcompile ~/.zshrc"`.
   - Verified that `_zellij_sync_client_env a -c mobile ...` successfully parses session name `mobile` and writes the environment file `$env_dir/mobile`.
   - Verified that nested Zellij panes (`ZELLIJ=0`) and explicitly bypassed shells (`ZELLIJ_NO_AUTOSTART=1`) skip auto-start completely.
