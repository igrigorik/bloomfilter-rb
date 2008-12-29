require 'helper'

class TestBloomFilter < Test::Unit::TestCase
  def test_include?
    bf = BloomFilter.new(10, 2, 1)
    bf.insert("test")
    assert bf.include?("test")
    assert !bf.include?("lkajdsfhlkajsdfhlakjsdfhalsjdkfh")
  end
end
