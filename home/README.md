My dotfiles for my working environment.

- [yadm](https://yadm.io) tracks the files.
- [mise](https://mise.jdx.dev) installs tools and packages and runs the bootstrap.
- [fnox](https://fnox.jdx.dev) keeps API keys age-encrypted; the age key lives in Bitwarden.
- git-crypt encrypts whole files (SSH keys, `.netrc`, work configs).

## New machine

```sh
yadm clone git@github.com:jiminj/dotfiles.git   # offers to run the bootstrap
yadm config local.class Work                    # work machines only, then: yadm bootstrap
bw config server <url>                          # self-hosted Bitwarden only
mise run secrets:setup
exec zsh
```

`yadm bootstrap` installs mise and runs `mise bootstrap`. It is safe to re-run.

## Commands

| Command | What it does |
|---|---|
| `yadm bootstrap` | Install mise, then packages, tools, fonts and plugins |
| `mise bootstrap --dry-run` | Preview what the bootstrap would install |
| `mise -E work bootstrap --save-env` | Bootstrap with the work profile and remember it |
| `mise install` | Install tools added to the config |
| `mise upgrade` | Upgrade installed tools |
| `mise tasks` | List the tasks below |
| `mise run secrets:setup` | New machine: fetch the age key from Bitwarden, unlock the encrypted files |
| `mise run secrets:backup-key` | Once: store this machine's age key in Bitwarden |
| `mise run secrets:status` | Show the state of the secrets chain |
| `mise run font:pragmasevka` / `font:jetbrains-mono` | Install the terminal fonts |
| `mise run tmux:plugins` / `vim:plug` / `shell:login` | Individual bootstrap steps |

## Secrets

Chain: Bitwarden login → age key (`~/.config/fnox/age.txt`, never committed) →
fnox secrets → git-crypt key → encrypted files.

```sh
fnox set NAME --global      # add or change an API key (value on stdin)
fnox list                   # names only
```

Keys load into every zsh session through `fnox activate`.

## Layout

| Path | Purpose |
|---|---|
| `.config/mise/config.toml` | Tools, packages, tasks for every machine |
| `.config/mise/config.work.toml` | Work-only additions (encrypted) |
| `.config/mise/scripts/` | Font installer, secrets script, container test |
| `.config/fnox/config.toml` | Encrypted API keys |
| `.config/yadm/bootstrap` | Thin wrapper around `mise bootstrap` |

## Testing the bootstrap

```sh
docker run --rm [-e TEST_CLASS=Work] \
  -v ~/.config/mise:/src/mise:ro \
  -v ~/.config/yadm/bootstrap:/src/yadm-bootstrap:ro \
  -v ~/.tmux.conf:/src/tmux.conf:ro \
  ubuntu:24.04 bash /src/mise/scripts/container-test.sh
```
