require 'set'
require 'lib/bloomfilter-rb'

items = 1_000_00
bits = 1

# p BloomFilter::Redis.new(:size => items*bits, :hashes => 7) # 2.5 mb
# p BloomFilter::Redis.new(:size => items*bits*5, :hashes => 7) # 13 mb
# p BloomFilter::Redis.new(:size => items*bits*30, :hashes => 7) # 73 mb

# 1%   error rate for 5M items/day, 10 bits per item, for 30 days of data: 358.52 mb
# 0.1% error rate for 5M items/day, 15 bits per item, for 30 days of data: 537.33 mb

bf = BloomFilter::Redis.new(:size => items*bits, :hashes => 7) # 2.5 mb

seen = Set.new
err = 0
num = 100000

num.times do
  item = rand(items)

  if bf.include?(item) != seen.include?(item)
    err += 1
  end

  seen << item
  bf.insert(item)
end

p [:error_rate, (err.to_f / num) * 100]