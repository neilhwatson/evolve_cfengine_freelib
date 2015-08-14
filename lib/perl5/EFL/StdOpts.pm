#
# Modules
#
package StdOpts;

use strict;
use warnings;
use feature qw/say/;

sub new {
   my ( $class ) = @_;
   return bless {}, $class;
}

sub get_standard_args {
   my $self = shift;

   my $std_cli_arg_ref = {
      'version'  => sub { say $main::VERSION; exit                        },
      'test'     => sub { main::_run_tests(); exit                        },
      'man'      => sub { main::pod2usage( -verbose => 2, -exitval => 0 ) },

      'help|?'   => sub {
         main::pod2usage( -sections => ['OPTIONS'],  -exitval => 0,
            -verbose => 99)
      },
      'usage'    => sub {
         main::pod2usage( -sections => ['SYNOPSIS'], -exitval => 0,
            -verbose => 99)
      },
      'examples' => sub {
         main::pod2usage( -sections => 'EXAMPLES',   -exitval => 0,
            -verbose => 99)
      },
   };

   return $std_cli_arg_ref;
}

1;

=pod

=head1 NAME

StdOpts - A module to hand standard cli options like man, help, usage, 
version, and examples.

=head1 SYNOPSIS

Std::Opts contains standard CLI options that all your programs and scripts
should contain. In a corporate environment you might separate this module
and install it properly. You could also add to is or extend it with sub 
modules.

Your program will require Getop::long, Data::Dumper, and Pod::Usage. 

   my $options = Std::Opts->new();
   my $std_cli_arg_ref = $options->get_standard_args;

   # Read, process, and validate cli args
   GetOptions(
      $cli_arg_ref,
      %{ $std_cli_arg_ref },

      # Custom args for your program here
      'myarg=s',
      'arg2=i',

   );

=head1 AUTHOR

Neil H. Watson, http://watson-wilson.ca, C<< <neil@watson-wilson.ca> >>

=cut
