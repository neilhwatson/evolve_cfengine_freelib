require 'spec_helper'

3.times do |i|
   describe file ("/tmp/efl_test/efl_link/l/0#{i+1}_link" )do
      it { should be_linked_to "/tmp/efl_test/efl_link/s/0#{i+1}" }
   end
end
