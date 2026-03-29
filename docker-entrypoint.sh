#!/bin/sh
set -e

BINARY="/opt/hmlangw/hmlangw"
SERIAL_FILE="/data/serialnumber.txt"
SERIAL_LINK="/opt/hmlangw/serialnumber.txt"

# -------------------------------------------------------
# Symlink: /opt/hmlangw/serialnumber.txt -> /data/serialnumber.txt
# Der Daemon sucht die Datei im eigenen Arbeitsverzeichnis.
# Das Volume liegt unter /data, daher wird ein Symlink gesetzt.
# -------------------------------------------------------
mkdir -p /data
if [ ! -L "$SERIAL_LINK" ]; then
    ln -sf "$SERIAL_FILE" "$SERIAL_LINK"
    echo "[hmlangw] Symlink gesetzt: ${SERIAL_LINK} -> ${SERIAL_FILE}"
fi

# -------------------------------------------------------
# Seriennummer bestimmen
# -------------------------------------------------------
if [ -n "$HM_SERIAL" ]; then
    SERIAL_ARG="-n ${HM_SERIAL}"
elif [ -f "$SERIAL_FILE" ]; then
    echo "[hmlangw] Lese Seriennummer aus ${SERIAL_FILE}"
    SERIAL_ARG="-n read"
else
    echo "[hmlangw] WARNUNG: Keine Seriennummer gesetzt (HM_SERIAL) und keine ${SERIAL_FILE} gefunden."
    echo "[hmlangw]          Starte ohne explizite Seriennummer."
    SERIAL_ARG=""
fi

# -------------------------------------------------------
# Server-Adresse bestimmen
# -------------------------------------------------------
if [ -n "$HM_SERVER" ]; then
    SERVER_ARG="-s ${HM_SERVER}"
else
    echo "[hmlangw] WARNUNG: HM_SERVER nicht gesetzt – nutze Standard (/dev/ttyAMA0)."
    SERVER_ARG=""
fi

# -------------------------------------------------------
# Seriennummer-Datei ins Volume schreiben (wenn gesetzt)
# -------------------------------------------------------
if [ -n "$HM_SERIAL" ] && [ ! -f "$SERIAL_FILE" ]; then
    echo "$HM_SERIAL" > "$SERIAL_FILE"
    echo "[hmlangw] Seriennummer in ${SERIAL_FILE} gespeichert."
fi

# -------------------------------------------------------
# Starten
# -------------------------------------------------------
echo "[hmlangw] Starte: ${BINARY} ${SERIAL_ARG} ${SERVER_ARG} ${HM_PARAMS}"
exec ${BINARY} ${SERIAL_ARG} ${SERVER_ARG} ${HM_PARAMS}
