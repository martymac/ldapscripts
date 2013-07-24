#  Makefile for the lapscripts

#  Copyright (C) 2007 Ganaël LAPLANCHE
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
#  USA.

# Configuration / variables section
PREFIX = /usr/local

# Where to install scripts
BINDIR = $(PREFIX)/bin
# Where to install man pages
MANDIR = $(PREFIX)/man
# Where to install configuration files
ETCDIR = $(PREFIX)/etc/ldapscripts
# Where to install the runtime file
RUNDIR = $(ETCDIR)

### Do not edit ###
SHELL=/bin/sh
NAME = ldapscripts
#SUFFIX = -devel
VERSION = 1.7.1

RUNFILE = runtime
ETCFILE = ldapscripts.conf
PWDFILE = ldapscripts.passwd
BINFILES =	_ldapdeletemachine _ldapmodifygroup _ldappasswd _lsldap ldapadduser \
			 ldapdeleteuser ldapsetprimarygroup _ldapfinger _ldapmodifymachine \
			_ldaprenamegroup ldapaddgroup ldapaddusertogroup ldapdeleteuserfromgroup \
			_ldapinit _ldapmodifyuser _ldaprenamemachine ldapaddmachine ldapdeletegroup \
			ldaprenameuser
MAN1FILES =	_ldapdeletemachine.1 _ldapmodifymachine.1 _ldaprenamemachine.1 ldapadduser.1 \
			ldapdeleteuserfromgroup.1 _ldapfinger.1 _ldapmodifyuser.1 _lsldap.1 \
			ldapaddusertogroup.1 ldaprenameuser.1 _ldapinit.1 _ldappasswd.1 ldapaddgroup.1 \
			ldapdeletegroup.1 ldapsetprimarygroup.1 _ldapmodifygroup.1 _ldaprenamegroup.1 \
			ldapaddmachine.1 ldapdeleteuser.1
MAN5FILES = ldapscripts.5
TMPLFILES = ldapaddgroup.template.sample ldapaddmachine.template.sample ldapadduser.template.sample

# Default target
all:	help

# Help target
help:
	@echo "Usage: make [VARIABLE=<value>] <target>"
	@echo "Valid variables :"
	@echo "  PREFIX : main target directory for installation (default = /usr/local)"
	@echo "  BINDIR : where to install scripts (default = PREFIX/bin)"
	@echo "  MANDIR : where to install man pages (default = PREFIX/man)"
	@echo "  ETCDIR : where to install the configuration file (default = PREFIX/etc/ldapscripts)"
	@echo "  RUNDIR : where to install the runtime file (default = PREFIX)"
	@echo "Valid targets :"
	@echo "  configure    : prepare sources for installation"
	@echo "  install      : install everything"
	@echo "  uninstall    : uninstall everything (except the main configuration file)"
	@echo "  clean        : clean up sources"
	@echo "  package      : create a package in /tmp"
	@echo "  help         : this help"
	@echo "Additional targets :"
	@echo "  installbin   : install main scripts"
	@echo "  installman   : install man pages"
	@echo "  installetc   : install configuration, runtime and template files"
	@echo "  uninstallbin : uninstall main scripts"
	@echo "  uninstallman : uninstall man pages"
	@echo "  uninstalletc : uninstall configuration, runtime and template files"
	@echo "  deinstall    : synonym for uninstall"
	@echo "  distclean    : synonym for clean"
	@echo "  mrproper     : synonym for clean"

# Configure target
configure:
	@echo -n 'Configuring scripts... '
	@sed 's|^BINDPWDFILE=.*|BINDPWDFILE=\"$(ETCDIR)/$(PWDFILE)\"|g' 'etc/$(ETCFILE)' > 'etc/$(ETCFILE).patched'
	@sed 's|^_CONFIGFILE=.*|_CONFIGFILE=\"$(ETCDIR)/$(ETCFILE)\"|g' 'etc/$(RUNFILE)' > 'etc/$(RUNFILE).patched'
	@for i in $(BINFILES) ; do \
		sed 's|^_RUNTIMEFILE=.*|_RUNTIMEFILE=\"$(RUNDIR)/$(RUNFILE)\"|g' "bin/$$i" > "bin/$$i.patched" ; \
	done
	@echo 'ok. '

