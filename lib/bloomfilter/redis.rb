module BloomFilter
  class Redis < Filter

    def initialize(opts = {})
      @opts = {
        :size    => 100,
        :hashes  => 4,
        :seed    => Time.now.to_i,
        :namespace => 'redis',
        :eager  => false,
        :server => {}
      }.merge opts
      @db = ::Redis.new(@opts[:server])

      if @opts[:eager]
        @db.setbit @opts[:namespace], @opts[:size]+1, 1
      end
    end

    def insert(key, ttl=nil)
      @db.pipelined do
        indexes_for(key) { |idx| @db.setbit @opts[:namespace], idx, 1 }
      end
    end
    alias :[]= :insert

    def include?(*keys)
      keys.each do |key|
        indexes = []
        indexes_for(key) { |idx| indexes << idx }

        return false if @db.getbit(@opts[:namespace], indexes.shift) == 0

        result = @db.pipelined do
          indexes.each do |idx|
            @db.getbit(@opts[:namespace], idx)
          end
        end

        return false if result.include?(0)
      end

      true
    end
    alias :key? :include?

    def delete(key)
      @db.pipelined do
        indexes_for(key) do |idx|
          @db.setbit @opts[:namespace], idx, 0
        end
      end
    end

    def clear
      @db.set @opts[:namespace], 0
    end

    def num_set
      @db.strlen @opts[:namespace]
    end
    alias :size :num_set

    def stats
      printf "Number of filter buckets (m): %d\n" % @opts[:size]
      printf "Number of filter hashes (k) : %d\n" % @opts[:hashes]
    end

    private

      # compute index offsets for provided key
      def indexes_for(key)
        indexes = []
        @opts[:hashes].times do |i|
          yield Zlib.crc32("#{key}:#{i+@opts[:seed]}") % @opts[:size]
        end
      end

  end
end
