module BloomFilter
  class Filter
    def options
      @opts
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
end