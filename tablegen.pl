#!/usr/bin/perl -w

$bcolor = q{#AAACCC};
$title = "My page";
$html_head = qq{<HTML><HEAD><TITLE>$title</TITLE></HEAD><BODY BGCOLOR="} . $bcolor . q{">};
$html_tail = q{</BODY></HTML>};
$sep = q/<TD>/;
$ssep = q/<TH>/;
$rsep = q/<TR>/;
$thead = q/<TABLE border = "1">/;
$ttail = q{</TABLE>};

$myt = getfile("mytable");
open(TARG, ">test.html") || die "Could not open output: $1\n";
print TARG $html_head . $thead;
$myt = alphasort($myt);
transform($myt);
print TARG $ttail . $html_tail;
close(TARG);


sub alphasort
	# Sorts a string, seperated by newlines, back into a string
{
my $grab = shift;
my @holdr = split /\n/,$grab;
return join "\n",
	sort {lc($a) cmp lc($b)} @holdr;
}

sub transform
	# Writes to filehandle TARG table output based on the encoded string it gets
{
my $inpstr = shift;
my @ia = split /\n/, $inpstr;
foreach my $line (@ia)
	{
	next if $line =~ /^\W$/;
	$line =~ s/^/$rsep$sep/;
	$line =~ s/!!/$ssep/g;
	$line =~ s/!/$sep/;
	print TARG $line;
	}
}

sub getfile
	# Reads argument as filename, returns scalar with contents
{
my $fn = shift;
open(FN, $fn) || die "Could not open $fn: $!\n";
local undef $/;
my $rstring = <FN>;
close(FN);
return $rstring;
}
