PACKAGE = docdiff
VERSION = 0.3.3
# DATE = `date +%Y%m%d`
DIST = ChangeLog Makefile devutil docdiff docdiff.conf.example docdiff.rb \
       docdiffwebui.html docdiffwebui.cgi \
       index.html img readme.html readme.en.html readme.ja.html sample \
       testcharstring.rb testdiff.rb testdifference.rb testdocdiff.rb testdocument.rb testview.rb
# PWDBASE = `pwd | sed "s|^.*[/\\]||"`

test: testdocdiff testcharstring testdocument testdiff testdifference testview

testdocdiff:
	ruby testdocdiff.rb
testcharstring:
	ruby testcharstring.rb
testdocument:
	ruby testdocument.rb
testdiff:
	ruby testdiff.rb
testdifference:
	ruby testdifference.rb
testview:
	ruby testview.rb

ChangeLog:
	svn log -rHEAD:0 -v > ChangeLog
	# For real ChangeLog style, try svn2cl.xsl at http://tiefighter.et.tudelft.nl/~arthur/svn2cl/

readme.en.html: readme.html
	rm -f readme.en.html
	ruby -e 'print ARGF.read.gsub(/<([a-z]+) +(?:lang="ja"|title="ja").*?>.*?<\/\1>[\r\n]?/m, "")' readme.html > readme.en.html
readme.ja.html: readme.html
	ruby -e 'print ARGF.read.gsub(/<([a-z]+) +(?:lang="en"|title="en").*?>.*?<\/\1>[\r\n]?/m, "")' readme.html > readme.ja.html

document: ChangeLog readme.en.html readme.ja.html

dist: $(DIST)
	rm -fr $(PACKAGE)-$(VERSION)
	mkdir $(PACKAGE)-$(VERSION)
	cp -rp $(DIST) $(PACKAGE)-$(VERSION)
	tar -z -v -c --exclude "*/.svn" -f $(PACKAGE)-$(VERSION).tar.gz $(PACKAGE)-$(VERSION)
	rm -fr $(PACKAGE)-$(VERSION)

clean:
	rm -f ChangeLog
	rm -f readme.en.html
	rm -f readme.ja.html

distclean: clean
	rm -f $(PACKAGE)-$(VERSION).tar.gz
