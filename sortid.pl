#!/usr/bin/perl -w

# Given a flat directory of MP3s with unreliable filenames,
# sort things into my music layout, renaming as needed

use MP3::Tag;
use File::Copy;
our $do_rename=1;
my $targdir = '/mnt/tears/ericsorted';
main();

##########

sub main
{
opendir(HERE, '.') || die "Could not open present directory!:$!\n";
my @files =
	grep /\.mp3$/,
	readdir(HERE);
closedir(HERE);
if(@ARGV > 0)
	{
	@files = @ARGV;
	}
foreach my $file (sort @files)
	{
	my $tag = MP3::Tag->new($file);
	$tag->get_tags();
	my %info;
	$info{Artist} = 'UNKNOWN';
	$info{Album} = 'misc';
	$info{Title} = 'ERROR';
	$info{Track} = '00';
	my $gotinfo=0;
	if(exists $tag->{ID3v2})
		{
		$gotinfo = 1;
		my $frameref = $tag->{ID3v2}->get_frame_ids();
#		print join(':', keys %$frameref);
		foreach my $key (qw/Artist Album Title Track/)
			{
			my ($value) = $tag->{ID3v2}->get_frame(id3v2_mapframes($key));
			if(defined($value) && ($value ne ''))
				{
				$info{$key} = $value;
				}
			}
		if((! defined($info{Artist})) || ($info{Artist} eq 'UNKNOWN') )
			{
			my ($value) = $tag->{ID3v2}->get_frame(id3v2_mapframes('Artist2'));
			if(defined($value) && ($value ne ''))
				{
				$info{Artist} = $value;
				}
			}
		if((! defined($info{Artist})) || ($info{Artist} eq 'UNKNOWN') )
			{
			my ($value) = $tag->{ID3v2}->get_frame(id3v2_mapframes('Artist3'));
			if(defined($value) && ($value ne ''))
				{
				$info{Artist} = $value;
				}
			}
		}
	elsif(exists $tag->{ID3v1})
		{
		$gotinfo=1;
		foreach my $key (qw/Artist Album Title Track/)
			{
			my $ukey = lc($key);
			my ($value) = $tag->{ID3v1}->$ukey;
			if(defined($value) && (! ref $value) && ($value ne ''))
				{
				$info{$key} = $value;
				}
			}
		}
#	print "File:$file\n";
	print "File:$file\n\tTrack: $info{Track}\n\tArtist:$info{Artist}\n\tAlbum:$info{Album}\n\tTitle:$info{Title}\n";
	$tag->close();
		{
		map{
			$info{$_} = lc($info{$_});
			$info{$_} =~ tr/A-Z -/a-z__/;
			$info{$_} =~ tr/¡יסףü/ienou/;
			$info{$_} =~ tr/ּ//d;
			$info{$_} =~ tr/,\.\?'\*\"<>`\/\\//d;
			$info{$_} =~ s/([\[\]\(\)])$//g;
			$info{$_} =~ tr/][)(:!\$/________/;
			$info{$_} =~ s/_?\&_?/_and_/g;
			$info{$_} =~ s/_?\@_?/_at_/g;
			$info{$_} =~ s/_?\+_?/_and_/g;
			$info{$_} =~ s/#/number_/g;
			$info{$_} =~ s/_?°_?/_degrees/g;
			$info{$_} =~ s/_?=_?/_equals_/g;
			$info{$_} =~ s/_+/_/g;
			} keys(%info);
		my $realtarg = "$targdir/$info{Artist}-$info{Album}";
		if(! -d $realtarg)
			{
			if($realtarg =~ /([^\/0-9A-Za-z_-]+)/)
				{
				die "Please examine $file because I'm confused by it:$realtarg ($1)\n";
				}
			if($do_rename)
				{
				mkdir($realtarg) || die "Could not make $realtarg:$!\n";
				}
			else
				{
				print "Would mkdir($realtarg) if not exists\n";
				}
			}
		if($do_rename)
			{
			my $trackpart = '';
			if(defined($info{Track}) && ($info{Track} ne '00'))
				{
				$trackpart = $info{Track} . '-';
				}
			my $targfile = $realtarg . '/' . $trackpart . $info{Title} . '.mp3';
			if($targfile=~ /([^\/0-9A-Za-z_.-]+)/)
				{
				die "Please examine $file because I'm confused by its target filename:$targfile ($1)\n";
				}
			if(-e $targfile)
				{
				warn("Skip file $file because $targfile already exists\n");
				next;
				}
			move($file, $targfile);
			}
		}
	}
}

sub id3v2_mapframes($)
{
my ($logical) = @_;
my %map = 	(
		Track => 'TRCK',
		Album => 'TALB',
		Artist => 'TOPE',
		Artist2 => 'TP1',
		Artist3 => 'TPE1',
		Title => 'TIT2'
		);
if(! defined($map{$logical}))
	{die "Unknown mapframe request for $logical\n";}
return $map{$logical};
}

