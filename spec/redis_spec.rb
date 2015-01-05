require 'helper'

describe BloomFilter::Redis do

  context "use Redis bitstring for storage" do
    before do
      # clear all redis databases
      subject.instance_variable_get(:@db).flushall
    end

    it "should store data in Redis" do
      subject.insert(:abcd)
      subject.insert('test')
      expect(subject.include?('test')).to be true
      expect(subject.key?('test')).to be true

      expect(subject.include?('test', 'test2')).to be false
      expect(subject.include?('test', 'abcd')).to be true
    end

    it "should not delete keys from Redis" do
      subject.insert('test')
      expect(subject.include?('test')).to be true

      subject.delete('test')
      expect(subject.include?('test')).to be true
    end

    it "should clear Redis filter" do
      subject.insert('test')
      expect(subject.include?('test')).to be true

      subject.clear
      expect(subject.include?('test')).to be false
    end

    it "should output current stats" do
      subject.clear
      subject.insert('test')
      expect { subject.stats }.not_to raise_error
    end

    it "should connect to remote redis server" do
      expect { BloomFilter::Redis.new }.not_to raise_error
    end

    it "should allow redis client instance to be passed in" do
      redis_client = double("Redis")
      bf = BloomFilter::Redis.new(:db => redis_client)
      expect(bf.instance_variable_get(:@db)).to be redis_client
    end

    it "should allow namespaced BloomFilters" do
      bf1 = BloomFilter::Redis.new(:namespace => :a)
      bf2 = BloomFilter::Redis.new(:namespace => :b)

      bf1.insert('test')
      expect(bf1.include?('test')).to be true
      expect(bf2.include?('test')).to be false
    end
  end
end
