#!/usr/bin/env ruby
require 'bloomfilter'

WORDS = %w(duck penguin bear panda)
TEST = %w(penguin moose racooon)

bf = BloomFilter.new(:size => 100, :hashes => 2, :seed => 1, :bucket => 3, :raise => false)

WORDS.each { |w| bf.insert(w) }
TEST.each do |w|
  puts "#{w}: #{bf.include?(w)}"
end

bf.stats

#  penguin: true
#  moose: false
#  racooon: false
#
#  Number of filter buckets (m): 100
#  Number of bits per buckets (b): 1
#  Number of filter elements (n): 4
#  Number of filter hashes (k) : 4
#  Raise on overflow? (r) : false
#  Predicted false positive rate = 0.05%
