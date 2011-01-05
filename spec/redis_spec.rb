require 'helper'

describe BloomFilter::Redis do
  include BloomFilter

  context "use Redis bitstring for storage" do
    let(:bf) { Redis.new }

    it "should store data in Redis" do
      bf.insert(:abcd)
      bf.insert('test')
      bf.include?('test').should be_true
      bf.key?('test').should be_true

      bf.include?('test', 'test2').should be_false
      bf.include?('test', 'abcd').should be_true
    end

    it "should delete keys from Redis" do
      bf.insert('test')
      bf.include?('test').should be_true

      bf.delete('test')
      bf.include?('test').should be_false
    end

    it "should clear Redis filter" do
      bf.insert('test')
      bf.include?('test').should be_true

      bf.clear
      bf.include?('test').should be_false
    end

    it "should output current stats" do
      bf.clear
      bf.insert('test')
      lambda { bf.stats }.should_not raise_error
    end

    it "should connect to remote redis server" do
      lambda { Redis.new }.should_not raise_error
    end

    it "should allow namespaced BloomFilters" do
      bf1 = Redis.new(:namespace => :a)
      bf2 = Redis.new(:namespace => :b)

      bf1.insert('test')
      bf1.include?('test').should be_true
      bf2.include?('test').should be_false
    end
  end
end