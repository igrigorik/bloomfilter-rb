require 'bitset' # gem
require 'zlib'   # stdlib

class BloomFilter
  attr_reader :bitmap

  # The default values require 8 kilobytes of storage and recognize:
  # < 4000 strings; FPR 0.1%
  # < 7000 strings; FPR 1%
  # >  10k strings; FPR 5%
  # The false positive rate goes up as more strings are added
  def initialize(num_bits: 2**16, num_hashes: 5)
    @num_bits = num_bits
    @num_hashes = num_hashes
    @bitmap = Bitset.new(@num_bits)
  end

  # return an array of bit indices representing "on bits"
  # use ruby's #hash "for free"; successive crc32 beyond that
  def bits(str)
    val = 0
    Array.new(@num_hashes - 1) {
      # use prior val as the seed for next hash
      val = Zlib.crc32(str, val)
      val % @num_bits
    }.push(str.hash % @num_bits)
  end

  def add(str)
    @bitmap.set *self.bits(str)
  end
  alias_method(:<<, :add)

  def include?(str)
    @bitmap.set? *self.bits(str)
  end

  def likelihood(str)
    self.include?(str) ? 1.0 - self.fpr : 0
  end
  alias_method(:[], :likelihood)

  def percent_full
    @bitmap.to_a.count.to_f / @num_bits
  end

  def fpr
    self.percent_full**@num_hashes
  end

  def to_s
    format("%i bits (%.1f kB, %i hashes) %i%% full; FPR: %.3f%%",
           @num_bits, @num_bits.to_f / 2**13, @num_hashes,
           self.percent_full * 100, self.fpr * 100)
  end
  alias_method(:inspect, :to_s)
end

if __FILE__ == $0
  puts "Enter strings into the filter; empty line to display filter status"
  puts "Two empty lines to quit"
  puts

  bf = BloomFilter.new(num_bits: 2**8, num_hashes: 5)
  num = 0
  last = ''

  # ingest loop
  while str = $stdin.gets&.chomp
    if str.empty?
      puts bf
      break if last.empty?
    else
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
    if str.empty?
      puts bf
      break if last.empty?
    else
      puts format("%.1f%%\t%s", bf[str] * 100,  str)
    end
    last = str
  end
end


# the two newlines above should break the ingest loop
# and now we can put stuff in the test loop:
if false
  puts
  # ingest loop
  # test loop
end
