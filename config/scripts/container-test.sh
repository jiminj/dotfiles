#!/bin/bash
# End-to-end bootstrap test in a clean ubuntu:24.04 container, run as root.
# It creates a sudo-capable user, copies the config in, runs the yadm bootstrap
# script twice (a stub stands in for yadm itself), then asserts the result.
#
#   docker run --rm \
#     -v ~/.config/mise:/src/mise:ro \
#     -v ~/.config/yadm/bootstrap:/src/yadm-bootstrap:ro \
#     -v ~/.tmux.conf:/src/tmux.conf:ro \
#     ubuntu:24.04 bash /src/mise/scripts/container-test.sh
#
# Optional env: APT_MIRROR=kr.archive.ubuntu.com  (when the default mirror is slow)
#               TEST_CLASS=Work                   (exercise the work profile)
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
if [ -n "${APT_MIRROR:-}" ]; then
  sed -i "s#archive.ubuntu.com#$APT_MIRROR#" /etc/apt/sources.list.d/ubuntu.sources
fi
apt-get update -qq >/dev/null
# git because yadm needs it on a real machine; curl is left out on purpose.
apt-get install -y -qq sudo git ca-certificates >/dev/null 2>&1
useradd -m -s /bin/bash tester
echo 'tester ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/tester

H=/home/tester
mkdir -p $H/.config/yadm $H/.tmux/plugins
cp -r /src/mise $H/.config/mise
rm -f $H/.config/mise/*.local.toml   # per-machine state, not part of the repo
cp /src/yadm-bootstrap $H/.config/yadm/bootstrap
cp /src/tmux.conf $H/.tmux.conf
chown -R tester:tester $H

# Stand-in for yadm: `submodule` clones tpm (the public submodule), and the
# class comes from TEST_CLASS.
cat > /usr/local/bin/yadm <<EOF
#!/bin/sh
case "\$1" in
  config) [ -n "${TEST_CLASS:-}" ] && echo "${TEST_CLASS:-}"; exit 0 ;;
  submodule)
    [ -d "\$HOME/.tmux/plugins/tpm/.git" ] || \
      git clone -q https://github.com/tmux-plugins/tpm "\$HOME/.tmux/plugins/tpm" ;;
  *) exit 0 ;;
esac
EOF
chmod +x /usr/local/bin/yadm

sudo -iu tester env TEST_CLASS="${TEST_CLASS:-}" bash -s <<'EOS'
set -uo pipefail
M=~/.local/bin/mise

echo "== bootstrap run 1"
start=$(date +%s)
bash ~/.config/yadm/bootstrap > /tmp/run1.log 2>&1; rc1=$?
echo "exit=$rc1 seconds=$(( $(date +%s) - start ))"
[ $rc1 -ne 0 ] && tail -40 /tmp/run1.log
grep -E '^warning:' /tmp/run1.log | cut -c1-160

echo "== bootstrap run 2 (idempotency)"
start=$(date +%s)
bash ~/.config/yadm/bootstrap > /tmp/run2.log 2>&1; rc2=$?
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
check "tmux plugins"        "test -d ~/.tmux/plugins/tmux-sensible && test -d ~/.tmux/plugins/tmux-resurrect"
check "login shell is zsh"  "getent passwd tester | grep -q 'zsh$'"
check "git from git-core PPA" "apt-cache policy git | grep -A1 '\*\*\*' | grep -q ppa.launchpadcontent.net"
if [ "${TEST_CLASS:-}" = Work ]; then
  check "work profile saved" "grep -rqs work ~/.config/mise/miserc.local.toml"
fi
echo "== missing tools: $($M ls --missing 2>/dev/null | wc -l)"
echo "== result: rc1=$rc1 rc2=$rc2 fail=$fail"
EOS
