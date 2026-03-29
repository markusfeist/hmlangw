# Container-Nutzung

Neben der klassischen Debian-Paket-Installation kann `hmlangw` auch als
Docker-Container betrieben werden.

## Voraussetzungen

- Docker ≥ 20.10
- Docker Compose ≥ 2.x (optional, empfohlen)

## Schnellstart mit Docker Compose

1. Die Dateien `Dockerfile`, `docker-compose.yml`, `docker-entrypoint.sh`
   und `.dockerignore` in das Repository-Verzeichnis legen.

2. `docker-compose.yml` anpassen:

   ```yaml
   environment:
     HM_SERIAL: "OEQ0610638"       # eigene Seriennummer eintragen
     HM_SERVER: "192.168.6.10:2324" # IP:Port des CoPro
     HM_PARAMS: "-t"                # -t = Netzwerkzugriff
   ```

3. Container bauen und starten:

   ```bash
   docker compose up -d --build
   ```

4. Logs verfolgen:

   ```bash
   docker compose logs -f
   ```

## Manuell mit Docker

```bash
# Image bauen
docker build -t hmlangw .

# Container starten (Netzwerk-CoPro)
docker run -d \
  --name hmlangw \
  --restart unless-stopped \
  -e HM_SERIAL="OEQ0610638" \
  -e HM_SERVER="192.168.6.10:2324" \
  -e HM_PARAMS="-t" \
  -p 2000:2000 \
  -v hmlangw_data:/data \
  hmlangw
```

## Lokaler serieller CoPro

Soll ein direkt angeschlossener CoPro (z.B. `/dev/ttyAMA0`) genutzt werden,
`-t` aus `HM_PARAMS` entfernen und das Gerät durchreichen:

```bash
docker run -d \
  --name hmlangw \
  --restart unless-stopped \
  -e HM_SERIAL="OEQ0610638" \
  -e HM_SERVER="/dev/ttyAMA0" \
  -e HM_PARAMS="" \
  -p 2000:2000 \
  -v hmlangw_data:/data \
  --device /dev/ttyAMA0:/dev/ttyAMA0 \
  hmlangw
```

Oder in `docker-compose.yml` die `devices`-Sektion einkommentieren.

## Umgebungsvariablen

| Variable     | Standard    | Bedeutung                                      |
|--------------|-------------|------------------------------------------------|
| `HM_SERIAL`  | _(leer)_    | 10-stellige Seriennummer des Gateways          |
| `HM_SERVER`  | _(leer)_    | Adresse:Port des CoPro oder serieller Pfad     |
| `HM_PARAMS`  | `-t`        | Zusätzliche Parameter (siehe `hmlangw -h`)     |

## Persistenz der Seriennummer

Die Datei `serialnumber.txt` wird im Docker-Volume `/data` gespeichert.
Beim ersten Start mit gesetzter `HM_SERIAL` wird sie automatisch angelegt.
Bei späteren Starts ohne `HM_SERIAL` wird sie aus dem Volume gelesen.

## Hinweise

- Der Container verwendet **kein** systemd. Der Daemon läuft direkt als
  PID 1 über das Entrypoint-Skript.
- `--restart unless-stopped` sorgt für automatischen Neustart nach
  einem Absturz oder System-Neuboot.
- Für GPIO-Reset-Unterstützung (`-r <pin>`) muss der Container mit
  `--privileged` oder passendem `--device` gestartet werden.
