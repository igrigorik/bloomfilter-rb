require 'sbloomfilter'

class BloomFilter
  def stats
    fp = ((1.0 - Math.exp(-(self.k * self.num_set).to_f / self.m)) ** self.k) * 100
    printf "Number of filter buckets (m): %d\n" % self.m
    printf "Number of bits per buckets (b): %d\n" % self.b
    printf "Number of filter elements (n): %d\n" % self.num_set
    printf "Number of filter hashes (k) : %d\n" % self.k
    printf "Raise on overflow? (r) : %s\n" % self.r.to_s
    printf "Predicted false positive rate = %.2f%\n" % fp
  end

  def []= key, value
    insert(key)
    @hash_value[key] = value
  end

  def [] key
    return nil unless include?(key)
    @hash_value[key]
  end

  def key? key
    include?(key)
  end

  def keys
    @hash_value.keys
  end
end
