My dotfiles for my working environment, managed with [mise](https://mise.jdx.dev).

- **mise** tracks the dotfiles where they live in `$HOME`, installs tools and
  packages, and runs the bootstrap.
- **[fnox](https://fnox.jdx.dev)** keeps API keys and the SSH private keys
  age-encrypted.
- The **age key** (`~/.config/fnox/age.txt`, never committed) lives in Bitwarden.

This branch is written by mise (`mise dot sync`); do not commit to it by hand.
`config/` is `~/.config/mise`, `home/` is `$HOME`, and `home@<os>+<profile>/`
holds the per-OS and work-only versions of a file.

## New machine

```sh
url=https://raw.githubusercontent.com/jiminj/dotfiles/mise/config/scripts/setup.sh
curl -fsSL $url | BW_SERVER=https://<my-bitwarden> sh -s -- install          # personal
curl -fsSL $url | BW_SERVER=https://<my-bitwarden> sh -s -- install --work   # work
exec zsh
```

`BW_SERVER` is only needed for a self-hosted Bitwarden.

`setup.sh install` installs mise, fetches the age key from Bitwarden, restores
the dotfiles, then runs `mise bootstrap` (packages, tools, fonts, plugins). It
is safe to re-run.

## Daily use

| Command | What it does |
|---|---|
| `mise dot status` | What is tracked, and what has unsaved changes |
| `mise dot save -d "message"` | Save a checkpoint of the tracked files (local) |
| `mise dot sync` | Push checkpoints to GitHub and fetch other machines' |
| `mise dot pull` | Write fetched changes into the files |
| `mise dot track <path>` | Start tracking a file |
| `mise dot track --encrypt <path>` | Track a file that must be stored encrypted |
| `mise dot track --profile work --os linux <path>` | Track a per-machine-type version |
| `mise dot history` / `mise dot undo` | Browse and roll back |
| `mise bootstrap` | Install anything missing; `--dry-run` previews |
| `mise -E work bootstrap --save-env` | Bootstrap with the work profile and remember it |
| `mise upgrade` | Upgrade installed tools |
| `mise tasks` | List the tasks below |

Nothing leaves the machine until `mise dot sync`: the repository is public, so
sync is manual. Encrypted files are pushed as ciphertext.

## Tasks

| Task | What it does |
|---|---|
| `mise run secrets:status` | State of the chain: age key, fnox, Bitwarden, dotfiles |
| `mise run secrets:backup-key` | Once: store this machine's age key in Bitwarden |
| `mise run secrets:setup` | Fetch the age key from Bitwarden if this machine lost it |
| `mise run font:pragmasevka` / `font:jetbrains-mono` | Terminal fonts |
| `mise run nvim:config` | Clone the Neovim config |
| `mise run tmux:plugins` / `vim:plug` / `shell:login` | Individual bootstrap steps |
| `mise run work:all` | Work-only installs (work profile) |

## Secrets

Chain: Bitwarden login → age key → fnox (API keys, SSH private keys) and
mise-encrypted dotfiles (`.netrc`, GPG export, work configs).

```sh
fnox set NAME --global            # add or change an API key (value on stdin)
fnox set --file ~/.ssh/id_x --global   # store a whole file
fnox list                         # names only
```

API keys load into every zsh session through `fnox activate`.

## Layout

| Path | Purpose |
|---|---|
| `~/.config/mise/config.toml` | Tools, packages, tasks and the `[dotfiles]` list |
| `~/.config/mise/config.work.toml` | Work profile (`-E work`) |
| `~/.config/mise/scripts/` | `setup.sh`, font installer, container test |
| `~/.config/dotfiles/work.sh` | Work-only install steps (encrypted) |
| `~/.config/fnox/config.toml` | Encrypted API keys and SSH keys |

## Testing a restore

```sh
git clone --bare --branch mise https://github.com/jiminj/dotfiles.git /tmp/dotfiles.git
docker run --rm [-e TEST_CLASS=Work] \
  -v /tmp/dotfiles.git:/src/origin.git:ro \
  -v ~/.config/fnox/age.txt:/src/age.txt:ro \
  -v ~/.config/mise/scripts:/src/scripts:ro \
  ubuntu:24.04 bash /src/scripts/container-test.sh
```
