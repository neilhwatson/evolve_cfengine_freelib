#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Carp;

# Prevents CFEngine locking issues
my $unique_prefix      = qr{
   R: \s+ \w+ \n
}mxs; 

my $report_prefix_line = qr{
   \n* # might be a new line
   $unique_prefix
   \Q1..1\E \n 
   $unique_prefix
}msx;

my $expected_output = qr{
\A

$report_prefix_line
\Qok 1 - efl_main order 1\E
$report_prefix_line
\Qok 1 - efl_main order 2\E
$report_prefix_line
\Qok 1 - efl_main order 3\E
$report_prefix_line
\Qok 1 - efl_main order 4\E
$report_prefix_line
\Qok 1 - efl_main order 5\E
$report_prefix_line
\Qok 1 - efl_main order 6\E
$report_prefix_line
\Qok 1 - efl_main order 7\E
$report_prefix_line
\Qok 1 - efl_main order 8\E
$report_prefix_line
\Qok 1 - efl_main order 9\E
$report_prefix_line
\Qok 1 - efl_main order 10\E
$report_prefix_line
\Qok 1 - efl_main order 11\E
$report_prefix_line
\Qok 1 - efl_main order 12\E
$report_prefix_line
\Qok 1 - efl_main order 13\E
$report_prefix_line
\Qok 1 - efl_main order 14\E
$report_prefix_line
\Qok 1 - efl_main order 15\E
$report_prefix_line
\Qok 1 - efl_main order 16\E
\s*
\z}mxs;

# Where policy will be run
chdir 'test/masterfiles' or croak "Cannot cd to test/masterfiles $!";

# Define data param formats that we test
my @data_formats = qw/ csv json /;
my $number_of_tests = scalar @data_formats;

# Test each data format
for my $next_format ( @data_formats ){
   my $output =
      qx{ cf-agent -D test_$next_format,iteration_order -Kf ./promises.cf 2>&1 };
   like( $output, $expected_output,
      "Iteration order using $next_format data" );
}

done_testing( $number_of_tests );
=pod

=head1 SYNOPSIS

Test that data file contents is processed in the order they appear in the file.

=cut

# Sample data:
__DATA__
R: efl_data_efl_test_simple_01_iteration_order_csv_cd91db1d8005b7c06166f7204e0fd177d6386937
1..1
R: efl_data_efl_test_simple_01_iteration_order_csv_cd91db1d8005b7c06166f7204e0fd177d6386937
ok 1 - efl_main order 1
R: efl_data_efl_test_simple_02_iteration_order_csv_3426e2bf7199be78173f43d3e8b18d150761089d
1..1
R: efl_data_efl_test_simple_02_iteration_order_csv_3426e2bf7199be78173f43d3e8b18d150761089d
ok 1 - efl_main order 2
R: efl_data_efl_test_simple_03_iteration_order_csv_741cdec33b8b18e18720c706ba3aac9ca6aad5c4

....

1..1
R: efl_data_efl_test_simple_16_iteration_order_csv_df7df4238093cec3e9da8ff965850d9c3123ed4b
ok 1 - efl_main order 16
