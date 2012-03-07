require 'helper'

describe BloomFilter::Native do
  include BloomFilter

  it "should clear" do
    bf = Native.new(:size => 100, :hashes => 2, :seed => 1, :bucket => 3, :raise => false)
    bf.insert("test")
    bf.include?("test").should be_true
    bf.clear
    bf.include?("test").should be_false
  end

  it "should merge" do
    bf1 = Native.new(:size => 100, :hashes => 2, :seed => 1, :bucket => 3, :raise => false)
    bf2 = Native.new(:size => 100, :hashes => 2, :seed => 1, :bucket => 3, :raise => false)
    bf2.insert("test")
    bf1.include?("test").should be_false
    bf1.merge!(bf2)
    bf1.include?("test").should be_true
    bf2.include?("test").should be_true
  end

  context "behave like a bloomfilter" do
    it "should test set memerbship" do
      bf = Native.new(:size => 100, :hashes => 2, :seed => 1, :bucket => 3, :raise => false)
      bf.insert("test")
      bf.insert("test1")

      bf.include?("test").should be_true
      bf.include?("abcd").should be_false
      bf.include?("test", "test1").should be_true
    end

    it "should work with any object's to_s" do
      bf = Native.new
      bf.insert(:test)
      bf.insert(:test1)
      bf.insert(12345)

      bf.include?("test").should be_true
      bf.include?("abcd").should be_false
      bf.include?("test", "test1", '12345').should be_true
    end

    it "should return the number of bits set to 1" do
      bf = Native.new(:hashes => 4)
      bf.insert("test")
      bf.bits_count.should == 4

      bf = Native.new(:hashes => 1)
      bf.insert("test")
      bf.bits_count.should == 1
    end
  end

  context "behave like counting bloom filter" do
    it "should delete / decrement keys" do
      bf = Native.new

      bf.insert("test")
      bf.include?("test").should be_true

      bf.delete("test")
      bf.include?("test").should be_false
    end
  end

  context "serialize" do
    after(:each) { File.unlink('bf.out') }

    it "should marshall the bloomfilter" do
      bf = Native.new
      lambda { bf.save('bf.out') }.should_not raise_error
    end

    it "should load marshalled bloomfilter" do
      bf = Native.new
      bf.insert('foo')
      bf.insert('bar')
      bf.save('bf.out')

      bf = Native.load('bf.out')
      bf.include?('foo').should be_true
      bf.include?('bar').should be_true
      bf.include?('baz').should be_false
    end
  end
end
