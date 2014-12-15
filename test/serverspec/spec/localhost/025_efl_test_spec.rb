require 'spec_helper'

3.times do |i|
   describe file ("/var/tmp/efl_test_0#{i+1}_link" )do
      it { should be_linked_to "/tmp/efl_test_0#{i+1}" }
   end
end
