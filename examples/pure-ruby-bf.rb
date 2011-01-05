#
# Pure ruby implementation of a Bloom filter, just for kicks
#

require 'bitset'
require 'zlib'

class BloomFilter

  def initialize(max_entries, num_hashes, seed)
    @num_hashes = num_hashes
    @size = max_entries.to_i
    @bitmap = BitSet.new(@size)
    @__mask = BitSet.new(@size)
    @seed = seed
  end

  def insert(key)
    mask = make_mask(key)
    @bitmap |= mask
  end

  def new?(key)
    mask = make_mask(key)
    return ((@bitmap & mask) != mask);
  end

  def make_mask(key)
    @__mask.clear
    0.upto(@num_hashes.to_i - 1) do |i|
      hash = Zlib.crc32(key, i + @seed)
      @__mask.set(hash % @size, 1)
    end
    return @__mask
  end
end

def main
  bf = BloomFilter.new(1000000, 4, 0)
  num = 0
  while line = ARGF.gets
    data = line.chop

    if bf.new_entry?(data)
      num += 1
      bf.insert(data)
    end
  end
  print "#element = #{num}\n"
end

main
