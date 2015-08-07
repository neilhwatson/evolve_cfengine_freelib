#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Carp;

# Prevents CFEngine locking issues
my $unique_prefix      = qr{
   R: \s+ \w+
}mxs; 

my $report_prefix_line = qr{
   \s* # might be a new line
   $unique_prefix
   \s # new line
   \Q1..1\E
   \s # new line
   $unique_prefix
   \s # new line
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
\s+ # trailing new line
\z}mxs;

# Where policy will be run
chdir 'test/masterfiles' or croak "Cannot cd to test/masterfiles $!";

# Define data param formats that we test
my @data_formats = qw/ csv json /;
my $number_of_tests = scalar @data_formats;

# Test each data format
for my $next_format ( @data_formats ){
   my $output =
      qx{ cf-agent -D iteration_order_$next_format -Kf ./promises.cf 2>&1 };
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
R:  ___iteration_order_01_efl_test_simple_csv_5e709852a7969d011037185b114481fce2101371
1..1
R:  ___iteration_order_01_efl_test_simple_csv_5e709852a7969d011037185b114481fce2101371
ok 1 - efl_main order 1
R:  ___iteration_order_02_efl_test_simple_csv_c7ecb81491f87fc4368a7c020cbc0275ad1ecccc
1..1
R:  ___iteration_order_02_efl_test_simple_csv_c7ecb81491f87fc4368a7c020cbc0275ad1ecccc
ok 1 - efl_main order 2
