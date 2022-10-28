#!/usr/bin/perl -w
#
# Script to create a 2D terrain of nodes
#
# modified copy of https://github.com/rainbow-src/sensors/tree/master/terrain%20generators

use strict;
use Math::Random;

(@ARGV==3) || die "usage: $0 <terrain_side_size_(m)> <num_of_nodes> <num_of_gateways>\ne.g. $0 1000 1000 10\n";

my $tx = $ARGV[0];
my $nodes = $ARGV[1];
my $gws = $ARGV[2];

($tx < 1) && die "grid side must be higher than 1 meters!\n";
($nodes < 1) && die "number of nodes must be higher than 1!\n";

my @sensors;
my @gws;
my %coords;

for(my $i=1; $i<=$gws; $i++){
	my ($x, $y) = (int(rand($tx*10)), int(rand($tx*10)));
	($x, $y) = ($x/10, $y/10);
	while (exists $coords{$x}{$y}){
		($x, $y) = (int(rand($tx*10)), int(rand($tx*10)));
		($x, $y) = ($x/10, $y/10);
	}
	$coords{$x}{$y} = 1;
	push(@gws, [$x, $y]);
}
# split $nodes to $gws equal parts
my %n_per_gw = ();
for (my $i=0; $i<$gws; $i+=1){
	$n_per_gw{$i} = $nodes / (scalar @gws);
}
for (my $i=0; $i<($nodes%$gws); $i+=1){
	$n_per_gw{$i} += 1;
}
my $g = 0;
my $sd = $tx/4;
foreach my $gw (@gws){
	my ($x, $y) = @$gw;
	for(my $i=1; $i<=$n_per_gw{$g}; $i++){
		my ($nx, $ny) = ( int(random_normal(1, $x, $sd)), int(random_normal(1, $y, $sd)) );
		while ((exists $coords{$nx}{$ny}) || ($nx < 0) || ($nx > $tx) || ($ny < 0) || ($ny > $tx)){
			($nx, $ny) = ( int(random_normal(1, $x, $sd)), int(random_normal(1, $y, $sd)) );
		}
		$coords{$nx}{$ny} = 1;
		push(@sensors, [$nx, $ny]);
	}
	$g += 1;
}


printf "# terrain map [%i x %i]\n", $tx, $tx;
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
printf "# stats: nodes=%i gateways=%i terrain=%.1fm^2 node_sz=%.2fm^2\n", scalar @sensors, scalar @gws, $tx*$tx, 0.1 * 0.1;
