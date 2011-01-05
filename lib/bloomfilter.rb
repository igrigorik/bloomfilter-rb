require 'redisbloom'
require 'cbloomfilter'

class BloomFilter
  VERSION = "1.3.1"

  attr_reader :bf

  def initialize(opts = {})
    @opts = {
      :size    => 100,
      :hashes  => 4,
      :seed    => Time.now.to_i,
      :bucket  => 3,
      :raise   => false,
      :type    => :c,
      :values  => false
    }.merge(opts)

    @values = {}
    @bf = create_filter
  end

  def create_filter(bitmap = nil)
    case @opts[:type]
      # arg 1: m => size : number of buckets in a bloom filter
      # arg 2: k => hashes : number of hash functions
      # arg 3: s => seed : seed of hash functions
      # arg 4: b => bucket : number of bits in a bloom filter bucket
      # arg 5: r => raise : raise on bucket overflow?
      when :c then
        bf = CBloomFilter.new(@opts[:size], @opts[:hashes], @opts[:seed], @opts[:bucket], @opts[:raise])
        bf.load(bitmap) if !bitmap.nil?
        bf
      when :redis then RedisBloom.new(@opts)
      else
        raise "invalid type"
    end
  end

  def insert(key, value=nil, ttl=nil)
    @bf.insert(key, ttl)
    @values[key] = value if @opts[:values]
  end
  alias :[]= :insert

  def include?(*keys)
    if @opts[:values]
      keys.collect do |key|
        @values[key] if @bf.include?(key)
      end.compact
    else
      @bf.include?(*keys)
    end
  end
  alias :key? :include?

  def [](key)
    return nil if not (@opts[:values] and include?(key))
    @values[key]
  end

  def keys
    return nil if not @opts[:values]
    @values.keys
  end

  def delete(key); @bf.delete(key); end
  def clear; @bf.clear; end
  def size; @bf.num_set; end
  def merge!(o); @bf.merge!(o.bf); end

  def bitmap
    case @opts[:type]
    when :c then @bf.bitmap
    else
      raise "cannot export bitmap for this bloomfilter type"
    end
  end

  def marshal_load(ary)
    @opts, @values, bitmap = *ary
    @bf = create_filter(bitmap)
    @bf
  end

  def marshal_dump
    [@opts, @values, @bf.bitmap]
  end

  def self.load(filename)
    Marshal.load(File.open(filename, 'r'))
  end

  def save(filename)
    File.open(filename, 'w') do |f|
      f << Marshal.dump(self)
    end
  end

  def stats
    fp = ((1.0 - Math.exp(-(@opts[:hashes] * size).to_f / @opts[:size])) ** @opts[:hashes]) * 100
    printf "Number of filter buckets (m): %d\n" % @opts[:size]
    printf "Number of bits per buckets (b): %d\n" % @opts[:bucket]
    printf "Number of filter elements (n): %d\n" % size
    printf "Number of filter hashes (k) : %d\n" % @opts[:hashes]
    printf "Raise on overflow? (r) : %s\n" % @opts[:raise].to_s
    printf "Predicted false positive rate = %.2f%\n" % fp
  end
end
