require 'spec_helper'

files = [
   '/tmp/ssh/ssh_config',
   '/tmp/efl_test/029/01/a.txt',
   '/tmp/efl_test/029/01/b.txt',
]

describe "029 030 efl test" do
   for i in files
      describe file ( "#{i}" ) do
         it { should be_file }
         it { should be_mode 644 }
         it { should be_owned_by 'root' }
         it { should be_grouped_into 'root' }
      end
   end
   describe "029 030 test, this file is excluded from copy by leaf_regex" do
      describe file ( '/tmp/efl_test/029/01/c.html' ) do
         it { should_not be_file }
         it { should_not be_directory }
         it { should_not be_socket }
      end
   end
end


