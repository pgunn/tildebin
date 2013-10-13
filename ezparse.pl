#!/usr/bin/perl -w

my $usetab = "";
# my $usetab = "\t";


while(<>)
{
chomp;
tr/'//d;
@parts = split(/,/,$_,2);
next if($parts[0] =~ /^\!/);
print "===![[$parts[0]]]!===\n";
$body = $parts[1];
$body =~ s/\r//g;
$body =~ s/\\r//g;
$body =~ s/\\n/\n/g;
$body =~ s/\\/'/g;
@body = split(/\n/, $body);
print join("\n", map{$usetab . $_} @body);
print "\n\n";
}


