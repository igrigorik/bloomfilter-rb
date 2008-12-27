require 'sbloomfilter'

class BloomFilter
  def stats
    fp = ((1.0 - Math.exp(-(self.k * self.num_set).to_f / self.m)) ** self.k) * 100
    printf "Number of filter bits (m): %d\n" % self.m
    printf "Number of filter elements (n): %d\n" % self.num_set
    printf "Number of filter hashes (k) : %d\n" % self.k
    printf "Predicted false positive rate = %.2f%\n" % fp
  end
end