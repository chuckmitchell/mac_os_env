# mac_os_env

Personal macOS terminal stack:

**Ghostty → zsh → Starship → Catppuccin Mocha → fzf + zoxide + eza + bat**

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

## Repo layout

```text
Brewfile                 # Homebrew packages + casks
zshrc                    # → ~/.zshrc
zprofile                 # → ~/.zprofile
config/
  ghostty/config         # → ~/.config/ghostty/config
  starship.toml          # → ~/.config/starship.toml
  bat/config             # → ~/.config/bat/config
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

### 3. Link (or copy) config files

**Option A — symlink** (edits in the repo update your live config):

```bash
ln -sf "$PWD/zshrc" ~/.zshrc
ln -sf "$PWD/zprofile" ~/.zprofile

mkdir -p ~/.config/ghostty ~/.config/bat
ln -sf "$PWD/config/ghostty/config" ~/.config/ghostty/config
ln -sf "$PWD/config/starship.toml" ~/.config/starship.toml
ln -sf "$PWD/config/bat/config" ~/.config/bat/config
```

**Option B — copy** (independent files on the new machine):

```bash
cp zshrc ~/.zshrc
cp zprofile ~/.zprofile

mkdir -p ~/.config/ghostty ~/.config/bat
cp config/ghostty/config ~/.config/ghostty/config
cp config/starship.toml ~/.config/starship.toml
cp config/bat/config ~/.config/bat/config
```

If you already have a `.zshrc` / `.zprofile`, back them up first:

```bash
cp ~/.zshrc ~/.zshrc.bak 2>/dev/null
cp ~/.zprofile ~/.zprofile.bak 2>/dev/null
```

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

### 5. Open Ghostty and reload

1. Open **Ghostty** from `/Applications` (or Spotlight).
2. Reload config with **`⌘⇧,`**, or quit and reopen.
3. Open a **new tab** so zsh reads `~/.zshrc`.

You should see:

- Catppuccin Mocha background
- JetBrains Mono Nerd Font
- Starship prompt (`❯`, lavender path, mauve git branch in repos)

### 6. Smoke test

```bash
starship --version
fzf --version
zoxide --version
eza --version
bat --version

ls          # eza with icons
ll          # long list + git status column in a repo
bat ~/.zshrc
```

| Shortcut / command | Expected |
| --- | --- |
| `Ctrl+R` | fzf history search |
| `cd ~/Desktop` then `z Desk` | zoxide jump |
| `cat ~/.zshrc` | same as `bat` (alias) |

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

git add -A
git status
git commit -m "Update terminal configs"
git push
```

## License

Personal config — use and fork freely.
