#!/usr/bin/perl

use strict;
use warnings;

use Carp;
use Cwd;
use Data::Dumper;
use lib './lib/perl5';
use EFL::Apt;
use EFL::Yum;
use EFL::StdOpts;
use English qw/ -no_match_vars/;
use Getopt::Long;
use POSIX qw( WIFEXITED );
use Pod::Usage;
use Test::More;
use feature qw/say/;
my $VERSION = 1;

#
# Subs
#
sub _get_cli_args {

   # Bundles that we can test
   my $allowed_bundles_ref
      = [ qw/ efl_packages efl_packages_via_cmd efl_packages_new /];

   # Define ways to valid your arguments using anonymous subs or regexes.
   my $valid_arg_ref = {
      bundles => {
         constraint => sub {
            my $bundles_ref = shift;

            # Create hash keys of allowed bundles
            my %allowed_bundles;
            @allowed_bundles{ @{ $allowed_bundles_ref } } = ();

            # Collect bundles if they are not allowed bundles
            my @invalid_bundles
               = grep { ! exists $allowed_bundles{$_} } @{ $bundles_ref };

            # Return undef is there are unallowed bundles
            return if @invalid_bundles;

            # Else return ok
            return 1;
         },
         error => 'Bundles must be efl_packages,'
            . ' efl_packages_via_cmd, or efl_packages_new',
      },
   };

   # Get standard options, that all progs should have, from reusable module
   my $options = StdOpts->new();
   my $std_cli_arg_ref = $options->get_standard_args;

   # Set default CLI args here. Getopts will override.
   my $cli_arg_ref = { };

   # Read, process, and validate cli args
   GetOptions(
      $cli_arg_ref,
      %{ $std_cli_arg_ref },
      'bundles=s@',
      'dumpargs',
   );

   # Default to testing all allowed bundles if cli provides none.
   $cli_arg_ref->{bundles} = exists $cli_arg_ref->{bundles}
      ? $cli_arg_ref->{bundles} : $allowed_bundles_ref;

   # Dumps args and exit when asked.
   if ( $cli_arg_ref->{dumpargs} ) {
      say Dumper( $cli_arg_ref );
      exit;
   }

   # Futher, more complex cli arg validation
   _validate_cli_args({
         cli_inputs   => $cli_arg_ref,
         valid_inputs => $valid_arg_ref
   });

   return $cli_arg_ref;
}

sub _validate_cli_args {
   my ( $arg )     = @_;
   my $cli         = $arg->{cli_inputs};
   my $valid_input = $arg->{valid_inputs};
   my $errors      = q{};

   # Process cli args and test against the given contraint
   for my $arg ( keys %{ $cli }) {
      if ( defined $valid_input->{$arg} ) {
         my $constraint = $valid_input->{$arg}->{constraint};
         my $error      = $valid_input->{$arg}->{error};
         my $ref        = ref $constraint;

         # Test when constraint is a code reference.
         if ( $ref eq 'CODE' ) {
            $errors
            .= "\n" . $error unless ( ${constraint}->( $cli->{$arg} ) );
         }

         # Test when contraint is a regular expression.
         elsif ( $ref eq 'Regexp' ) {
            $errors .= "\n" . $error unless ( $cli->{$arg} =~ $constraint );
         }
      }
   }

   # Report any invalid cli args 
   pod2usage( -msg => 'Error '.$errors, -exitval => 2 ) if length $errors > 0;

   return 1;
}

#
# Testing
#
sub _run_tests {

   # Define test subs and sub arguments.
   my %test = (
      # Name test 't\d\d' to ensure order
      t01 => {
         name => \&_test_doc_help,
         arg  => q{},
      },
      t02 => {
         name => \&_test_doc_usage,
         arg  => q{},
      },
      t03 => {
         name => \&_test_doc_examples,
         arg  => q{},
      },
      t04 => {
         name => \&_test_cli_wrong_bundle,
         arg  => 'efl_packages_not',
      },
   );
   my $number_of_tests = keys %test;

   # Run tests in order
   for my $next_test ( sort keys %test ) {
      $test{$next_test}->{name}->( $test{$next_test}->{arg} );
   }

   done_testing( $number_of_tests );

   return;
}

