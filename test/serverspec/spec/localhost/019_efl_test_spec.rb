require_relative '../spec_helper'

describe "019 efl test" do
   context linux_kernel_parameter( 'vm.swappiness' ) do
      its(:value) { should eq 63 }
   end
end


