# Symlinks anlegen
ln -s /tank/SynologyDrive/homefolder/Desktop    ~/Desktop
ln -s /tank/SynologyDrive/homefolder/Dokumente  ~/Dokumente
ln -s /tank/SynologyDrive/homefolder/Downloads  ~/Downloads
ln -s /tank/SynologyDrive/homefolder/Videos     ~/Videos
ln -s /tank/SynologyDrive/homefolder/Bilder     ~/Bilder
ln -s /tank/SynologyDrive/music                 ~/Musik
ln -s /tank/SynologyDrive/homefolder/Vorlagen   ~/Vorlagen

# FSTAB mount
UUID=x-x-x-x-x /tank          btrfs   subvol=/@tank,defaults,noatime,ssd,compress=zstd,commit=120 0 0
UUID=x-x-x-x-x /games         btrfs   subvol=/@games,defaults,noatime,ssd,compress=zstd,commit=120 0 0
UUID=x-x-x-x-x /rclone        btrfs   subvol=/@rclone,defaults,noatime,ssd,compress=zstd,commit=120 0 0
UUID=x-x-x-x-x /archiv        btrfs   subvol=/@archiv,defaults,noatime,ssd,compress=zstd,commit=120 0 0
