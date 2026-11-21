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
# New machine (BW_SERVER is only for a self-hosted Bitwarden):
#   curl -fsSL https://raw.githubusercontent.com/jiminj/dotfiles/mise/config/scripts/setup.sh \
#     | BW_SERVER=https://vault.example.com sh -s -- install [--work]
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
bw() { if [ -n "$BW_BIN" ]; then "$BW_BIN" "$@"; else "$MISE" exec "bitwarden@${BW_VERSION:-2026.10.1}" -- bw "$@"; fi; }
jq() { if [ -n "$JQ_BIN" ]; then "$JQ_BIN" "$@"; else "$MISE" exec jq -- jq "$@"; fi; }

# Log in if needed and export a session token for this process only.
bw_session() {
  case "$(bw status 2>/dev/null)" in
    *'"status":"unauthenticated"'*)
      if [ -n "${BW_SERVER:-}" ]; then
        bw config server "$BW_SERVER" >/dev/null || die "bw rejected the server '$BW_SERVER'"
      fi
      say "Bitwarden login at $(bw config server 2>/dev/null) (self-hosted: set BW_SERVER=<url>)"
      # A newer CLI can fail a post-login migration against an older
      # self-hosted server while the login itself went through.
      bw login </dev/tty >/dev/tty || warn "bw login reported an error; checking whether the login took"
      case "$(bw status 2>/dev/null)" in
        *'"status":"unauthenticated"'*)
          die "Bitwarden login failed. An older CLI may suit the server: BW_VERSION=2026.9.1 sh $0 ..." ;;
      esac ;;
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
  work="" take=""
  for arg in "$@"; do
    case "$arg" in
      --work) work=1 ;;
      --take-remote) take=1 ;;
      *) die "unknown option: $arg" ;;
    esac
  done

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
  if [ -n "$work" ]; then
    set -- -E work bootstrap --yes --save-env
  else
    set -- bootstrap --yes
  fi

  if ! grep -qs '^\[history.origin\]' "$HOME/.config/mise/config.local.toml"; then
    say "Restore dotfiles and bootstrap${work:+ (work profile)}"
    "$MISE" "$@" --adopt "$REPO?ref=$BRANCH" || true
  fi
  # A machine that already has some of these files (for example from yadm) is
  # left untouched: mise pauses until told which side wins. The [dotfiles]
  # table only arrives with the restored config, so it marks a finished restore.
  if ! grep -qs '^\[dotfiles\]' "$HOME/.config/mise/config.toml"; then
    if [ -z "$take" ]; then
      "$MISE" dot status || true
      die "the restore is paused: files on this machine differ from the repository (listed above).
       Nothing was changed. To overwrite them with the repository's version, run this again
       with --take-remote. Files that only exist here are never touched."
    fi
    say "Replace differing files with the repository's version"
    "$MISE" dot pull --take-remote-all
  fi
  say "Bootstrap"
  "$MISE" "$@"

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
  *) echo "usage: $0 {install [--work] [--take-remote]|key|backup-key|status}" >&2; exit 2 ;;
esac
