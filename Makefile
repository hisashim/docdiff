PACKAGE = docdiff
VERSION = 0.3.0
# DATE = `date +%Y%m%d`
DIST = Makefile devutil docdiff docdiff.conf.example docdiff.rb \
       encoding readme.html sample \
       testcharstring.rb testdiff.rb testdifference.rb testdocdiff.rb testdocument.rb testview.rb
# PWDBASE = `pwd | sed "s|^.*[/\\]||"`

test:
	ruby testcharstring.rb && \
	ruby testdocument.rb && \
	ruby testdiff.rb && \
	ruby testdifference.rb && \
	ruby testview.rb && \
	ruby testdocdiff.rb

dist: $(DIST)
	rm -ir $(PACKAGE)-$(VERSION)
	mkdir $(PACKAGE)-$(VERSION)
	cp -rp $(DIST) $(PACKAGE)-$(VERSION)
	tar zvcf $(PACKAGE)-$(VERSION).tar.gz $(PACKAGE)-$(VERSION)
	rm -ir $(PACKAGE)-$(VERSION)

# tar:
# 	(cd ..; \
# 	tar --create --verbose --gzip \
# 	--exclude CVS --exclude junk --exclude tmp --exclude old --exclude "#*#" --exclude "~*"\
# 	-f $(PACKAGE)-snapshot$(DATE).tar.gz $(PWDBASE))
# pwdbase:
# 	echo $(PWDBASE)
