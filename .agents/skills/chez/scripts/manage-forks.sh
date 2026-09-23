#!/usr/bin/env bash
# manage-forks.sh — Autonomous management, receipts, and build/sync for maintained software forks.
# Maintained by `chez` skill for Hylian/dotfiles.

set -euo pipefail

# Determine dotfiles repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"

# Machine-local state directory for build receipts
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/builds"
mkdir -p "$STATE_DIR"

# Inherit Zellij dynamic SSH agent socket if running in a non-interactive subshell
if [[ -z "${SSH_AUTH_SOCK:-}" && -S "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/zellij-env/ssh-auth-sock" ]]; then
  export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/zellij-env/ssh-auth-sock"
fi

# Fork definitions: name|relative_path|target_bin|branch
FORKS=(
  "zellij|software/zellij|$HOME/.local/bin/zellij|hylian/latency"
  "zjstatus|software/zjstatus|$HOME/.config/zellij/plugins/zjstatus.wasm|hylian/autorender"
)

get_receipt_commit() {
  local fork="$1"
  local receipt="${STATE_DIR}/${fork}.json"
  if [[ -f "$receipt" ]]; then
    if command -v jq >/dev/null 2>&1; then
      jq -r '.commit // empty' "$receipt"
    else
      sed -n 's/.*"commit": *"\{0,1\}\([^",]*\).*/\1/p' "$receipt"
    fi
  fi
}

write_receipt() {
  local fork="$1"
  local commit="$2"
  local target="$3"
  local receipt="${STATE_DIR}/${fork}.json"
  local timestamp
  timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  local hostname
  hostname="$(hostname)"
  local os
  os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  local arch
  arch="$(uname -m)"

  cat > "$receipt" <<EOF
{
  "name": "$fork",
  "commit": "$commit",
  "target": "$target",
  "built_at": "$timestamp",
  "hostname": "$hostname",
  "os": "$os",
  "arch": "$arch"
}
EOF
}

get_submodule_commit() {
  local path="$1"
  if [[ -d "${REPO_ROOT}/${path}/.git" || -f "${REPO_ROOT}/${path}/.git" ]]; then
    git -C "${REPO_ROOT}/${path}" rev-parse HEAD 2>/dev/null || true
  fi
}

prune_zjstatus_cache() {
  local os
  os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  local cache_dir=""
  if [[ "$os" == "darwin" ]]; then
    cache_dir="$HOME/Library/Caches/org.Zellij-Contributors.Zellij"
  else
    cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zellij"
  fi

  if [[ -d "$cache_dir" ]]; then
    # Prune plugin_cache directories without touching permissions.kdl or contract_version_1/
    find "$cache_dir" -type d -name "plugin_cache" -exec rm -rf {} + 2>/dev/null || true
    # Prune temporary download blobs while preserving session-critical directories
    find "$cache_dir" -maxdepth 1 -type f -name "*.blob" -exec rm -f {} + 2>/dev/null || true
  fi
}

build_zellij() {
  local dir="${REPO_ROOT}/software/zellij"
  local target="$HOME/.local/bin/zellij"
  echo "🔨 [zellij] Building from ${dir}..."

  if ! command -v cargo >/dev/null 2>&1; then
    echo "❌ cargo not found on PATH. Ensure Rust toolchain is installed." >&2
    return 1
  fi

  mkdir -p "$(dirname "$target")"

  # Build using xtask install
  (
    cd "$dir"
    cargo xtask install "$target"
  )

  # On macOS, ensure fresh inode to prevent kernel CDHash vnode signature mismatch SIGKILL
  if [[ "$(uname -s)" == "Darwin" ]]; then
    local release_bin="${dir}/target/release/zellij"
    if [[ -f "$release_bin" ]]; then
      rm -f "$target"
      cp "$release_bin" "$target"
      codesign -s - --force "$target" >/dev/null 2>&1 || true
    fi
  fi

  # Clean any protobuf/wasm asset mutations written into the working tree by xtask
  git -C "$dir" checkout -- . >/dev/null 2>&1 || true

  local commit
  commit="$(git -C "$dir" rev-parse HEAD)"
  write_receipt "zellij" "$commit" "$target"
  echo "✅ [zellij] Installed to ${target} (commit ${commit:0:8})"
}

build_zjstatus() {
  local dir="${REPO_ROOT}/software/zjstatus"
  local target="$HOME/.config/zellij/plugins/zjstatus.wasm"
  echo "🔨 [zjstatus] Building wasm from ${dir}..."

  if ! command -v cargo >/dev/null 2>&1; then
    echo "❌ cargo not found on PATH. Ensure Rust toolchain is installed." >&2
    return 1
  fi

  mkdir -p "$(dirname "$target")"

  (
    cd "$dir"
    cargo build --release --target wasm32-wasip1
  )

  local wasm_out="${dir}/target/wasm32-wasip1/release/zjstatus.wasm"
  if [[ ! -f "$wasm_out" ]]; then
    echo "❌ Build artifact not found at ${wasm_out}" >&2
    return 1
  fi

  cp "$wasm_out" "$target"
  prune_zjstatus_cache

  local commit
  commit="$(git -C "$dir" rev-parse HEAD)"
  write_receipt "zjstatus" "$commit" "$target"
  echo "✅ [zjstatus] Installed to ${target} (commit ${commit:0:8})"
}

