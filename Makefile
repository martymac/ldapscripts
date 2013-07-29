#  Makefile for the lapscripts

#  Copyright (C) 2007-2011 Ganaël LAPLANCHE
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
DESTDIR = 
PREFIX = /usr/local

# Identity
SHELL= /bin/sh
NAME = ldapscripts
#SUFFIX = -devel
VERSION = 2.0.1

# Default installation paths
SBINDIR = $(PREFIX)/sbin
MANDIR = $(PREFIX)/man
ETCDIR = $(PREFIX)/etc/$(NAME)
LIBDIR = $(PREFIX)/lib/$(NAME)

# Files to install
RUNFILE = runtime
ETCFILE = ldapscripts.conf
PWDFILE = ldapscripts.passwd
SBINFILES =	ldapdeletemachine ldapmodifygroup ldapsetpasswd lsldap ldapadduser \
			ldapdeleteuser ldapsetprimarygroup ldapfinger ldapid ldapgid ldapmodifymachine \
			ldaprenamegroup ldapaddgroup ldapaddusertogroup ldapdeleteuserfromgroup \
			ldapinit ldapmodifyuser ldaprenamemachine ldapaddmachine ldapdeletegroup \
			ldaprenameuser
MAN1FILES =	ldapdeletemachine.1 ldapmodifymachine.1 ldaprenamemachine.1 ldapadduser.1 \
			ldapdeleteuserfromgroup.1 ldapfinger.1 ldapid.1 ldapgid.1 ldapmodifyuser.1 lsldap.1 \
			ldapaddusertogroup.1 ldaprenameuser.1 ldapinit.1 ldapsetpasswd.1 ldapaddgroup.1 \
			ldapdeletegroup.1 ldapsetprimarygroup.1 ldapmodifygroup.1 ldaprenamegroup.1 \
			ldapaddmachine.1 ldapdeleteuser.1
MAN5FILES = ldapscripts.5
TMPLFILES = ldapaddgroup.template.sample ldapaddmachine.template.sample \
			ldapadduser.template.sample

# Default target
all:	help

# Help target
help:
	@echo "Usage: make [VARIABLE=<value>] <target>"
	@echo "Valid variables :"
	@echo "  DESTDIR : root target directory to install to (default = *empty*)"
	@echo "  PREFIX  : main target directory within DESTDIR (default = /usr/local)"
	@echo "  SBINDIR : where to install scripts (default = PREFIX/sbin)"
	@echo "  MANDIR  : where to install man pages (default = PREFIX/man)"
	@echo "  ETCDIR  : where to install the configuration file (default = PREFIX/etc/ldapscripts)"
	@echo "  LIBDIR  : where to install the runtime file (default = PREFIX/lib/ldapscripts)"
	@echo "Valid targets :"
	@echo "  configure       : prepare sources for installation"
	@echo "  install         : install everything"
	@echo "  uninstall       : uninstall everything"
	@echo "  clean           : clean up sources"
	@echo "  package         : create a source tarball in /tmp"
	@echo "  help            : this help"
	@echo "Additional targets :"
	@echo "  [un]installsbin : [un]install main scripts"
	@echo "  [un]installman  : [un]install man pages"
	@echo "  [un]installetc  : [un]install configuration and template files"
	@echo "  [un]installlib  : [un]install libraries [runtime file]"
	@echo "  deinstall       : synonym for uninstall"
	@echo "  distclean       : synonym for clean"
	@echo "  mrproper        : synonym for clean"

# Configure target
configure:
	@echo -n 'Configuring scripts... '
	@sed 's|^BINDPWDFILE=.*|BINDPWDFILE=\"$(ETCDIR)/$(PWDFILE)\"|g' 'etc/$(ETCFILE)' > 'etc/$(ETCFILE).patched'
	@sed 's|^_CONFIGFILE=.*|_CONFIGFILE=\"$(ETCDIR)/$(ETCFILE)\"|g' 'lib/$(RUNFILE)' > 'lib/$(RUNFILE).patched'
	@for i in $(SBINFILES) ; do \
		sed 's|^_RUNTIMEFILE=.*|_RUNTIMEFILE=\"$(LIBDIR)/$(RUNFILE)\"|g' "sbin/$$i" > "sbin/$$i.patched" ; \
	done
	@echo 'ok.'

# Install targets
install:	installsbin installman installetc installlib
installsbin:	configure
	@echo -n 'Installing scripts into $(DESTDIR)$(SBINDIR)... '
	@install -d -m 755 '$(DESTDIR)$(SBINDIR)' 2>/dev/null
	@for i in $(SBINFILES) ; do \
		install -m 750 "sbin/$$i.patched" "$(DESTDIR)$(SBINDIR)/$$i" ; \
	done
	@echo 'ok.'

installman:
	@echo -n 'Installing man files into $(DESTDIR)$(MANDIR)... '
	@install -d -m 755 '$(DESTDIR)$(MANDIR)/man1' 2>/dev/null
	@for i in $(MAN1FILES) ; do \
		cat "man/man1/$$i" | gzip - > "$(DESTDIR)$(MANDIR)/man1/`basename $$i`.gz" ; \
	done
	@install -d -m 755 '$(DESTDIR)$(MANDIR)/man5' 2>/dev/null
	@for i in $(MAN5FILES) ; do \
		cat "man/man5/$$i" | gzip - > "$(DESTDIR)$(MANDIR)/man5/`basename $$i`.gz" ; \
	done
	@echo 'ok.'

