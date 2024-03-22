# stdlib
require 'rbconfig/sizeof'
require 'zlib'

class BitSet
  # in bits, e.g. 64 bit / 32 bit platforms.  SIZEOF returns byte width
  INT_WIDTH = RbConfig::SIZEOF.fetch('long') * 8

  # return an array of ones and zeroes, padded to INT_WIDTH
  def self.bits(int)
    bit_ary = int.digits(2)
    bit_ary + Array.new(INT_WIDTH - bit_ary.count, 0)
  end

  attr_reader :storage

  # create an array of integers, default 0
  # use flip_even_bits to initialize with every even bit set to 1
  def initialize(num_bits, flip_even_bits: false)
    init = flip_even_bits ? (2**INT_WIDTH / 3r).to_i : 0
    @storage = Array.new((num_bits / INT_WIDTH.to_f).ceil, init)
  end

  # ensure the given bit_indices are set to 1
  def set(bit_indices)
    bit_indices.each { |b|
      slot, val = b.divmod(INT_WIDTH)
      @storage[slot] |= (1 << val)
    }
  end

  # determine if all given bit indices are set to 1
  def set?(bit_indices)
    bit_indices.all? { |b|
      slot, val = b.divmod(INT_WIDTH)
      @storage[slot][val] != 0
    }
  end

  # returns an array of ones and zeroes, padded to INT_WIDTH
  def bits
    @storage.flat_map { |i| self.class.bits(i) }
  end

  # returns an array of bit indices
  def on_bits
    self.bits.filter_map.with_index { |b, i| i if b == 1 }
  end
end

class BloomFilter
  MAX_BITS = 2**32 # CRC32 yields 32-bit values

  attr_reader :bits, :aspects, :bitmap

  # The default values require 8 kilobytes of storage and recognize:
  # < 7000 strings at 1% False Positive Rate (4k @ 0.1%) (10k @ 5%)
  # FPR goes up as more strings are added
  def initialize(bits: 2**16, aspects: 5)
    @bits = bits
    raise("bits: #{@bits}") if @bits > MAX_BITS
    @aspects = aspects
    @bitmap = BitSet.new(@bits)
  end

  # Return an array of bit indices ("on bits") corresponding to
  # multiple rounds of string hashing (CRC32 is fast and ~fine~)
  def index(str)
    val = 0
    Array.new(@aspects) { (val = Zlib.crc32(str, val)) % @bits }
  end

  def add(str)
    @bitmap.set(self.index(str))
  end
  alias_method(:<<, :add)

  # true or false; a `true` result may be a "false positive"
  def include?(str)
    @bitmap.set?(self.index(str))
  end

  # returns either 0 or a number like 0.95036573
  def likelihood(str)
    self.include?(str) ? 1.0 - self.fpr : 0
  end
  alias_method(:[], :likelihood)

  # relatively expensive; don't test against this in a loop
  def percent_full
    @bitmap.on_bits.count.to_f / @bits
  end

  def fpr
    self.percent_full**@aspects
  end

  def to_s
    format("%i bits (%.1f kB, %i aspects) %i%% full; FPR: %.3f%%",
           @bits, @bits.to_f / 2**13, @aspects,
           self.percent_full * 100, self.fpr * 100)
  end
  alias_method(:inspect, :to_s)
end

if __FILE__ == $0
  puts "Enter strings into the filter; empty line to display filter status"
  puts "Two empty lines to quit"
  puts

  bf = BloomFilter.new(bits: 512, aspects: 5)
  num = 0
  last = ''

  # ingest loop
  while str = $stdin.gets&.chomp
    if str.empty? # display status; end the loop on consecutive empty lines
      puts bf
      break if last.empty?
    else          # ingest the line; update the count
      bf << str
      num += 1
    end
    last = str
  end

  puts "ingested #{num} strings"
  puts "test if the filter recognizes strings below:"
  puts

  # test loop
  last = ''
  while str = $stdin.gets&.chomp
    if str.empty? # as before
      puts bf
      break if last.empty?
    else          # show the likelihood for each item and its index
      puts format("%04.1f%% %s \t %s", bf[str] * 100, str, bf.index(str))
    end
    last = str
  end
end


# Everything below this line is to enable using this source file as input:
#   cat examples/pure-ruby-bf.rb | ruby examples/pure-ruby-bf.rb
# the two newlines above should break the ingest loop
# and now we can put stuff in the test loop:
if false
  # nothing in here will execute, but check if we've seen these lines before
  # 1. puts                (yes)
  # 2. ingest loop comment (yes)
  # 3. test loop comment   (yes)
  # 4. end                 (yes)
  puts
  # ingest loop
  # test loop
end
