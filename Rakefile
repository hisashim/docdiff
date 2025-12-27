require "rake/clean"
require "rake/testtask"
require "bundler/gem_tasks"

ENV["SOURCE_DATE_EPOCH"] ||= `git show --quiet --format=%ct HEAD`

Rake::TestTask.new do |t|
  t.test_files = FileList["test/*_test.rb"]
  t.verbose = true
end

task :default => :test
