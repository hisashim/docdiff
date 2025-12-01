# Warning: this Makefile is obsolete, use Rakefile instead

PRODUCT = docdiff
VERSION = $(shell $(RUBY) -r./lib/docdiff/version.rb -e 'Docdiff::VERSION.display')
RUBY = ruby
TAR_XVCS = tar --exclude=.svn --exclude=.git
MD2HTML = md2html --full-html

DOCS   = doc/readme.en.html doc/readme.ja.html doc/news.html
DOCSRC = readme.md readme_ja.md news.md doc/img sample
TESTS  = test/*_test.rb
DIST   = Makefile devutil lib docdiff.conf.example bin/docdiff \
         docdiff.gemspec \
         docdiffwebui.html docdiffwebui.cgi \
         $(DOCSRC) $(DOCS) $(TESTS)
TESTLOGS = $(foreach t,\
                     $(wildcard test/*_test.rb),\
                     $(t:test/%_test.rb=%_test.log)) \

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

doc/readme.en.html: readme.md
	$(MD2HTML) --html-title="$(shell grep '^# .*' $< | head -n 1 | sed 's/^# //')" $< \
	| sed 's/\(href\|src\)="doc\/\([^"]*\)"/\1="\2"/g' \
	| sed 's/href="\([^"]*\).md"/href="\1.html"/g' > $@

doc/readme.ja.html: readme_ja.md
	$(MD2HTML) --html-title="$(shell grep '^# .*' $< | head -n 1 | sed 's/^# //')" $< \
	| sed 's/\(href\|src\)="doc\/\([^"]*\)"/\1="\2"/g' \
	| sed 's/href="\([^"]*\).md"/href="\1.html"/g' > $@

doc/news.html: news.md
	$(MD2HTML) --html-title="$(shell grep '^# .*' $< | head -n 1 | sed 's/^# //')" $< \
	| sed 's/\(href\|src\)="doc\/\([^"]*\)"/\1="\2"/g' \
	| sed 's/href="\([^"]*\).md"/href="\1.html"/g' > $@

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

clean:
	-rm -fr $(DOCS)
	-rm -fr $(TESTLOGS)

distclean: clean
	-rm -fr $(PRODUCT)-$(VERSION).tar.gz
	-rm -fr $(PRODUCT)-$(VERSION).gem

.PHONY:	all testall test docs install uninstall dist gem clean distclean
