
require 'spec_helper'
require 'digest/md5'

clone_dir = '/tmp/efl_test/efl_rcs_pull/clone'
repo_dir  = '/tmp/efl_test/efl_rcs_pull/repo'
test_file = 'efl_update.cf'

md5_of_test_file \
   = Digest::MD5.hexdigest( File.read( "#{repo_dir}/#{test_file}" ) )

describe file( "#{clone_dir}/#{test_file}" ) do
   it { should be_file }
   its(:md5sum) { should == md5_of_test_file }
end

describe file( "#{clone_dir}/.git" ) do
   it { should be_directory }
end
