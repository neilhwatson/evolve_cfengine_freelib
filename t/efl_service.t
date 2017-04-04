#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use File::Copy;
use File::Path qw/ make_path remove_tree /;
use Proc::Killall;
use POSIX qw/ WIFEXITED /;
use Cwd;
use Carp;

my $start_dir = getcwd();

my $test_config     = '/tmp/efl_test/efl_service';
my $config_src      = '/tmp/efl_test/templates/';
my $restart_flag    = $test_config. '/restarted';
my @data_formats    = qw/ csv json /;
my @templates       = qw / none mustache cfe /;
my $number_of_tests
      # Each test* sub is 2 tests.
   = ( scalar @data_formats * scalar @templates * 4 )
      # test_service_start is 2 tests
   + 
   ( scalar @data_formats * 2 );

my $daemon_proc
   = qr{\A /bin/sh \s /tmp/efl_test/efl_test_daemon \z}mxs;

for my $next_format ( @data_formats ){

   for my $next_template ( @templates ) {

      test_service_build({ 
         format   => $next_format,
         template => $next_template });
      test_service_repair({ 
         format   => $next_format,
         template => $next_template });
   }
   test_service_start({ format => $next_format });
}

done_testing( $number_of_tests );

# Ensure service is not running
killall( 'KILL', $daemon_proc );

#
# Subs
#
sub test_service_build {
   my ( $arg_ref ) = @_;
   my $data_format = $arg_ref->{format};
   my $template = defined $arg_ref->{template} ? $arg_ref->{template}
      : 'none';

   unless ( $template =~ m/ (?: none | mustache | cfe ) /misx ) {
      croak "Wrong template format [$template]"
      .". Allowed: none, mustache, or cfe";
   }

   # remove existing test files
   remove_tree( $test_config );

   # Ensure service is not running
   killall( 'KILL', $daemon_proc );

   run_cfagent({ format => $data_format, template => $template });
   test_end_state();

   return;
}

sub test_service_start {
   my ( $arg_ref ) = @_;
   my $data_format = $arg_ref->{format};

   # Ensure service is not running
   killall( 'KILL', $daemon_proc );

   run_cfagent({ format => $data_format });
   test_end_state();

   return;
}

sub test_service_repair {
   my ( $arg_ref ) = @_;
   my $data_format = $arg_ref->{format};
   my $template = defined $arg_ref->{template} ? $arg_ref->{template}
      : 'none';

   unless ( $template =~ m/ (?: none | mustache | cfe ) /misx ) {
      croak "Wrong template format [$template]"
         .". Allowed: none, mustache, or cfe";
   }

   # Damage config file to force repair
   open my $config_file, '>>', "$test_config/config"
      or croak "Cannot open $test_config/config $!";
   say $config_file "This is corrupting data";
   close $config_file;

   # Remove restart flag if there
   my $restart_flag = "$test_config/restarted";
   if ( -e $restart_flag ) {
      unlink $restart_flag or croak "remove $restart_flag file $!";
   }

   run_cfagent({ format => $data_format, template => $template });
   test_end_state();

   return;
}

sub run_cfagent {
   my ( $arg_ref ) = @_;
   my $data_format = $arg_ref->{format};
   my $template = defined $arg_ref->{template} ? $arg_ref->{template}
      : 'none';

   unless ( $template =~ m/ (?: none | mustache | cfe ) /misx ) {
      croak "Wrong template format [$template]"
         .". Allowed: none, mustache, or cfe";
   }

   # Run cf-agent test policy
   chdir 'test/masterfiles' or croak "Cannot cd to test/masterfiles $!";
   my $cf_agent = "cf-agent -D test_$data_format,efl_service,$template "
      ."-Kf ./promises.cf";
   ok( 
      WIFEXITED( ( system $cf_agent ) >> 8)
      , "Run efl_service with classes: "
         . "test_$data_format,efl_service, with template $template"
   );

   return;
}

sub test_end_state {
   # Test the results of cf-agent test policy
   chdir '../serverspec' or croak "Cannot cd to test/serverspec $!";
   my $rspec = "rspec spec/localhost/efl_service.rb";
   ok( WIFEXITED( ( system $rspec ) >> 8), $rspec);

   # Return to original dir
   chdir $start_dir or croak "Cannot cd to $start_dir $!";

   return;
}

=pod

=head1 SYNOPSIS

Test efl_service bundle

=cut
=begin tests

1. Test service build with file copy.
2. Test service build with cfe template.
3. Test service build with mustache template.
4. Test service repair with file copy.
5. Test service repair with cfe template.
6. Test service repair with mustache template.
7. Test service start.

=cut
