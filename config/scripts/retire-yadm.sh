#!/bin/sh
# One-time: retire yadm on a machine whose dotfiles are now tracked by mise.
# Nothing is deleted; yadm's repository and its leftover files are moved to
# ~/.local/share/yadm-archive, which can be removed by hand later.
#
#   1. Checkouts that were yadm submodules get their own .git directory.
#   2. Symlinks that yadm pointed at an alternate ("name##os.Darwin") become
#      regular files with the same content.
#   3. yadm-only files in $HOME (alternates, .gitattributes, .gitmodules,
#      .git-crypt, .gitignore, the yadm bootstrap) move to the archive.
#   4. yadm's repository moves to the archive.
#
#   retire-yadm.sh [--dry-run]
set -eu

DATA="$HOME/.local/share/yadm"
REPO="$DATA/repo.git"
ARCHIVE="$HOME/.local/share/yadm-archive"
dry=""
[ "${1:-}" = --dry-run ] && dry=1

say() { printf '== %s\n' "$*"; }
run() { if [ -n "$dry" ]; then printf '   would: %s\n' "$*"; else "$@"; fi; }

[ -d "$REPO" ] || { echo "no yadm repository at $REPO; nothing to do"; exit 0; }
[ -e "$ARCHIVE" ] && { echo "$ARCHIVE already exists; move it away first" >&2; exit 1; }
cd "$HOME"
tracked=$(git --git-dir="$REPO" --work-tree="$HOME" ls-files)

say "Submodule checkouts"
for path in $(git --git-dir="$REPO" --work-tree="$HOME" config -f .gitmodules --get-regexp 'submodule\..*\.path' 2>/dev/null | cut -d' ' -f2); do
  gitfile="$HOME/$path/.git"
  if [ -f "$gitfile" ]; then
    moddir="$REPO/modules/$path"
    [ -d "$moddir" ] || { echo "   $path: no module data at $moddir; skipped" >&2; continue; }
    echo "   $path: give it its own .git directory"
    if [ -z "$dry" ]; then
      rm "$gitfile"
      mv "$moddir" "$gitfile"
      git -C "$HOME/$path" config --unset core.worktree || true
      git -C "$HOME/$path" status -sb >/dev/null
    fi
  else
    echo "   $path: already standalone or absent"
  fi
done

say "Symlinks to yadm alternates"
printf '%s\n' "$tracked" | grep '##' | sed 's/##.*//' | sort -u | while IFS= read -r f; do
  [ -L "$f" ] || continue
  case "$(readlink "$f")" in
    *'##'*)
      if [ -e "$f" ]; then
        echo "   $f: replace the link with a copy of its target"
        if [ -z "$dry" ]; then cp -p "$f" "$f.retire-tmp" && rm "$f" && mv "$f.retire-tmp" "$f"; fi
      else
        echo "   $f: dangling link, removed"
        run rm "$f"
      fi ;;
  esac
done

say "yadm-only files -> $ARCHIVE/home"
printf '%s\n' "$tracked" | grep -E '##|^\.gitattributes$|^\.gitmodules$|^\.gitignore$|^\.git-crypt/|^\.config/yadm/bootstrap$' | while IFS= read -r f; do
  [ -e "$f" ] || [ -L "$f" ] || continue
  echo "   $f"
  if [ -z "$dry" ]; then
    mkdir -p "$ARCHIVE/home/$(dirname "$f")"
    mv "$f" "$ARCHIVE/home/$f"
  fi
done
[ -n "$dry" ] || rmdir "$HOME/.git-crypt/keys/default/0" "$HOME/.git-crypt/keys/default" "$HOME/.git-crypt/keys" "$HOME/.git-crypt" 2>/dev/null || true

say "yadm repository -> $ARCHIVE/yadm"
if [ -z "$dry" ]; then
  mkdir -p "$ARCHIVE"
  mv "$DATA" "$ARCHIVE/yadm"
else
  echo "   would: mv $DATA $ARCHIVE/yadm"
fi

say "Done. mise tracks the dotfiles: mise dot status"
echo "   The archive holds yadm's full history, including commits never pushed."
echo "   Remove it when you no longer need it: rm -rf $ARCHIVE"
