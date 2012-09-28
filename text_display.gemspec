# -*- ruby -*-

Gem::Specification.new do |s|
  s.name = "text_display"
  s.version = File.read("VERSION")
  s.authors = ["pasberth"]
  s.description = %{}
  s.summary = %q{}
  s.email = "pasberth@gmail.com"
  s.extensions = ["ext/text_display/ext/extconf.rb"]
  s.extra_rdoc_files = ["README.rst"]
  s.rdoc_options = ["--charset=UTF-8"]
  s.homepage = "http://github.com/pasberth/TextDisplay"
  s.require_paths = ["lib"]
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- spec/*`.split("\n")
  s.add_development_dependency "rspec"
  s.add_dependency "paint"
  s.add_dependency "give4each"
  s.add_dependency "unicode-display_width"
end
