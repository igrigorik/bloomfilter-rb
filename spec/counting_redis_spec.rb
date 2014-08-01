require 'helper'

describe BloomFilter::CountingRedis do

  it "should connect to remote redis server" do
    expect { BloomFilter::CountingRedis.new }.not_to raise_error
  end

  it "should allow redis client instance to be passed in" do
    redis_client = double("Redis")
    bf = BloomFilter::CountingRedis.new(:db => redis_client)
    expect(bf.instance_variable_get(:@db)).to be(redis_client)
  end

  context "a default CountingRedis instance" do
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
      expect(subject.include?('test', 'abcd', 'nada')).to be false
    end

    it "should delete keys from Redis" do
      subject.insert('test')
      expect(subject.include?('test')).to be true

      subject.delete('test')
      expect(subject.include?('test')).to be false
    end

    it "should output current stats" do
      subject.insert('test')
      expect(subject.size).to eq(4)
      expect { subject.stats }.not_to raise_error
    end
  end

  context "a TTL 1 instance" do
    subject { BloomFilter::CountingRedis.new(:ttl => 1) }

    it "should accept a TTL value for a key" do
      subject.instance_variable_get(:@db).flushall

      subject.insert('test')
      expect(subject.include?('test')).to be true

      sleep(2)
      expect(subject.include?('test')).to be false
    end
  end
end
