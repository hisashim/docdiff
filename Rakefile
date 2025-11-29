require 'rake/clean'
require 'rake/testtask'
require 'bundler/gem_tasks'

RUBY    = ENV['RUBY'] ||= 'ruby'
MD2HTML = ENV['MD2HTML'] ||= 'md2html --full-html'
DOCS   = FileList['readme.en.html', 'readme.ja.html', 'news.html']
DOCSRC = FileList['readme.md', 'readme_ja.md', 'news.md', 'img', 'sample']
TESTS  = FileList['test/*_test.rb']
TESTLOGS = Dir.glob('test/*_test.rb').map{|f|
  File.basename(f).ext('log')
}

Rake::TestTask.new do |t|
  t.test_files = TESTS
  t.verbose = true
end

task :default => :test

desc "generate documents"
task :docs => DOCS

file 'readme.en.html' => 'readme.md' do |t|
  sh "#{MD2HTML} --html-title='Readme' #{t.source} > #{t.name}"
end

file 'readme.ja.html' => 'readme_ja.md' do |t|
  sh "#{MD2HTML} --html-title='Readme (ja)' #{t.source} > #{t.name}"
end

file 'news.html' => 'news.md' do |t|
  sh "#{MD2HTML} --html-title='News' #{t.source} > #{t.name}"
end

CLEAN.include(DOCS, TESTLOGS)
