require 'spec_helper'

describe file ('/etc/sysctl.conf' ) do
   it { should be_file }
   it { should be_mode 644 }
   it { should be_owned_by 'root' }
   it { should be_grouped_into 'root' }
   its(:md5sum) { should eq '4c3a767a5e089ec0e07ec1af092d3f9b' }
end

