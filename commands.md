# Häufig genutzte Commands

mount -t nfs STORAGE-IP:/volume1/USERNAME /remotes/nfs/STORAGE/USERNAME

# RCLONE
sudo pacman -S rclone
rclone config
rclone rcd --rc-web-gui

# DUPLICATI
yay -S duplicati
systemctl --user enable duplicati
systemctl --user start duplicati

# SYNCTHING
sudo pacman -S syncthing
systemctl --user enable syncthing.service
systemctl --user start syncthing.service
