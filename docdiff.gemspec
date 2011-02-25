# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "docdiff"
  s.version     = "0.4.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Hisashi Morita"]
  s.email       = ["hisashim at users.sourceforge.net"]
  s.homepage    = "http://docdiff.sourceforge.net"
  s.summary     = %q{Word-by-word diff}
  s.description = %q{DocDiff compares two text files and shows the
                     difference. It can compare files word by word,
                     character by character, or line by line. It has
                     several output formats such as HTML, tty, Manued,
                     or user-defined markup.}
  s.rubyforge_project = "docdiff"
  s.files       = Dir.glob %w{Makefile Rakefile devutil/**/*
                              docdiff.conf.example docdiff.gemspec
                              docdiff.rb docdiff/**/* docdiffwebui.cgi
                              docdiffwebui.html img/**/* index.html
                              langfilter.rb readme.html sample/**/*
                              test*.rb viewdiff.rb}
  s.test_files  = Dir.glob %w{test*.rb}
  s.bindir      = "."
  s.executables = "docdiff.rb"
  s.require_paths = ["."]
end
