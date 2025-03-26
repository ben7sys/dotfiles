# Häufig genutzte Commands

mount -t nfs 192.168.77.77:/volume1/sieben /remotes/nfs/syno/sieben

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
