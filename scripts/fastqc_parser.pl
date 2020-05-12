#!/usr/bin/perl

use strict;

if ($#ARGV!=0)
{
        die "Usage: fastqc_parser <directory>\n"
}

my $dirname = $ARGV[0];
my $fcount = 0;
my %basic_stats = {};
my %per_base_quality = {};
my %per_tile_quality = {};
my %per_seq_quality = {};
my %per_base_seq_content = {};
my %per_base_gc = {};
my %per_base_n = {};
my %seq_length_dist = {};
my %seq_dupl = {};
my %over_seq = {};
my %adapter_content = {};
my %kmer_content = {};



if (-e $dirname)
{
        #ls files and redirect stderr to stdout
        my @files = `ls -1 $dirname/*_fastqc.zip 2>&1`;
        if ($files[0] =~ /cannot access/)
        {
                print "There does not appear to be any _fastqc.zip files in the specified directory\n";
                exit(0);
        }
        foreach my $f (@files)
        {
                #print "$f\n"unzip -c $f $fastqtext.txt 2>&1
                chomp($f); #as it has \n on the end

                my $fastqtext = $f;
                $fastqtext =~ s/.*\///g;
                $fastqtext =~ s/\.zip//g;  #strip tail
                my @zipout = `unzip -c $f $fastqtext/summary.txt 2>&1`;
                if ($#zipout<2 || $zipout[2] =~ /filename not matched/)
                {
                        print "Warning: $f is not a fastqc zip file (ignored)\n";
                }
                else
                {
                        #print "Found valid fastqc zip $f\n";

                        $fcount++;


                        #PASS	Basic Statistics	test.fastq
                        #PASS	Per base sequence quality	test.fastq
                        #PASS	Per tile sequence quality	test.fastq
                        #PASS	Per sequence quality scores	test.fastq
                        #FAIL	Per base sequence content	test.fastq
                        #WARN	Per sequence GC content	test.fastq
                        #PASS	Per base N content	test.fastq
                        #PASS	Sequence Length Distribution	test.fastq
                        #PASS	Sequence Duplication Levels	test.fastq
                        #WARN	Overrepresented sequences	test.fastq
                        #PASS	Adapter Content	test.fastq
                        #PASS	Kmer Content	test.fastq

                        for(my $l=2; $l<=$#zipout; $l++)
                        {


                                chomp($zipout[$l]);
                                my @cols = split("\t",$zipout[$l]);

                                if ($l==2)
                                {
                                        if (exists($basic_stats{$cols[0]}))
                                        {
                                                $basic_stats{$cols[0]} = $basic_stats{$cols[0]}+1;
                                        }
                                        else
                                        {
                                                $basic_stats{$cols[0]} = 1;
                                        }
                                }
                                elsif ($l==3)
                                {
                                        if (exists($per_base_quality{$cols[0]}))
                                        {
                                                $per_base_quality{$cols[0]} = $per_base_quality{$cols[0]}+1;
                                        }
                                        else
                                        {
                                                $per_base_quality{$cols[0]} = 1;
                                        }
                                }
                                elsif ($l==4)
                                {
                                        if (exists($per_tile_quality{$cols[0]}))
                                        {
                                                $per_tile_quality{$cols[0]} = $per_tile_quality{$cols[0]}+1;
                                        }
                                        else
                                        {
                                                $per_tile_quality{$cols[0]} = 1;
                                        }
                                }
                                elsif ($l==5)
                                {
                                        if (exists($per_seq_quality{$cols[0]}))
                                        {
                                                $per_seq_quality{$cols[0]} = $per_seq_quality{$cols[0]}+1;
                                        }
                                        else
                                        {
                                                $per_seq_quality{$cols[0]} = 1;
                                        }
                                }
                                elsif ($l==6)
                                {
                                        if (exists($per_base_seq_content{$cols[0]}))
                                        {
                                                $per_base_seq_content{$cols[0]} = $per_base_seq_content{$cols[0]}+1;
                                        }
                                        else
                                        {
                                                $per_base_seq_content{$cols[0]} = 1;
                                        }
                                }
                                elsif ($l==7)
                                {
                                         if (exists($per_base_gc{$cols[0]}))
                                         {
                                                 $per_base_gc{$cols[0]} = $per_base_gc{$cols[0]}+1;
                                         }
                                         else
                                         {
                                                 $per_base_gc{$cols[0]} = 1;
                                         }
                                }
                                elsif ($l==8)
                                {
                                         if (exists($per_base_n{$cols[0]}))
                                         {
                                                 $per_base_n{$cols[0]} = $per_base_n{$cols[0]}+1;
                                         }
                                         else
                                         {
                                                 $per_base_n{$cols[0]} = 1;
                                         }
                                }
                                elsif ($l==9)
                                {
                                         if (exists($seq_length_dist{$cols[0]}))
                                         {
                                                 $seq_length_dist{$cols[0]} = $seq_length_dist{$cols[0]}+1;
                                         }
                                         else
                                         {
                                                 $seq_length_dist{$cols[0]} = 1;
                                         }
                                }
                                elsif ($l==10)
                                {
                                         if (exists($seq_dupl{$cols[0]}))
                                         {
                                                 $seq_dupl{$cols[0]} = $seq_dupl{$cols[0]}+1;
                                         }
                                         else
                                         {
                                                 $seq_dupl{$cols[0]} = 1;
                                         }
                                }
                                elsif ($l==11)
                                {
                                         if (exists($over_seq{$cols[0]}))
                                         {
                                                 $over_seq{$cols[0]} = $over_seq{$cols[0]}+1;
                                         }
                                         else
                                         {
                                                 $over_seq{$cols[0]} = 1;
                                         }
                                }
                                elsif ($l==12)
                                {
                                         if (exists($adapter_content{$cols[0]}))
                                         {
                                                 $adapter_content{$cols[0]} = $adapter_content{$cols[0]}+1;
                                         }
                                         else
                                         {
                                                 $adapter_content{$cols[0]} = 1;
                                         }
                                }
                                elsif ($l==13)
                                {
                                         if (exists($kmer_content{$cols[0]}))
                                         {
                                                 $kmer_content{$cols[0]} = $kmer_content{$cols[0]}+1;
                                         }
                                         else
                                         {
                                                 $kmer_content{$cols[0]} = 1;
                                         }
                                }



                        }



                }

        }

        if ($fcount>0)
        {
                print "Total fastqc.zip files: $fcount\n";
                print "                        ";
                printf "%-4s %-15s %-15s %-15s","","PASS","WARN","FAIL";
                print "\n";

                print "Basic statistics      : ";
                if (exists($basic_stats{"PASS"}))
                {
                        printf "%4s %-4d (%-3d%)     ","",$basic_stats{"PASS"},(($basic_stats{"PASS"}/$fcount)*100);
                }
                else
                {
                        printf "%4s %-15s ","","0 (0%)";
                }
                if (exists($basic_stats{"WARN"}))
                {
                        printf "%4s %-4d (%-3d%)     ","",$basic_stats{"WARN"},(($basic_stats{"WARN"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }
                if (exists($basic_stats{"FAIL"}))
                {
                        printf "%4s %-4d (%-3d%)     ","",$basic_stats{"FAIL"},(($basic_stats{"FAIL"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }


                print "\nPer base quality      : ";
                if (exists($per_base_quality{"PASS"}))
                {
                        printf "%4s %-4d (%-3d%)     ","",$per_base_quality{"PASS"},(($per_base_quality{"PASS"}/$fcount)*100);
                }
                else
                {
                        printf "%4s %-15s ","","0 (0%)";
                }
                if (exists($per_base_quality{"WARN"}))
                {
                        printf "%-4d (%-3d%)     ",$per_base_quality{"WARN"},(($per_base_quality{"WARN"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }
                if (exists($per_base_quality{"FAIL"}))
                {
                        printf "%-4d (%-3d%)     ",$per_base_quality{"FAIL"},(($per_base_quality{"FAIL"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }

                print "\nPer tile quality      : ";
                if (exists($per_tile_quality{"PASS"}))
                {
                        printf "%4s %-4d (%-3d%)     ","",$per_tile_quality{"PASS"},(($per_tile_quality{"PASS"}/$fcount)*100);
                }
                else
                {
                        printf "%4s %-15s ","","0 (0%)";
                }
                if (exists($per_tile_quality{"WARN"}))
                {
                        printf "%-4d (%-3d%)     ",$per_tile_quality{"WARN"},(($per_tile_quality{"WARN"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }
                if (exists($per_tile_quality{"FAIL"}))
                {
                        printf "%-4d (%-3d%)     ",$per_tile_quality{"FAIL"},(($per_tile_quality{"FAIL"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }


                print "\nPer sequence quality  : ";
                if (exists($per_seq_quality{"PASS"}))
                {
                        printf "%4s %-4d (%-3d%)     ","",$per_seq_quality{"PASS"},(($per_seq_quality{"PASS"}/$fcount)*100);
                }
                else
                {
                        printf "%4s %-15s ","","0 (0%)";
                }
                if (exists($per_seq_quality{"WARN"}))
                {
                        printf "%-4d (%-3d%)     ",$per_seq_quality{"WARN"},(($per_seq_quality{"WARN"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }
                if (exists($per_seq_quality{"FAIL"}))
                {
                        printf "%-4d (%-3d%)     ",$per_seq_quality{"FAIL"},(($per_seq_quality{"FAIL"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }


                print "\nPer base seq. content : ";
                if (exists($per_base_seq_content{"PASS"}))
                {
                        printf "%4s %-4d (%-3d%)     ","",$per_base_seq_content{"PASS"},(($per_base_seq_content{"PASS"}/$fcount)*100);
                }
                else
                {
                        printf "%4s %-15s ","","0 (0%)";
                }
                if (exists($per_base_seq_content{"WARN"}))
                {
                        printf "%-4d (%-3d%)     ",$per_base_seq_content{"WARN"},(($per_base_seq_content{"WARN"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }
                if (exists($per_base_seq_content{"FAIL"}))
                {
                        printf "%-4d (%-3d%)     ",$per_base_seq_content{"FAIL"},(($per_base_seq_content{"FAIL"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }


                print "\nPer base GC content   : ";
                if (exists($per_base_gc{"PASS"}))
                {
                        printf "%4s %-4d (%-3d%)     ","",$per_base_gc{"PASS"},(($per_base_gc{"PASS"}/$fcount)*100);
                }
                else
                {
                        printf "%4s %-15s ","","0 (0%)";
                }
                if (exists($per_base_gc{"WARN"}))
                {
                        printf "%-4d (%-3d%)     ",$per_base_gc{"WARN"},(($per_base_gc{"WARN"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }
                if (exists($per_base_gc{"FAIL"}))
                {
                        printf "%-4d (%-3d%)     ",$per_base_gc{"FAIL"},(($per_base_gc{"FAIL"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }

                print "\nPer base N  content   : ";
                if (exists($per_base_n{"PASS"}))
                {
                        printf "%4s %-4d (%-3d%)     ","",$per_base_n{"PASS"},(($per_base_n{"PASS"}/$fcount)*100);
                }
                else
                {
                        printf "%4s %-15s ","","0 (0%)";
                }
                if (exists($per_base_n{"WARN"}))
                {
                        printf "%-4d (%-3d%)     ",$per_base_n{"WARN"},(($per_base_n{"WARN"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }
                if (exists($per_base_n{"FAIL"}))
                {
                        printf "%-4d (%-3d%)     ",$per_base_n{"FAIL"},(($per_base_n{"FAIL"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }

                print "\nSeq length distrib.   : ";
                if (exists($seq_length_dist{"PASS"}))
                {
                        printf "%4s %-4d (%-3d%)     ","",$seq_length_dist{"PASS"},(($seq_length_dist{"PASS"}/$fcount)*100);
                }
                else
                {
                        printf "%4s %-15s ","","0 (0%)";
                }
                if (exists($seq_length_dist{"WARN"}))
                {
                        printf "%-4d (%-3d%)     ",$seq_length_dist{"WARN"},(($seq_length_dist{"WARN"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }
                if (exists($seq_length_dist{"FAIL"}))
                {
                        printf "%-4d (%-3d%)     ",$seq_length_dist{"FAIL"},(($seq_length_dist{"FAIL"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }


                print "\nSequence duplication  : ";
                if (exists($seq_dupl{"PASS"}))
                {
                        printf "%4s %-4d (%-3d%)     ","",$seq_dupl{"PASS"},(($seq_dupl{"PASS"}/$fcount)*100);
                }
                else
                {
                        printf "%4s %-15s ","","0 (0%)";
                }
                if (exists($seq_dupl{"WARN"}))
                {
                        printf "%-4d (%-3d%)     ",$seq_dupl{"WARN"},(($seq_dupl{"WARN"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }
                if (exists($seq_dupl{"FAIL"}))
                {
                        printf "%-4d (%-3d%)     ",$seq_dupl{"FAIL"},(($seq_dupl{"FAIL"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }


                print "\nOver represented seq. : ";
                if (exists($over_seq{"PASS"}))
                {
                        printf "%4s %-4d (%-3d%)     ","",$over_seq{"PASS"},(($over_seq{"PASS"}/$fcount)*100);
                }
                else
                {
                        printf "%4s %-15s ","","0 (0%)";
                }
                if (exists($over_seq{"WARN"}))
                {
                        printf "%-4d (%-3d%)     ",$over_seq{"WARN"},(($over_seq{"WARN"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }
                if (exists($over_seq{"FAIL"}))
                {
                        printf "%-4d (%-3d%)     ",$over_seq{"FAIL"},(($over_seq{"FAIL"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }


                print "\nAdapter content       : ";
                if (exists($adapter_content{"PASS"}))
                {
                        printf "%4s %-4d (%-3d%)     ","",$adapter_content{"PASS"},(($adapter_content{"PASS"}/$fcount)*100);
                }
                else
                {
                        printf "%4s %-15s ","","0 (0%)";
                }
                if (exists($adapter_content{"WARN"}))
                {
                        printf "%-4d (%-3d%)     ",$adapter_content{"WARN"},(($adapter_content{"WARN"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }
                if (exists($adapter_content{"FAIL"}))
                {
                        printf "%-4d (%-3d%)     ",$adapter_content{"FAIL"},(($adapter_content{"FAIL"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }

                print "\nKmer content          : ";
                if (exists($kmer_content{"PASS"}))
                {
                        printf "%4s %-4d (%-3d%)     ","",$kmer_content{"PASS"},(($kmer_content{"PASS"}/$fcount)*100);
                }
                else
                {
                        printf "%4s %-15s ","","0 (0%)";
                }
                if (exists($kmer_content{"WARN"}))
                {
                        printf "%-4d (%-3d%)     ",$kmer_content{"WARN"},(($kmer_content{"WARN"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }
                if (exists($kmer_content{"FAIL"}))
                {
                        printf "%-4d (%-3d%)     ",$kmer_content{"FAIL"},(($kmer_content{"FAIL"}/$fcount)*100);
                }
                else
                {
                        printf "%-15s ","0 (0%)";
                }




               print "\n";
       }

}
else
{
        die "Unable to locate directory $dirname\n"
}
