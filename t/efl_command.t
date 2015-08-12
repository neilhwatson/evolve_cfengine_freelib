#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use File::Path qw/ make_path remove_tree /;
use POSIX qw/ WIFEXITED /;
use Cwd;
use Carp;
use Perl6::Slurp;
use Digest::MD5 qw( md5_hex );

my $test_hash = 'a95cee7d8d28c9a1d6f4cd86100d341c' ;
# Change this and you must change the cfe data files.
my $test_dir  = '/tmp/efl_test';
my $test_file = $test_dir.'/023_efl_test';
make_path( $test_dir );

my $start_dir = getcwd();

my @data_formats = qw/ csv json /;
my $number_of_tests = scalar @data_formats * 2;

for my $next_format ( @data_formats ){

   # Remove test file to start test
   unlink $test_file;

   # Run cf-agent test policy
   chdir 'test/masterfiles' or croak "Cannot cd to test/masterfiles $!";
   ok( 
      WIFEXITED(
         ( system
            "cf-agent -D test_$next_format,efl_command -Kf ./promises.cf" )
            >> 8), "Run efl_command with $next_format"
   );

   # Test the results of cf-agent test policy
   my $hash = get_md5_hash( $test_file );
   is( $hash, $test_hash, "Hash of test file"  );

   # Return to original dir
   chdir $start_dir or croak "Cannot cd to $start_dir $!";
}
# Return to original dir
chdir $start_dir or croak "Cannot cd to $start_dir $!";

done_testing( $number_of_tests );

#
# Subs
#
sub get_md5_hash {
   my $file = shift;

   my $file_data = slurp $file, { raw => 1 };

   return md5_hex( $file_data );
}

=pod

=head1 SYNOPSIS

Test efl_command bundle

=cut
