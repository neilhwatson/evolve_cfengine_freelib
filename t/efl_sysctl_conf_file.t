#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use POSIX qw/ WIFEXITED /;
use Cwd;
use Carp;

my $start_dir = getcwd();

my @data_formats = qw/ csv json /;
my $number_of_tests = scalar @data_formats * 2;

for my $next_format ( @data_formats ){

   # Run cf-agent test policy
   chdir 'test/masterfiles' or croak "Cannot cd to test/masterfiles $!";
   my $cf_agent
      = "cf-agent -D test_$next_format,efl_sysctl_conf_file "
      .  "-Kf ./promises.cf";
   ok( 
      WIFEXITED( ( system $cf_agent ) >> 8)
      , "Run efl_sysctl_conf with $next_format"
   );

   # Test the results of cf-agent test policy
   chdir '../serverspec' or croak "Cannot cd to test/serverspec $!";
   my $rspec = "rspec spec/localhost/efl_sysctl_conf_file.rb >/dev/null";
   ok( WIFEXITED( ( system $rspec ) >> 8), $rspec);

   # Return to original dir
   chdir $start_dir or croak "Cannot cd to $start_dir $!";
}

done_testing( $number_of_tests );
chdir $start_dir or croak "Cannot cd to $start_dir $!";

=pod

=head1 SYNOPSIS

Testing bundle efl_sysctl_conf_file

=cut
