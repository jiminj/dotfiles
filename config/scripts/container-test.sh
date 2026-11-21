#!/bin/bash
# End-to-end new-machine test in a clean ubuntu:24.04 container, run as root.
# It creates a sudo-capable user, gives it the age key (standing in for the
# Bitwarden fetch), runs `setup.sh install` twice against a copy of the dotfile
# history, then asserts the result.
#
#   git clone --bare --branch mise https://github.com/jiminj/dotfiles.git /tmp/dotfiles.git
#   docker run --rm \
#     -v /tmp/dotfiles.git:/src/origin.git:ro \
#     -v ~/.config/fnox/age.txt:/src/age.txt:ro \
#     -v ~/.config/mise/scripts:/src/scripts:ro \
#     ubuntu:24.04 bash /src/scripts/container-test.sh
#
# The container sees the real age key and so the real SSH keys; it is removed
# afterwards (--rm). Optional env:
#   APT_MIRROR=kr.archive.ubuntu.com  (when the default mirror is slow)
#   TEST_CLASS=Work                   (exercise the work profile)
#   TEST_REF=mise                     (branch of /src/origin.git to restore)
#   TEST_CONFLICT=1                   (start with differing files in place)
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
if [ -n "${APT_MIRROR:-}" ]; then
  sed -i "s#archive.ubuntu.com#$APT_MIRROR#" /etc/apt/sources.list.d/ubuntu.sources
fi
apt-get update -qq >/dev/null
# git and curl are left out on purpose: setup.sh must install them.
apt-get install -y -qq sudo ca-certificates >/dev/null 2>&1
useradd -m -s /bin/bash tester
echo 'tester ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/tester

H=/home/tester
install -d -o tester -g tester -m 700 $H/.config $H/.config/fnox
install -o tester -g tester -m 600 /src/age.txt $H/.config/fnox/age.txt
git config --system --add safe.directory '*' 2>/dev/null || printf '[safe]\n\tdirectory = *\n' > /etc/gitconfig

sudo -iu tester env TEST_CLASS="${TEST_CLASS:-}" TEST_REF="${TEST_REF:-mise}" TEST_CONFLICT="${TEST_CONFLICT:-}" bash -s <<'EOS'
set -uo pipefail
M=~/.local/bin/mise
export DOTFILES_REPO=/src/origin.git DOTFILES_REPO_SSH=/src/origin.git DOTFILES_REF=$TEST_REF
flag=""; [ "$TEST_CLASS" = Work ] && flag=--work

if [ -n "$TEST_CONFLICT" ]; then
  # A machine that already has dotfiles (as one coming from yadm does): the
  # first run must stop without touching them, --take-remote must finish.
  echo "== setup run 0 (existing files)"
  echo "# local" > ~/.zshrc; echo "# only here" > ~/.only-here
  sh /src/scripts/setup.sh install $flag > /tmp/run0.log 2>&1; rc0=$?
  if [ $rc0 -ne 0 ] && [ "$(cat ~/.zshrc)" = "# local" ] && grep -q 'restore is paused' /tmp/run0.log; then
    echo "ok    paused, existing file untouched"
  else
    echo "FAIL  expected a paused restore (exit=$rc0)"; tail -20 /tmp/run0.log
  fi
  flag="$flag --take-remote"
fi

echo "== setup run 1"
start=$(date +%s)
sh /src/scripts/setup.sh install $flag > /tmp/run1.log 2>&1; rc1=$?
echo "exit=$rc1 seconds=$(( $(date +%s) - start ))"
[ $rc1 -ne 0 ] && tail -40 /tmp/run1.log
grep -E '^warning:' /tmp/run1.log | cut -c1-160

echo "== setup run 2 (idempotency)"
start=$(date +%s)
sh ~/.config/mise/scripts/setup.sh install $flag > /tmp/run2.log 2>&1; rc2=$?
echo "exit=$rc2 seconds=$(( $(date +%s) - start ))"
[ $rc2 -ne 0 ] && tail -40 /tmp/run2.log
grep -E 'installed [0-9]+ tools|package\(s\)|already installed$' /tmp/run2.log | cut -c1-120

