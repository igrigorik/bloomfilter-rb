module BloomFilter
  class Native < Filter
    attr_reader :bf

    def initialize(opts = {})
      @opts = {
        :size    => 100,
        :hashes  => 4,
        :seed    => Time.now.to_i,
        :bucket  => 3,
        :raise   => false
      }.merge(opts)

      # arg 1: m => size : number of buckets in a bloom filter
      # arg 2: k => hashes : number of hash functions
      # arg 3: s => seed : seed of hash functions
      # arg 4: b => bucket : number of bits in a bloom filter bucket
      # arg 5: r => raise : raise on bucket overflow?

      @bf = CBloomFilter.new(@opts[:size], @opts[:hashes], @opts[:seed], @opts[:bucket], @opts[:raise])
    end

    def insert(key)
      @bf.insert(key)
    end
    alias :[]= :insert

    def include?(*keys)
      @bf.include?(*keys)
    end
    alias :key? :include?
    alias :[] :include?

    def delete(key); @bf.delete(key); end
    def clear; @bf.clear; end
    def size; @bf.num_set; end
    def merge!(o); @bf.merge!(o.bf); end

    # Returns the number of bits that are set to 1 in the filter.
    def set_bits
      @bf.set_bits
    end

    # Computes the intersection of two Bloom filters.
    # It assumes that both filters have the same size -
    # if this is not true +ArgumentError+ is raised.
    def &(o)
      raise ArgumentError.new() unless same_parameters?(o)
      result = self.class.new
      result.instance_variable_set(:@bf,@bf.&(o.bf))
      result
    end

    # Computes the union of two Bloom filters.
    # It assumes that both filters have the same size -
    # if this is not true +ArgumentError+ is raised.
    def |(o)
      raise ArgumentError.new() unless same_parameters?(o)
      result = self.class.new
      result.instance_variable_set(:@bf,@bf.|(o.bf))
      result
    end

    def bitmap
      @bf.bitmap
    end

    def marshal_load(ary)
      opts, bitmap = *ary

      @bf = Native.new(opts)
      @bf.bf.load(bitmap) if !bitmap.nil?
    end

    def marshal_dump
      [@opts, @bf.bitmap]
    end

    def self.load(filename)
      Marshal.load(File.open(filename, 'r'))
    end

    def save(filename)
      File.open(filename, 'w') do |f|
        f << Marshal.dump(self).force_encoding('UTF-8')
      end
    end

    protected

    # Returns true if parameters of the +o+ther filter are
    # the same.
    def same_parameters?(o)
      @bf.m == o.bf.m && @bf.k == o.bf.k &&
        @bf.s == o.bf.s && @bf.b == o.bf.b
    end

  end
end
