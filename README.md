# dotfiles
dotfiles with chezmoi

## Chezmoi mit GitHub Repo dotfiles


https://github.com/ben7sys/dotfiles.git

**Git Repo mit chezmoi initialisieren**
`chezmoi init https://github.com/ben7sys/dotfiles.git`
`chezmoi init --source ~/dotfiles`

**Lokale Änderungen pushen**
`chezmoi add` 

**Source Verzeichnis anzeigen**
`chezmoi source-path`  
`/home/sieben/.local/share/chezmoi`


# Chezmoi auf EndeavourOS.

1. Falls noch nicht installiert, installiere chezmoi:

```bash
sudo pacman -S chezmoi
```

2. Initialisiere chezmoi mit GitHub-Repository:

```bash

chezmoi init https://github.com/ben7sys/dotfiles.git
```

3. Füge eine hinzu:

```bash
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

```
git add dot_bashrc
git commit -m "Add .bashrc"
```



https://www.chezmoi.io/quick-start/

```
chezmoi init
chezmoi add ~/.bashrc
chezmoi edit ~/.bashrc
chezmoi diff
# -v=verbose only
chezmoi -v apply
# -v=verbose & -n=dry-run
chezmoi -vn apply
```


