# ExtractGraphdb.pm
package MMTests::ExtractGraphdb;
use MMTests::SummariseVariabletime;
use VMR::Stat;
our @ISA = qw(MMTests::SummariseVariabletime);
use strict;

sub new() {
	my $class = shift;
	my $self = {
		_ModuleName  => "ExtractGraphdb",
		_DataType    => MMTests::Extract::DATA_TIME_USECONDS,
		_PlotType    => "simple-filter",
		_ResultData  => []
	};
	bless $self, $class;
	return $self;
}

sub initialise() {
	my ($self, $reportDir, $testName) = @_;
	$self->{_Opname} = "Latency";
	$self->SUPER::initialise($reportDir, $testName);
}

sub extractReport($$$) {
	my ($self, $reportDir, $reportName) = @_;
	my @ops;

	my $start_timestamp;
	my $file = "$reportDir/noprofile/graphdb.log";
	die if ! -e "$reportDir/noprofile/graphdb.log";

	open(INPUT, "sort -n $file|");
	while (!eof(INPUT)) {
		my $line = <INPUT>;


		next if ($line !~ /[0-9]* [a-z]* [0-9]*$/);
		my ($timestamp, $op, $latency) = split(/\s+/, $line);
		next if ($timestamp > 2000000000000000);
		next if ($latency > 300000000);

		if ($start_timestamp == 0) {
			$start_timestamp = $timestamp;
		}


		push @{$self->{_ResultData}}, [ $op, $timestamp - $start_timestamp, $latency ];
	}

	$self->{_Operations} = [ "read", "write", "mmap", "munmap" ];
	close INPUT;
}

1;
