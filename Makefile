PACKAGE = docdiff
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

dist: $(DIST)
	mkdir $(PACKAGE)-$(VERSION)
	cp -rp $(DIST) $(PACKAGE)-$(VERSION)
	tar -z -v -c --exclude "*/.svn" -f \
	  $(PACKAGE)-$(VERSION).tar.gz $(PACKAGE)-$(VERSION)
	rm -fr $(PACKAGE)-$(VERSION)

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
	rm -f $(PACKAGE)-$(VERSION).tar.gz

.PHONY:	testall test docs dist clean distclean
