require_relative '../spec_helper'

describe "037 efl test" do
   
   describe service ( 'efl_test_daemon' ) do
      it { should be_running }
   end

   testdir = '/tmp/efl_test/037'

   for i in ['a','b']
      describe file ( "#{testdir}/01/#{i}.txt" ) do
         it { should be_file }
      end
      describe file ( "#{testdir}/01/#{i}.txt" ) do
         it { should be_file }
      end
   end

   describe file ( "#{testdir}/01/c.html" ) do
      it { should be_file }
   end

   describe file ( "#{testdir}/01/restarted" ) do
      it { should be_file }
   end
end
