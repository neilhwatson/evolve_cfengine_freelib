require 'spec_helper'

describe "efl_packages, efl_packages_new and efl_packages_via_cmd" do
   describe package( 'nano' ) do
      it { should_not be_installed }
   end
   describe package( 'dos2unix' ) do
      it { should be_installed }
   end
end

