#!/usr/bin/perl -w

use strict;
# use Statistics::PointEstimation;
use Statistics::Basic qw(:all);

die "usage: $0 <#gateways> <1=circular,2=square terrain> <1=uniform,2=gaussian placement>\n" unless (@ARGV == 3);

my %simulation = ();
my $rando = int(rand(9999999999));
my $file = "/tmp/temp$rando.txt";
my $repeats = 5;
my $gws = $ARGV[0];
my $terrain_side = 1500; # in meters
$terrain_side = 2250 if ($gws > 1);
my $terrain_type = $ARGV[1]; # 1=circular, 2=square
my $placement = $ARGV[2]; # 1=uniform, 2=gaussian

my $test = "./test_connectivity.pl %f";

$simulation{"LoRaWAN"}{"cmdline"} = "./LoRaWAN.pl 12 10000 2 %f %p";
$simulation{"LoRaWAN"}{"sf_pattern"} = 'Avg SF = ([0-9]+\.[0-9]+)';
$simulation{"LoRaWAN"}{"energy_pattern"} = 'Avg node consumption = ([0-9]+\.[0-9]+)';
$simulation{"LoRaWAN"}{"pdr_pattern"} = 'Packet Delivery Ratio = ([0-9]+\.[0-9]+)';
$simulation{"LoRaWAN"}{"prr_pattern"} = 'Packet Reception Ratio = ([0-9]+\.[0-9]+)';
$simulation{"LoRaWAN"}{"dropped_pattern"} = 'Total confirmed packets dropped = ([0-9]+)';
$simulation{"LoRaWAN"}{"rx1_pattern"} = 'No GW available in RX1 = ([0-9]+)';
$simulation{"LoRaWAN"}{"rx2_pattern"} = 'No GW available in RX1 or RX2 = ([0-9]+)';
$simulation{"LoRaWAN"}{"fair_pattern"} = 'Mean downlink fairness = ([0-9]+\.[0-9]+)';
$simulation{"LoRaWAN"}{"stdv_pattern"} = 'Stdv of downlink fairness = ([0-9]+\.[0-9]+)';
$simulation{"LoRaWAN"}{"trans_pattern"} = 'Stdv of unique transmissions = ([0-9]+\.[0-9]+)';

$simulation{"5RX2-SF"}{"cmdline"} = "./LoRaWAN-5RX2-SF.pl 12 10000 2 %f %p";
$simulation{"5RX2-SF"}{"sf_pattern"} = 'Avg SF = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-SF"}{"energy_pattern"} = 'Avg node consumption = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-SF"}{"pdr_pattern"} = 'Packet Delivery Ratio = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-SF"}{"prr_pattern"} = 'Packet Reception Ratio = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-SF"}{"dropped_pattern"} = 'Total confirmed packets dropped = ([0-9]+)';
$simulation{"5RX2-SF"}{"rx1_pattern"} = 'No GW available in RX1 = ([0-9]+)';
$simulation{"5RX2-SF"}{"rx2_pattern"} = 'No GW available in RX1 or RX2 = ([0-9]+)';
$simulation{"5RX2-SF"}{"fair_pattern"} = 'Mean downlink fairness = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-SF"}{"stdv_pattern"} = 'Stdv of downlink fairness = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-SF"}{"trans_pattern"} = 'Stdv of unique transmissions = ([0-9]+\.[0-9]+)';

$simulation{"5RX2-eqNodesperBnd"}{"cmdline"} = "./LoRaWAN-5RX2-eqNodesperBnd.pl 12 10000 2 %f %p";
$simulation{"5RX2-eqNodesperBnd"}{"sf_pattern"} = 'Avg SF = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-eqNodesperBnd"}{"energy_pattern"} = 'Avg node consumption = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-eqNodesperBnd"}{"pdr_pattern"} = 'Packet Delivery Ratio = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-eqNodesperBnd"}{"prr_pattern"} = 'Packet Reception Ratio = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-eqNodesperBnd"}{"dropped_pattern"} = 'Total confirmed packets dropped = ([0-9]+)';
$simulation{"5RX2-eqNodesperBnd"}{"rx1_pattern"} = 'No GW available in RX1 = ([0-9]+)';
$simulation{"5RX2-eqNodesperBnd"}{"rx2_pattern"} = 'No GW available in RX1 or RX2 = ([0-9]+)';
$simulation{"5RX2-eqNodesperBnd"}{"fair_pattern"} = 'Mean downlink fairness = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-eqNodesperBnd"}{"stdv_pattern"} = 'Stdv of downlink fairness = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-eqNodesperBnd"}{"trans_pattern"} = 'Stdv of unique transmissions = ([0-9]+\.[0-9]+)';

