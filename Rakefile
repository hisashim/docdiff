require 'bundler/gem_tasks'

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.test_files = FileList["test/test*.rb"]
  t.verbose = true
end

if RUBY_VERSION < '1.9'
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.test_files = FileList['test/test*.rb']
    t.output_dir = 'coverage'
    t.rcov_opts = ["--exclude /gems/*"]
    t.verbose = true
  end
end
