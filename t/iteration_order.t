#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 2;
use Carp;

my $expected_output = qr{
\A
\QR: PASS, any, efl_main order 1
R: PASS, any, efl_main order 2
R: PASS, any, efl_main order 3
R: PASS, any, efl_main order 4
R: PASS, any, efl_main order 5
R: PASS, any, efl_main order 6
R: PASS, any, efl_main order 7
R: PASS, any, efl_main order 8
R: PASS, any, efl_main order 9
R: PASS, any, efl_main order 10
R: PASS, any, efl_main order 11
R: PASS, any, efl_main order 12
R: PASS, any, efl_main order 13
R: PASS, any, efl_main order 14
R: PASS, any, efl_main order 15
R: PASS, any, efl_main order 16
\E
\z}mxs;

chdir 'test/masterfiles' or croak "Cannot cd to test/masterfiles $!";

my $output = qx{ cf-agent -D iteration_order_csv -Kf ./promises.cf 2>&1 };
like( $output, $expected_output, "Iteration order using csv data" );

$output = '';
$output = qx{ cf-agent -D iteration_order_json -Kf ./promises.cf 2>&1 };
like( $output, $expected_output, "Iteration order using json data" );

=pod

=head1 SYNOPSIS

Test that data file contents is processed in the order they appear in the file.

=cut
