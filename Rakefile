require 'rake/clean'
require 'rake/testtask'
require 'bundler/gem_tasks'

PRODUCT = 'docdiff'
RUBY    = ENV['RUBY'] ||= 'ruby'
VERSION = `#{RUBY} -r./lib/docdiff/version.rb -e 'Docdiff::VERSION.display'`
TAR_XVCS = 'tar --exclude=.svn --exclude=.git'

DOCS   = FileList['ChangeLog', 'readme.en.html', 'readme.ja.html',
                  'index.en.html', 'index.ja.html']
DOCSRC = FileList['readme.html', 'index.html', 'img', 'sample']
TESTS  = FileList['test/*_test.rb']
DIST   = FileList['Makefile', 'devutil', 'lib', 'docdiff.conf.example',
                  'bin/docdiff', 'docdiff.gemspec', 'docdiffwebui.html',
                  'docdiffwebui.cgi', DOCSRC, DOCS, TESTS]
TESTLOGS = Dir.glob('test/*_test.rb').map{|f|
  File.basename(f).ext('log')
}

WWWUSER     = ENV['WWWUSER']     ||= 'hisashim,docdiff'
WWWSITE     = ENV['WWWSITE']     ||= 'web.sourceforge.net'
WWWSITEPATH = ENV['WWWSITEPATH'] ||= 'htdocs/'
WWWDRYRUN   = ENV['WWWDRYRUN']   ||= '--dry-run'

DESTDIR = ENV['DESTDIR'] ||= ''
PREFIX  = ENV['PREFIX']  ||= File.join('/', 'usr', 'local')
bindir  = File.join(DESTDIR, PREFIX, 'bin')
datadir = File.join(DESTDIR, PREFIX, 'share')
datadir_p = File.join(datadir, PRODUCT)
etc_p   = File.join(DESTDIR, 'etc', PRODUCT)
datadir_doc_p = File.join(datadir, 'doc', PRODUCT)
product_version = "#{PRODUCT}-#{VERSION}"

rule '.log' => proc{|tn| File.join('test', tn.ext('rb'))} do |t|
  sh "#{RUBY} -I./lib #{t.prerequisites.first} | tee #{t.name}"
end

Rake::TestTask.new do |t|
  t.test_files = FileList["test/test*.rb"]
  t.verbose = true
end

task :default => DOCS

task :testall do |t|
  sh 'rake test RUBY=ruby1.9.1'
end

task :test => TESTLOGS

task :docs => DOCS

file 'ChangeLog' do |t|
  sh "devutil/changelog.sh > #{t.name}"
end

rule(/.*\.(?:en|ja)\.html/ => proc{|tn| tn.gsub(/\.(?:en|ja)/, '')}) do |t|
  sh "#{RUBY} -E UTF-8 langfilter.rb" +
    " --#{t.name.gsub(/.*?\.(en|ja)\.html/){$1}}" +
    " #{t.prerequisites.first} > #{t.name}"
end

[bindir, datadir_p, etc_p, datadir_doc_p].map{|d|
  directory d
}

task :install => FileList[DIST,
                          bindir, datadir_p, etc_p, datadir_doc_p] do |t|
  sh "cp -Ppv bin/docdiff #{bindir}"
  sh "chmod +x #{File.join(bindir, 'docdiff')}"
  sh "(cd lib && #{TAR_XVCS} -cf - *) | (cd #{datadir_p} && tar -xpf -)"
  sh "cp -Pprv docdiff.conf.example #{File.join(etc_p, 'docdiff.conf')}"
  sh "cp -Pprv #{DOCSRC} #{DOCS} #{datadir_doc_p}"
end

task :uninstall do |t|
  rm_rf File.join(bindir, 'docdiff')
  rm_rf datadir_p
  rm_rf etc_p
  rm_rf datadir_doc_p
end

directory product_version

task :dist => FileList[DIST, product_version] do |t|
  sh "cp -rp #{t.prerequisites[0..-2].join(' ')} #{product_version}"
  sh "#{TAR_XVCS} -zvcf #{product_version}.tar.gz #{product_version}"
  rm_rf product_version
end

file "#{product_version}.gem" => ["#{PRODUCT}.gemspec"] do |t|
  sh "gem build #{t.prerequisites.join(' ')}"
end

task :gem => "#{product_version}.gem"

task :wwwupload do |t|
  sh "rake www WWWDRYRUN="
end

task :www => [DOCSRC, DOCS] do |t|
  sh "rsync #{WWWDRYRUN} -auv -e ssh --delete" +
    " --exclude='.svn' --exclude='.git'" +
    t.prerequisites.join(' ') +
    " #{WWWUSER}@#{WWWSITE}:#{WWWSITEPATH}"
end

CLEAN.include(DOCS, TESTLOGS)
CLOBBER.include("#{product_version}.tar.gz",
                "#{product_version}.gem")
