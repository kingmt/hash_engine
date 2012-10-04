# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hash_engine"

Gem::Specification.new do |s|
  s.name        = "hash_engine"
  s.version     = HashEngine::VERSION
  s.authors     = ["Michael King"]
  s.email       = ["mking@enova.com"]
  s.homepage    = ""
  s.summary     = %q{HashEngine converts input data and intructions into output data.}
  s.description = %q{HashEngine converts input data, including a hash, csv string, or objects, using provided instructions into an output hash.}

  s.rubyforge_project = "hash_engine"

  s.files         = `git ls-files`.split("\n")
  s.files.reject! { |fn| fn.include? "cnu_code" }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
