# Security Policy

## Unterstützte Versionen

Sicherheitsupdates werden für folgende Versionen bereitgestellt:

| Version | Unterstützt        |
|---------|--------------------|
| 1.x     | :white_check_mark: |
| < 1.0   | :x:                |

## Sicherheitslücke melden

Bitte melde Sicherheitslücken **nicht** über öffentliche GitHub Issues, da dies
die Lücke vor einem Fix öffentlich bekannt machen würde.

Stattdessen nutze bitte das **GitHub Private Vulnerability Reporting**:

👉 [Sicherheitslücke privat melden](https://github.com/markusfeist/hmlangw/security/advisories/new)

Bitte die folgenden Informationen in der Meldung angeben:

- Beschreibung der Sicherheitslücke
- Betroffene Version(en)
- Schritte zur Reproduktion
- Mögliche Auswirkungen
- Optional: Vorschlag zur Behebung

## Ablauf

1. Die Meldung wird innerhalb von **48 Stunden** bestätigt.
2. Innerhalb von **7 Tagen** erfolgt eine erste Einschätzung der Schwere.
3. Ein Fix wird erarbeitet und ein Release-Datum abgestimmt.
4. Nach Veröffentlichung des Fixes wird die Lücke im Release-Changelog dokumentiert.

## Hinweise zur Sicherheit des Containers

- Das Docker-Image basiert auf `alpine:3.21` und wird bei jedem Release neu gebaut.
- Der Daemon läuft im Container als unprivilegierter Benutzer `hmlangw`.
- Für GPIO-Reset-Zugriff (`-r`) sind erhöhte Container-Rechte nötig (`--privileged`
  oder `--device`). Diese sollten nur aktiviert werden, wenn tatsächlich benötigt.
- Es wird empfohlen, immer die aktuelle Version zu verwenden:
  ```bash
  docker pull ghcr.io/markusfeist/hmlangw:latest
  ```

## Bekannte Einschränkungen

- Das CoPro-Firmware-Update (`-u`, `-f`) wurde vom Autor nicht getestet.
  Eine Nutzung erfolgt auf eigene Gefahr.
- Die Kommunikation zwischen CCU, HMLANGW und CoPro erfolgt unverschlüsselt
  über das lokale Netzwerk. Der Betrieb sollte daher ausschließlich in einem
  vertrauenswürdigen Netzwerksegment erfolgen.
