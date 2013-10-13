#!/usr/bin/perl 

use strict;
use File::Copy;
my $audioname = '/tmp/audiodump.wav';
main(@ARGV);

#################
# audio_to_mp3.pl
#	Convert anything mplayer can play into an mp3
#	Please please be in the same directory as where you want
#	the target file(s) to land
#	There is a *lot* of room for improvement in this:
#
#	1) Figure out path stuff
#	4) --help
#################

sub main
{
my @files = @ARGV;

ensure_safe();
map {if(! -f $_) {die "File [$_] not found\n";} } @files;
map	{
	my $fn = $_;
	my $targfn = $fn;
	$targfn =~ s/^(.*)\.(.*?)$/\1.mp3/;
	`mplayer -vo none -ao pcm:file=$audioname "$fn"`;
	`lame $audioname "$targfn"`;
	unlink($audioname);
	} @files;
}

sub ensure_safe
{
if(-f $audioname)
	{die "Cannot write temporary file [$audioname] - already exists!\n";}
}

