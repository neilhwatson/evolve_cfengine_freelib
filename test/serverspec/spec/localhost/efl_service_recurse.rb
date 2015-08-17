require 'spec_helper'
require 'digest/md5'

config_dir = '/tmp/efl_test/efl_service_recurse'
src_dir    = '/tmp/efl_test/efl_service_recurse_src'
efl_files = [ 'efl_common.cf', 'evolve_freelib.cf', 'efl_update.cf' ]
md5_of = {
   "#{src_dir}/efl_common.cf"     => 1,
   "#{src_dir}/evolve_freelib.cf" => 1,
   "#{src_dir}/efl_update.cf"     => 1,
}

# Get md5sum of original files
md5_of.each do|next_file,next_hash|
   md5_of["#{next_file}"] = 
      Digest::MD5.hexdigest( File.read( "#{next_file}" ) )
end

describe "recursive service config copy test" do
   efl_files.each do|next_file|
      describe file( "#{config_dir}/#{next_file}" ) do
         it { should be_file }
         it { should be_mode 640 }
         it { should be_owned_by 'root' }
         it { should be_grouped_into 'root' }
         its(:md5sum) {
            should eq md5_of["#{src_dir}/#{next_file}"] }
      end
   end
end

describe service ( 'efl_test_daemon' ) do
   it { should be_running }
end

describe file ( "#{config_dir}/restarted" ) do
   it { should be_file }
end
