#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Carp;

# Prevents CFEngine locking issues
my $prefix = qr{ R: \s+ }mxs; 

my $expected_output = qr/\A
$prefix \Qefl_global_lists.ntp_servers => [ntp1.example.com]\E \s
$prefix \Qefl_global_lists.ntp_servers => [ntp2.example.com]\E \s
$prefix \Qefl_global_lists.ntp_servers => [ntp3.example.com]\E \s

# Begin matching randomly ordered list of three items
(?:
   $prefix \Qefl_global_lists.name_servers => [10.0.0.\E [123] \] \s
){3} # Match the above three times


# Begin matching randomly order list of three items
(?:
   $prefix \Qefl_global_lists.web_servers => [\E [123] \Q.example.com]\E \s
){3}  # Match the above three times

\z/msx;

# Where policy will be run
chdir 'test/masterfiles' or croak "Cannot cd to test/masterfiles $!";

# Define data param formats that we test
my @data_formats = qw/ csv json /;
my $number_of_tests = scalar @data_formats;

# Test each data format
for my $next_format ( @data_formats ){
   my $output =
      qx{ cf-agent -D test_$next_format,efl_global_slists -Kf ./promises.cf 2>&1 };
   like( $output, $expected_output,
      "efl_global_lists $next_format data" );
}

done_testing( $number_of_tests );
=pod

=head1 SYNOPSIS

Test that lists are formed, shuffled, and that iteration works.

=cut

# Test data
__DATA__
R: efl_global_lists.ntp_servers => [ntp1.example.com]
R: efl_global_lists.ntp_servers => [ntp2.example.com]
R: efl_global_lists.ntp_servers => [ntp3.example.com]
R: efl_global_lists.name_servers => [10.0.0.1]
R: efl_global_lists.name_servers => [10.0.0.3]
R: efl_global_lists.name_servers => [10.0.0.2]
R: efl_global_lists.web_servers => [2.example.com]
R: efl_global_lists.web_servers => [1.example.com]
R: efl_global_lists.web_servers => [3.example.com]
