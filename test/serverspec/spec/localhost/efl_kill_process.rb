require 'spec_helper'

describe process ( 'ntpd' ) do
   it { should be_running }
end

describe service ( 'efl_test_daemon' ) do
   it { should_not be_running }
end
