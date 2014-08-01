require 'helper'

describe BloomFilter::Native do

  it "should clear" do
    bf = BloomFilter::Native.new(:size => 100, :hashes => 2, :seed => 1, :bucket => 3, :raise => false)
    bf.insert("test")
    expect(bf.include?("test")).to be true
    bf.clear
    expect(bf.include?("test")).to be false
  end

  it "should merge" do
    bf1 = BloomFilter::Native.new(:size => 100, :hashes => 2, :seed => 1, :bucket => 3, :raise => false)
    bf2 = BloomFilter::Native.new(:size => 100, :hashes => 2, :seed => 1, :bucket => 3, :raise => false)
    bf2.insert("test")
    expect(bf1.include?("test")).to be false
    bf1.merge!(bf2)
    expect(bf1.include?("test")).to be true
    expect(bf2.include?("test")).to be true
  end

  context "behave like a bloomfilter" do
    it "should test set membership" do
      bf = BloomFilter::Native.new(:size => 100, :hashes => 2, :seed => 1, :bucket => 3, :raise => false)
      bf.insert("test")
      bf.insert("test1")

      expect(bf.include?("test")).to be true
      expect(bf.include?("abcd")).to be false
      expect(bf.include?("test", "test1")).to be true
    end

    it "should work with any object's to_s" do
      subject.insert(:test)
      subject.insert(:test1)
      subject.insert(12345)

      expect(subject.include?("test")).to be true
      expect(subject.include?("abcd")).to be false
      expect(subject.include?("test", "test1", '12345')).to be true
    end

    it "should return the number of bits set to 1" do
      bf = BloomFilter::Native.new(:hashes => 4)
      bf.insert("test")
      expect(bf.set_bits).to be == 4
      bf.delete("test")
      expect(bf.set_bits).to be == 0

      bf = BloomFilter::Native.new(:hashes => 1)
      bf.insert("test")
      expect(bf.set_bits).to be == 1
    end

    it "should return intersection with other filter" do
      bf1 = BloomFilter::Native.new(:seed => 1)
      bf1.insert("test")
      bf1.insert("test1")

      bf2 = BloomFilter::Native.new(:seed => 1)
      bf2.insert("test")
      bf2.insert("test2")

      bf3 = bf1 & bf2
      expect(bf3.include?("test")).to be true
      expect(bf3.include?("test1")).to be false
      expect(bf3.include?("test2")).to be false
    end

    it "should raise an exception when intersection is to be computed for incompatible filters" do
      bf1 = BloomFilter::Native.new(:size => 10)
      bf1.insert("test")

      bf2 = BloomFilter::Native.new(:size => 20)
      bf2.insert("test")

      expect { bf1 & bf2 }.to raise_error(BloomFilter::ConfigurationMismatch)
    end

    it "should return union with other filter" do
      bf1 = BloomFilter::Native.new(:seed => 1)
      bf1.insert("test")
      bf1.insert("test1")

      bf2 = BloomFilter::Native.new(:seed => 1)
      bf2.insert("test")
      bf2.insert("test2")

      bf3 = bf1 | bf2
      expect(bf3.include?("test")).to be true
      expect(bf3.include?("test1")).to be true
      expect(bf3.include?("test2")).to be true
    end

    it "should raise an exception when union is to be computed for incompatible filters" do
      bf1 = BloomFilter::Native.new(:size => 10)
      bf1.insert("test")

      bf2 = BloomFilter::Native.new(:size => 20)
      bf2.insert("test")

      expect {bf1 | bf2}.to raise_error(BloomFilter::ConfigurationMismatch)
    end
  end

  context "behave like counting bloom filter" do
    it "should delete / decrement keys" do
      subject.insert("test")
      expect(subject.include?("test")).to be true

      subject.delete("test")
      expect(subject.include?("test")).to be false
    end
  end

  context "serialize" do
    after(:each) { File.unlink('bf.out') }

    it "should marshall the bloomfilter" do
      bf = BloomFilter::Native.new
      expect { bf.save('bf.out') }.not_to raise_error
    end

    it "should load marshalled bloomfilter" do
      subject.insert('foo')
      subject.insert('bar')
      subject.save('bf.out')

      bf2 = BloomFilter::Native.load('bf.out')
      expect(bf2.include?('foo')).to be true
      expect(bf2.include?('bar')).to be true
      expect(bf2.include?('baz')).to be false

      expect(subject.send(:same_parameters?, bf2)).to be true
    end

    it "should serialize to a file size proporational its bucket size" do
      fs_size = 0
      8.times do |i|
        bf = BloomFilter::Native.new(size: 10_000, bucket: i+1)
        bf.save('bf.out')
        prev_size, fs_size = fs_size, File.size('bf.out')
        expect(prev_size).to be < fs_size
      end
    end

  end
end
