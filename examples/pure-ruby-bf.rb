require 'bitset' # gem
require 'zlib'   # stdlib
require 'digest' # stdlib

class BloomFilter
  # return an array of bit indices ("on bits") via repeated string hashing
  # start with the fastest/cheapest algos, up to 8 rounds
  # beyond that, perform cyclic "hashing" with CRC32
  def self.hash_bits(str, num_hashes:, num_bits:)
    val = 0 # for cyclic hashing
    Array.new(num_hashes) { |i|
      case i
      when 0 then str.hash
      when 1 then Zlib.crc32(str)
      when 2 then Digest::MD5.hexdigest(str).to_i(16)
      when 3 then Digest::SHA1.hexdigest(str).to_i(16)
      when 4 then Digest::SHA256.hexdigest(str).to_i(16)
      when 5 then Digest::SHA384.hexdigest(str).to_i(16)
      when 6 then Digest::SHA512.hexdigest(str).to_i(16)
      when 7 then Digest::RMD160.hexdigest(str).to_i(16)
      else # cyclic hashing with CRC32
        val = Zlib.crc32(str, val)
      end % num_bits
    }
  end

  attr_reader :bitmap

  # The default values require 8 kilobytes of storage and recognize:
  # < 4000 strings: FPR 0.1%
  # < 7000 strings: FPR 1%
  # >  10k strings: FPR 5%
  # The false positive rate goes up as more strings are added
  def initialize(num_bits: 2**16, num_hashes: 5)
    @num_bits = num_bits
    @num_hashes = num_hashes
    @bitmap = Bitset.new(@num_bits)
  end

  def hash_bits(str)
    self.class.hash_bits(str, num_hashes: @num_hashes, num_bits: @num_bits)
  end

  def add(str)
    @bitmap.set *self.hash_bits(str)
  end
  alias_method(:<<, :add)

  def include?(str)
    @bitmap.set? *self.hash_bits(str)
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

  bf = BloomFilter.new(num_bits: 512, num_hashes: 5)
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
