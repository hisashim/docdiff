test:
	ruby -W0 testdocdiff.rb && \
	ruby -W0 testdifference.rb && \
	ruby -W0 testdiff.rb && \
	ruby -W0 testdocument.rb && \
	ruby -W0 testcharstring.rb
