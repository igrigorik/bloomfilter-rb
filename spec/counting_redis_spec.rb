require 'helper'

describe BloomFilter::CountingRedis do
  include BloomFilter

  context "use Redis for storage" do
    it "should store data in Redis" do
      bf = CountingRedis.new

      bf.insert(:abcd)
      bf.insert('test')
      bf.include?('test').should be_true
      bf.key?('test').should be_true

      bf.include?('test', 'test2').should be_false
      bf.include?('test', 'abcd').should be_true
    end

    it "should accept a TTL value for a key" do
      bf = CountingRedis.new(:ttl => 1)

      bf.insert('test')
      bf.include?('test').should be_true

      sleep(2)
      bf.include?('test').should be_false
    end

    it "should delete keys from Redis" do
      bf = CountingRedis.new

      bf.insert('test')
      bf.include?('test').should be_true

      bf.delete('test')
      bf.include?('test').should be_false
    end

    it "should output current stats" do
      bf = CountingRedis.new
      bf.clear

      bf.insert('test')
      bf.size.should == 4
      lambda { bf.stats }.should_not raise_error
    end

    it "should connect to remote redis server" do
      lambda { CountingRedis.new }.should_not raise_error
    end
  end
end