#!/usr/bin/env perl

package s;

use strict;
use warnings;

use Getopt::Long;

# This was set to '1' at first, as I remember, but the values aren't updated
# very frequently (?) so 2 seconds worked better?  I think.  They're still
# kind of slurred together a bit, like you'll see differences between two
# values that, when calculated as a rate, gives something beyond what the
# interface could provide (like 2Gbps on gig-E).  So averages are better.  I
# could make the window wider, but I really like the more continuous
# feedback of the faster rate, even knowing it's kinda screwed up.
$s::sleep = 2;
$s::quit = 0;

$s::first_tx_value = -1;
$s::previous_tx_value = 0;

$s::first_rx_value = -1;
$s::previous_rx_value = 0;

$s::adaptive_units = 1;

sub
sig_handler
{
	$s::quit = 1;
}

sub
stats_and_crap
{
	my ($path, $first_value_ref, $previous_value_ref) = @_;

	# So you have to open the file each time or you don't get the right
	# value. Even rewind() doesn't seem to help.
	open NET, $path or die "Couldn't open stats file '$path': $!";
	my $bytes = <NET>;

	chomp $bytes;
	close NET or die "Couldn't close stats file '$path': $!";

	if ($$first_value_ref == -1)
	{
		$$first_value_ref = $bytes;
		$$previous_value_ref = $bytes;

		if (!$s::adaptive_units) {
			return (0, "bps");
		} else {
			return (0, "kbps");
		}
	}

	# NOTE: it *really* is in various flavors of BYTES per second.
	my $diff = $bytes - $$previous_value_ref;
	$$previous_value_ref = $bytes;
	my $rate = $diff / $s::sleep;
	my $unit = "Bps";

	if ($s::adaptive_units)
	{
		# Must sort in reverse size
		if ($rate > 1000000.0)
		{
			$unit = "M" . $unit;
			$rate /= 1000000.0;
		} elsif ($rate > 1000.0)
		{
			$unit = "k" . $unit;
			$rate /= 1000.0;
		}
	} else {
		# units are bits-per-second when not using adaptive units
		$rate *= 8;
		$unit = "bps";
	}

	return ($rate, $unit);
#	printf "$date %16.3f %s\n", $rate, $unit;
}

sub
main
{
	my ($interface, $adaptive_units) = @_;

	my $start_time = time();
	while (!$s::quit)
	{
		my ($tx_rate, $tx_unit) = stats_and_crap("/sys/class/net/$interface/statistics/tx_bytes", \$s::first_tx_value, \$s::previous_tx_value);
		my ($rx_rate, $rx_unit) = stats_and_crap("/sys/class/net/$interface/statistics/rx_bytes", \$s::first_rx_value, \$s::previous_rx_value);

		my $date = `date +"%Y-%m-%d %H:%M:%S"`;
		chomp $date;
		if ($s::adaptive_units)
		{
			printf "$date Tx %8.3f %4s Rx %8.3f %4s\n",
				$tx_rate, $tx_unit,
				$rx_rate, $rx_unit;
		} else
		{
			printf "$date	%12.0f	%12.0f \n", $tx_rate, $rx_rate;
		}
		sleep $s::sleep;
	}
	my $end_time = time();

	my $time_diff =  $end_time - $start_time;

	my $total_tx_bytes = $s::previous_tx_value - $s::first_tx_value;
	my $total_tx_GB = $total_tx_bytes / 1E9;
	my $average_tx = $total_tx_bytes / $time_diff;

	my $total_rx_bytes = $s::previous_rx_value - $s::first_rx_value;
	my $total_rx_GB = $total_rx_bytes / 1E9;
	my $average_rx = $total_rx_bytes / $time_diff;

	print "Ran for $time_diff seconds\n";
	print "Transmitted $total_tx_bytes bytes ($total_tx_GB GB) in total\n";
	print "Received $total_rx_bytes bytes ($total_rx_GB GB) in total\n";
	printf "Average Tx bandwidth: %.3f bytes/sec\n", $average_tx;
	printf "Average Rx bandwidth: %.3f bytes/sec\n", $average_rx;
}

################################################################################
# 
################################################################################

my $interface = "eth0";
GetOptions("units!" => \$s::adaptive_units);

print "Adaptive units: " . ($s::adaptive_units ? "yes" : "no") . "\n";

if (scalar @ARGV > 0)
{
	$interface = shift @ARGV;
}

print "Looking at stats for interface '$interface'\n";

$SIG{INT} = \&sig_handler;
main($interface);
