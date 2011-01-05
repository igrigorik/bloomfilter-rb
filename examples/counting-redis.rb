#!/usr/bin/env ruby
require 'bloomfilter'

bf = BloomFilter::CountingRedis.new(:ttl => 2, :server => {:host => 'localhost'})

bf.insert('test')
puts bf.include?('test')

sleep(3)
puts bf.include?('test')

puts bf.stats