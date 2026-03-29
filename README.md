# HMLANGW

Diese Komponente stellt die Funktioen eines HMLANGateways (HomeMatic RF-LAN Gateway)
auf Basis eines Homematic CoPros bereit.
Der CoPro muss dafür die Firmware 1.4.1 (oder höher) installiert haben.

Dieses Service passiert auf dem HMLANGW von Oliver Kastl und Jens Maus:

- https://homematic-forum.de/forum/viewtopic.php?t=27705
- https://github.com/OpenCCU/OpenCCU/tree/a228d89a4fb2652a606e7b1c86228e982cc88592/buildroot-external/package/hmlangw

Es wird die Möglichkeit ergänzt, den CoPro per Netzwerk anzusprechen. Damit wird es möglich einen CoPro in einem CUNX
mit Homematic Pigator oder an einer seriellen Schnittstelle des MappleCUN zu nutzen.

Die Idee ist dabei:
CCU (z.B. OpenCCU) -Netzwerk-> HMLANGW -Netzwerk-> CoPro

> [!WARNING]
> Die Update des CoPro über Netzwerk (oder auch direkt) wurde von mir nicht getestet! Ein Aufruf erfolgt auf eigene
> Gefahr. (Meine CoPro habe ich damals per FHEM geupdatet.)

# Erstellen

Mit:

```
make all
```

wird das Projekt compiliert.
Mit:

```
make deb
```

wird ein Debian Paket erzeugt. Es wird für die Plattform compiliert, auf der das Make-Skript ausgeführt wird.

# Parameter

Die Parameter sind:

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

# Installation

Mit

```
dpki -i <Paket>
```

z.B.:

```
dpki -i hmlangw_1.0.0_amd64.deb
```

wird das Paket installiert.
Unter `/etc/default/hmlangw` kann die Konfiguration vorgenommen werden.
Es sind dabei folgende Parameter möglich:

```
# Seriennummer des Gateways
HM_SERIAL=OEQ0610638

# Adresse und Port des Gateways
HM_SERVER=192.168.6.10:2324

# Zusätzliche Parameter
HM_PARAMS=-t
```

Der Parameter `-t` aktiviert dabei den Netzwerkzugriff. (Mit Entfernen des Parameter und Anpassung von `HM_SERVER` auf
den seriellen Anschluss kann also das Modul für den Zugriff auf einen lokalen CoPro genutzt werden.)

# Lizenz

Ich veröffentliche dieses angepasste HMLANGW-Modul wie das ursprüngliche unter der MIT Lizenz siehe
auch [LICENSE](LICENSE).