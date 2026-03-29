# HMLANGW

Diese Komponente stellt die Funktionen eines HMLANGateways (HomeMatic RF-LAN Gateway)
auf Basis eines Homematic CoPros bereit.
Der CoPro muss dafür die Firmware 1.4.1 (oder höher) installiert haben.

Dieses Service basiert auf dem HMLANGW von Oliver Kastl und Jens Maus:

- <https://homematic-forum.de/forum/viewtopic.php?t=27705>
- <https://github.com/OpenCCU/OpenCCU/tree/a228d89a4fb2652a606e7b1c86228e982cc88592/buildroot-external/package/hmlangw>

Es wird die Möglichkeit ergänzt, den CoPro per Netzwerk anzusprechen. Damit wird es möglich, einen CoPro in einem CUNX
mit Homematic Pigator oder an einer seriellen Schnittstelle des MappleCUN zu nutzen.

Die Idee ist dabei:
```
CCU (z.B. OpenCCU) -Netzwerk-> HMLANGW -Netzwerk-> CoPro
```

> **Warnung**
> Die Update des CoPro über Netzwerk (oder auch direkt) wurde von mir nicht getestet! Ein Aufruf erfolgt auf eigene
> Gefahr. (Meine CoPro habe ich damals per FHEM geupdatet.)

---

## Inhaltsverzeichnis

- [Erstellen](#erstellen)
- [Parameter](#parameter)
- [Installation als Debian-Paket](#installation-als-debian-paket)
- [Installation als Docker-Container](#installation-als-docker-container)
- [Lizenz](#lizenz)

---

## Erstellen

```bash
# Kompilieren
make all

# Debian-Paket erzeugen
make deb
```

Das Paket wird für die Plattform kompiliert, auf der das Make-Skript ausgeführt wird.
Für Cross-Kompilierung können `CXX`, `VERSION` und `ARCH` überschrieben werden:

```bash
make deb CXX=aarch64-linux-gnu-g++ VERSION=1.2.0 ARCH=arm64
```

---

## Parameter

```
-n n    Specify 10-digit serial number
        Saves it to serialnumber.txt for later use
-n show Show 10-digit serial number of HM-MOD-RPI
-n auto Uses 10-digit serial number of HM-MOD-RPI
        Reads serial number to serialnumber.txt, if possible
        Saves serial number to serialnumber.txt, if possible
-n read Uses 10-digit serial number from serialnumber.txt
-n save Saves 10-digit serial number to serialnumber.txt
-s      name of serial device to use. Default is /dev/ttyAMA0
        If network ist used, syntax ist <servername>:<port>
-r      HM-MOD-RPI reset GPIO pin (default 18, -1 to disable)
-D      debug mode
-x      execute HM-MOD-RPI reset and exit
-b      do not put CoPro in bootloader mode
-h      this help
-l ip   listen on given IP address only (for example 127.0.0.1)
-u      update firmware of HM-MOD-RPI
-f      force update firmware of HM-MOD-RPI
-t      uses network to connect to copro
-V      show version (1.1.0)
```

---

## Installation als Debian-Paket

```bash
dpkg -i hmlangw_1.0.0_amd64.deb
```

Unter `/etc/default/hmlangw` kann die Konfiguration vorgenommen werden:

```bash
# Seriennummer des Gateways
HM_SERIAL=OEQ0610638

# Adresse und Port des Gateways
HM_SERVER=192.168.6.10:2324

# Zusätzliche Parameter
HM_PARAMS=-t
```

Der Parameter `-t` aktiviert den Netzwerkzugriff. Ohne `-t` und mit einem seriellen Pfad als `HM_SERVER`
kann das Modul auch für den Zugriff auf einen lokalen CoPro genutzt werden.

---

## Installation als Docker-Container

Neben der klassischen Debian-Paket-Installation kann `hmlangw` auch als Docker-Container betrieben werden.

### Voraussetzungen

- Docker ≥ 20.10
- Docker Compose ≥ 2.x (optional, empfohlen)

### Schnellstart mit Docker Compose

1. `docker-compose.yml` anpassen:

   ```yaml
   environment:
     HM_SERIAL: "OEQ0610638"        # eigene Seriennummer eintragen
     HM_SERVER: "192.168.6.10:2324"  # IP:Port des CoPro
     HM_PARAMS: "-t"                 # -t = Netzwerkzugriff
   ```

2. Container bauen und starten:

   ```bash
   docker compose up -d --build
   ```

3. Logs verfolgen:

   ```bash
   docker compose logs -f
   ```

### Manuell mit Docker

```bash
# Image bauen
docker build -t hmlangw .

# Container starten (Netzwerk-CoPro)
docker run -d \
  --name hmlangw \
  --restart unless-stopped \
  --network host \
  -e HM_SERIAL="OEQ0610638" \
  -e HM_SERVER="192.168.6.10:2324" \
  -e HM_PARAMS="-t" \
  -v hmlangw_data:/data \
  hmlangw
```

### Lokaler serieller CoPro

Soll ein direkt angeschlossener CoPro (z.B. `/dev/ttyAMA0`) genutzt werden,
`-t` aus `HM_PARAMS` entfernen und das Gerät durchreichen:

```bash
docker run -d \
  --name hmlangw \
  --restart unless-stopped \
  --network host \
  -e HM_SERIAL="OEQ0610638" \
  -e HM_SERVER="/dev/ttyAMA0" \
  -e HM_PARAMS="" \
  -v hmlangw_data:/data \
  --device /dev/ttyAMA0:/dev/ttyAMA0 \
  hmlangw
```

Oder in `docker-compose.yml` die `devices`-Sektion einkommentieren.

### Fertige Images (GitHub Container Registry)

```bash
docker pull ghcr.io/markusfeist/hmlangw:latest
```

### Umgebungsvariablen

| Variable    | Standard | Bedeutung                                  |
|-------------|----------|--------------------------------------------|
| `HM_SERIAL` | _(leer)_ | 10-stellige Seriennummer des Gateways      |
| `HM_SERVER` | _(leer)_ | Adresse:Port des CoPro oder serieller Pfad |
| `HM_PARAMS` | `-t`     | Zusätzliche Parameter (siehe `hmlangw -h`) |

### Hinweise

- Der Container verwendet **kein** systemd. Der Daemon läuft direkt als PID 1 über das Entrypoint-Skript.
- `--restart unless-stopped` sorgt für automatischen Neustart nach einem Absturz oder System-Neuboot.
- Die Datei `serialnumber.txt` wird im Docker-Volume `/data` gespeichert und beim ersten Start automatisch angelegt.
- Für GPIO-Reset-Unterstützung (`-r <pin>`) muss der Container mit `--privileged` oder passendem `--device` gestartet werden.

---

## Lizenz

Ich veröffentliche dieses angepasste HMLANGW-Modul wie das ursprüngliche unter der MIT Lizenz –
siehe auch [LICENSE](LICENSE).
