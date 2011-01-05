require 'redis'
require 'zlib'

class RedisBloom
  def initialize(opts)
    @opts = {
      :ttl => false,
      :server => {}
    }.merge opts
    @db = Redis.new(@opts[:server])
  end

  def insert(key, ttl=nil)
    ttl = @opts[:ttl] if ttl.nil?

    indexes_for(key).each do |idx|
      @db.incr idx
      @db.expire(idx, ttl) if ttl
    end
  end

  def delete(key)
    indexes_for(key).each do |idx|
      if @db.decr(idx).to_i <= 0
        @db.del(idx)
      end
    end
  end

  def include?(*keys)
    indexes = keys.collect { |key| indexes_for(key) }
    not @db.mget(*indexes.flatten).include? nil
  end

  def num_set
    @db.keys("rbloom:*").size
  end

  def clear
    @db.flushdb
  end

  private

  # compute index offsets for provided key
  def indexes_for(key)
    indexes = []
    @opts[:hashes].times do |i|
      indexes.push "rbloom:" + (Zlib.crc32("#{key}:#{i+@opts[:seed]}") % @opts[:size]).to_s
    end

    indexes
  end
end