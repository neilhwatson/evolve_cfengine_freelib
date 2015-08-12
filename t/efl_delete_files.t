#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use File::Path qw/ make_path remove_tree /;
use POSIX qw/ WIFEXITED /;
use Cwd;
use File::Touch;
use Carp;

# If you change this dir you must also change efl_data/efl_delete_files.csv
my $test_dir = '/tmp/efl_test/efl_delete_files';
my $start_dir = getcwd();

my @data_formats = qw/ csv json /;
my $number_of_tests = scalar @data_formats * 2;

for my $next_format ( @data_formats ){

   # Prep test dirs and files before each test
   prep_test_tree( $test_dir );

   # Run cf-agent test policy
   chdir 'test/masterfiles' or croak "Cannot cd to test/masterfiles $!";
   my $cf_agent
      = "cf-agent -D test_$next_format,efl_delete_files -Kf ./promises.cf";
   ok( 
      WIFEXITED(
         ( system $cf_agent ) >> 8)
         , "Run efl_delete_files with $next_format"
   );

   # Test the results of cf-agent test policy
   chdir '../serverspec' or croak "Cannot cd to test/serverspec $!";
   my $rspec = "rspec spec/localhost/efl_delete_files.rb >/dev/null";
   ok( WIFEXITED( ( system $rspec ) >> 8), $rspec);

   # Return to original dir
   chdir $start_dir or croak "Cannot cd to $start_dir $!";

   # Remove test files and dir
   remove_tree( $test_dir );
}

done_testing( $number_of_tests );

#
# Subs
#

sub prep_test_tree {
   my $dir = shift;
   my @touch_files;

   # Make sub dirs and build list of files to make
   my @sub_dirs = qw( 01 02 03 );
   my @test_files = qw( a.txt b.txt c.txt c.html );
   for my $next_sub_dir ( @sub_dirs ) {
      make_path( "$dir/$next_sub_dir" );

      for my $next_file ( @test_files ) {
         push @touch_files, "$dir/$next_sub_dir/$next_file";
      }
   }

   # More dirs and files
   make_path( "$dir/04" );
   push @touch_files, "$dir/04/b.json";
   make_path( "$dir/03/sub" );
   push @touch_files, "$dir/03/sub/b.json";

   # Make the files
   touch( @touch_files );

   # Make one more file with specific timestamp
   my $days_old = 2;
   my $day_seconds = 24*60**2;
   my $timestamp = time() - $day_seconds * $days_old;
   my $t = File::Touch->new( time => $timestamp );
   $t->touch( "$dir/04/a.txt" );

   return 1;
}

=pod

=head1 SYNOPSIS

Test efl_delete_files

=head2 Test File layout

=over 3

   /tmp/efl_test/efl_delete_files/
   /tmp/efl_test/efl_delete_files/01
   /tmp/efl_test/efl_delete_files/01/a.txt
   /tmp/efl_test/efl_delete_files/01/b.txt
   /tmp/efl_test/efl_delete_files/01/c.html
   /tmp/efl_test/efl_delete_files/01/c.txt
   /tmp/efl_test/efl_delete_files/02
   /tmp/efl_test/efl_delete_files/02/a.txt
   /tmp/efl_test/efl_delete_files/02/b.txt
   /tmp/efl_test/efl_delete_files/02/c.html
   /tmp/efl_test/efl_delete_files/02/c.txt
   /tmp/efl_test/efl_delete_files/03
   /tmp/efl_test/efl_delete_files/03/a.txt
   /tmp/efl_test/efl_delete_files/03/b.txt
   /tmp/efl_test/efl_delete_files/03/c.html
   /tmp/efl_test/efl_delete_files/03/c.txt
   /tmp/efl_test/efl_delete_files/03/sub
   /tmp/efl_test/efl_delete_files/03/sub/b.json
   /tmp/efl_test/efl_delete_files/04
   /tmp/efl_test/efl_delete_files/04/a.txt # > 1 day old.
   /tmp/efl_test/efl_delete_files/04/b.json

=back

=cut
