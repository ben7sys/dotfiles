# dotfiles
dotfiles mit chezmoi

## Setup

⚠️ **Wichtig**: Bevor Sie diese dotfiles verwenden, lesen Sie bitte [SETUP.md](SETUP.md) für Konfigurationsanweisungen. Dieses Repository enthält bereinigte Platzhalter, die durch Ihre tatsächlichen Werte ersetzt werden müssen.

## Chezmoi GitHub Repo dotfiles

https://github.com/ben7sys/dotfiles.git

**Git Repo mit chezmoi initialisieren**

```bash
chezmoi init https://github.com/ben7sys/dotfiles.git
chezmoi init --source ~/dotfiles
```

**Lokale Änderungen pushen**
    
```bash
chezmoi add
```

**Source Verzeichnis anzeigen**

```bash
chezmoi source-path
# Ausgabe: $HOME/.local/share/chezmoi
```

# Chezmoi auf EndeavourOS

1. Installiere chezmoi:

```bash
sudo pacman -S chezmoi
```

2. Initialisiere chezmoi mit GitHub-Repository:

```bash
chezmoi init https://github.com/ben7sys/dotfiles.git
```

3. Füge Datei oder Ordner hinzu:

```bash
# Datei
chezmoi add ~/.bashrc

# Verzeichnis
chezmoi add ~/.scripts
```

4. Überprüfe die Änderungen:

```bash
chezmoi diff
```

5. Commit und push:

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

## Weitere Informationen

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