echo "== assertions"
fail=0
check() { if eval "$2" >/dev/null 2>&1; then echo "ok    $1"; else echo "FAIL  $1"; fail=1; fi; }
for b in nvim tmux lazygit yq resvg bat rg fd eza delta zoxide dust tldr csvlens viu cargo \
         fzf jq btop yazi glow uv git git-lfs git-crypt gpg zsh vim wget mosh htop \
         claude codex bazel gcloud clang-20 clangd-20 lldb-20 valgrind protoc \
         node go x11vnc xpra fnox age bw; do
  flag=--version
  case "$b" in tmux) flag=-V ;; go) flag=version ;; esac
  if out=$($M exec -- $b $flag 2>&1 | head -1); then
    printf 'ok    %-9s %s\n' "$b" "$out" | cut -c1-90
  else
    printf 'FAIL  %-9s %s\n' "$b" "$out" | cut -c1-160; fail=1
  fi
done
for f in "Pragmasevka Nerd Font" "JetBrainsMono Nerd Font"; do
  check "font: $f" "fc-list : family | grep -q '^$f'"
done
check "python3 venv"        "python3 -m venv /tmp/venv-check"
check "vim-plug"            "test -f ~/.vim/autoload/plug.vim"
# The work ~/.tmux-local.conf hard-codes the real user's plugin path, which the
# test user does not have, so this is only checked on the default profile.
[ "${TEST_CLASS:-}" = Work ] || check "tmux plugins" "test -d ~/.tmux/plugins/tmux-sensible && test -d ~/.tmux/plugins/tmux-resurrect"
check "login shell is zsh"  "getent passwd tester | grep -q 'zsh$'"
check "git from git-core PPA" "apt-cache policy git | grep -A1 '\*\*\*' | grep -q ppa.launchpadcontent.net"
check "dotfiles: .zshrc restored"     "test -s ~/.zshrc && test ! -L ~/.zshrc"
check "dotfiles: nothing pending"     "$M dot status 2>&1 | grep -q 'entries up to date' && ! $M dot status 2>&1 | grep -q 'unsaved changes'"
check "secrets: .netrc decrypted 600" "test \"\$(stat -c %a ~/.netrc)\" = 600 && grep -q machine ~/.netrc"
check "secrets: SSH key from fnox"    "test \"\$(stat -c %a ~/.ssh/id_ed25519)\" = 600 && ssh-keygen -y -f ~/.ssh/id_ed25519"
check "secrets: SSH key matches .pub" "test \"\$(ssh-keygen -y -f ~/.ssh/id_ed25519 | cut -d' ' -f2)\" = \"\$(cut -d' ' -f2 ~/.ssh/id_ed25519.pub)\""
check "secrets: API keys load"        "test -n \"\$($M exec -- fnox get OPENAI_API_KEY)\""
check "nvim config cloned"            "test -f ~/.config/nvim/init.lua"
if [ "${TEST_CLASS:-}" = Work ]; then
  check "work profile saved"          "grep -rqs work ~/.config/mise/miserc.local.toml"
  check "work variant: work.sh"       "test -s ~/.config/dotfiles/work.sh"
  check "work variant: .zshrc-local"  "test \"\$(wc -l < ~/.zshrc-local)\" -gt 50"
  check "work variant: git email"     "git config --global --includes user.email | grep -qv jiminis"
else
  check "personal variant: no work.sh"       "test ! -e ~/.config/dotfiles/work.sh"
  check "personal variant: no local files"   "test ! -e ~/.zshrc-local && test ! -e ~/.gitconfig-local"
  check "personal variant: git email"        "git config --global --includes user.email | grep -q jiminis"
fi
echo "== missing tools: $($M ls --missing 2>/dev/null | wc -l)"
echo "== result: rc1=$rc1 rc2=$rc2 fail=$fail"
EOS