cmd_status() {
  echo "📦 Software Fork Fleet Status on $(hostname) ($(uname -s) $(uname -m)):"
  echo ""

  for entry in "${FORKS[@]}"; do
    IFS="|" read -r name rel_path target_bin branch <<< "$entry"
    local sub_commit
    sub_commit="$(get_submodule_commit "$rel_path")"
    local rec_commit
    rec_commit="$(get_receipt_commit "$name")"

    local binary_exists="no"
    if [[ -f "$target_bin" ]]; then
      binary_exists="yes"
    fi

    printf "  • %-10s " "$name"
    if [[ -z "$sub_commit" ]]; then
      printf "❌ submodule not initialized at %s\n" "$rel_path"
      continue
    fi

    local sub_short="${sub_commit:0:8}"
    local rec_short="${rec_commit:0:8}"

    if [[ "$binary_exists" != "yes" ]]; then
      printf "❌ NOT INSTALLED (submodule: %s, target: %s)\n" "$sub_short" "$target_bin"
    elif [[ -z "$rec_commit" ]]; then
      printf "⚠️  UNTRACKED RECEIPT (submodule: %s, target: exists)\n" "$sub_short"
    elif [[ "$sub_commit" == "$rec_commit" ]]; then
      printf "✨ UP TO DATE (%s) -> %s\n" "$sub_short" "$target_bin"
    else
      printf "🔄 NEEDS BUILD (installed: %s -> submodule: %s)\n" "$rec_short" "$sub_short"
    fi
  done
  echo ""
}

cmd_check() {
  local needs_build=0
  for entry in "${FORKS[@]}"; do
    IFS="|" read -r name rel_path target_bin branch <<< "$entry"
    local sub_commit
    sub_commit="$(get_submodule_commit "$rel_path")"
    local rec_commit
    rec_commit="$(get_receipt_commit "$name")"

    if [[ ! -f "$target_bin" || -z "$rec_commit" || "$sub_commit" != "$rec_commit" ]]; then
      needs_build=1
    fi
  done
  return "$needs_build"
}

cmd_build() {
  local target_fork="${1:-all}"

  for entry in "${FORKS[@]}"; do
    IFS="|" read -r name rel_path target_bin branch <<< "$entry"
    if [[ "$target_fork" == "all" || "$target_fork" == "$name" ]]; then
      case "$name" in
        zellij)   build_zellij ;;
        zjstatus) build_zjstatus ;;
        *) echo "Unknown fork: $name" >&2 ;;
      esac
    fi
  done
}

cmd_sync() {
  echo "🔍 Checking submodules in ${REPO_ROOT}..."
  GIT_SSH_COMMAND="ssh -o BatchMode=yes" git -C "$REPO_ROOT" submodule update --init --recursive 2>/dev/null || \
    git -C "$REPO_ROOT" -c url."https://github.com/".insteadOf="git@github.com:" submodule update --init --recursive

  local built_any=0
  for entry in "${FORKS[@]}"; do
    IFS="|" read -r name rel_path target_bin branch <<< "$entry"
    local sub_commit
    sub_commit="$(get_submodule_commit "$rel_path")"
    local rec_commit
    rec_commit="$(get_receipt_commit "$name")"

    if [[ ! -f "$target_bin" || -z "$rec_commit" || "$sub_commit" != "$rec_commit" ]]; then
      echo "⚡ Updating $name (installed: ${rec_commit:0:8:-none} -> submodule: ${sub_commit:0:8})..."
      case "$name" in
        zellij)   build_zellij; built_any=1 ;;
        zjstatus) build_zjstatus; built_any=1 ;;
      esac
    else
      echo "✨ $name is already up to date (${sub_commit:0:8})."
    fi
  done

  if [[ "$built_any" -eq 1 ]]; then
    echo "🎉 Fork build & install sync complete!"
  else
    echo "✨ All software forks are already up to date."
  fi
}

cmd_record() {
  local fork="$1"
  local commit="${2:-}"

  for entry in "${FORKS[@]}"; do
    IFS="|" read -r name rel_path target_bin branch <<< "$entry"
    if [[ "$fork" == "$name" ]]; then
      if [[ -z "$commit" ]]; then
        commit="$(get_submodule_commit "$rel_path")"
      fi
      if [[ -z "$commit" ]]; then
        echo "❌ Cannot determine commit for $fork" >&2
        return 1
      fi
      write_receipt "$fork" "$commit" "$target_bin"
      echo "📝 Recorded receipt for $fork: commit ${commit:0:8} -> $target_bin"
      return 0
    fi
  done
  echo "❌ Unknown fork: $fork" >&2
  return 1
}

case "${1:-status}" in
  status) cmd_status ;;
  check)  cmd_check ;;
  build)  shift; cmd_build "$@" ;;
  sync)   cmd_sync ;;
  record) shift; cmd_record "$@" ;;
  *)
    echo "Usage: $0 {status|check|build [fork]|sync|record <fork> [commit]}"
    exit 1
    ;;
esac
