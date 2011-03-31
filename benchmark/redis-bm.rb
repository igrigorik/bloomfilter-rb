$:<< 'lib'

require 'benchmark'
require 'bloomfilter-rb'

n = 10000

Benchmark.bm do |x|
  r = BloomFilter::Redis.new

  x.report("insert") do
    n.times do
      r.insert("a")
    end
  end

  x.report("lookup present") do
    n.times do
      r.include?("a")
    end
  end

  x.report("lookup missing") do
    n.times do
      r.include?("b")
    end
  end

end

#       user     system      total        real
# insert  1.000000   0.380000   1.380000 (  1.942181)
# lookup present  1.030000   0.470000   1.500000 (  2.577577)
# lookup missing  0.370000   0.160000   0.530000 (  1.060429)