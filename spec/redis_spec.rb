require 'helper'

describe BloomFilter::Redis do
  include BloomFilter

  context "use Redis for storage" do
    it "should store data in Redis" do
      bf = Redis.new(:type => :redis)

      bf.insert(:abcd)
      bf.insert('test')
      bf.include?('test').should be_true
      bf.key?('test').should be_true

      bf.include?('test', 'test2').should be_false
      bf.include?('test', 'abcd').should be_true
    end

    xit "should optionally store values" do
      bf = Redis.new(:type => :redis, :values => true)

      bf['foo'] = 'bar'
      bf.include?('foo').should be_true
      bf['foo'].should == 'bar'
    end

    it "should accept a TTL value for a key" do
      bf = Redis.new(:type => :redis, :ttl => 1)

      bf.insert('test')
      bf.include?('test').should be_true

      sleep(2)
      bf.include?('test').should be_false
    end

    it "should delete keys from Redis" do
      bf = Redis.new(:type => :redis)

      bf.insert('test')
      bf.include?('test').should be_true

      bf.delete('test')
      bf.include?('test').should be_false
    end

    it "should output current stats" do
      bf = Redis.new(:type => :redis)
      bf.clear

      bf.insert('test')
      bf.size.should == 4
      lambda { bf.stats }.should_not raise_error
    end

    it "should connect to remote redis server" do
      lambda {
        Redis.new(:type => :redis, :server => {:host => 'localhost'})
      }.should_not raise_error
    end
  end
end