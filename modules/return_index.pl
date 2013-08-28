#!/usr/bin/perl

# Prints an ordered number slist useful for ordered indexes.

sub error{
	$err = shift;
	print "Error: $err 
Usage return_index.pl <list var name> <positive integer>
Return Cfengine module array from 0 to given argument";
}

# validate
if ( scalar @ARGV != 2 ){
	error( "Wrong numer of args.");
	exit 1
}

$var_name = $ARGV[0];
$index_length = $ARGV[1];

if ( $index_length !~ m/^\d+$/ ){
	error( "Invalid arguement, integer expected." );
	exit 2
}

# main matter
print "\@$var_name= { ";

foreach $i ( 0 .. ($index_length - 1) ){
	print "'$i'";
	if ( $i < ($index_length - 1)) {
		print ', ';
	}
}

print "}\n";
