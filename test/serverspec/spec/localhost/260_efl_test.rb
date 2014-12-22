require 'spec_helper'

describe "260 efl test" do
   
   describe service ( 'efl_test_daemon' ) do
      it { should be_running }
   end

   testdir = '/tmp/efl_test/260'

   describe file ( "#{testdir}/cfengine_template" ) do
      it { should be_file }
   end

   describe file ( "#{testdir}/restarted" ) do
      it { should be_file }
   end
end