# Test that program returns general help
sub _test_doc_help {

   # Get command output
   my $returned_text = qx{ $PROGRAM_NAME -? };

   # Test command oupput
   like( $returned_text, qr{ Options: .+ test }xims
      , "[$PROGRAM_NAME] -h, for help" );

   return;
}

# Test that program returns usage
sub _test_doc_usage {
   
   # Get command output
   my $returned_text = qx/ $PROGRAM_NAME -u /;

   # Test command oupput
   like( $returned_text, qr{ Usage .+ usage }ixms
      , "[$PROGRAM_NAME] -u, for usage." );

   return;
}

# Test that examples documentation is returned
sub _test_doc_examples {

   # Get command output
   my $returned_text = qx/ $PROGRAM_NAME -e /;

   # Test command oupput
   like( $returned_text, qr{ Examples: .+ }ixms
      , "[$PROGRAM_NAME] -e, for examples." );

   return;
}

# Test when bundle option is wrong
sub _test_cli_wrong_bundle{
   my $arg = shift;

   # Get command output
   my $returned_text = qx{ $PROGRAM_NAME -bundles '$arg' 2>&1 };

   # Test command oupput
   like( $returned_text, qr{ Error \s+ bundles \s+ must \s+ be }xmis,
      'Error message from wong bundle arg');

   return;
}

#
# Main matter
#
my $cli_arg_ref = _get_cli_args();

my $start_dir = getcwd();
my @data_formats = qw/ csv json /;
my @package_bundles = @{ $cli_arg_ref->{bundles} };
my $number_of_tests = scalar @data_formats * scalar @package_bundles * 2;

my $yum = qx{ which yum 2> /dev/null };
my $apt = qx{ which apt-get 2> /dev/null };
my $pkg;

if ( $yum ){
   $pkg = EFL::Yum->new();
}
elsif ( $apt ){
   $pkg = EFL::Apt->new();
}
else {
   croak "Cannot find yum or apt";
}

for my $next_format ( @data_formats ){
   for my $next_bundle ( @package_bundles ) {

      # Prep by installing or removing packages. Currently supports Debian
      # only.
      # install nano
      # remove e3
      $pkg->install( 'nano' ) or croak "Test prep: cannot install nano";
      $pkg->remove( 'e3' )    or croak "Test prep: cannot remove e3";

      # Run cf-agent test policy
      chdir 'test/masterfiles' or croak "Cannot cd to test/masterfiles $!";
      my $cf_agent
         = "cf-agent -D test_$next_format,$next_bundle -Kf ./promises.cf";
      ok( 
         WIFEXITED( ( system $cf_agent ) >> 8 )
            , "Run $next_bundle with $next_format" 
      );

      # Test the results of cf-agent test policy
      chdir '../serverspec' or croak "Cannot cd to test/serverspec $!";
      my $rspec = "rspec spec/localhost/efl_packages.rb >/dev/null";
      ok( WIFEXITED( ( system $rspec ) >> 8), $rspec);

      # Return to original dir
      chdir $start_dir or croak "Cannot cd to $start_dir $!";
   }
}

done_testing( $number_of_tests );

=pod

=head1 SYNOPSIS

Test efl_packages, efl_packages_new, and efl_packages_via_cmd. This is
determined by the cli arg [-b|--bundle]

efl_packages.t  [-v|--version], [-h|-?|--help], [-u|--usage ], [-t|--test],
[-d|--dumpargs] [-b|--bundles] <bundles1>,<bundle2>

=head1 OPTIONS

=over 4

=item
[-t|--test]
Run test suite for developing this application.

=item
[-d|--dumpargs]
Dump cli args to stdout for development testing.

=item
[-b|--bundle] <bundle_to_test>
Bundles to test. Defaults to package all bundles.

=back

=head1 EXAMPLES

=over 3

=item Test bundle efl_packages_new

   efl_packages --bundle efl_packages_new

=item via prove

   prove t/efl_packages :: --bundle  efl_packages_new

=back 
