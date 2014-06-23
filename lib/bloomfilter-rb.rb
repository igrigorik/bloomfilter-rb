require 'redis'
require 'zlib'

require 'cbloomfilter' unless defined? JRUBY_VERSION
require 'bloomfilter/filter'
require 'bloomfilter/native'
require 'bloomfilter/counting_redis'
require 'bloomfilter/redis'
require 'bloomfilter/version'