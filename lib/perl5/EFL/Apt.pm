package EFL::Apt;

use strict;
use warnings;
use POSIX qw( WIFEXITED );
use Carp;

my $apt_cmd;

sub new {
   my ( $class ) = @_;
   my $self = bless {}, $class;

   $apt_cmd = '/usr/bin/apt-get -qq --yes';

   return $self;
}

sub install {
   my ( $self, $package ) = @_;

   return WIFEXITED( ( system "$apt_cmd install $package" ) >> 8);
}

sub remove{
   my ( $self, $package ) = @_;

   return WIFEXITED( ( system "$apt_cmd remove $package" ) >> 8);
}


sub DESTROY {
    my $dead_body = $_[0];
    my $super = $dead_body->can("SUPER::DESTROY");
    goto &$super if $super;
}

1;

=pod

=head1 NAME

Apt

=head1 SYNOPSIS

A module to remove or install packages via apt.

   my $apt->new()

   my $return = apt->remove( 'nano' );
   my $return = apt->install( 'nano );

=cut
