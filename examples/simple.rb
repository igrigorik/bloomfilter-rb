#!/usr/bin/env ruby
require 'bloomfilter'

WORDS = %w(duck penguin bear panda)
TEST = %w(penguin moose racooon)

# m = 100, k = 4, seed = 1
bf = BloomFilter.new(100, 4, 1)

WORDS.each { |w| bf.insert(w) }
TEST.each do |w|
  puts "#{w}: #{bf.include?(w)}"
end

bf.stats

#  penguin: true
#  moose: false
#  racooon: false
#
#  Number of filter bits (m): 100
#  Number of filter elements (n): 4
#  Number of filter hashes (k) : 4
#  Predicted false positive rate = 0.05%
