#!usr/bin/perl

# Reads CSV counts in from R with Gencode ENSID as first column
# We then fix this ID, and look up with the ENSEMBL 75 (last hg19) annot
# and write a final file

use strict;

if ($#ARGV != 2)
{
	die "usage perl convert_gencode_genecounts.pl genecounts.csv biomart_ensembl.txt finaloutput.txt";
}

open(IN,"<$ARGV[0]") or die "Unable to open counts.csv file";

open(ENS,"<$ARGV[1]") or die "Unable to open ensemble txt annotation";

open(OUT,">$ARGV[2]") or die "Unable to save output file";

open(MISS,">$ARGV[2].missing") or die "Unable to save output missing file";

my %ensmap = {};

while(<ENS>)
{
	my $line = $_;
	chomp($line);

	my @cols = split("\t",$line);

	#Ensembl Gene ID  	Associated genename / sympbol 			Description

	$ensmap{$cols[0]} = $line;
}
close(ENS);

my $header=0;
while(<IN>)
{
        my $line = $_;
        chomp($line);

	if ($header==0)
	{
		$line =~ s/,/\t/g;
		print OUT "$line\tEnsemblID\tSymbol\tDescription\n";
		$header=1;
		next;
	}

        my @cols = split(",",$line);

	if($cols[0] =~ /^ENSGR/)  #fix specific gencode IDs
	{
		$cols[0] =~ s/^ENSGR/ENSG0/;
	}

	#strip trailing ID characters
	$cols[0] =~ s/\.[0-9]+//;

	#now do the lookup
	if (exists($ensmap{$cols[0]}))
	{
		$line =~ s/,/\t/g;
		print OUT $line."\t".$ensmap{$cols[0]}."\n";		
	}
	else
	{
		# not found in lookup 
		
		#save to missing list
		print MISS "$cols[0]\n";
		
		#save empty extra identifiers to outputs
		print OUT $line."\t\t\t\n";
		
		#die "Unable to find identifier $cols[0] ... aborting\n";
	}
}
		
close(IN);
close(OUT);

