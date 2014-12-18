require 'spec_helper'

describe "035 efl test" do
   describe service ( 'efl_test_daemon' ) do
      it { should be_running }
   end
end


