# dotfiles
dotfiles with chezmoi

## Setup

⚠️ **Important**: Before using these dotfiles, please read [SETUP.md](SETUP.md) for configuration instructions. This repository contains sanitized placeholders that need to be replaced with your actual values.

📖 **Deutsch**: Eine deutsche Version dieser README finden Sie in [README_DE.md](README_DE.md).

## Chezmoi GitHub Repo dotfiles

https://github.com/ben7sys/dotfiles.git

**Initialize Git Repo with chezmoi**

```bash
chezmoi init https://github.com/ben7sys/dotfiles.git
chezmoi init --source ~/dotfiles
```

**Push local changes**
    
```bash
chezmoi add
```

**Show source directory**

```bash
chezmoi source-path
# Output: $HOME/.local/share/chezmoi
```

# Chezmoi on EndeavourOS

1. Install chezmoi:

```bash
sudo pacman -S chezmoi
```

2. Initialize chezmoi with GitHub repository:

```bash
chezmoi init https://github.com/ben7sys/dotfiles.git
```

3. Add file or directory:

```bash
# File
chezmoi add ~/.bashrc

# Directory
chezmoi add ~/.scripts
```

4. Check changes:

```bash
chezmoi diff
```

5. Commit and push:

```bash
chezmoi cd
chezmoi git -- add .
chezmoi git -- commit -m "added .bashrc .aliases .env_common .gitconfig"
git push
cd -
```

```bash
git add dot_bashrc
git commit -m "Add .bashrc"
```

## More Information

https://www.chezmoi.io/quick-start/

```bash
chezmoi init
chezmoi add ~/.bashrc
chezmoi edit ~/.bashrc
chezmoi diff
# -v=verbose only
chezmoi -v apply
# -v=verbose & -n=dry-run
chezmoi -vn apply
```
