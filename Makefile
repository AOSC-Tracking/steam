#! /bin/make -f

all:
	@echo 'Run steam with "./steam" or install it with "sudo make install"'

install: install-bin install-docs install-icons install-bootstrap install-desktop install-appdata install-apt-source

install-bin:
	install -d -m 755 $(DESTDIR)$(PREFIX)/bin/
	install -d -m 755 $(DESTDIR)$(pkglibdir)/steam_launcher/
	install -p -m 755 bin_steam.sh $(DESTDIR)$(pkglibdir)/
	install -p -m 755 bin_steamdeps.py $(DESTDIR)$(pkglibdir)/
	install -p -m 644 steam_launcher/__init__.py $(DESTDIR)$(pkglibdir)/steam_launcher/
	install -p -m 644 steam_launcher/launcherutils.py $(DESTDIR)$(pkglibdir)/steam_launcher/
	ln -fns $(pkglibdir)/bin_steam.sh $(DESTDIR)$(bindir)/$(PACKAGE)
	ln -fns $(pkglibdir)/bin_steamdeps.py $(DESTDIR)$(bindir)/$(PACKAGE)deps

install-docs:
	install -d -m 755 $(DESTDIR)$(PREFIX)/share/doc/$(PACKAGE)/
	install -p -m 644 README steam_subscriber_agreement.txt $(DESTDIR)$(PREFIX)/share/doc/$(PACKAGE)/
	install -d -m 755 $(DESTDIR)$(PREFIX)/share/man/man6/
	install -m 644 $(PACKAGE).6 $(DESTDIR)$(PREFIX)/share/man/man6/

install-icons:
	install -d -m 755 $(DESTDIR)$(PREFIX)/share/icons/hicolor/16x16/apps/
	install -p -m 644 icons/16/$(PACKAGE).png $(DESTDIR)$(PREFIX)/share/icons/hicolor/16x16/apps/
	install -d -m 755 $(DESTDIR)$(PREFIX)/share/icons/hicolor/24x24/apps/
	install -p -m 644 icons/24/$(PACKAGE).png $(DESTDIR)$(PREFIX)/share/icons/hicolor/24x24/apps/
	install -d -m 755 $(DESTDIR)$(PREFIX)/share/icons/hicolor/256x256/apps/
	install -p -m 644 icons/256/$(PACKAGE).png $(DESTDIR)$(PREFIX)/share/icons/hicolor/256x256/apps/
	install -d -m 755 $(DESTDIR)$(PREFIX)/share/icons/hicolor/32x32/apps/
	install -p -m 644 icons/32/$(PACKAGE).png $(DESTDIR)$(PREFIX)/share/icons/hicolor/32x32/apps/
	install -d -m 755 $(DESTDIR)$(PREFIX)/share/icons/hicolor/48x48/apps/
	install -p -m 644 icons/48/$(PACKAGE).png $(DESTDIR)$(PREFIX)/share/icons/hicolor/48x48/apps/
	install -d -m 755 $(DESTDIR)$(PREFIX)/share/pixmaps/
	install -p -m 644 icons/48/$(PACKAGE).png $(DESTDIR)$(PREFIX)/share/pixmaps/
	install -p -m 644 icons/48/steam_tray_mono.png $(DESTDIR)$(PREFIX)/share/pixmaps/$(PACKAGE)_tray_mono.png

install-bootstrap:
	install -d -m 755 $(DESTDIR)$(PREFIX)/lib/$(PACKAGE)/
	install -p -m 644 bootstraplinux_ubuntu12_32.tar.xz $(DESTDIR)$(PREFIX)/lib/$(PACKAGE)/

install-desktop:
	install -d -m 755 $(DESTDIR)$(PREFIX)/share/applications/
	install -d -m 755 $(DESTDIR)$(pkglibdir)/
	# If we create a desktop symlink in $(datadir)/applications/, the md5sum deb file
	# will not contain an entry for it and appstream-generator will complain that
	# the package is missing the desktop file. Instead we place the real file in
	# $(datadir)/applications/ and create a symlink in $(pkglibdir)
	install -p -m 644 $(PACKAGE).desktop $(DESTDIR)$(datadir)/applications/
	ln -fns $(datadir)/applications/$(PACKAGE).desktop $(DESTDIR)$(pkglibdir)/

install-appdata:
	install -d -m 755 $(DESTDIR)$(PREFIX)/share/metainfo/
	install -p -m 644 $(PACKAGE_ID).metainfo.xml $(DESTDIR)$(PREFIX)/share/metainfo/

install-apt-source:
	if [ -d /etc/apt ]; then \
		install -d -m 755 $(DESTDIR)/etc/apt/sources.list.d/; \
		install -p -m 644 steam-stable.list $(DESTDIR)/etc/apt/sources.list.d/; \
		install -p -m 644 steam-beta.list $(DESTDIR)/etc/apt/sources.list.d/; \
		install -d -m 755 $(DESTDIR)/usr/share/keyrings/; \
		install -p -m 644 steam.gpg $(DESTDIR)/usr/share/keyrings/; \
	fi

#########################

PACKAGE=steam
PACKAGE_ID=com.valvesoftware.Steam
PREFIX?=/usr
bindir = $(PREFIX)/bin
datadir = $(PREFIX)/share
pkglibdir = $(PREFIX)/lib/$(PACKAGE)
PYTHON ?= python3

.PHONY: all install install-bin install-docs install-icons install-bootstrap install-desktop install-appdata install-apt-source

check:
	prove -v tests/*.sh
.PHONY: check

clean:
	rm -fr .mypy_cache
	rm -fr buildutils/__pycache__
	rm -fr steam-launcher/__pycache__
.PHONY: clean
