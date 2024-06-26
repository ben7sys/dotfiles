# NFS JSON MOUNT TOOL

Das "NFS JSON MOUNT TOOL" ist ein Bash-Skript, das es ermöglicht, NFS-Shares basierend auf einer JSON-Konfigurationsdatei zu mounten und zu unmounten. Dieses Tool bietet eine automatisierte Lösung zur Verwaltung von NFS-Mounts und verbessert die Effizienz und Fehlerfreiheit im Umgang mit Netzwerkdateisystemen.

## Merkmale

- **Automatisches Mounten/Unmounten**: Mounten oder Unmounten von NFS-Shares basierend auf dem aktuellen Zustand und Benutzereingaben.
- **JSON-basierte Konfiguration**: Einfaches Ändern und Erweitern der NFS-Shares durch Bearbeiten einer einzigen JSON-Datei.
- **Interaktive Benutzeroberfläche**: Benutzerfreundliche Prompts für das Mounten und Unmounten mit klarer, farbiger Konsolenausgabe.

## Voraussetzungen

Das "NFS JSON MOUNT TOOL" wird `jq` versuchen mithilfe von `sudo apt-get install jq` auf Ihrem System zu installieren um die JSON-Konfigurationsdatei zu parsen.

## Installation

Klonen Sie das Repository oder laden Sie den Unterordner dotfiles/nfsjsonmounts herunter:

```bash
git clone https://github.com/ben7sys/dotfiles.git
cd dotfiles/nfsjsonmounts
```

Stellen Sie sicher, dass das Skript ausführbar ist:

```bash
chmod +x setup.sh
```


# Detaillierte Beschreibung

Dieses Skript ist ein Bash-Skript, 
das zum Einbinden von NFS-Shares (Network File System) aus einer JSON-Datei verwendet wird. 

Es wird zuerst die Existenz einer JSON-Datei überprüft 
und dann die darin enthaltenen Informationen verwendet, um die NFS-Shares einzubinden.

Zu Beginn des Skripts wird eine Variable JSON_FILE definiert, 
die den Namen der JSON-Datei enthält, die die Informationen über die NFS-Shares enthält.

Das Skript überprüft dann, ob die JSON-Datei existiert. 
Wenn die Datei nicht existiert, gibt das Skript eine Fehlermeldung aus 
und beendet sich mit einem Exit-Status von 1, was auf einen Fehler hinweist.

Wenn die JSON-Datei existiert, liest das Skript die Datei 
und verwendet das jq-Tool, um jedes Element in der JSON-Datei zu verarbeiten. 

jq ist ein Befehlslinien-JSON-Prozessor.
Es nimmt JSON-Daten als Eingabe und kann sie in verschiedene Formate umwandeln.

Für jedes Element in der JSON-Datei extrahiert das Skript die Werte der 
NFS_SERVER, NFS_EXPORT, NFS_OPTIONS und LOCAL_NFS_MOUNT Felder und speichert sie in entsprechenden Variablen.

Das Skript erstellt dann das lokale Mount-Verzeichnis, 
falls es noch nicht existiert, mit dem mkdir -p Befehl. 
Der -p Schalter sorgt dafür, dass das Verzeichnis erstellt wird, wenn es noch nicht existiert.

Schließlich verwendet das Skript den mount-Befehl, um das NFS-Share einzubinden. 
Es verwendet die zuvor extrahierten Werte für den NFS-Server, 
den NFS-Export, die NFS-Optionen und das lokale NFS-Mount-Verzeichnis, 
um den mount-Befehl zu konstruieren und auszuführen.


# Projektentwurf

Script mit anpassbaren Variablen, um ein NFS share zu mounten:

    Variablen:
        NFS_SERVER:IP/hostname
        NFS_EXPORT:/export/path
        NFS_OPTIONS:hard,nolock,anonuid=1000,anongid=1000,vers=4
        LOCAL_NFS_MOUNT:/mnt/nfs/path

Die Variablen sollen in einer json gespeichert werden damit mehrere Ziele hinzugefügt werden können.
Später soll es zusätzlich die Option geben SMB mit in json aufzunehmen.


**Kurzbeschreibung bestimmter NFS Optionen**

hard: Diese Option gibt an, dass das System mehrere Versuche unternehmen soll, um eine Verbindung zu einem NFS-Server herzustellen, bevor es aufgibt. 
Wenn die Verbindung unterbrochen wird, wartet das System auf die Wiederherstellung der Verbindung, anstatt den Vorgang sofort abzubrechen.

nolock: Diese Option deaktiviert die Verwendung von NFS-Locks. 
NFS-Locks werden normalerweise verwendet, um sicherzustellen, dass Dateien nicht gleichzeitig von mehreren Clients geändert werden können. 
Durch das Deaktivieren dieser Option können mehrere Clients gleichzeitig auf dieselbe Datei zugreifen, was jedoch zu Inkonsistenzen führen kann, 
wenn mehrere Clients gleichzeitig Änderungen vornehmen.

anonuid=1000: Diese Option legt die Benutzer-ID (UID) fest, die für anonyme (nicht authentifizierte) Zugriffe auf den NFS-Server verwendet wird. 
In diesem Fall wird die UID 1000 verwendet.

anongid=1000: Diese Option legt die Gruppen-ID (GID) fest, die für anonyme Zugriffe auf den NFS-Server verwendet wird. 
In diesem Fall wird die GID 1000 verwendet.

vers=4: Diese Option gibt die Version des NFS-Protokolls an, 
das verwendet werden soll. In diesem Fall wird die Version 4 verwendet.