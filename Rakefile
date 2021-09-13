require 'rake/clean'
require 'rake/testtask'
require 'bundler/gem_tasks'

RUBY    = ENV['RUBY'] ||= 'ruby'
MD2HTML = ENV['MD2HTML'] ||= 'md2html --full-html'
DOCS   = FileList['ChangeLog', 'readme.en.html', 'readme.ja.html', 'news.html',
                  'index.en.html', 'index.ja.html']
DOCSRC = FileList['readme.html', 'news.md', 'index.html', 'img', 'sample']
TESTS  = FileList['test/*_test.rb']
TESTLOGS = Dir.glob('test/*_test.rb').map{|f|
  File.basename(f).ext('log')
}

WWWUSER     = ENV['WWWUSER']     ||= 'hisashim,docdiff'
WWWSITE     = ENV['WWWSITE']     ||= 'web.sourceforge.net'
WWWSITEPATH = ENV['WWWSITEPATH'] ||= 'htdocs/'
WWWDRYRUN   = ENV['WWWDRYRUN']   ||= '--dry-run'

Rake::TestTask.new do |t|
  t.test_files = TESTS
  t.verbose = true
end

task :default => :test

desc "generate documents"
task :docs => DOCS

file 'ChangeLog' do |t|
  sh "devutil/changelog.sh > #{t.name}"
end

rule(/.*\.(?:en|ja)\.html/ => proc{|tn| tn.gsub(/\.(?:en|ja)/, '')}) do |t|
  sh "#{RUBY} -E UTF-8 langfilter.rb" +
    " --#{t.name.gsub(/.*?\.(en|ja)\.html/){$1}}" +
    " #{t.prerequisites.first} > #{t.name}"
end

file 'news.html' => 'news.md' do |t|
  sh "#{MD2HTML} --html-title='News' #{t.source} > #{t.name}"
end

desc "force to rsync web contents"
task :wwwupload do |t|
  sh "rake www WWWDRYRUN="
end

desc "rsync web contents"
task :www => DOCSRC + DOCS do |t|
  sh "rsync #{WWWDRYRUN} -auv -e ssh --delete" +
    " --exclude='.svn' --exclude='.git'" +
    t.prerequisites.join(' ') +
    " #{WWWUSER}@#{WWWSITE}:#{WWWSITEPATH}"
end

CLEAN.include(DOCS, TESTLOGS)
