#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use POSIX qw/ WIFEXITED /;
use Cwd;
use Carp;
use File::Path qw/ make_path remove_tree /;
use File::Touch;

# If you change this dir you must also change efl_data/efl_link.csv and
# efl_link.rb
my $test_dir = '/tmp/efl_test/';
my $link_dir = '/var/tmp/efl_test/';
my $start_dir = getcwd();

my @data_formats = qw/ csv json /;
my $number_of_tests = scalar @data_formats * 2;

for my $next_format ( @data_formats ){

   # Prep test dirs and files before each test
   make_path( $test_dir );
   make_path( $link_dir );
   prep_test_tree( $test_dir );

   # Run cf-agent test policy
   chdir 'test/masterfiles' or croak "Cannot cd to test/masterfiles $!";
   ok( 
      WIFEXITED(
         ( system
            "cf-agent -D test_$next_format,efl_link -Kf ./promises.cf" )
            >> 8), "Run efl_link with $next_format"
   );

   # Test the results of cf-agent test policy
   chdir '../serverspec' or croak "Cannot cd to test/serverspec $!";
   my $rspec = "rspec spec/localhost/efl_link.rb >/dev/null";
   ok( WIFEXITED( ( system $rspec ) >> 8), $rspec);

   # Return to original dir
   chdir $start_dir or croak "Cannot cd to $start_dir $!";

   remove_tree( $test_dir );
   remove_tree( $link_dir );
}

done_testing( $number_of_tests );

#
# Subs
#
sub prep_test_tree {
   my $dir = shift;

   my @files;
   for my $next_file ( qw/ 01 02 03 / ) {
      push @files, "$dir/$next_file";
   }
   touch @files;
}

=pod

=head1 SYNOPSIS

Test bundle efl_link

=cut
