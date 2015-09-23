#!/usr/bin/perl

use strict;
use warnings;
use POSIX qw/ WIFEXITED /;
use Cwd;
use Git::Repository;
use File::Copy qw/ copy /;
use File::Path qw/ make_path remove_tree /;
use feature 'say';
use Test::More;
use Carp;

my $start_dir = getcwd();
my $version   = '3.7';
my $bundle    = 'efl_kill_process';
my @tests     = (
   {
      name    => "$bundle using json data.",
      subtest => sub
         { run_agent_and_test({
               Dclass => "test_json",
               bundle => $bundle
         }) },
   },
);

# Include the extra daemon start test
my $number_of_tests = scalar @tests * 2 ;

for my $next_test ( @tests ) {

   # Ensure test daemon to kill is running.
   subtest "Start test daemon for later kill test" => sub {
      run_agent_and_test({
         Dclass => "test_json",
         bundle => "efl_start_service"
      }) };
   
   # Minimum kill elapsed time in policy is 1 minutes, so we sleep
   sleep 60;
   subtest $next_test->{name} => $next_test->{subtest};
}

done_testing( $number_of_tests );

#
# subs 
#

sub run_agent_and_test {
   my ( $arg_ref ) = @_;
   my $Dclass = $arg_ref->{Dclass};
   my $bundle = $arg_ref->{bundle};

   croak "No Dlcass provided" unless $Dclass;
   croak "No bundle provided" unless $bundle;

   # Run cf-agent test policy
   chdir 'test/masterfiles' or croak "Cannot cd to test/masterfiles $!";
   my $cf_agent = "cf-agent -D $Dclass,$bundle -Kf ./promises.cf";
   ok( WIFEXITED( ( system $cf_agent ) >> 8), "Pull or new clone" );

   # Test the results of cf-agent test policy
   chdir '../serverspec' or croak "Cannot cd to test/serverspec $!";
   my $rspec = "rspec spec/localhost/$bundle.rb >/dev/null";
   ok( WIFEXITED( ( system $rspec ) >> 8), $rspec);

   # Return to original dir
   chdir $start_dir or croak "Cannot cd to $start_dir $!";

   return 1;
}


=pod

=head1 SYNOPSIS

Testing efl_kill_process

=cut
