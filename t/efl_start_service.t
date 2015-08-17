#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Proc::Killall;
use POSIX qw/ WIFEXITED /;
use Cwd;
use Carp;

my $start_dir = getcwd();

my @data_formats = qw/ csv json /;
my $number_of_tests = scalar @data_formats * 2;

for my $next_format ( @data_formats ){

   # Ensure service is not running
   killall( 'KILL', '\Aefl_test_daemon\z' );

   # Run cf-agent test policy
   chdir 'test/masterfiles' or croak "Cannot cd to test/masterfiles $!";
   my $cf_agent = "cf-agent -D test_$next_format,efl_start_service "
      ."-Kf ./promises.cf";
   ok( 
      WIFEXITED( ( system $cf_agent ) >> 8)
      , "Run efl_start_service with $next_format"
   );

   # Test the results of cf-agent test policy
   chdir '../serverspec' or croak "Cannot cd to test/serverspec $!";
   my $rspec = "rspec spec/localhost/efl_start_service.rb >/dev/null";
   ok( WIFEXITED( ( system $rspec ) >> 8), $rspec);

   # Return to original dir
   chdir $start_dir or croak "Cannot cd to $start_dir $!";
}

done_testing( $number_of_tests );

# Ensure service is not running
killall( 'KILL', '\Aefl_test_daemon\z' );

#
# Subs
#

=pod

=head1 SYNOPSIS

Test efl_start_service bundle

=cut
