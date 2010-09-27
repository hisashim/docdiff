PACKAGE = docdiff
VERSION = 0.4.0
RUBY = ruby
# DATE = `date +%Y%m%d`
DOCS = ChangeLog readme.en.html readme.ja.html index.en.html index.ja.html
DOCSRC = readme.html index.html
DIST = $(DOCS) $(DOCSRC) Makefile devutil docdiff docdiff.conf.example docdiff.rb \
       docdiffwebui.html docdiffwebui.cgi \
       index.html img sample \
       testcharstring.rb testdiff.rb testdifference.rb testdocdiff.rb testdocument.rb testview.rb
TESTLOG = testdocdiff.log testcharstring.log testdocument.log \
	testdiff.log testdifference.log testview.log testviewdiff.log
# PWDBASE = `pwd | sed "s|^.*[/\\]||"`

testall:
	$(MAKE) test RUBY=ruby1.9.1
	$(MAKE) test RUBY=ruby1.8

test: $(TESTLOGS)

test%.log:
	$(RUBY) -I. test$*.rb | tee $@

ChangeLog:
	svn log -rHEAD:0 -v > ChangeLog
	# For real ChangeLog style, try svn2cl.xsl at http://tiefighter.et.tudelft.nl/~arthur/svn2cl/

readme.%.html: readme.html
	$(RUBY) langfilter.rb --$* $< > $@
index.%.html: index.html
	$(RUBY) langfilter.rb --$* $< > $@

dist: $(DIST)
	mkdir $(PACKAGE)-$(VERSION)
	cp -rp $(DIST) $(PACKAGE)-$(VERSION)
	tar -z -v -c --exclude "*/.svn" -f $(PACKAGE)-$(VERSION).tar.gz $(PACKAGE)-$(VERSION)
	rm -fr $(PACKAGE)-$(VERSION)

clean:
	rm -f $(DOCS)
	rm -f $(TESTLOGS)

distclean: clean
	rm -f $(PACKAGE)-$(VERSION).tar.gz
