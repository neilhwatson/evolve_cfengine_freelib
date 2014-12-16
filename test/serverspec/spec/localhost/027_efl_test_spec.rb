require 'spec_helper'

testdir = '/tmp/efl_test/027'

for i in ['a','b']
   describe file ( "#{testdir}/01/#{i}.txt" ) do
      it { should_not be_file }
      it { should_not be_directory }
      it { should_not be_socket }
   end
   describe file ( "#{testdir}/02/#{i}.txt" ) do
      it { should be_file }
   end
   describe file ( "#{testdir}/03/#{i}.txt" ) do
      it { should_not be_file }
      it { should_not be_directory }
      it { should_not be_socket }
   end
end

describe file ( "#{testdir}/01/c.html" ) do
   it { should be_file }
end

describe file ( "#{testdir}/02/c.html" ) do
      it { should_not be_file }
      it { should_not be_directory }
      it { should_not be_socket }
end

describe file ( "#{testdir}/03/c.html" ) do
      it { should_not be_file }
      it { should_not be_directory }
      it { should_not be_socket }
end

describe file ( "#{testdir}/03/sub/d.json" ) do
      it { should_not be_file }
      it { should_not be_directory }
      it { should_not be_socket }
end

describe file ( "#{testdir}/04/a.txt" ) do
      it { should_not be_file }
      it { should_not be_directory }
      it { should_not be_socket }
end

describe file ( "#{testdir}/04/b.json" ) do
      it { should be_file }
end
