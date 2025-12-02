require 'rake/clean'
require 'rake/testtask'
require 'bundler/gem_tasks'

RUBY    = ENV['RUBY'] ||= 'ruby'
MD2HTML = ENV['MD2HTML'] ||= 'md2html --full-html'
DOCS   = FileList['doc/readme.en.html', 'doc/readme.ja.html', 'doc/news.html']
DOCSRC = FileList['readme.md', 'readme_ja.md', 'doc/news.md', 'doc/img', 'doc/example']
TESTS  = FileList['test/*_test.rb']

Rake::TestTask.new do |t|
  t.test_files = TESTS
  t.verbose = true
end

task :default => :test

desc "generate documents"
task :docs => DOCS

file 'doc/readme.en.html' => 'readme.md' do |t|
  title =  File.read(t.source, encoding: "UTF-8").scan(/^# (.*)$/).first.first
  sh <<~EOS
    #{MD2HTML} --html-title='#{title}' #{t.source} \
    | sed 's/\\(href\\|src\\)="doc\\/\\([^"]*\\)"/\\1="\\2"/g' \
    | sed 's/href="\\([^"]*\\).md"/href="\\1.html"/g' > #{t.name}
  EOS
end

file 'doc/readme.ja.html' => 'readme_ja.md' do |t|
  title =  File.read(t.source, encoding: "UTF-8").scan(/^# (.*)$/).first.first
  sh <<~EOS
    #{MD2HTML} --html-title='#{title}' #{t.source} \
    | sed 's/\\(href\\|src\\)="doc\\/\\([^"]*\\)"/\\1="\\2"/g' \
    | sed 's/href="\\([^"]*\\).md"/href="\\1.html"/g' > #{t.name}
  EOS
end

file 'doc/news.html' => 'doc/news.md' do |t|
  title =  File.read(t.source, encoding: "UTF-8").scan(/^# (.*)$/).first.first
  sh <<~EOS
    #{MD2HTML} --html-title='#{title}' #{t.source} \
    | sed 's/\\(href\\|src\\)="doc\\/\\([^"]*\\)"/\\1="\\2"/g' \
    | sed 's/href="\\([^"]*\\).md"/href="\\1.html"/g' > #{t.name}
  EOS
end

CLEAN.include(DOCS)
