require 'spec_helper'
require 'digest/md5'

config_dir = '/tmp/efl_test/efl_service'
src_dir    = '/tmp/efl_test/templates'

md5_of_config = Digest::MD5.hexdigest( File.read( "#{src_dir}/config" ) )

describe file( "#{config_dir}/config" ) do
   it { should be_file }
   it { should be_mode 640 }
   it { should be_owned_by 'root' }
   it { should be_grouped_into 'root' }
   its(:md5sum) {
      should == md5_of_config }
end

describe service ( 'efl_test_daemon' ) do
   it { should be_running }
end

describe file ( "#{config_dir}/restarted" ) do
   it { should be_file }
end
