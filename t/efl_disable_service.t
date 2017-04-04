#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use lib 'lib/perl5';
use POSIX qw/ WIFEXITED /;
use EFL::Systemd;
use Cwd;
use Carp;

my $start_dir = getcwd();
my $bundle    = 'efl_disable_service';
my $service   = 'efl_test_daemon';
my @tests = (
   {
      name => "$bundle with csv data.",
      Dclass => "test_csv,$bundle",
   },
   {
      name => "$bundle with json data.",
      Dclass => "test_json,$bundle",
   },
);

my $systemd = qx{ which systemctl };
my $chkconfig = qx{ which chkconfig };
chomp $systemd;
chomp $chkconfig;

my $use_systemd   = -e $systemd                         ? 1 : 0;
my $use_chkconfig = -e $chkconfig and $use_systemd == 0 ? 1 : 0;

my $service_control;
my $service_type;
if ( $use_systemd ) {
   $service_type = 'systemd';
   $service_control = EFL::Systemd->new();
}
elsif ( $use_chkconfig ) {
   $service_type = 'chkconfig';
   $service_control = EFL::Chkconfig->new();
}
else {
   croak "Could not use systemd or chkconfig for testing.";
}

my $number_of_tests = 2 * scalar @tests;

for my $next_test ( @tests ) {

   $service_control->enable( $service ) or croak "Cannot disable $service";

   # Run cf-agent test policy
   chdir 'test/masterfiles' or croak "Cannot cd to test/masterfiles $!";
   my $cf_agent = "cf-agent -D $next_test->{Dclass} -Kf ./promises.cf";
   ok( WIFEXITED( ( system $cf_agent ) >> 8), $next_test->{name} );

   ok( ! $service_control->is_enabled( $service )
         , "Test if $service is disabled using $service_type" );

   # Return to original dir
   chdir $start_dir or croak "Cannot cd to $start_dir $!";
}

# We're done, disable the test service.
$service_control->disable( $service );

done_testing( $number_of_tests );

=pod

=head1 SYNOPSIS

A testing efl_disable_service

=cut
