%w{ rubygems bacon facon }.each { |dep| require dep  }

Bacon.extend Bacon::TestUnitOutput
Bacon.summary_on_exit

$:.unshift "#{File.dirname(__FILE__)}/../lib"
require 'casuistry'

