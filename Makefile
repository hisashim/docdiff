PACKAGE = docdiff
DATE = `date +%Y%m%d`
PWDBASE = `pwd | sed "s|^.*[/\\]||"`
TARFILE := $(PACKAGE)-snapshot$(DATE).tar.gz
TARDIR := $(PWDBASE)

test:
	ruby testcharstring.rb && \
	ruby testdocument.rb && \
	ruby testdiff.rb && \
	ruby testdifference.rb && \
	ruby testview.rb && \
	ruby testdocdiff.rb
tar:
	(cd ..; \
	tar --create --verbose --gzip \
	--exclude CVS --exclude junk --exclude tmp --exclude old --exclude "#*#" --exclude "~*"\
	-f $(TARFILE) $(TARDIR))
pwdbase:
	echo $(PWDBASE)