installetc:	configure
	@echo -n 'Installing configuration files into $(DESTDIR)$(ETCDIR)... '
	@install -d -m 755 '$(DESTDIR)$(ETCDIR)' 2>/dev/null
	@install -m 440 'etc/$(ETCFILE).patched' '$(DESTDIR)$(ETCDIR)/$(ETCFILE).sample'
	@if [ ! -f '$(DESTDIR)$(ETCDIR)/$(ETCFILE)' ]; then \
		install -m 640 '$(DESTDIR)$(ETCDIR)/$(ETCFILE).sample' '$(DESTDIR)$(ETCDIR)/$(ETCFILE)'; \
	fi
	@install -m 440 -b 'etc/$(PWDFILE)' '$(DESTDIR)$(ETCDIR)/$(PWDFILE).sample'
	@if [ ! -f '$(DESTDIR)$(ETCDIR)/$(PWDFILE)' ]; then \
		install -m 640 '$(DESTDIR)$(ETCDIR)/$(PWDFILE).sample' '$(DESTDIR)$(ETCDIR)/$(PWDFILE)'; \
	fi
	@for i in $(TMPLFILES) ; do \
		install -m 440 "etc/$$i" '$(DESTDIR)$(ETCDIR)' ; \
	done
	@echo 'ok.'

installlib:	configure
	@echo -n 'Installing library files into $(DESTDIR)$(LIBDIR)... '
	@install -d -m 755 '$(DESTDIR)$(LIBDIR)' 2>/dev/null
	@install -m 440 'lib/$(RUNFILE).patched' '$(DESTDIR)$(LIBDIR)/$(RUNFILE)'
	@echo 'ok.'

# Uninstall targets
deinstall: uninstall
uninstall:	uninstallsbin uninstallman uninstalletc uninstalllib
uninstallsbin:
	@echo -n 'Uninstalling scripts from $(DESTDIR)$(SBINDIR)... '
	@for i in $(SBINFILES) ; do \
		rm -f "$(DESTDIR)$(SBINDIR)/$$i" ; \
	done
	@rmdir '$(DESTDIR)$(SBINDIR)' 2>/dev/null || true
	@echo 'ok.'

uninstallman:
	@echo -n 'Uninstalling man files from $(DESTDIR)$(MANDIR)... '
	@for i in $(MAN1FILES) ; do \
		rm -f "$(DESTDIR)$(MANDIR)/man1/`basename $$i`.gz" ; \
	done
	@rmdir '$(DESTDIR)$(MANDIR)/man1' 2>/dev/null || true
	@for i in $(MAN5FILES) ; do \
		rm -f "$(DESTDIR)$(MANDIR)/man5/`basename $$i`.gz" ; \
	done
	@rmdir '$(DESTDIR)$(MANDIR)/man5' 2>/dev/null || true
	@rmdir '$(MANDIR)' 2>/dev/null || true
	@echo 'ok.'

uninstalletc:
	@echo -n 'Uninstalling configuration files from $(DESTDIR)$(ETCDIR)... '
	@if cmp -s '$(DESTDIR)$(ETCDIR)/$(ETCFILE)' '$(DESTDIR)$(ETCDIR)/$(ETCFILE).sample'; then \
		rm -f '$(DESTDIR)$(ETCDIR)/$(ETCFILE)'; \
	fi
	@rm -f '$(DESTDIR)$(ETCDIR)/$(ETCFILE).sample'
	@if cmp -s '$(DESTDIR)$(ETCDIR)/$(PWDFILE)' '$(DESTDIR)$(ETCDIR)/$(PWDFILE).sample'; then \
		rm -f '$(DESTDIR)$(ETCDIR)/$(PWDFILE)'; \
	fi
	@rm -f '$(DESTDIR)$(ETCDIR)/$(PWDFILE).sample'
	@for i in $(TMPLFILES) ; do \
		rm -f "$(DESTDIR)$(ETCDIR)/$$i" ; \
	done
	@rmdir '$(DESTDIR)$(ETCDIR)' 2>/dev/null || true
	@echo 'ok.'

uninstalllib:
	@echo -n 'Uninstalling library files from $(DESTDIR)$(LIBDIR)... '
	@rm -f '$(DESTDIR)$(LIBDIR)/$(RUNFILE)'
	@rmdir '$(DESTDIR)$(LIBDIR)' 2>/dev/null || true
	@echo 'ok.'

# Clean targets
clean:
	@echo -n 'Cleaning sources... '
	@rm -f 'etc/$(ETCFILE).patched'
	@rm -f 'lib/$(RUNFILE).patched'
	@for i in $(SBINFILES) ; do \
		rm -f "sbin/$$i.patched" ; \
	done
	@echo 'ok.'
distclean:	clean
mrproper:	clean

# Source tarball target
package:	clean
	@echo -n 'Creating source tarball /tmp/$(NAME)-$(VERSION)$(SUFFIX).tgz... '
	@echo '$(VERSION)$(SUFFIX)' > VERSION
	@(cd .. && tar czf /tmp/$(NAME)-$(VERSION)$(SUFFIX).tgz $(NAME)-$(VERSION))
	@echo 'ok.'

