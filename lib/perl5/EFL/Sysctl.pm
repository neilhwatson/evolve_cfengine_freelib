package EFL::Sysctl;

use strict;
use warnings;
use POSIX qw( WIFEXITED );
use Carp;

my $sysctl_cmd = '/sbin/sysctl';
my %sysctl_var;

sub new {
   my ( $class, $arg_ref ) = @_;
   my $self = bless {}, $class;

   $sysctl_cmd = '/sbin/sysctl';

   $sysctl_var{$self} = $arg_ref->{variable}
      || croak q{
Error Setting variable => is required when contructing new class. e.g.
Sysctl->new({ variable => 'vm.swappiness' }); };

   return $self;
}

sub get {
   my $self = shift;
   my ( $sysctl_value )
      = qx{ $sysctl_cmd $sysctl_var{$self} } =~ m/= \s+ (\S+) /mxs;
   return $sysctl_value;
}

sub set {
   my ( $self, $value ) = @_;

   return WIFEXITED(
      ( system "$sysctl_cmd -w $sysctl_var{$self}='$value'" ) >> 8
   );
}

sub DESTROY {
    my $dead_body = $_[0];
    delete $sysctl_var{$dead_body};
    my $super = $dead_body->can("SUPER::DESTROY");
    goto &$super if $super;
}

1;

=pod

=head1 NAME

Sysctl

=head1 SYNOPSIS

A module used to get or set sysctl settings.

   my $vm_swappiness = Sysctl->new({ variable => 'vm.swappiness' });

   is( $vm_swappiness->get, 60, "vm.swappiness == 60" );
   ok( $vm_swappiness->set( 67 ), "set vm.swappiness = 67" );
   is( $vm_swappiness->get, 67, "vm.swappiness == 67" );
   ok( $vm_swappiness->set( 60 ), "set vm.swappiness = 60" );
   is( $vm_swappiness->get, 60, "vm.swappiness == 60" );

   done_testing;

=cut
