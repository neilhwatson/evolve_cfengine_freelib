package EFL::Chkconfig;

use strict;
use warnings;
use POSIX qw( WIFEXITED );
use Carp;

my $chkconfig;

sub new {
   my ( $class, $arg_ref ) = @_;
   my $self = bless {}, $class;

   $chkconfig = qx{ which chkconfig };
   chomp $chkconfig;
   croak "Cannot find chkconfig command" unless -e $chkconfig;

   return $self;
}

sub enable {
   my ($self, $service ) = @_; 

   return WIFEXITED(
      ( system "$chkconfig $service on > /dev/null 2>&1" ) >> 8 );

   return
}

sub disable {
   my ($self, $service ) = @_; 

   return WIFEXITED(
      ( system "$chkconfig $service off > /dev/null 2>&1" ) >> 8 );

   return
}

sub is_enabled {
   my ($self, $service ) = @_; 

   # Chkconfig to check enable status is different on Debian class linuxes
   my $apt_get = qx{ which apt-get };
   chomp $apt_get;
   if ( -e $apt_get ) {
      $chkconfig = "$chkconfig -c";
   }

   return WIFEXITED(
      ( system "$chkconfig $service > /dev/null 2>&1" ) >> 8 );

   return
}

1;

=pod

=head1 NAME

Chkconfig

=head1 SYNOPSIS

A module used to enable, disable, or check is-enabled service using chkconfig.

   my $chkconfig = EFL::Chkconfig->new();

   $chkconfig->enable( "ntp" );
   $chkconfig->disable( "ntp" );
   $chkconfig->is_enabled( "ntp" );

=cut
