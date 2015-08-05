#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 1;
use Carp;


chdir 'test/masterfiles' or croak "Cannot cd to test/masterfiles $!";

my $output = qx{ cf-promises -cf ./promises.cf 2>&1 };

like( $output, qr{\A\z}mxs, "CFEngine syntax check returns no output" );

