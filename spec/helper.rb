require 'bundler/setup'
require 'bloomfilter-rb'

module SpecHelper
  extend self

  def silence_stdout
    $stdout = File.new( '/dev/null', 'w' )
    yield
  ensure
    $stdout = STDOUT
  end
end