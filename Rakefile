require 'rake/clean'
require 'rake/testtask'
require 'bundler/gem_tasks'

RUBY    = ENV['RUBY'] ||= 'ruby'
MD2HTML = ENV['MD2HTML'] ||= 'md2html --full-html'
DOCS   = FileList['doc/README.md', 'doc/README_ja.md', 'doc/README.html', 'doc/README_ja.html', 'doc/news.html']
DOCSRC = FileList['README.md', 'README_ja.md', 'doc/news.md', 'doc/img', 'doc/example']
TESTS  = FileList['test/*_test.rb']
ENV['SOURCE_DATE_EPOCH'] ||= `git show --quiet --format=%ct HEAD`

Rake::TestTask.new do |t|
  t.test_files = TESTS
  t.verbose = true
end

task :default => :test

desc "generate documents"
task :docs => DOCS

rule '.html' => '.md' do |t|
  title =  File.read(t.source, encoding: "UTF-8").scan(/^# (.*)$/).first.first
  sh <<~EOS
    #{MD2HTML} --html-title='#{title}' #{t.source} \
    | sed 's/\\(href\\|src\\)="doc\\/\\([^"]*\\)"/\\1="\\2"/g' \
    | sed 's/href="\\([^"]*\\).md"/href="\\1.html"/g' > #{t.name}
  EOS
end

file 'doc/README.md' => 'README.md' do |t|
  cp t.source, t.name
end

file 'doc/README_ja.md' => 'README_ja.md' do |t|
  cp t.source, t.name
end

CLEAN.include(DOCS)
