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

my $version         = '3.7';
my $test_config     = '/tmp/efl_test/efl_service_recurse';
my $config_src      = '/tmp/efl_test/efl_service_recurse_src/';
my $restart_flag    = $test_config. '/restarted';
my @data_formats    = qw/ csv json /;
my $number_of_tests = scalar @data_formats * 6;
my $daemon_proc
   = qr{\A /bin/sh \s /tmp/efl_test/efl_test_daemon \z}mxs;


# Prep copy source files
prep_source_files( $config_src );

for my $next_format ( @data_formats ){

   test_service_build({ format => $next_format });
   test_service_start({ format => $next_format });
   test_service_repair({ format => $next_format });
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

   # remove existing test files
   remove_tree( $test_config);

   # Ensure service is not running
   killall( 'KILL', $daemon_proc );

   run_cfagent({ format => $data_format });
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

   # Damage config file to force repair
   open my $config_file, '>>', "$test_config/efl_update.cf"
      or croak "Cannot open $test_config/efl_update.cf $!";
   say $config_file "This is corrupting data";
   close $config_file;

   # Remove restart flag
   unlink "$test_config/restarted"
      or croak "Cannot remove restart flag file $!";

   run_cfagent({ format => $data_format });
   test_end_state();

   return;
}

sub run_cfagent {
   my ( $arg_ref ) = @_;
   my $data_format = $arg_ref->{format};

   # Run cf-agent test policy
   chdir 'test/masterfiles' or croak "Cannot cd to test/masterfiles $!";
   my $cf_agent = "cf-agent -D test_$data_format,efl_service_recurse "
      ."-Kf ./promises.cf";
   ok( 
      WIFEXITED( ( system $cf_agent ) >> 8)
      , "Run efl_service_recurse with $data_format"
   );

   return;
}

sub test_end_state {
   # Test the results of cf-agent test policy
   chdir '../serverspec' or croak "Cannot cd to test/serverspec $!";
   my $rspec = "rspec spec/localhost/efl_service_recurse.rb >/dev/null";
   ok( WIFEXITED( ( system $rspec ) >> 8), $rspec);

   # Return to original dir
   chdir $start_dir or croak "Cannot cd to $start_dir $!";

   return;
}

sub prep_source_files {
   my $dir = shift;

   my @src_files = qw/ efl_common.cf evolve_freelib.cf efl_update.cf /;

   # make source dir for copy_from
   make_path( $dir );

   # Copies files to src dir for testing
   for my $next_file ( @src_files ) {
      copy( "test/masterfiles/lib/$version/EFL/$next_file" , "$dir/" )
         or croak "Cannot copy source file $next_file $!";
   }

   return;
}


=pod

=head1 SYNOPSIS

Test efl_service_recurse bundle

=cut
