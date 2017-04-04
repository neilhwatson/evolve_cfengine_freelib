#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use File::Path qw/ make_path remove_tree /;
use POSIX qw/ WIFEXITED /;
use Cwd;
use File::Touch;
use File::Copy;
use Carp;

# If you change this dir you must also change efl_data/efl_copy_files.csv
my $recurse_copy_dir = '/tmp/efl_test/efl_copy_files_recurse';
my $single_copy_dir  = '/tmp/efl_test/efl_copy_files_single';
my $src_copy_dir     = '/tmp/efl_test/efl_copy_files_src';
my $src_file_path    = "$recurse_copy_dir/../efl_copy_files_src";
my $start_dir        = getcwd();


my @data_formats = qw/ csv json /;
my $number_of_tests = scalar @data_formats * 2;

for my $next_format ( @data_formats ){

   prep_source_files( $src_file_path );
   # Run cf-agent test policy
   chdir 'test/masterfiles' or croak "Cannot cd to test/masterfiles $!";
   ok( 
      WIFEXITED(
         ( system
            "cf-agent -D test_$next_format,efl_copy_files -Kf ./promises.cf" )
            >> 8), "Run efl_copy_files with $next_format"
   );

   # Test the results of cf-agent test policy
   chdir '../serverspec' or croak "Cannot cd to test/serverspec $!";
   my $rspec = "rspec spec/localhost/efl_copy_files.rb >/dev/null";
   ok( WIFEXITED( ( system $rspec ) >> 8), $rspec);

   # Return to original dir
   chdir $start_dir or croak "Cannot cd to $start_dir $!";

   # Remove test files and dir
   remove_tree( $recurse_copy_dir );
   remove_tree( $src_file_path);
}

done_testing( $number_of_tests );

#
# Subs
#

sub prep_source_files {
   my $dir = shift;

   my @src_files = qw/ efl_common.cf evolve_freelib.cf efl_update.cf /;

   # make source dir for copy_from
   make_path( $dir );

   # Copies files to src dir for testing
   for my $next_file ( @src_files ) {
      copy( "test/masterfiles/lib/EFL/$next_file" , "$dir/" )
         or croak "Cannot copy source file $next_file $!";
   }
}

=pod

=head1 SYNOPSIS

A testing template for use with rspec

=cut
