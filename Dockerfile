# ============================================================
# Stage 1: Build (statisch gelinkt mit musl)
# ============================================================
FROM alpine:3.21 AS builder

RUN apk add --no-cache g++ make musl-dev linux-headers

WORKDIR /build

COPY hmframe.h hmframe.cpp hmlangw.cpp Makefile ./

# Statisch linken: keine shared libraries im Runtime-Image nötig
# strip reduziert die Binary-Größe nochmal deutlich
RUN make all CXXFLAGS="-Wall -pipe -O2" \
 && strip hmlangw

# ============================================================
# Stage 2: Runtime – Alpine minimal (~8 MB)
# ============================================================
FROM alpine:3.21

LABEL maintainer="markusfeist" \
      description="HomeMatic LAN Gateway Daemon" \
      org.opencontainers.image.source="https://github.com/markusfeist/hmlangw"

# Dedicated user für den Daemon
# dialout-Gruppe: Zugriff auf seriellen Port und GPIO-Reset-Pin (-r)
RUN addgroup -S hmlangw \
 && adduser -S -G hmlangw hmlangw \
 && addgroup hmlangw dialout \
 && mkdir -p /data /opt/hmlangw \
 && chown hmlangw:hmlangw /data /opt/hmlangw

WORKDIR /opt/hmlangw

COPY --from=builder /build/hmlangw ./hmlangw

# Seriennummer-Datei wird in ein beschreibbares Volume gemountet
VOLUME ["/data"]

# Port, auf dem der HMLANGW lauscht (Standard: 2000)
EXPOSE 2000

# Konfiguration über Umgebungsvariablen
# HM_SERIAL  – 10-stellige Seriennummer des Gateways
# HM_SERVER  – Adresse:Port des CoPro (z.B. 192.168.6.10:2324)
# HM_PARAMS  – Zusätzliche Parameter (z.B. -t für Netzwerkzugriff)
ENV HM_SERIAL="" \
    HM_SERVER="" \
    HM_PARAMS="-t"

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER hmlangw

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
