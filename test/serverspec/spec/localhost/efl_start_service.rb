require 'spec_helper'

describe service ( 'efl_test_daemon' ) do
   it { should be_running }
end

