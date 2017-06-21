# Warning: this Makefile is obsolete, use Rakefile instead

PRODUCT = docdiff
VERSION = $(shell $(RUBY) -r./lib/docdiff/version.rb -e 'Docdiff::VERSION.display')
RUBY = ruby
TAR_XVCS = tar --exclude=.svn --exclude=.git

DOCS   = ChangeLog readme.en.html readme.ja.html \
         index.en.html index.ja.html
DOCSRC = readme.html index.html img sample
TESTS  = test/*_test.rb
DIST   = Makefile devutil lib docdiff.conf.example bin/docdiff \
         docdiff.gemspec \
         docdiffwebui.html docdiffwebui.cgi \
         $(DOCSRC) $(DOCS) $(TESTS)
TESTLOGS = $(foreach t,\
                     $(wildcard test/*_test.rb),\
                     $(t:test/%_test.rb=%_test.log)) \

WWWUSER = hisashim,docdiff
WWWSITE = web.sourceforge.net
WWWSITEPATH = htdocs/
WWWDRYRUN = --dry-run

DESTDIR =
PREFIX  = /usr/local
datadir = $(DESTDIR)$(PREFIX)/share

all:	$(DOCS)

testall:
	$(MAKE) test RUBY=ruby1.9.1

test: $(TESTLOGS)

%_test.log:
	$(RUBY) -I./lib test/$*_test.rb | tee $@

docs:	$(DOCS)

ChangeLog:
	devutil/changelog.sh > $@

readme.%.html: readme.html
	$(RUBY) -Ku langfilter.rb --$* $< > $@
index.%.html: index.html
	$(RUBY) -Ku langfilter.rb --$* $< > $@

install: $(DIST)
	@if [ ! -d $(DESTDIR)$(PREFIX)/bin ]; then \
	  mkdir -p $(DESTDIR)$(PREFIX)/bin; \
	fi
	cp -Ppv bin/docdiff $(DESTDIR)$(PREFIX)/bin/
	chmod +x $(DESTDIR)$(PREFIX)/bin/docdiff

	@if [ ! -d $(datadir)/$(PRODUCT) ]; then \
	  mkdir -p $(datadir)/$(PRODUCT); \
	fi
	(cd lib && $(TAR_XVCS) -cf - *) | (cd $(datadir)/$(PRODUCT) && tar -xpf -)

	@if [ ! -d $(DESTDIR)/etc/$(PRODUCT) ]; then \
	  mkdir -p $(DESTDIR)/etc/$(PRODUCT); \
	fi
	cp -Pprv docdiff.conf.example $(DESTDIR)/etc/$(PRODUCT)/docdiff.conf

	@if [ ! -d $(datadir)/doc/$(PRODUCT) ]; then \
	  mkdir -p $(datadir)/doc/$(PRODUCT); \
	fi
	cp -Pprv $(DOCSRC) $(DOCS) $(datadir)/doc/$(PRODUCT)

uninstall:
	-rm -fr $(DESTDIR)$(PREFIX)/bin/docdiff
	-rm -fr $(datadir)/$(PRODUCT)
	-rm -fr $(DESTDIR)/etc/$(PRODUCT)
	-rm -fr $(datadir)/doc/$(PRODUCT)

dist: $(DIST)
	mkdir $(PRODUCT)-$(VERSION)
	cp -rp $(DIST) $(PRODUCT)-$(VERSION)
	$(TAR_XVCS) -zvcf $(PRODUCT)-$(VERSION).tar.gz $(PRODUCT)-$(VERSION)
	-rm -fr $(PRODUCT)-$(VERSION)

gem: $(PRODUCT)-$(VERSION).gem
$(PRODUCT)-$(VERSION).gem: $(PRODUCT).gemspec
	gem build $<

wwwupload:
	$(MAKE) www WWWDRYRUN=
www: $(DOCSRC) $(DOCS)
	rsync $(WWWDRYRUN) -auv -e ssh --delete \
	  --exclude='.svn' --exclude='.git' \
	  $(DOCSRC) $(DOCS) \
	  $(WWWUSER)@$(WWWSITE):$(WWWSITEPATH)

clean:
	-rm -fr $(DOCS)
	-rm -fr $(TESTLOGS)

distclean: clean
	-rm -fr $(PRODUCT)-$(VERSION).tar.gz
	-rm -fr $(PRODUCT)-$(VERSION).gem

.PHONY:	all testall test docs install uninstall dist gem \
	wwwupload www clean distclean
