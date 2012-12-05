require 'helper'

include BloomFilter

describe Native do

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
    it "should test set membership" do
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
      bf.set_bits.should == 4
      bf.delete("test")
      bf.set_bits.should == 0

      bf = Native.new(:hashes => 1)
      bf.insert("test")
      bf.set_bits.should == 1
    end

    it "should return intersection with other filter" do
      bf1 = Native.new(:seed => 1)
      bf1.insert("test")
      bf1.insert("test1")

      bf2 = Native.new(:seed => 1)
      bf2.insert("test")
      bf2.insert("test2")

      bf3 = bf1 & bf2
      bf3.include?("test").should be_true
      bf3.include?("test1").should be_false
      bf3.include?("test2").should be_false
    end

    it "should raise an exception when intersection is to be computed for incompatible filters" do
      bf1 = Native.new(:size => 10)
      bf1.insert("test")

      bf2 = Native.new(:size => 20)
      bf2.insert("test")

      proc {bf1 & bf2}.should raise_error(BloomFilter::ConfigurationMismatch)
    end

    it "should return union with other filter" do
      bf1 = Native.new(:seed => 1)
      bf1.insert("test")
      bf1.insert("test1")

      bf2 = Native.new(:seed => 1)
      bf2.insert("test")
      bf2.insert("test2")

      bf3 = bf1 | bf2
      bf3.include?("test").should be_true
      bf3.include?("test1").should be_true
      bf3.include?("test2").should be_true
    end

    it "should raise an exception when union is to be computed for incompatible filters" do
      bf1 = Native.new(:size => 10)
      bf1.insert("test")

      bf2 = Native.new(:size => 20)
      bf2.insert("test")

      proc {bf1 | bf2}.should raise_error(BloomFilter::ConfigurationMismatch)
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

      bf2 = Native.load('bf.out')
      bf2.include?('foo').should be_true
      bf2.include?('bar').should be_true
      bf2.include?('baz').should be_false

      bf.send(:same_parameters?, bf2).should be_true
    end

    it "should serialize to a file size proporational its bucket size" do
      fs_size = 0
      8.times do |i|
        bf = Native.new(size: 10_000, bucket: i+1)
        bf.save('bf.out')
        prev_size, fs_size = fs_size, File.size('bf.out')
        prev_size.should < fs_size
      end
    end

  end
end
