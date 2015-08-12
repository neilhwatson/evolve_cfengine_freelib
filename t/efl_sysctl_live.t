#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use POSIX qw/ WIFEXITED /;
use Cwd;
use Carp;
use lib './lib/perl5';
use EFL::Sysctl;

my @data_formats = qw/ csv json /;
my $number_of_tests = scalar @data_formats * 2;
my $start_dir = getcwd();

# Prepare to read and write sysctl's vm.swappiness
my $vm_swappiness = EFL::Sysctl->new({ variable => 'vm.swappiness' });
# Keep original value
my $vms_original = $vm_swappiness->get;

for my $next_format ( @data_formats ){

   # Set sysctl to initial value
   $vm_swappiness->set( 67 );

   # Run cf-agent test policy
   chdir 'test/masterfiles' or croak "Cannot cd to test/masterfiles $!";
   ok( 
      WIFEXITED(
         ( system
            "cf-agent -D test_$next_format,efl_sysctl_live -Kf ./promises.cf" )
            >> 8), "Run efl_sysctl_live with $next_format"
   );

   # Test the results of cf-agent test policy
   is( $vm_swappiness->get, 67, "vm.swappiness == 67" );

   # Return to original dir
   chdir $start_dir or croak "Cannot cd to $start_dir $!";

   # Reset to original value
   $vm_swappiness->set( $vms_original );
}

done_testing();

# Return to original dir
chdir $start_dir or croak "Cannot cd to $start_dir $!";
# Reset to original value
$vm_swappiness->set( $vms_original );

=pod

=head1 SYNOPSIS

Test efl_sysctl_live bundle

=cut
