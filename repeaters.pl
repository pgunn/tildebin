#!/usr/bin/perl -w

use strict;

open(DICT, "/usr/share/dict/words") || die "Failed to open dictionary:$!\n";
while(<DICT>)
	{ # Normally we'd want to chomp the newlines out, but in this case we're ok printing them back
	if($_ =~ /(\w)\1(\w)\2(\w)\3/)
		{
		print "$_";
		}
	}
close(DICT);

