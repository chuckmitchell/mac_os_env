# mac_os_env

Personal macOS terminal stack:

**Ghostty → zsh → Starship → Catppuccin Mocha → fzf + zoxide + eza + bat → mise (Node)**

This repo stores the config files and a Brewfile so you can recreate the same setup on another Mac.

## What's in the stack

| Piece | Role |
| --- | --- |
| [Ghostty](https://ghostty.org) | GPU terminal app (tabs, theme, font) |
| zsh | macOS default shell |
| [Starship](https://starship.rs) | Prompt (git branch, path, exit status) |
| [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) | Shared dark color palette |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy history / file picker (`Ctrl+R`) |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` via `z` |
| [eza](https://eza.rocks) | Modern `ls` with icons / git column |
| [bat](https://github.com/sharkdp/bat) | Syntax-highlighted `cat` |
| [mise](https://mise.jdx.dev) | Runtime version manager (Node LTS globally) |

## Repo layout

```text
Brewfile                 # Homebrew packages + casks
zshrc                    # → ~/.zshrc
zprofile                 # → ~/.zprofile
.gitconfig.example       # copy to ~/.gitconfig (fill in name/email)
config/
  ghostty/config         # → ~/.config/ghostty/config
  starship.toml          # → ~/.config/starship.toml
  bat/config             # → ~/.config/bat/config
  mise/config.toml       # → ~/.config/mise/config.toml
```

The Catppuccin theme file for `bat` is downloaded during setup (not stored here). Ghostty and Starship get Mocha from built-in / config palette.

## Recreate on a new Mac

### 0. Prerequisites

- Apple Silicon or Intel Mac
- [Homebrew](https://brew.sh) installed
- Login shell already zsh (macOS default): `echo $SHELL` → `/bin/zsh`

If Homebrew is missing:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then put Homebrew on your PATH for this session (Apple Silicon):

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 1. Clone this repo

```bash
mkdir -p ~/Projects
git clone https://github.com/chuckmitchell/mac_os_env.git ~/Projects/mac_os_env
cd ~/Projects/mac_os_env
```

### 2. Install packages

```bash
brew bundle --file=./Brewfile
```

That installs Ghostty, JetBrains Mono Nerd Font, Starship, fzf, zoxide, eza, and bat.

### 2b. Install mise (official binary, not Homebrew)

Homebrew’s `mise` formula is slower and larger. Install the optimized binary from [mise.run](https://mise.run). The default CDN (`mise.jdx.dev`) often returns **403** on this network; pull the same release from GitHub:

```bash
curl https://mise.run | MISE_INSTALL_FROM_GITHUB=1 sh
```

That puts the binary at `~/.local/bin/mise` (already on `PATH` via `zshrc`). Activation is already in `zshrc`:

```zsh
eval "$(mise activate zsh)"
```

Open a new tab, then:

```bash
mise --version
```

If GitHub is also blocked, download the macOS ARM tarball from [jdx/mise releases](https://github.com/jdx/mise/releases) and extract `mise` to `~/.local/bin/mise`.

### 3. Link (or copy) config files

**Option A — symlink** (edits in the repo update your live config):

```bash
ln -sf "$PWD/zshrc" ~/.zshrc
ln -sf "$PWD/zprofile" ~/.zprofile

mkdir -p ~/.config/ghostty ~/.config/bat ~/.config/mise
ln -sf "$PWD/config/ghostty/config" ~/.config/ghostty/config
ln -sf "$PWD/config/starship.toml" ~/.config/starship.toml
ln -sf "$PWD/config/bat/config" ~/.config/bat/config
ln -sf "$PWD/config/mise/config.toml" ~/.config/mise/config.toml
```

**Option B — copy** (independent files on the new machine):

```bash
cp zshrc ~/.zshrc
cp zprofile ~/.zprofile

mkdir -p ~/.config/ghostty ~/.config/bat ~/.config/mise
cp config/ghostty/config ~/.config/ghostty/config
cp config/starship.toml ~/.config/starship.toml
cp config/bat/config ~/.config/bat/config
cp config/mise/config.toml ~/.config/mise/config.toml
```

If you already have a `.zshrc` / `.zprofile` / `.gitconfig`, back them up first:

```bash
cp ~/.zshrc ~/.zshrc.bak 2>/dev/null
cp ~/.zprofile ~/.zprofile.bak 2>/dev/null
cp ~/.gitconfig ~/.gitconfig.bak 2>/dev/null
```

Git config is **not** symlinked. Install the example only when `~/.gitconfig` is missing — never overwrite a live file (it holds your name, email, and signing key). Then fill in name and email (GitHub → **Settings → Emails** shows your `noreply` address):

```bash
if [ -e ~/.gitconfig ]; then
  echo "Keeping existing ~/.gitconfig (not overwritten). Merge any new keys from .gitconfig.example by hand."
else
  cp .gitconfig.example ~/.gitconfig
fi
```

Do not commit `~/.gitconfig`. Use a work address only on work machines, and only if that address is verified on the GitHub account that will receive the commits.

### 4. Install Catppuccin for bat

```bash
mkdir -p "$(bat --config-dir)/themes"

curl -fsSL -o "$(bat --config-dir)/themes/Catppuccin Mocha.tmTheme" \
  "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme"

bat cache --build
```

Confirm:

```bash
bat --list-themes | grep -i catppuccin
```

### 5. Install Node with mise

`config/mise/config.toml` requests **Node LTS** globally (`node = "lts"`). After the config is linked:

```bash
mise install
node -v
npm -v
```

`mise` is activated in `zshrc` (`eval "$(mise activate zsh)"`). New shells pick it up automatically. In the current tab, `eval "$(mise activate zsh)"` then `mise install`.

Per-project versions (optional):

```bash
cd ~/path/to/project
mise use node@22
```

That writes a `mise.toml` in the project so that directory uses Node 22.

#### Zscaler: `mise install` 403 on `.tar.gz`

If Node’s `.tar.gz` is blocked, install the same version as `.tar.xz` into mise’s install dir. Check [nodejs.org/dist](https://nodejs.org/dist/) if `24.21.0` is stale.

```bash
VER=24.21.0
FILE="node-v${VER}-darwin-arm64.tar.xz"
TMP=$(mktemp -d) && cd "$TMP"

curl -fLO "https://nodejs.org/dist/v${VER}/${FILE}"
curl -fLO "https://nodejs.org/dist/v${VER}/SHASUMS256.txt"
grep "  ${FILE}\$" SHASUMS256.txt | shasum -a 256 -c -

DEST="$HOME/.local/share/mise/installs/node/${VER}"
mkdir -p "$DEST"
tar -xJf "$FILE" -C "$DEST" --strip-components=1

node -v
npm -v
```

When LTS moves, repeat with the new `VER`.

### 6. Open Ghostty and reload

1. Open **Ghostty** from `/Applications` (or Spotlight).
2. Reload config with **`⌘⇧,`**, or quit and reopen.
3. Open a **new tab** so zsh reads `~/.zshrc`.

You should see:

- Catppuccin Mocha background
- JetBrains Mono Nerd Font
- Starship prompt (`❯`, lavender path, mauve git branch in repos)

### 7. Smoke test

```bash
starship --version
fzf --version
zoxide --version
eza --version
bat --version
mise --version
node -v     # Node LTS via mise

ls          # eza with icons
ll          # long list + git status column in a repo
bat ~/.zshrc
```

| Shortcut / command | Expected |
| --- | --- |
| `Ctrl+R` | fzf history search |
| `cd ~/Desktop` then `z Desk` | zoxide jump |
| `cat ~/.zshrc` | same as `bat` (alias) |
| `node -v` | Node LTS from mise |

## Day-to-day notes

- **Reload Ghostty config:** `⌘⇧,`
- **Reload shell config:** open a new tab, or `source ~/.zshrc`
- **Real `/bin/cat`:** `\cat file` (bypasses the `bat` alias)
- **Theme variants:** change Ghostty `theme = Catppuccin Latte` (etc.) and Starship `palette = "catppuccin_latte"` if you want light mode later

## Updating this repo from a machine

After you change live configs, copy them back in and commit:

```bash
cd ~/Projects/mac_os_env

cp ~/.zshrc zshrc
cp ~/.zprofile zprofile
cp ~/.config/ghostty/config config/ghostty/config
cp ~/.config/starship.toml config/starship.toml
cp ~/.config/bat/config config/bat/config
cp ~/.config/mise/config.toml config/mise/config.toml

git add -A
git status
git commit -m "Update terminal configs"
git push
```

Do **not** copy `~/.gitconfig` or anything under `~/.ssh/` into this repo. Those files hold your email and private key.

## Security and privacy

- **Identity stays local.** `.gitconfig.example` is the template. Copy it to `~/.gitconfig` only if that file is missing; never overwrite a live config, and never commit it.
- **Work email on personal repos.** Commits using an employer domain are public on GitHub and can link this account to work. Prefer GitHub’s noreply address for personal projects; use `[includeIf]` if work and personal checkouts need different emails.
- **SSH keys.** Generate a per-machine Ed25519 key. Never commit `id_ed25519` (private) or reuse one private key across machines. The `.pub` file is not secret, but the comment often contains your email — that is already on GitHub once you upload the key.
- **HTTPS vs SSH.** The shared Git config rewrites `https://github.com/` to SSH so clones use your key instead of a password or token prompt.
- **Shell history.** `HIST_IGNORE_SPACE` is on: prefix a command with a space if it contains a token or password. Assume `~/.zsh_history` is sensitive; do not copy it into the repo.
- **`git add -A`.** Review `git status` before commit so a stray key, `.env`, or live `.gitconfig` does not land in history.

## License

Personal config — use and fork freely.
