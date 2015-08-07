#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 1;
use Carp;


my $output = qx/ cf-promises -v /;

like( $output,
   qr{ CFEngine \s+ Core \s+ 3\.7\.\d+ }mxs,
   "CFEngine version number" );

