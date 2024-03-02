require 'zlib'   # stdlib
require 'bitset' # gem

class BloomFilter
  MAX_BITS = 2**32 # CRC32 yields 32-bit values

  attr_reader :bitsize, :aspects, :bitmap

  # The default values require 8 kilobytes of storage and recognize:
  # < 7000 strings at 1% False Positive Rate (4k @ 0.1%) (10k @ 5%)
  # FPR goes up as more strings are added
  def initialize(bitsize: 2**16, aspects: 5)
    @bitsize = bitsize
    raise("bitsize: #{@bitsize}") if @bitsize > MAX_BITS
    @aspects = aspects
    @bitmap = Bitset.new(@bitsize)
  end

  # Return an array of bit indices ("on bits") corresponding to
  # multiple rounds of string hashing (CRC32 is fast and ~fine~)
  def bits(str)
    val = 0
    Array.new(@aspects) { (val = Zlib.crc32(str, val)) % @bitsize }
  end

  def add(str)
    @bitmap.set(*self.bits(str))
  end
  alias_method(:<<, :add)

  # true or false; a `true` result may be a "false positive"
  def include?(str)
    @bitmap.set?(*self.bits(str))
  end

  # returns either 0 or a number like 0.95036573
  def likelihood(str)
    self.include?(str) ? 1.0 - self.fpr : 0
  end
  alias_method(:[], :likelihood)

  # relatively expensive; don't test against this in a loop
  def percent_full
    @bitmap.to_a.count.to_f / @bitsize
  end

  def fpr
    self.percent_full**@aspects
  end

  def to_s
    format("%i bits (%.1f kB, %i aspects) %i%% full; FPR: %.3f%%",
           @bitsize, @bitsize.to_f / 2**13, @aspects,
           self.percent_full * 100, self.fpr * 100)
  end
  alias_method(:inspect, :to_s)
end

if __FILE__ == $0
  puts "Enter strings into the filter; empty line to display filter status"
  puts "Two empty lines to quit"
  puts

  bf = BloomFilter.new(bitsize: 512, aspects: 5)
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
      puts format("%04.1f%% %s \t %s", bf[str] * 100, str, bf.bits(str))
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
  # 1. puts (yes)
  # 2. ingest loop comment (yes)
  # 3. test loop comment (yes)
  # 4. end (yes)
  puts
  # ingest loop
  # test loop
end
