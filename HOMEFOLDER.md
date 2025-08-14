# Symlinks anlegen
ln -s /tank/SynologyDrive/homefolder/Desktop    ~/Desktop
ln -s /tank/SynologyDrive/homefolder/Dokumente  ~/Dokumente
ln -s /tank/SynologyDrive/homefolder/Downloads  ~/Downloads
ln -s /tank/SynologyDrive/homefolder/Videos     ~/Videos
ln -s /tank/SynologyDrive/homefolder/Bilder     ~/Bilder
ln -s /tank/SynologyDrive/music                 ~/Musik
ln -s /tank/SynologyDrive/homefolder/Vorlagen   ~/Vorlagen

# FSTAB mount
UUID=a3ed186e-92e8-4abf-85b8-4c2a25c22acd /tank          btrfs   subvol=/@tank,defaults,noatime,ssd,compress=zstd,commit=120 0 0
UUID=a3ed186e-92e8-4abf-85b8-4c2a25c22acd /games         btrfs   subvol=/@games,defaults,noatime,ssd,compress=zstd,commit=120 0 0
UUID=a3ed186e-92e8-4abf-85b8-4c2a25c22acd /rclone        btrfs   subvol=/@games,defaults,noatime,ssd,compress=zstd,commit=120 0 0
UUID=a3ed186e-92e8-4abf-85b8-4c2a25c22acd /archiv        btrfs   subvol=/@games,defaults,noatime,ssd,compress=zstd,commit=120 0 0
