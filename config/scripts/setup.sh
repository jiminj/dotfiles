#!/bin/sh
# Dotfiles setup. Chain of trust:
#   Bitwarden login -> age key (~/.config/fnox/age.txt)
#   -> encrypted dotfiles (mise) and API keys / SSH keys (fnox)
#
#   setup.sh install [--work]  new machine: mise, age key, dotfiles, bootstrap
#   setup.sh key               fetch the age key from Bitwarden if it is missing
#   setup.sh backup-key        once: store this machine's age key in Bitwarden
#   setup.sh status            show where each link of the chain stands
#
# New machine (self-hosted Bitwarden: the script stops and tells you to run
# `bw config server <url>` only if you are not logged in yet):
#   curl -fsSL https://raw.githubusercontent.com/jiminj/dotfiles/mise/config/scripts/setup.sh | sh -s -- install [--work]
set -eu

REPO="${DOTFILES_REPO:-https://github.com/jiminj/dotfiles.git}"
REPO_SSH="${DOTFILES_REPO_SSH:-git@github.com:jiminj/dotfiles.git}"
BRANCH="${DOTFILES_REF:-mise}"
ITEM="${DOTFILES_AGE_ITEM:-dotfiles-age-key}"   # Bitwarden secure note name
AGE_KEY="$HOME/.config/fnox/age.txt"
MISE="$HOME/.local/bin/mise"

say() { printf '\n== %s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die() { printf 'setup: %s\n' "$*" >&2; exit 1; }

# bw and jq come from mise; before the dotfiles exist they are fetched ad hoc.
# (Resolved before the wrappers are defined, so these are real paths or empty.)
BW_BIN=$(command -v bw || true)
JQ_BIN=$(command -v jq || true)
bw() { if [ -n "$BW_BIN" ]; then "$BW_BIN" "$@"; else "$MISE" exec bitwarden -- bw "$@"; fi; }
jq() { if [ -n "$JQ_BIN" ]; then "$JQ_BIN" "$@"; else "$MISE" exec jq -- jq "$@"; fi; }

# Log in if needed and export a session token for this process only.
bw_session() {
  case "$(bw status 2>/dev/null)" in
    *'"status":"unauthenticated"'*)
      say "Bitwarden login (self-hosted? first run: bw config server <url>)"
      bw login </dev/tty >/dev/tty ;;
  esac
  say "Unlock Bitwarden"
  BW_SESSION=$(bw unlock --raw </dev/tty) || die "Bitwarden unlock failed"
  export BW_SESSION
  bw sync >/dev/null
}

cmd_key() {
  if [ -s "$AGE_KEY" ]; then
    echo "age key already present"
    return 0
  fi
  bw_session
  say "Fetch the age key from Bitwarden item '$ITEM'"
  umask 077
  mkdir -p "$(dirname "$AGE_KEY")"
  bw get notes "$ITEM" > "$AGE_KEY.tmp" || { rm -f "$AGE_KEY.tmp"; die "item '$ITEM' not found"; }
  grep -q '^AGE-SECRET-KEY-' "$AGE_KEY.tmp" || { rm -f "$AGE_KEY.tmp"; die "item '$ITEM' holds no age key"; }
  mv "$AGE_KEY.tmp" "$AGE_KEY"
  bw lock >/dev/null 2>&1 || true
}

cmd_install() {
  work=""
  [ "${1:-}" = --work ] && work=1

  if [ "$(uname -s)" = Darwin ] && ! xcode-select -p >/dev/null 2>&1; then
    die "Xcode Command Line Tools are required. Run: xcode-select --install"
  fi
  # mise restores the dotfiles with git.
  if ! command -v git >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1; then
    command -v apt-get >/dev/null 2>&1 || die "git and curl are required"
    say "Install git and curl"
    sudo apt-get update
    sudo apt-get install -y git curl ca-certificates
  fi
  if [ ! -x "$MISE" ]; then
    say "Install mise"
    curl -fsSL https://mise.run | MISE_INSTALL_HELP=0 sh
  fi

  cmd_key

  # The key location is also set in the dotfiles' mise config, but that config
  # is what is being fetched here, so say it once by hand.
  export MISE_AGE_KEY_FILE="$AGE_KEY"
  if grep -qs '^\[history.origin\]' "$HOME/.config/mise/config.local.toml"; then
    say "Dotfiles already restored; re-running the bootstrap"
    "$MISE" bootstrap --yes
    say "Done."
    return 0
  fi
  if [ -n "$work" ]; then
    say "Restore dotfiles and bootstrap (work profile)"
    "$MISE" -E work bootstrap --adopt "$REPO?ref=$BRANCH" --yes --save-env
  else
    say "Restore dotfiles and bootstrap"
    "$MISE" bootstrap --adopt "$REPO?ref=$BRANCH" --yes
  fi

  # The dotfiles were fetched read-only over https; switch to SSH for pushing
  # now that the SSH key is in place.
  say "Point the dotfile history at $REPO_SSH"
  "$MISE" dot origin set "$REPO_SSH" --branch "$BRANCH" --sync manual --yes ||
    warn "could not connect over SSH; later run: mise dot origin set $REPO_SSH --branch $BRANCH"

  say "Done. Start a new shell (exec zsh) to pick up the tools and API keys."
}

cmd_backup_key() {
  [ -s "$AGE_KEY" ] || die "no age key at $AGE_KEY"
  bw_session
  if bw get item "$ITEM" >/dev/null 2>&1; then
    die "Bitwarden already has an item named '$ITEM'; delete or rename it first"
  fi
  say "Create Bitwarden secure note '$ITEM'"
  bw get template item \
    | jq --rawfile key "$AGE_KEY" --arg name "$ITEM" \
        '.type = 2 | .secureNote = {type: 0} | .name = $name | .notes = $key | .login = null' \
    | bw encode | bw create item >/dev/null
  bw sync >/dev/null
  # Read it back and compare, without printing either copy.
  if [ "$(bw get notes "$ITEM" | sha256sum)" = "$(sha256sum < "$AGE_KEY")" ] || \
     [ "$(bw get notes "$ITEM" | tr -d '\r' | sed -e '$a\' | sha256sum)" = "$(sha256sum < "$AGE_KEY")" ]; then
    say "Stored and verified"
  else
    die "stored note does not match the local key; check the item in Bitwarden"
  fi
  bw lock >/dev/null 2>&1 || true
}

cmd_status() {
  if [ -s "$AGE_KEY" ]; then echo "age key:      present ($AGE_KEY)"; else echo "age key:      MISSING"; fi
  if fnox get --file "$HOME/.ssh/id_ed25519" >/dev/null 2>&1; then echo "fnox decrypt: ok"; else echo "fnox decrypt: FAILS"; fi
  echo "bitwarden:    $(bw status 2>/dev/null | sed -n 's/.*"status":"\([a-z]*\)".*/\1/p')"
  echo "dotfiles:     $("$MISE" dot status 2>/dev/null | grep -E 'entries ·|unsaved|Branch:' | sed 's/^ *//' | tr '\n' ';')"
}

case "${1:-}" in
  install) shift; cmd_install "$@" ;;
  key) cmd_key ;;
  backup-key) cmd_backup_key ;;
  status) cmd_status ;;
  *) echo "usage: $0 {install [--work]|key|backup-key|status}" >&2; exit 2 ;;
esac
