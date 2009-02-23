spec = Gem::Specification.new do |s|
  s.name = 'bloomfilter'
  s.version = '0.1'
  s.date = '2009-02-21'
  s.summary = 'Counting Bloom Filter in Ruby'
  s.description = s.summary
  s.email = 'ilya@igvita.com'
  s.homepage = "http://github.com/igrigorik/bloomfilter"
  s.has_rdoc = true
  s.authors = ["Ilya Grigorik", "Tatsuya Mori"]
  s.extensions = ["ext/extconf.rb"]
 
  # ruby -rpp -e' pp `git ls-files`.split("\n") '
  s.files = [
    "README.rdoc",
    "Rakefile",
    "ext/crc32.c",
		"ext/crc32.h",
    "ext/extconf.rb",
    "ext/sbloomfilter.c",
    "lib/bloomfilter.rb",
    "examples/bf.rb",
    "examples/simple.rb",
    "test/helper.rb",
    "test/test_bloom_filter.rb",
  ]
end
