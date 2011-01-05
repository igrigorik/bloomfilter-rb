# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bloomfilter/version"

Gem::Specification.new do |s|
  s.name        = "bloomfilter"
  s.version     = BloomFilter::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ilya Grigorik", "Tatsuya Mori"]
  s.email       = ["ilya@igvita.com"]
  s.homepage    = "http://github.com/igrigorik/bloomfilter"
  s.summary     = "Counting Bloom Filter implemented in Ruby"
  s.description = s.summary
  s.rubyforge_project = "bloomfilter"

  s.add_dependency "redis"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"

  s.extensions = ["ext/cbloomfilter/extconf.rb"]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end