CXX ?= g++

#CXXFLAGS = -O2 -Wall -Wno-deprecated
#CXXFLAGS = -O2 -pipe -Wall
#CXXFLAGS = -Wall -O2 -pipe -march=armv6j -mtune=arm1176jzf-s -mfpu=vfp -mfloat-abi=hard
CXXFLAGS ?= -Wall -pipe -g

# --- Debian Paket ---
PACKAGE     = hmlangw
VERSION    ?= 1.0.0
ARCH       ?= amd64
MAINTAINER ?= Markus Feist Kontakt https://github.com/markusfeist/hmlangw/issues
DESCRIPTION = HomeMatic LAN Gateway Daemon - Version for Netzwork Proxy
INSTALLDIR  = /opt/hmlangw

PKG_DIR = $(PACKAGE)_$(VERSION)_$(ARCH)

.PHONY: install deb clean clean-deb

all: hmlangw

hmlangw: hmlangw.o hmframe.o
	$(CXX) -o hmlangw hmlangw.o hmframe.o -lpthread

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $<

hmlangw.o: hmlangw.cpp hmframe.h
hmframe.o: hmframe.cpp hmframe.h

install:
	install -d $(DESTDIR)$(INSTALLDIR)
	install -m 755 hmlangw $(DESTDIR)$(INSTALLDIR)/hmlangw
	install -d $(DESTDIR)/etc/systemd/system
	install -m 644 hmlangw.service $(DESTDIR)/etc/systemd/system/hmlangw.service
	install -d $(DESTDIR)/etc/default
	install -m 644 hmlangw.default $(DESTDIR)/etc/default/hmlangw

deb: hmlangw
	# Verzeichnisstruktur anlegen
	mkdir -p $(PKG_DIR)$(INSTALLDIR)
	mkdir -p $(PKG_DIR)/etc/systemd/system
	mkdir -p $(PKG_DIR)/etc/default
	mkdir -p $(PKG_DIR)/DEBIAN

	# control Datei erstellen
	echo "Package: $(PACKAGE)"       > $(PKG_DIR)/DEBIAN/control
	echo "Version: $(VERSION)"      >> $(PKG_DIR)/DEBIAN/control
	echo "Architecture: $(ARCH)"    >> $(PKG_DIR)/DEBIAN/control
	echo "Maintainer: $(MAINTAINER)" >> $(PKG_DIR)/DEBIAN/control
	echo "Description: $(DESCRIPTION)" >> $(PKG_DIR)/DEBIAN/control

	# Dateien installieren
	$(MAKE) install DESTDIR=$(PKG_DIR)

	# postinst: Service aktivieren und starten
	echo '#!/bin/sh'                       > $(PKG_DIR)/DEBIAN/postinst
	echo 'set -e'                         >> $(PKG_DIR)/DEBIAN/postinst
	echo 'systemctl daemon-reload'        >> $(PKG_DIR)/DEBIAN/postinst
	echo 'systemctl enable hmlangw.service' >> $(PKG_DIR)/DEBIAN/postinst
	echo 'systemctl start hmlangw.service'  >> $(PKG_DIR)/DEBIAN/postinst
	chmod 755 $(PKG_DIR)/DEBIAN/postinst

	# prerm: Service stoppen und deaktivieren
	echo '#!/bin/sh'                              > $(PKG_DIR)/DEBIAN/prerm
	echo 'set -e'                                >> $(PKG_DIR)/DEBIAN/prerm
	echo 'systemctl stop hmlangw.service || true'    >> $(PKG_DIR)/DEBIAN/prerm
	echo 'systemctl disable hmlangw.service || true' >> $(PKG_DIR)/DEBIAN/prerm
	chmod 755 $(PKG_DIR)/DEBIAN/prerm

	# Paket bauen
	dpkg-deb --build $(PKG_DIR)
	@echo "Paket erstellt: $(PKG_DIR).deb"

clean:
	rm -f *.o || true
	rm -f hmlangw || true
	rm -rf $(PKG_DIR) $(PKG_DIR).deb
