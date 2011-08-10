# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "docdiff/version"

Gem::Specification.new do |s|
  s.name        = "docdiff"
  s.version     = Docdiff::VERSION
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

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
