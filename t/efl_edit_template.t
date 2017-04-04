#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use POSIX qw/ WIFEXITED /;
use Cwd;
use Carp;

my $start_dir = getcwd();

my $bundle      = 'efl_edit_template';
my $test_config = "/tmp/efl_test/$bundle/config";

my @tests = (
   {
      name => "$bundle with csv data and a cfengine template",
      Dclass => "test_csv,$bundle,cfe",
   },
   {
      name => "$bundle with csv data and a mustache template",
      Dclass => "test_csv,$bundle,mustache",
   },
   {
      name => "$bundle with json data and a cfengine template",
      Dclass => "test_json,$bundle,cfe",
   },
   {
      name => "$bundle with json data and a mustache template",
      Dclass => "test_json,$bundle,mustache",
   },
);

my $number_of_tests = 2 * scalar @tests;

for my $next_test ( @tests ) {

   # Remove promiser file before test begin
   if ( -e $test_config ) {
      unlink $test_config or croak "Cannot remove $test_config $!";
   }

   # Run cf-agent test policy
   chdir 'test/masterfiles' or croak "Cannot cd to test/masterfiles $!";
   my $cf_agent = "cf-agent -D $next_test->{Dclass} -Kf ./promises.cf";
   ok( WIFEXITED( ( system $cf_agent ) >> 8), $next_test->{name} );

   # Test the results of cf-agent test policy
   chdir '../serverspec' or croak "Cannot cd to test/serverspec $!";
   my $rspec = "rspec spec/localhost/$bundle.rb";
   ok( WIFEXITED( ( system $rspec ) >> 8), "$rspec of $next_test->{name}" );

   # Return to original dir
   chdir $start_dir or croak "Cannot cd to $start_dir $!";
}

done_testing( $number_of_tests );

=pod

=head1 SYNOPSIS

Test efl_edit_template bundle

=cut
