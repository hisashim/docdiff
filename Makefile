PRODUCT = docdiff
VERSION = $(shell $(RUBY) -r./lib/docdiff/version.rb -e 'Docdiff::VERSION.display')
RUBY = ruby
TAR_XVCS = tar --exclude=.svn --exclude=.git
MD2HTML = md2html --full-html

DOCS   = doc/README.md doc/README_ja.md doc/README.html doc/README_ja.html doc/news.html doc/man/$(PRODUCT).1
DOCSRC = README.md README_ja.md doc/news.md doc/img doc/example doc/man/$(PRODUCT).adoc
TESTS  = test/*_test.rb
DIST   = $(shell git ls-files)
SOURCE_DATE_EPOCH = $(shell git show --quiet --format=%ct HEAD)

DESTDIR =
PREFIX  = /usr/local
datadir = $(DESTDIR)$(PREFIX)/share

all:	$(DOCS)

test: $(TESTS)
	$(RUBY) -I./lib -e 'ARGV.map{|a| require_relative "#{a}"}' $^

docs:	$(DOCS)

%.html: %.md
	$(MD2HTML) --html-title="$(shell grep '^# .*' $< | head -n 1 | sed 's/^# //')" $< \
	| sed 's/\(href\|src\)="doc\/\([^"]*\)"/\1="\2"/g' \
	| sed 's/href="\([^"]*\).md"/href="\1.html"/g' > $@

doc/%.md: %.md
	cp $^ $@

%.1: %.adoc
	SOURCE_DATE_EPOCH=$(SOURCE_DATE_EPOCH) asciidoctor --backend=manpage --out-file=$@ $<

doc/man/$(PRODUCT).1: doc/man/$(PRODUCT).adoc
	sed 's|/path/to/README.html|$(PREFIX)/share/doc/$(PRODUCT)/README.html|g' $< \
	| SOURCE_DATE_EPOCH=$(SOURCE_DATE_EPOCH) asciidoctor --backend=manpage --out-file=$@ -

install: $(DIST) $(DOCS)
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
	cp -Pprv doc/example/docdiff.conf.example $(DESTDIR)/etc/$(PRODUCT)/docdiff.conf

	@if [ ! -d $(datadir)/doc/$(PRODUCT) ]; then \
	  mkdir -p $(datadir)/doc/$(PRODUCT); \
	fi
	cp -Pprv $(DOCSRC) $(datadir)/doc/$(PRODUCT)
	cp -Pprv $(DOCS) $(datadir)/doc/$(PRODUCT)

uninstall:
	-rm -fr $(DESTDIR)$(PREFIX)/bin/docdiff
	-rm -fr $(datadir)/$(PRODUCT)
	-rm -fr $(DESTDIR)/etc/$(PRODUCT)
	-rm -fr $(datadir)/doc/$(PRODUCT)

dist:
	git archive --prefix="$(PRODUCT)-$(VERSION)/" --format=tar HEAD --output="$(PRODUCT)-$(VERSION).tar.gz"

gem: $(PRODUCT)-$(VERSION).gem
$(PRODUCT)-$(VERSION).gem: $(PRODUCT).gemspec
	SOURCE_DATE_EPOCH=$(SOURCE_DATE_EPOCH) gem build $<

clean:
	-rm -fr $(DOCS)

distclean: clean
	-rm -fr $(PRODUCT)-$(VERSION).tar.gz
	-rm -fr $(PRODUCT)-$(VERSION).gem

.PHONY:	all test docs install uninstall dist gem clean distclean
