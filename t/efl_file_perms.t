#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use File::Path qw/ make_path remove_tree /;
use POSIX qw/ WIFEXITED /;
use Cwd;
use Carp;

# If you change this dir you must also change efl_data/efl_file_perms.csv
my $test_dir = '/tmp/efl_test/efl_file_perms';
my $start_dir = getcwd();

my @data_formats = qw/ csv json /;
my $number_of_tests = scalar @data_formats * 2;

for my $next_format ( @data_formats ){

   # Prep test dirs and files before each test
   remove_tree( $test_dir );
   prep_test_tree( $test_dir );

   # Run cf-agent test policy
   chdir 'test/masterfiles' or croak "Cannot cd to test/masterfiles $!";
   ok( 
      WIFEXITED(
         ( system
            "cf-agent -D test_$next_format,efl_file_perms -Kf ./promises.cf" )
            >> 8), "Run efl_file_perms with $next_format"
   );

   # Test the results of cf-agent test policy
   chdir '../serverspec' or croak "Cannot cd to test/serverspec $!";
   my $rspec = "rspec spec/localhost/efl_file_perms.rb >/dev/null";
   ok( WIFEXITED( ( system $rspec ) >> 8), $rspec);

   # Return to original dir
   chdir $start_dir or croak "Cannot cd to $start_dir $!";
}

done_testing();

#
# Subs
#

sub touch {
   my $file = shift;
   my $now = time;

   unless ( utime ($now, $now, $file) ){

      my $touch_file;
      unless ( open ( $touch_file , '>>', $file) ){
         warn "Cannot touch [$file} $!";
         return;
      }
      close $touch_file;
   }
   else{
      warn "Cannot touch [$file} $!";
      return;
   }
   return 1;
} 

sub prep_test_tree {
      my $dir = shift;

   make_path( $dir, {
      mode => 444,
      owner => 12000,
      group => 12000
   });

   make_path( "$dir/sub", {
      mode => 600,
      owner => 12000,
      group => 12000
   });

   for my $next_dir ( qw/ a b d / ) {
      touch( "$dir/$next_dir" );
   }
}

=pod

=head1 SYNOPSIS

Test bundle efl_file_perms

=cut