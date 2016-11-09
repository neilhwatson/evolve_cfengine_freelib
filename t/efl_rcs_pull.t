#!/usr/bin/perl

use strict;
use warnings;
use POSIX qw/ WIFEXITED /;
use Cwd;
use Git::Repository;
use File::Copy qw/ copy /;
use File::Path qw/ make_path remove_tree /;
use feature 'say';
use Test::More;
use Carp;

my $start_dir = getcwd();
my $version   = '3.7';
my $repo      = '/tmp/efl_test/efl_rcs_pull/repo';
my $clone     = '/tmp/efl_test/efl_rcs_pull/clone';
my $src       = "masterfiles/lib/EFL";
my $file      = "efl_update.cf";
my $bundle    = 'efl_rcs_pull';
my @tests     = (
   {
      name    => "$bundle clone fresh using csv data.",
      subtest => sub { new_clone({ Dclass => "test_csv,$bundle" }) },
   },
   {
      name    => "$bundle clone fresh using json data.",
      subtest => sub { new_clone({ Dclass => "test_json,$bundle" }) },
   },
   {
      name    => "$bundle pull using csv data.",
      subtest => sub { update_clone({ Dclass => "test_csv,$bundle" }) },
   },
   {
      name    => "$bundle pull using json data.",
      subtest => sub { update_clone({ Dclass => "test_json,$bundle" }) },
   },
   {
      name    => "$bundle repair clone using csv data.",
      subtest => sub { repair_clone({ Dclass => "test_csv,$bundle" }) },
   },
   {
      name    => "$bundle repair clone using json data.",
      subtest => sub { repair_clone({ Dclass => "test_json,$bundle" }) },
   },
);

my $number_of_tests = scalar @tests;

make_repo({ repo => $repo, add_file => $file, from_src => $src });

for my $next_test ( @tests ) {

   subtest $next_test->{name} => $next_test->{subtest};
}

done_testing( $number_of_tests );

#
# subs 
#
sub make_repo {

   my ( $arg_ref ) = @_;
   my $repo = $arg_ref->{repo};
   my $file = $arg_ref->{add_file};
   my $src  = $arg_ref->{from_src};

   if ( -d $repo ) {
      remove_tree( $repo ) or croak "Cannot remove dir for test repo $!";
   }
   make_path( $repo ) or croak "Cannot make dir for test repo $!";
   copy( "$src/$file", $repo )
      or croak "Cannot copy $src/$file to new test repo $!";

   Git::Repository->run( init => $repo )
      or croak "Cannot init repo $repo $!";
   my $git = Git::Repository->new( work_tree => $repo )
      or croak "Cannot make new git object for $repo $!";

   # Add file
   my $return = 0;
   $git->run( add => $file );
   $return = $? >> 8;
   croak "Cannot add new files to git $repo $!" if $return > 0;

   # Commit changes
   $git->run( commit => '-m', 'add new file' );
   $return = $? >> 8;
   croak "Cannot commit to git $repo $!" if $return > 0;

   return 1;
}

sub new_clone {
   my ( $arg_ref ) = @_;
   my $Dclass = $arg_ref->{Dclass};

   croak "No Dlcass provided" unless $Dclass;

   run_agent_and_test({ Dclass => $Dclass });

   return 1;
}

sub repair_clone {
   my ( $arg_ref ) = @_;
   my $Dclass = $arg_ref->{Dclass};

   croak "No Dlcass provided" unless $Dclass;

   remove_tree( "$clone/.git" ) or croak "Cannot remove $clone/.git $!";

   run_agent_and_test({ Dclass => $Dclass });

   return 1;
}

sub update_clone {
   my ( $arg_ref ) = @_;
   my $Dclass = $arg_ref->{Dclass};

   croak "No Dlcass provided" unless $Dclass;

   my $git = Git::Repository->new( work_tree => $repo )
      or croak "Cannot create git object for $repo $!";

   open( my $update_file, '>>', "$repo/$file")
      or croak "Cannot open $repo/$file $!";
   say $update_file "This is a new line to trigger a commit";
   close $update_file;

   $git->run( commit => '-am', "Modify $file for testing" );
      my $return = $? >> 8;
      croak "Cannot commit to git $repo $!" if $return > 0;

   run_agent_and_test({ Dclass => $Dclass });

   return 1;
}

sub run_agent_and_test {
   my ( $arg_ref ) = @_;
   my $Dclass = $arg_ref->{Dclass};

   croak "No Dlcass provided" unless $Dclass;

   # Run cf-agent test policy
   chdir 'test/masterfiles' or croak "Cannot cd to test/masterfiles $!";
   my $cf_agent = "cf-agent -D $Dclass -Kf ./promises.cf";
   ok( WIFEXITED( ( system $cf_agent ) >> 8), "Pull or new clone" );

   # Test the results of cf-agent test policy
   chdir '../serverspec' or croak "Cannot cd to test/serverspec $!";
   my $rspec = "rspec spec/localhost/$bundle.rb >/dev/null";
   ok( WIFEXITED( ( system $rspec ) >> 8), $rspec);

   # Return to original dir
   chdir $start_dir or croak "Cannot cd to $start_dir $!";

   return 1;
}


=pod

=head1 SYNOPSIS

Testing efl_rcs_pull

=cut
