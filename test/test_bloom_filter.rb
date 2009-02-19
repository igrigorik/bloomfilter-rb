require 'helper'

class TestBloomFilter < Test::Unit::TestCase
  def test_include?
    bf = BloomFilter.new(10, 2, 1, 1, false)
    bf.insert("test")
    bf.insert("test")
    bf.insert("test")
    bf.insert("test")
    bf.insert("test")
    assert bf.include?("test")
    assert !bf.include?("lkajdsfhlkajsdfhlakjsdfhalsjdkfh")
  end

  def test_hash_key_insert
   bf = BloomFilter.new(10, 2, 1)
   bf['foo'] = 'bar'
   assert bf.key?('foo')
   assert_equal 'bar', bf['foo']
  end

  def test_hash_key?
   bf = BloomFilter.new(10, 2, 1)
   assert !bf.key?('foo')
   bf['foo'] = 'bar'
   assert bf.key?('foo')
  end

  def test_keys
   bf = BloomFilter.new(10, 2, 1)
   bf['foo'] = 'bar'
   bf['awesome'] = 'bar'
   assert_equal %w{ awesome foo }.sort, bf.keys.sort
  end

  #TODO: no delete function yet.
  def test_delete
    bf = BloomFilter.new(10, 2, 1, 2, false)
    bf.insert("test")
    assert bf.include?("test")
    bf.delete("test")
    assert !bf.include?("test")
  end
end
