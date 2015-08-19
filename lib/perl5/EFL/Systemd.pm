package EFL::Systemd;

use strict;
use warnings;
use POSIX qw( WIFEXITED );
use Carp;

my $systemctl;

sub new {
   my ( $class, $arg_ref ) = @_;
   my $self = bless {}, $class;

   $systemctl = qx{ which systemctl };
   chomp $systemctl;
   croak "Cannot find systemctl command" unless -e $systemctl;

   return $self;
}

sub enable {
   my ($self, $service ) = @_; 

   return WIFEXITED(
      ( system "$systemctl enable $service > /dev/null 2>&1" ) >> 8 );

   return
}

sub disable {
   my ($self, $service ) = @_; 

   return WIFEXITED(
      ( system "$systemctl disable $service > /dev/null 2>&1" ) >> 8 );

   return
}

sub is_enabled {
   my ($self, $service ) = @_; 

   return WIFEXITED(
      ( system "$systemctl is-enabled $service > /dev/null 2>&1" ) >> 8 );

   return
}

1;

=pod

=head1 NAME

Systemd

=head1 SYNOPSIS

A module used to enable, disable, or check is-enabled service using systemd.

   my $systemd = EFL::Systemd->new();

   $systemd->enable( "ntp" );
   $systemd->disable( "ntp" );
   $systemd->is_enabled( "ntp" );

=cut
