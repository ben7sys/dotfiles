#!/bin/bash

# System aktualisieren
sudo dnf -y update

# Podman installieren
sudo dnf -y install podman

# Python3 und pip installieren (falls nicht bereits vorhanden)
sudo dnf -y install python3 python3-pip

# Podman-Compose installieren
sudo pip3 install podman-compose
