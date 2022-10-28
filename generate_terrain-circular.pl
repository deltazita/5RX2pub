#!/usr/bin/perl -w
#
# Script to create a 2D terrain of nodes
#
# modified copy of https://github.com/rainbow-src/sensors/tree/master/terrain%20generators

use strict;
use Math::Random;

(@ARGV==2) || die "usage: $0 <num_of_nodes> <num_of_gateways>\ne.g. $0 500 10\n";

my $nodes = $ARGV[0];
# my $gws = $ARGV[1];
my $gws = 1;

($nodes < 1) && die "number of nodes must be higher than 1!\n";

my @sensors;
my @gws;
my %coords;
my @sensis = ([7,-124,-122,-116], [8,-127,-125,-119], [9,-130,-128,-122], [10,-133,-130,-125], [11,-135,-132,-128], [12,-137,-135,-129]);
my $var = 3.57; # variance
my ($dref, $Lpld0, $gamma) = (40, 110, 2.08); # attenuation model parameters
my $bw = 125000; # channel bandwidth
my $bwi = bwconv();
my $r = 10**( (14 - 10 - $sensis[12-7][$bwi] - $Lpld0 - $var*0)/(10*$gamma) ) * $dref;
for(my $i=1; $i<=$nodes; $i++){
# 	my ($x, $y) = (int(rand(2*$r*10)), int(rand(2*$r*10)));
	my ($x, $y) = (random_uniform_integer(1, 0, 2*$r*10), random_uniform_integer(1, 0, 2*$r*10));
	($x, $y) = ($x/10, $y/10);
	while ( (exists $coords{$x}{$y}) || (distance($x, $r, $y, $r) > $r) ){
# 		($x, $y) = (int(rand(2*$r*10)), int(rand(2*$r*10)));
		($x, $y) = (random_uniform_integer(1, 0, 2*$r*10), random_uniform_integer(1, 0, 2*$r*10));
		($x, $y) = ($x/10, $y/10);
	}
	$coords{$x}{$y} = 1;
	push(@sensors, [$x, $y]);
}
# for(my $i=1; $i<=$gws; $i++){
# 	my ($x, $y) = (int(rand(2*$r*10)), int(rand(2*$r*10)));
# 	($x, $y) = ($x/10, $y/10);
# 	while (exists $coords{$x}{$y}){
# 		($x, $y) = (int(rand(2*$r*10)), int(rand(2*$r*10)));
# 		($x, $y) = ($x/10, $y/10);
# 	}
# 	$coords{$x}{$y} = 1;
# 	push(@gws, [$x, $y]);
# }
@gws = ([$r, $r]);


printf "# terrain map [%i x %i]\n", $r, $r;
print "# node coords:";
my $n = 1;
foreach my $s (@sensors){
	my ($x, $y) = @$s;
	printf " %s [%.1f %.1f]", $n, $x, $y;
	$n++;
}
print "\n";
print "# gateway coords:";
my $l = "A";
foreach my $g (@gws){
	my ($x, $y) = @$g;
	printf " %s [%.1f %.1f]", $l, $x, $y;
	$l++;
}
print "\n";

print  "# generated with: $0 ",join(" ",@ARGV),"\n";
printf "# stats: nodes=%i gateways=%i terrain=%.1fm^2 node_sz=%.2fm^2\n", scalar @sensors, scalar @gws, 2*$r*2*$r, 0.1 * 0.1;


sub bwconv{
	my $bwi = 0;
	if ($bw == 125000){
		$bwi = 1;
	}elsif ($bw == 250000){
		$bwi = 2;
	}elsif ($bw == 500000){
		$bwi = 3;
	}
	return $bwi;
}

sub distance {
	my ($x1, $x2, $y1, $y2) = @_;
	return sqrt( (($x1-$x2)*($x1-$x2))+(($y1-$y2)*($y1-$y2)) );
}
