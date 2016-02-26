package EFL::Yum;

use strict;
use warnings;
use POSIX qw( WIFEXITED );
use Carp;

my $yum_cmd;

sub new {
   my ( $class ) = @_;
   my $self = bless {}, $class;

   $yum_cmd = '/usr/bin/yum -y -q';

   return $self;
}

sub install {
   my ( $self, $package ) = @_;

   return WIFEXITED( ( system "$yum_cmd install $package" ) >> 8);
}

sub remove{
   my ( $self, $package ) = @_;

   return WIFEXITED( ( system "$yum_cmd remove $package" ) >> 8);
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

A module to remove or install packages via yum.

   my $yum->new()

   my $return = yum->remove( 'nano' );
   my $return = yum->install( 'nano );

=cut
