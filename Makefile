PACKAGE = docdiff
VERSION = 0.3.2
# DATE = `date +%Y%m%d`
DIST = ChangeLog Makefile devutil docdiff docdiff.conf.example docdiff.rb \
       readme.html sample \
       testcharstring.rb testdiff.rb testdifference.rb testdocdiff.rb testdocument.rb testview.rb
# PWDBASE = `pwd | sed "s|^.*[/\\]||"`

test:
	ruby testcharstring.rb && \
	ruby testdocument.rb && \
	ruby testdiff.rb && \
	ruby testdifference.rb && \
	ruby testview.rb && \
	ruby testdocdiff.rb

ChangeLog:
	rm -f ChangeLog
	svn log -v > ChangeLog
	# For real ChangeLog style, try svn2cl.xsl at http://tiefighter.et.tudelft.nl/~arthur/svn2cl/

dist: $(DIST)
	rm -fr $(PACKAGE)-$(VERSION)
	mkdir $(PACKAGE)-$(VERSION)
	cp -rp $(DIST) $(PACKAGE)-$(VERSION)
	tar -z -v -c --exclude "*/.svn" -f $(PACKAGE)-$(VERSION).tar.gz $(PACKAGE)-$(VERSION)
	rm -fr $(PACKAGE)-$(VERSION)