$simulation{"5RX2-eqNodesperCh"}{"cmdline"} = "./LoRaWAN-5RX2-eqNodesperCh.pl 12 10000 2 %f %p";
$simulation{"5RX2-eqNodesperCh"}{"sf_pattern"} = 'Avg SF = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-eqNodesperCh"}{"energy_pattern"} = 'Avg node consumption = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-eqNodesperCh"}{"pdr_pattern"} = 'Packet Delivery Ratio = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-eqNodesperCh"}{"prr_pattern"} = 'Packet Reception Ratio = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-eqNodesperCh"}{"dropped_pattern"} = 'Total confirmed packets dropped = ([0-9]+)';
$simulation{"5RX2-eqNodesperCh"}{"rx1_pattern"} = 'No GW available in RX1 = ([0-9]+)';
$simulation{"5RX2-eqNodesperCh"}{"rx2_pattern"} = 'No GW available in RX1 or RX2 = ([0-9]+)';
$simulation{"5RX2-eqNodesperCh"}{"fair_pattern"} = 'Mean downlink fairness = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-eqNodesperCh"}{"stdv_pattern"} = 'Stdv of downlink fairness = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-eqNodesperCh"}{"trans_pattern"} = 'Stdv of unique transmissions = ([0-9]+\.[0-9]+)';

$simulation{"5RX2-eqToAperBnd"}{"cmdline"} = "./LoRaWAN-5RX2-eqToAperBnd.pl 12 10000 2 %f %p";
$simulation{"5RX2-eqToAperBnd"}{"sf_pattern"} = 'Avg SF = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-eqToAperBnd"}{"energy_pattern"} = 'Avg node consumption = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-eqToAperBnd"}{"pdr_pattern"} = 'Packet Delivery Ratio = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-eqToAperBnd"}{"prr_pattern"} = 'Packet Reception Ratio = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-eqToAperBnd"}{"dropped_pattern"} = 'Total confirmed packets dropped = ([0-9]+)';
$simulation{"5RX2-eqToAperBnd"}{"rx1_pattern"} = 'No GW available in RX1 = ([0-9]+)';
$simulation{"5RX2-eqToAperBnd"}{"rx2_pattern"} = 'No GW available in RX1 or RX2 = ([0-9]+)';
$simulation{"5RX2-eqToAperBnd"}{"fair_pattern"} = 'Mean downlink fairness = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-eqToAperBnd"}{"stdv_pattern"} = 'Stdv of downlink fairness = ([0-9]+\.[0-9]+)';
$simulation{"5RX2-eqToAperBnd"}{"trans_pattern"} = 'Stdv of unique transmissions = ([0-9]+\.[0-9]+)';

$simulation{"10pRX1"}{"cmdline"} = "./LoRaWAN-10pRX1.pl 12 10000 2 %f %p";
$simulation{"10pRX1"}{"sf_pattern"} = 'Avg SF = ([0-9]+\.[0-9]+)';
$simulation{"10pRX1"}{"energy_pattern"} = 'Avg node consumption = ([0-9]+\.[0-9]+)';
$simulation{"10pRX1"}{"pdr_pattern"} = 'Packet Delivery Ratio = ([0-9]+\.[0-9]+)';
$simulation{"10pRX1"}{"prr_pattern"} = 'Packet Reception Ratio = ([0-9]+\.[0-9]+)';
$simulation{"10pRX1"}{"dropped_pattern"} = 'Total confirmed packets dropped = ([0-9]+)';
$simulation{"10pRX1"}{"rx1_pattern"} = 'No GW available in RX1 = ([0-9]+)';
$simulation{"10pRX1"}{"rx2_pattern"} = 'No GW available in RX1 or RX2 = ([0-9]+)';
$simulation{"10pRX1"}{"fair_pattern"} = 'Mean downlink fairness = ([0-9]+\.[0-9]+)';
$simulation{"10pRX1"}{"stdv_pattern"} = 'Stdv of downlink fairness = ([0-9]+\.[0-9]+)';
$simulation{"10pRX1"}{"trans_pattern"} = 'Stdv of unique transmissions = ([0-9]+\.[0-9]+)';

