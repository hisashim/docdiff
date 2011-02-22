PRODUCT = docdiff
VERSION = 0.4.0
RUBY = ruby
# DATE = `date +%Y%m%d`
GENERATEDDOCS = ChangeLog readme.en.html readme.ja.html \
	index.en.html index.ja.html
DOCS = readme.html index.html img sample
TESTS = testcharstring.rb testdiff.rb testdifference.rb \
	testdocdiff.rb testdocument.rb testview.rb
DIST = Makefile devutil docdiff docdiff.conf.example docdiff.rb \
	docdiffwebui.html docdiffwebui.cgi \
	$(DOCS) $(GENERATEDDOCS) $(TESTS)
TESTLOGS = testdocdiff.log testcharstring.log testdocument.log \
	testdiff.log testdifference.log testview.log testviewdiff.log
# PWDBASE = `pwd | sed "s|^.*[/\\]||"`
WWWUSER = hisashim,docdiff
WWWSITE = web.sourceforge.net
WWWSITEPATH = htdocs/
WWWDRYRUN = --dry-run

DESTDIR =
PREFIX  = /usr/local
datadir = $(DESTDIR)$(PREFIX)/share
rubylibdir = $(shell $(RUBY) -rrbconfig -e \
                             "Config::CONFIG['rubylibdir'].display")

testall:
	$(MAKE) test RUBY=ruby1.9.1
	$(MAKE) test RUBY=ruby1.8

test: $(TESTLOGS)

test%.log:
	$(RUBY) -I. test$*.rb | tee $@

docs:	$(GENERATEDDOCS)

ChangeLog:
# For real ChangeLog style, try http://arthurdejong.org/svn2cl/
	if [ -d .svn ] ; then \
	  svn log -rHEAD:0 -v > ChangeLog ; \
	else \
	  git svn log > ChangeLog ; \
	fi

readme.%.html: readme.html
	$(RUBY) langfilter.rb --$* $< > $@
index.%.html: index.html
	$(RUBY) langfilter.rb --$* $< > $@

install: $(DIST)
	@if [ ! -d $(DESTDIR)$(PREFIX)/bin ]; then \
	  mkdir -p $(DESTDIR)$(PREFIX)/bin; \
	fi
	cp -Ppv docdiff.rb $(DESTDIR)$(PREFIX)/bin/docdiff
	chmod +x $(DESTDIR)$(PREFIX)/bin/docdiff

	@if [ ! -d $(DESTDIR)$(rubylibdir) ]; then \
	  mkdir -p $(DESTDIR)$(rubylibdir); \
	fi
	(tar --exclude=.svn --exclude=.git -cf - docdiff) \
	 | (cd $(DESTDIR)$(rubylibdir) && tar -xpf -)

	@if [ ! -d $(DESTDIR)/etc/$(PRODUCT) ]; then \
	  mkdir -p $(DESTDIR)/etc/$(PRODUCT); \
	fi
	cp -Pprv docdiff.conf.example $(DESTDIR)/etc/$(PRODUCT)/docdiff.conf

	@if [ ! -d $(datadir)/doc/$(PRODUCT) ]; then \
	  mkdir -p $(datadir)/doc/$(PRODUCT); \
	fi
	cp -Pprv $(DOCS) $(GENERATEDDOCS) $(datadir)/doc/$(PRODUCT)

uninstall:
	-rm -fr $(DESTDIR)$(PREFIX)/bin/docdiff
	-rm -fr $(DESTDIR)$(rubylibdir)/$(PRODUCT)
	-rm -fr $(DESTDIR)/etc/$(PRODUCT)
	-rm -fr $(datadir)/doc/$(PRODUCT)

dist: $(DIST)
	mkdir $(PRODUCT)-$(VERSION)
	cp -rp $(DIST) $(PRODUCT)-$(VERSION)
	tar -z -v -c --exclude "*/.svn" -f \
	  $(PRODUCT)-$(VERSION).tar.gz $(PRODUCT)-$(VERSION)
	rm -fr $(PRODUCT)-$(VERSION)

wwwupload:
	make www WWWDRYRUN=
www: $(DOCS) $(GENERATEDDOCS)
	rsync $(WWWDRYRUN) -auv -e ssh --delete --exclude='.svn' \
	$(DOCS) $(GENERATEDDOCS) \
	$(WWWUSER)@$(WWWSITE):$(WWWSITEPATH)

clean:
	rm -f $(GENERATEDDOCS)
	rm -f $(TESTLOGS)

distclean: clean
	rm -f $(PRODUCT)-$(VERSION).tar.gz

.PHONY:	testall test docs dist clean distclean
