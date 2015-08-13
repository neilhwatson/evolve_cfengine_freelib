require 'spec_helper'
require 'digest/md5'

recurse_copy_dir = '/tmp/efl_test/efl_copy_files_recurse'
single_copy_dir  = '/tmp/efl_test/efl_copy_files_single'
src_copy_dir     = '/tmp/efl_test/efl_copy_files_src'
efl_files = [ 'efl_common.cf', 'evolve_freelib.cf', 'efl_update.cf' ]
md5_of    = {
   "/etc/ssh/ssh_config" => 1,
   "#{src_copy_dir}/efl_common.cf"       => 1,
   "#{src_copy_dir}/evolve_freelib.cf"   => 1,
   "#{src_copy_dir}/efl_update.cf"       => 1,
}

# Get md5sum of original files
md5_of.each do|next_file,next_hash|
   md5_of["#{next_file}"] = 
      Digest::MD5.hexdigest( File.read( "#{next_file}" ) )
end

describe "Single file copy test" do
   describe file( "#{single_copy_dir}/ssh_config" ) do
      it { should be_file }
      it { should be_mode 644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      its(:md5sum) { should eq md5_of["/etc/ssh/ssh_config"] }
   end
end

describe "recursive file copy test" do
   efl_files.each do|next_file|
      describe file( "#{recurse_copy_dir}/#{next_file}" ) do
         it { should be_file }
         it { should be_mode 640 }
         it { should be_owned_by 'root' }
         it { should be_grouped_into 'root' }
         its(:md5sum) {
            should eq md5_of["#{src_copy_dir}/#{next_file}"] }
      end
   end
end