my $nodes = 500;
if ($gws > 1){
	$nodes = 1200;
}
for (my $conf=0.1; $conf<=1; $conf+=0.1){
	print STDERR "------------------------------------------\n";
	my %sf = ();
	my %data_sf = ();
	my %energy = ();
	my %data_energy = ();
	my %pdr = ();
	my %data_pdr = ();
	my %prr = ();
	my %data_prr = ();
	my %dropped = ();
	my %data_dropped = ();
	my %rx1 = ();
	my %data_rx1 = ();
	my %rx2 = ();
	my %data_rx2 = ();
	my %fair = ();
	my %data_fair = ();
	my %stdv = ();
	my %data_stdv = ();
	my %trans = ();
	my %data_trans = ();
	
	for (my $i=1; $i<=10; $i++){
		if ($terrain_type == 1){
			system("./generate_terrain-circular.pl $nodes $gws > $file");
		}elsif ($terrain_type == 2){
			if ($placement == 1){
				system("./generate_terrain.pl $terrain_side $nodes $gws > $file");
			}elsif ($placement == 2){
				system("./generate_terrain_gaussian.pl $terrain_side $nodes $gws > $file");
			}
		}
		my $oops = 0;
		
		my $exec = $test;
		$exec =~ s/\%f/$file/;
		my $check = 0;
		while ($check == 0){
			$check = 1;
			my $tests_num = 10;
			for (my $j=1; $j<=$tests_num; $j+=1){
				my $output = `$exec`;
				if ($output =~ /terrain too large/){
					$check = 0;
					$j = $tests_num + 1;
				}
			}
			if ($check == 0){
				if ($terrain_type == 1){
					system("./generate_terrain-circular.pl $nodes $gws > $file");
				}elsif ($terrain_type == 2){
					if ($placement == 1){
						system("./generate_terrain.pl $terrain_side $nodes $gws > $file");
					}elsif ($placement == 2){
						system("./generate_terrain_gaussian.pl $terrain_side $nodes $gws > $file");
					}
				}
			}
		}
		
		foreach my $alg (sort keys %simulation){
			last if ($oops > 0);
			print STDERR "\t $alg : ";
			$sf{$alg} = 0;
			$energy{$alg} = 0;
			$pdr{$alg} = 0;
			$prr{$alg} = 0;
			$dropped{$alg} = 0;
			$rx1{$alg} = 0;
			$rx2{$alg} = 0;
			$fair{$alg} = 0;
			$stdv{$alg} = 0;
			$trans{$alg} = 0;
			my $exec = $simulation{$alg}{"cmdline"};
			
			for (my $j=1; $j<=$repeats; $j++){
				print STDERR "$j ";
				$exec =~ s/\%f/$file/;
				$exec =~ s/\%p/$conf/;
				my $output = `$exec`;
				
				if ($output =~ /terrain too large/){
					$oops = 1;
					$j = $repeats + 1;
					print STDERR "ooops! ";
				}else{
					if ($output =~ /$simulation{$alg}{"sf_pattern"}/){
						$sf{$alg} += $1;
					}
					if ($output =~ /$simulation{$alg}{"energy_pattern"}/){
						$energy{$alg} += $1;
					}
					if ($output =~ /$simulation{$alg}{"pdr_pattern"}/){
						$pdr{$alg} += $1;
					}
					if ($output =~ /$simulation{$alg}{"prr_pattern"}/){
						$prr{$alg} += $1;
					}
					if ($output =~ /$simulation{$alg}{"dropped_pattern"}/){
						$dropped{$alg} += $1;
					}
					if ($output =~ /$simulation{$alg}{"rx1_pattern"}/){
						$rx1{$alg} += $1;
					}
					if ($output =~ /$simulation{$alg}{"rx2_pattern"}/){
						$rx2{$alg} += $1;
					}
					if ($output =~ /$simulation{$alg}{"fair_pattern"}/){
						$fair{$alg} += $1;
					}
					if ($output =~ /$simulation{$alg}{"stdv_pattern"}/){
						$stdv{$alg} += $1;
					}
					if ($output =~ /$simulation{$alg}{"trans_pattern"}/){
						$trans{$alg} += $1;
					}
				}
			}
			print STDERR "done!" if ($oops == 0);
			print STDERR "\n";
		}
		if ($oops == 0){
			foreach my $alg (sort keys %simulation){
				push (@{$data_sf{$alg}}, $sf{$alg}/$repeats);
				push (@{$data_energy{$alg}}, $energy{$alg}/$repeats);
				push (@{$data_pdr{$alg}}, $pdr{$alg}/$repeats);
				push (@{$data_prr{$alg}}, $prr{$alg}/$repeats);
				push (@{$data_dropped{$alg}}, $dropped{$alg}/$repeats);
				push (@{$data_rx1{$alg}}, $rx1{$alg}/$repeats);
				push (@{$data_rx2{$alg}}, $rx2{$alg}/$repeats);
				push (@{$data_fair{$alg}}, $fair{$alg}/$repeats);
				push (@{$data_stdv{$alg}}, $stdv{$alg}/$repeats);
				push (@{$data_trans{$alg}}, $trans{$alg}/$repeats);
				
				printf STDERR "# %s %.1f %d %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f\n", $alg, $conf, $i, $sf{$alg}/$repeats, $energy{$alg}/$repeats, $pdr{$alg}/$repeats, $prr{$alg}/$repeats, $dropped{$alg}/$repeats, $rx1{$alg}/$repeats, $rx2{$alg}/$repeats, $fair{$alg}/$repeats, $stdv{$alg}/$repeats, $trans{$alg}/$repeats;
			}
		}else{
			$i -= 1;
		}
	}
	
	my %stat_sf = ();
	my %stat_energy = ();
	my %stat_pdr = ();
	my %stat_prr = ();
	my %stat_dropped = ();
	my %stat_rx1 = ();
	my %stat_rx2 = ();
	my %stat_fair = ();
	my %stat_stdv = ();
	my %stat_trans = ();
	foreach my $alg (keys %simulation){
		$stat_sf{$alg}{"mean"} = mean(\@{$data_sf{$alg}});
		$stat_sf{$alg}{"ci-"} = $stat_sf{$alg}{"mean"} - 1.96 * stddev(\@{$data_sf{$alg}})/(sqrt(scalar @{$data_sf{$alg}}));
		$stat_sf{$alg}{"ci+"} = $stat_sf{$alg}{"mean"} + 1.96 * stddev(\@{$data_sf{$alg}})/(sqrt(scalar @{$data_sf{$alg}}));
		
		$stat_energy{$alg}{"mean"} = mean(\@{$data_energy{$alg}});
		$stat_energy{$alg}{"ci-"} = $stat_energy{$alg}{"mean"} - 1.96 * stddev(\@{$data_energy{$alg}})/(sqrt(scalar @{$data_energy{$alg}}));
		$stat_energy{$alg}{"ci+"} = $stat_energy{$alg}{"mean"} + 1.96 * stddev(\@{$data_energy{$alg}})/(sqrt(scalar @{$data_energy{$alg}}));
		
		$stat_pdr{$alg}{"mean"} = mean(\@{$data_pdr{$alg}});
		$stat_pdr{$alg}{"ci-"} = $stat_pdr{$alg}{"mean"} - 1.96 * stddev(\@{$data_pdr{$alg}})/(sqrt(scalar @{$data_pdr{$alg}}));
		$stat_pdr{$alg}{"ci+"} = $stat_pdr{$alg}{"mean"} + 1.96 * stddev(\@{$data_pdr{$alg}})/(sqrt(scalar @{$data_pdr{$alg}}));
		
		$stat_prr{$alg}{"mean"} = mean(\@{$data_prr{$alg}});
		$stat_prr{$alg}{"ci-"} = $stat_prr{$alg}{"mean"} - 1.96 * stddev(\@{$data_prr{$alg}})/(sqrt(scalar @{$data_prr{$alg}}));
		$stat_prr{$alg}{"ci+"} = $stat_prr{$alg}{"mean"} + 1.96 * stddev(\@{$data_prr{$alg}})/(sqrt(scalar @{$data_prr{$alg}}));
		
		$stat_dropped{$alg}{"mean"} = mean(\@{$data_dropped{$alg}});
		$stat_dropped{$alg}{"ci-"} = $stat_dropped{$alg}{"mean"} - 1.96 * stddev(\@{$data_dropped{$alg}})/(sqrt(scalar @{$data_dropped{$alg}}));
		$stat_dropped{$alg}{"ci+"} = $stat_dropped{$alg}{"mean"} + 1.96 * stddev(\@{$data_dropped{$alg}})/(sqrt(scalar @{$data_dropped{$alg}}));
		
		$stat_rx1{$alg}{"mean"} = mean(\@{$data_rx1{$alg}});
		$stat_rx1{$alg}{"ci-"} = $stat_rx1{$alg}{"mean"} - 1.96 * stddev(\@{$data_rx1{$alg}})/(sqrt(scalar @{$data_rx1{$alg}}));
		$stat_rx1{$alg}{"ci+"} = $stat_rx1{$alg}{"mean"} + 1.96 * stddev(\@{$data_rx1{$alg}})/(sqrt(scalar @{$data_rx1{$alg}}));
		
		$stat_rx2{$alg}{"mean"} = mean(\@{$data_rx2{$alg}});
		$stat_rx2{$alg}{"ci-"} = $stat_rx2{$alg}{"mean"} - 1.96 * stddev(\@{$data_rx2{$alg}})/(sqrt(scalar @{$data_rx2{$alg}}));
		$stat_rx2{$alg}{"ci+"} = $stat_rx2{$alg}{"mean"} + 1.96 * stddev(\@{$data_rx2{$alg}})/(sqrt(scalar @{$data_rx2{$alg}}));
		
		$stat_fair{$alg}{"mean"} = mean(\@{$data_fair{$alg}});
		$stat_fair{$alg}{"ci-"} = $stat_fair{$alg}{"mean"} - 1.96 * stddev(\@{$data_fair{$alg}})/(sqrt(scalar @{$data_fair{$alg}}));
		$stat_fair{$alg}{"ci+"} = $stat_fair{$alg}{"mean"} + 1.96 * stddev(\@{$data_fair{$alg}})/(sqrt(scalar @{$data_fair{$alg}}));
		
		$stat_stdv{$alg}{"mean"} = mean(\@{$data_stdv{$alg}});
		$stat_stdv{$alg}{"ci-"} = $stat_stdv{$alg}{"mean"} - 1.96 * stddev(\@{$data_stdv{$alg}})/(sqrt(scalar @{$data_stdv{$alg}}));
		$stat_stdv{$alg}{"ci+"} = $stat_stdv{$alg}{"mean"} + 1.96 * stddev(\@{$data_stdv{$alg}})/(sqrt(scalar @{$data_stdv{$alg}}));
		
		$stat_trans{$alg}{"mean"} = mean(\@{$data_trans{$alg}});
		$stat_trans{$alg}{"ci-"} = $stat_trans{$alg}{"mean"} - 1.96 * stddev(\@{$data_trans{$alg}})/(sqrt(scalar @{$data_trans{$alg}}));
		$stat_trans{$alg}{"ci+"} = $stat_trans{$alg}{"mean"} + 1.96 * stddev(\@{$data_trans{$alg}})/(sqrt(scalar @{$data_trans{$alg}}));
	}
	
	printf "%.1f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\t %.3f\n",
	$conf,
	$stat_sf{"LoRaWAN"}{"mean"}, $stat_sf{"LoRaWAN"}{"ci-"}, $stat_sf{"LoRaWAN"}{"ci+"},
	$stat_energy{"LoRaWAN"}{"mean"}, $stat_energy{"LoRaWAN"}{"ci-"}, $stat_energy{"LoRaWAN"}{"ci+"},
	$stat_pdr{"LoRaWAN"}{"mean"}, $stat_pdr{"LoRaWAN"}{"ci-"}, $stat_pdr{"LoRaWAN"}{"ci+"},
	$stat_prr{"LoRaWAN"}{"mean"}, $stat_prr{"LoRaWAN"}{"ci-"}, $stat_prr{"LoRaWAN"}{"ci+"},
	$stat_dropped{"LoRaWAN"}{"mean"}, $stat_dropped{"LoRaWAN"}{"ci-"}, $stat_dropped{"LoRaWAN"}{"ci+"},
	$stat_rx1{"LoRaWAN"}{"mean"}, $stat_rx1{"LoRaWAN"}{"ci-"}, $stat_rx1{"LoRaWAN"}{"ci+"},
	$stat_rx2{"LoRaWAN"}{"mean"}, $stat_rx2{"LoRaWAN"}{"ci-"}, $stat_rx2{"LoRaWAN"}{"ci+"},
	$stat_fair{"LoRaWAN"}{"mean"}, $stat_fair{"LoRaWAN"}{"ci-"}, $stat_fair{"LoRaWAN"}{"ci+"},
	$stat_stdv{"LoRaWAN"}{"mean"}, $stat_stdv{"LoRaWAN"}{"ci-"}, $stat_stdv{"LoRaWAN"}{"ci+"},
	$stat_trans{"LoRaWAN"}{"mean"}, $stat_trans{"LoRaWAN"}{"ci-"}, $stat_trans{"LoRaWAN"}{"ci+"},
	$stat_sf{"5RX2-SF"}{"mean"}, $stat_sf{"5RX2-SF"}{"ci-"}, $stat_sf{"5RX2-SF"}{"ci+"},
	$stat_energy{"5RX2-SF"}{"mean"}, $stat_energy{"5RX2-SF"}{"ci-"}, $stat_energy{"5RX2-SF"}{"ci+"},
	$stat_pdr{"5RX2-SF"}{"mean"}, $stat_pdr{"5RX2-SF"}{"ci-"}, $stat_pdr{"5RX2-SF"}{"ci+"},
	$stat_prr{"5RX2-SF"}{"mean"}, $stat_prr{"5RX2-SF"}{"ci-"}, $stat_prr{"5RX2-SF"}{"ci+"},
	$stat_dropped{"5RX2-SF"}{"mean"}, $stat_dropped{"5RX2-SF"}{"ci-"}, $stat_dropped{"5RX2-SF"}{"ci+"},
	$stat_rx1{"5RX2-SF"}{"mean"}, $stat_rx1{"5RX2-SF"}{"ci-"}, $stat_rx1{"5RX2-SF"}{"ci+"},
	$stat_rx2{"5RX2-SF"}{"mean"}, $stat_rx2{"5RX2-SF"}{"ci-"}, $stat_rx2{"5RX2-SF"}{"ci+"},
	$stat_fair{"5RX2-SF"}{"mean"}, $stat_fair{"5RX2-SF"}{"ci-"}, $stat_fair{"5RX2-SF"}{"ci+"},
	$stat_stdv{"5RX2-SF"}{"mean"}, $stat_stdv{"5RX2-SF"}{"ci-"}, $stat_stdv{"5RX2-SF"}{"ci+"},
	$stat_trans{"5RX2-SF"}{"mean"}, $stat_trans{"5RX2-SF"}{"ci-"}, $stat_trans{"5RX2-SF"}{"ci+"},
	$stat_sf{"5RX2-eqNodesperBnd"}{"mean"}, $stat_sf{"5RX2-eqNodesperBnd"}{"ci-"}, $stat_sf{"5RX2-eqNodesperBnd"}{"ci+"},
	$stat_energy{"5RX2-eqNodesperBnd"}{"mean"}, $stat_energy{"5RX2-eqNodesperBnd"}{"ci-"}, $stat_energy{"5RX2-eqNodesperBnd"}{"ci+"},
	$stat_pdr{"5RX2-eqNodesperBnd"}{"mean"}, $stat_pdr{"5RX2-eqNodesperBnd"}{"ci-"}, $stat_pdr{"5RX2-eqNodesperBnd"}{"ci+"},
	$stat_prr{"5RX2-eqNodesperBnd"}{"mean"}, $stat_prr{"5RX2-eqNodesperBnd"}{"ci-"}, $stat_prr{"5RX2-eqNodesperBnd"}{"ci+"},
	$stat_dropped{"5RX2-eqNodesperBnd"}{"mean"}, $stat_dropped{"5RX2-eqNodesperBnd"}{"ci-"}, $stat_dropped{"5RX2-eqNodesperBnd"}{"ci+"},
	$stat_rx1{"5RX2-eqNodesperBnd"}{"mean"}, $stat_rx1{"5RX2-eqNodesperBnd"}{"ci-"}, $stat_rx1{"5RX2-eqNodesperBnd"}{"ci+"},
	$stat_rx2{"5RX2-eqNodesperBnd"}{"mean"}, $stat_rx2{"5RX2-eqNodesperBnd"}{"ci-"}, $stat_rx2{"5RX2-eqNodesperBnd"}{"ci+"},
	$stat_fair{"5RX2-eqNodesperBnd"}{"mean"}, $stat_fair{"5RX2-eqNodesperBnd"}{"ci-"}, $stat_fair{"5RX2-eqNodesperBnd"}{"ci+"},
	$stat_stdv{"5RX2-eqNodesperBnd"}{"mean"}, $stat_stdv{"5RX2-eqNodesperBnd"}{"ci-"}, $stat_stdv{"5RX2-eqNodesperBnd"}{"ci+"},
	$stat_trans{"5RX2-eqNodesperBnd"}{"mean"}, $stat_trans{"5RX2-eqNodesperBnd"}{"ci-"}, $stat_trans{"5RX2-eqNodesperBnd"}{"ci+"},
	$stat_sf{"5RX2-eqNodesperCh"}{"mean"}, $stat_sf{"5RX2-eqNodesperCh"}{"ci-"}, $stat_sf{"5RX2-eqNodesperCh"}{"ci+"},
	$stat_energy{"5RX2-eqNodesperCh"}{"mean"}, $stat_energy{"5RX2-eqNodesperCh"}{"ci-"}, $stat_energy{"5RX2-eqNodesperCh"}{"ci+"},
	$stat_pdr{"5RX2-eqNodesperCh"}{"mean"}, $stat_pdr{"5RX2-eqNodesperCh"}{"ci-"}, $stat_pdr{"5RX2-eqNodesperCh"}{"ci+"},
	$stat_prr{"5RX2-eqNodesperCh"}{"mean"}, $stat_prr{"5RX2-eqNodesperCh"}{"ci-"}, $stat_prr{"5RX2-eqNodesperCh"}{"ci+"},
	$stat_dropped{"5RX2-eqNodesperCh"}{"mean"}, $stat_dropped{"5RX2-eqNodesperCh"}{"ci-"}, $stat_dropped{"5RX2-eqNodesperCh"}{"ci+"},
	$stat_rx1{"5RX2-eqNodesperCh"}{"mean"}, $stat_rx1{"5RX2-eqNodesperCh"}{"ci-"}, $stat_rx1{"5RX2-eqNodesperCh"}{"ci+"},
	$stat_rx2{"5RX2-eqNodesperCh"}{"mean"}, $stat_rx2{"5RX2-eqNodesperCh"}{"ci-"}, $stat_rx2{"5RX2-eqNodesperCh"}{"ci+"},
	$stat_fair{"5RX2-eqNodesperCh"}{"mean"}, $stat_fair{"5RX2-eqNodesperCh"}{"ci-"}, $stat_fair{"5RX2-eqNodesperCh"}{"ci+"},
	$stat_stdv{"5RX2-eqNodesperCh"}{"mean"}, $stat_stdv{"5RX2-eqNodesperCh"}{"ci-"}, $stat_stdv{"5RX2-eqNodesperCh"}{"ci+"},
	$stat_trans{"5RX2-eqNodesperCh"}{"mean"}, $stat_trans{"5RX2-eqNodesperCh"}{"ci-"}, $stat_trans{"5RX2-eqNodesperCh"}{"ci+"},
	$stat_sf{"5RX2-eqToAperBnd"}{"mean"}, $stat_sf{"5RX2-eqToAperBnd"}{"ci-"}, $stat_sf{"5RX2-eqToAperBnd"}{"ci+"},
	$stat_energy{"5RX2-eqToAperBnd"}{"mean"}, $stat_energy{"5RX2-eqToAperBnd"}{"ci-"}, $stat_energy{"5RX2-eqToAperBnd"}{"ci+"},
	$stat_pdr{"5RX2-eqToAperBnd"}{"mean"}, $stat_pdr{"5RX2-eqToAperBnd"}{"ci-"}, $stat_pdr{"5RX2-eqToAperBnd"}{"ci+"},
	$stat_prr{"5RX2-eqToAperBnd"}{"mean"}, $stat_prr{"5RX2-eqToAperBnd"}{"ci-"}, $stat_prr{"5RX2-eqToAperBnd"}{"ci+"},
	$stat_dropped{"5RX2-eqToAperBnd"}{"mean"}, $stat_dropped{"5RX2-eqToAperBnd"}{"ci-"}, $stat_dropped{"5RX2-eqToAperBnd"}{"ci+"},
	$stat_rx1{"5RX2-eqToAperBnd"}{"mean"}, $stat_rx1{"5RX2-eqToAperBnd"}{"ci-"}, $stat_rx1{"5RX2-eqToAperBnd"}{"ci+"},
	$stat_rx2{"5RX2-eqToAperBnd"}{"mean"}, $stat_rx2{"5RX2-eqToAperBnd"}{"ci-"}, $stat_rx2{"5RX2-eqToAperBnd"}{"ci+"},
	$stat_fair{"5RX2-eqToAperBnd"}{"mean"}, $stat_fair{"5RX2-eqToAperBnd"}{"ci-"}, $stat_fair{"5RX2-eqToAperBnd"}{"ci+"},
	$stat_stdv{"5RX2-eqToAperBnd"}{"mean"}, $stat_stdv{"5RX2-eqToAperBnd"}{"ci-"}, $stat_stdv{"5RX2-eqToAperBnd"}{"ci+"},
	$stat_trans{"5RX2-eqToAperBnd"}{"mean"}, $stat_trans{"5RX2-eqToAperBnd"}{"ci-"}, $stat_trans{"5RX2-eqToAperBnd"}{"ci+"},
	$stat_sf{"10pRX1"}{"mean"}, $stat_sf{"10pRX1"}{"ci-"}, $stat_sf{"10pRX1"}{"ci+"},
	$stat_energy{"10pRX1"}{"mean"}, $stat_energy{"10pRX1"}{"ci-"}, $stat_energy{"10pRX1"}{"ci+"},
	$stat_pdr{"10pRX1"}{"mean"}, $stat_pdr{"10pRX1"}{"ci-"}, $stat_pdr{"10pRX1"}{"ci+"},
	$stat_prr{"10pRX1"}{"mean"}, $stat_prr{"10pRX1"}{"ci-"}, $stat_prr{"10pRX1"}{"ci+"},
	$stat_dropped{"10pRX1"}{"mean"}, $stat_dropped{"10pRX1"}{"ci-"}, $stat_dropped{"10pRX1"}{"ci+"},
	$stat_rx1{"10pRX1"}{"mean"}, $stat_rx1{"10pRX1"}{"ci-"}, $stat_rx1{"10pRX1"}{"ci+"},
	$stat_rx2{"10pRX1"}{"mean"}, $stat_rx2{"10pRX1"}{"ci-"}, $stat_rx2{"10pRX1"}{"ci+"},
	$stat_fair{"10pRX1"}{"mean"}, $stat_fair{"10pRX1"}{"ci-"}, $stat_fair{"10pRX1"}{"ci+"},
	$stat_stdv{"10pRX1"}{"mean"}, $stat_stdv{"10pRX1"}{"ci-"}, $stat_stdv{"10pRX1"}{"ci+"},
	$stat_trans{"10pRX1"}{"mean"}, $stat_trans{"10pRX1"}{"ci-"}, $stat_trans{"10pRX1"}{"ci+"};
}
unlink "file";
