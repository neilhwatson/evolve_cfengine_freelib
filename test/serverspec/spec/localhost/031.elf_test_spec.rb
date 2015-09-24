require_relative '../spec_helper'

describe "031 and 032 efl_test" do
   describe package( 'nano' ) do
      it { should_not be_installed }
   end
   describe package( 'e3' ) do
      it { should be_installed }
   end
end

