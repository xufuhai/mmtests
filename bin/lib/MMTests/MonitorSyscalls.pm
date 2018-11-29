# MonitorSyscalls.pm
package MMTests::MonitorSyscalls;
use MMTests::Monitor;
use VMR::Stat;
our @ISA = qw(MMTests::Monitor);
use strict;

sub new() {
	my $class = shift;
	my $self = {
		_ModuleName    => "MonitorSyscalls",
		_DataType      => MMTests::Monitor::MONITOR_SYSCALLS,
		_ResultData    => []
	};
	bless $self, $class;
	return $self;
}

sub initialise() {
	my ($self, $reportDir, $testName) = @_;

        my $fieldLength = 24;
        $self->{_FieldLength} = $fieldLength;
	$self->{_FieldFormat} = [ "%-${fieldLength}s", "%-${fieldLength}s", "%${fieldLength}.2f" ];
	$self->{_FieldHeaders} = [ "Source", "Mean" ];
        $self->SUPER::initialise($reportDir, $testName);
}

my %_colMap = (
	"Count"		=> 4,
	"Latency"	=> 5,
);

sub printDataType() {
	my ($self) = @_;
	my $headingIndex = $self->{_HeadingIndex};

	if ($headingIndex == 4) {
		print "Syscall,Count,Events\n";
	} elsif ($headingIndex == 5) {
		print "Syscall,Time,Latency (ms)\n";
	} else {
		print "Unknown\n";
	}
}

my %activity;

sub extractSummary() {
	my ($self, $subHeading) = @_;
	my @data = @{$self->{_ResultData}};

	my $fieldLength = 24;

	my @headers;
	my @summaryRow;
	push @headers, "dummy";
	push @summaryRow, "mean";
	foreach my $thread (sort keys %activity) {
		my @event;

		push @headers, $thread;

		foreach my $rowRef (@data) {
			my @row = @{$rowRef};
			next if ($row[1] ne $thread);

			push @event, $row[2];
		}

		push @summaryRow, calc_mean(@event);
	}

	push @{$self->{_SummaryData}}, \@summaryRow;
	$self->{_SummaryHeaders} = \@headers;

	return 1;
}


sub extractReport($$$$) {
	my ($self, $reportDir, $testName, $testBenchmark, $subHeading, $rowOrientated) = @_;
	my ($reading_before, $reading_after);
	my $elapsed_time;
	my $timestamp;
	my $format;
	my $start_timestamp = 0;

	my ($subHeading, $subSummary) = split(/-/, $subHeading);

	if (!defined $_colMap{$subHeading}) {
		die("Unrecognised heading $subHeading");
	}
	my $headingIndex = $_colMap{$subHeading};
	$self->{_HeadingIndex} = $headingIndex;

	my $file = "$reportDir/syscalls-$testName-$testBenchmark";
	if (-e $file) {
		open(INPUT, $file) || die("Failed to open $file: $!\n");
	} else {
		$file .= ".gz";
		open(INPUT, "gunzip -c $file|") || die("Failed to open $file: $!\n");
	}

	my %totalEvents;

	while (<INPUT>) {
		my $line = $_;
		$line =~ s/^\s+//;

		if ($line =~ /^time: ([0-9]+)/) {
			if ($start_timestamp == 0) {
				$timestamp = $1;
				$start_timestamp = $timestamp;
			} else {
				foreach my $thread (sort keys %totalEvents) {
					push @{$self->{_ResultData}},
						[ $timestamp - $start_timestamp, $thread, $totalEvents{$thread} ];
				}
				$timestamp = $1;
			}
			%totalEvents = ();
			next;
		}

		next if ($line !~ /^[0-9].*/);

		my @elements = split(/\s+/, $line);
		my $thread;
		if ($subSummary eq "thread") {
			$thread = "$elements[3]__$elements[2]-$elements[1]";
		} else {
			$thread = "$elements[3]";
		}
		$totalEvents{$thread} += $elements[$headingIndex];
		$activity{$thread} = 1;
	}
}

1;
