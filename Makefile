#  Makefile for the lapscripts

#  Copyright (C) 2007 Gana�l LAPLANCHE
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

# Identity
SHELL=/bin/sh
NAME = ldapscripts
#SUFFIX = -devel
VERSION = 1.8.0rc1

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
			 ldapdeleteuser ldapsetprimarygroup ldapfinger ldapid ldapmodifymachine \
			ldaprenamegroup ldapaddgroup ldapaddusertogroup ldapdeleteuserfromgroup \
			ldapinit ldapmodifyuser ldaprenamemachine ldapaddmachine ldapdeletegroup \
			ldaprenameuser
MAN1FILES =	ldapdeletemachine.1 ldapmodifymachine.1 ldaprenamemachine.1 ldapadduser.1 \
			ldapdeleteuserfromgroup.1 ldapfinger.1 ldapid.1 ldapmodifyuser.1 lsldap.1 \
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
	@echo "  PREFIX  : main target directory for installation (default = /usr/local)"
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
	@echo -n 'Installing scripts into $(SBINDIR)... '
	@install -d -m 755 '$(SBINDIR)' 2>/dev/null
	@for i in $(SBINFILES) ; do \
		install -m 750 "sbin/$$i.patched" "$(SBINDIR)/$$i" ; \
	done
	@echo 'ok.'

installman:
	@echo -n 'Installing man files into $(MANDIR)... '
	@install -d -m 755 '$(MANDIR)/man1' 2>/dev/null
	@for i in $(MAN1FILES) ; do \
		cat "man/man1/$$i" | gzip - > "$(MANDIR)/man1/`basename $$i`.gz" ; \
	done
	@install -d -m 755 '$(MANDIR)/man5' 2>/dev/null
	@for i in $(MAN5FILES) ; do \
		cat "man/man5/$$i" | gzip - > "$(MANDIR)/man5/`basename $$i`.gz" ; \
	done
	@echo 'ok.'

installetc:	configure
	@echo -n 'Installing configuration files into $(ETCDIR)... '
	@install -d -m 755 '$(ETCDIR)' 2>/dev/null
	@install -m 440 'etc/$(ETCFILE).patched' '$(ETCDIR)/$(ETCFILE).sample'
	@if [ ! -f '$(ETCDIR)/$(ETCFILE)' ]; then \
		install -m 640 '$(ETCDIR)/$(ETCFILE).sample' '$(ETCDIR)/$(ETCFILE)'; \
	fi
	@install -m 440 -b 'etc/$(PWDFILE)' '$(ETCDIR)/$(PWDFILE).sample'
	@if [ ! -f '$(ETCDIR)/$(PWDFILE)' ]; then \
		install -m 640 '$(ETCDIR)/$(PWDFILE).sample' '$(ETCDIR)/$(PWDFILE)'; \
	fi
	@for i in $(TMPLFILES) ; do \
		install -m 440 "etc/$$i" '$(ETCDIR)' ; \
	done
	@echo 'ok.'

installlib:	configure
	@echo -n 'Installing library files into $(LIBDIR)... '
	@install -d -m 755 '$(LIBDIR)' 2>/dev/null
	@install -m 440 'lib/$(RUNFILE).patched' '$(LIBDIR)/$(RUNFILE)'
	@echo 'ok.'

# Uninstall targets
deinstall: uninstall
uninstall:	uninstallsbin uninstallman uninstalletc uninstalllib
uninstallsbin:
	@echo -n 'Uninstalling scripts from $(SBINDIR)... '
	@for i in $(SBINFILES) ; do \
		rm -f "$(SBINDIR)/$$i" ; \
	done
	@rmdir '$(SBINDIR)' 2>/dev/null || true
	@echo 'ok.'

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
	@rmdir '$(MANDIR)' 2>/dev/null || true
	@echo 'ok.'

uninstalletc:
	@echo -n 'Uninstalling configuration files from $(ETCDIR)... '
	@if cmp -s '$(ETCDIR)/$(ETCFILE)' '$(ETCDIR)/$(ETCFILE).sample'; then \
		rm -f '$(ETCDIR)/$(ETCFILE)'; \
	fi
	@rm -f '$(ETCDIR)/$(ETCFILE).sample'
	@if cmp -s '$(ETCDIR)/$(PWDFILE)' '$(ETCDIR)/$(PWDFILE).sample'; then \
		rm -f '$(ETCDIR)/$(PWDFILE)'; \
	fi
	@rm -f '$(ETCDIR)/$(PWDFILE).sample'
	@for i in $(TMPLFILES) ; do \
		rm -f "$(ETCDIR)/$$i" ; \
	done
	@rmdir '$(ETCDIR)' 2>/dev/null || true
	@echo 'ok.'

uninstalllib:
	@echo -n 'Uninstalling library files from $(LIBDIR)... '
	@rm -f '$(LIBDIR)/$(RUNFILE)'
	@rmdir '$(LIBDIR)' 2>/dev/null || true
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
	@(cd .. && tar czf /tmp/$(NAME)-$(VERSION)$(SUFFIX).tgz $(NAME)-$(VERSION))
	@echo 'ok.'