# Install targets
install:	installbin installman installetc
installbin:	configure
	@echo -n 'Installing scripts into $(BINDIR)... '
	@mkdir -p '$(BINDIR)' 2>/dev/null
	@for i in $(BINFILES) ; do \
		install -m 750 "bin/$$i.patched" "$(BINDIR)/$$i" ; \
	done
	@echo 'ok. '

installman:
	@echo -n 'Installing man files into $(MANDIR)... '
	@mkdir -p '$(MANDIR)/man1' 2>/dev/null
	@for i in $(MAN1FILES) ; do \
		cat "man/man1/$$i" | gzip - > "$(MANDIR)/man1/`basename $$i`.gz" ; \
	done
	@mkdir -p '$(MANDIR)/man5' 2>/dev/null
	@for i in $(MAN5FILES) ; do \
		cat "man/man5/$$i" | gzip - > "$(MANDIR)/man5/`basename $$i`.gz" ; \
	done
	@echo 'ok. '

installetc:
	@echo -n 'Installing configuration files into $(ETCDIR)... '
	@mkdir -p '$(ETCDIR)' 2>/dev/null
	@install -m 640 -b 'etc/$(ETCFILE).patched' '$(ETCDIR)/$(ETCFILE)'
	@install -m 440 -b 'etc/$(PWDFILE)' '$(ETCDIR)'
	@for i in $(TMPLFILES) ; do \
		install -m 440 "etc/$$i" '$(ETCDIR)' ; \
	done
	@mkdir -p '$(RUNDIR)' 2>/dev/null
	@install -m 440 'etc/$(RUNFILE).patched' '$(RUNDIR)/$(RUNFILE)'
	@echo 'ok. '

# Uninstall targets
deinstall: uninstall
uninstall:	uninstallbin uninstallman uninstalletc
uninstallbin:
	@echo -n 'Uninstalling scripts from $(BINDIR)... '
	@for i in $(BINFILES) ; do \
		rm -f "$(BINDIR)/$$i" ; \
	done
	@rmdir '$(BINDIR)' 2>/dev/null || true
	@echo 'ok. '

uninstallman:
	@echo -n 'Uninstalling man files from $(MANDIR)... '
	@for i in $(MAN1FILES) ; do \
		rm -f "$(MANDIR)/man1/`basename $$i`.gz" ; \
	done
	@rmdir '$(MANDIR)/man1' 2>/dev/null || true
	@for i in $(MAN5FILES) ; do \
		rm -f "$(MANDIR)/man5/`basename $$i`.gz" ; \
	done
	@rmdir '$(MANDIR)/man5' 2>/dev/null || true
	@echo 'ok. '

uninstalletc:
	@echo '(Leaving $(ETCDIR)/$(ETCFILE) as it is the main configuration file)'
	@echo -n 'Uninstalling other configuration files from $(ETCDIR)... '
	@rm -f '$(ETCDIR)/$(PWDFILE)'
	@for i in $(TMPLFILES) ; do \
		rm -f "$(ETCDIR)/$$i" ; \
	done
	@rm -f '$(RUNDIR)/$(RUNFILE)'
	@rmdir '$(RUNDIR)' 2>/dev/null || true
	@echo 'ok. '

# Clean targets
clean:
	@echo -n 'Cleaning sources... '
	@rm -f 'etc/$(ETCFILE).patched'
	@rm -f 'etc/$(RUNFILE).patched'
	@for i in $(BINFILES) ; do \
		rm -f "bin/$$i.patched" ; \
	done
	@echo 'ok. '
distclean:	clean
mrproper:	clean

# Package target
package:	clean
	@echo -n 'Creating package /tmp/$(NAME)-$(VERSION)$(SUFFIX).tgz... '
	@(cd .. && tar czf /tmp/$(NAME)-$(VERSION)$(SUFFIX).tgz $(NAME)-$(VERSION))
	@echo 'ok. '

