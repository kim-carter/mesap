#!/usr/bin/perl

my $html2text = "html2text"; # installed systemwide

use strict;

if ($#ARGV!=0)
{
        die "Usage: samstat_parser <directory>\n"
}

my $dirname = $ARGV[0];
my $fcount = 0;

my $total_map_g30 = 0;
my $ming30 = 100;
my $maxg30 = -1;

my $total_map_l30 = 0;
my $minl30 = 100;
my $maxl30 = -1;

my $total_map_l20 = 0;
my $minl20 = 100;
my $maxl20 = -1;

my $total_map_l10 = 0;
my $minl10 = 100;
my $maxl10 = -1;

my $total_map_l3 = 0;
my $minl3 = 100;
my $maxl3 = -1;

my $total_unmap = 0;
my $minunmap = 100;
my $maxunmap = -1;

my $total_reads = 0;
my $minreads = 100000000;
my $maxreads = 0;

if (-e $dirname)
{
        #ls files and redirect stderr to stdout
        my @files = `ls -1 $dirname/*.samstat.html 2>&1`;
        if ($files[0] =~ /cannot access/)
        {
                print "There does not appear to be any .samstat.html files in the specified directory\n";
                exit(0);
        }
        foreach my $f (@files)
        {
                $fcount++;
                chomp($f); #as it has \n on the end

                my @text = `$html2text $f`;



                # ** handle inconsistent html generation from long filenames
                my $add=0;
                chomp($text[1]);
                #print "xx".$text[1]."xx\n";
                if ($text[1] =~ /\*\*/)
                {
                      #print "Needs add $f\n";
                      $add=1;
                }
                #line 12 >30

                $text[12+$add] =~ s/ +/ /;
                my @temp = split(" ",$text[12+$add]);
                $total_map_g30 = $total_map_g30+$temp[4];
                #print "G30 = $temp[4]  $text[12]\n";
                if ($temp[4]<$ming30)
                {
                        $ming30 = $temp[4];
                }
                if ($temp[4]>$maxg30)
                {
                        $maxg30 = $temp[4];
                }


                #line 13 <30
                $text[13+$add] =~ s/ +/ /;
                my @temp = split(" ",$text[13+$add]);
                $total_map_l30 = $total_map_l30+$temp[4];
                if ($temp[4]<$minl30)
                {
                        $minl30 = $temp[4];
                }
                if ($temp[4]>$maxl30)
                {
                        $maxl30 = $temp[4];
                }

                #line 14 <20
                $text[14+$add] =~ s/ +/ /;
                my @temp = split(" ",$text[14+$add]);
                $total_map_l20 = $total_map_l20+$temp[4];
                if ($temp[4]<$minl20)
                {
                        $minl20 = $temp[4];
                }
                if ($temp[4]>$maxl20)
                {
                        $maxl20 = $temp[4];
                }

                #line 15 <10
                $text[15+$add] =~ s/ +/ /;
                my @temp = split(" ",$text[15+$add]);
                $total_map_l10 = $total_map_l10+$temp[4];
                if ($temp[4]<$minl10)
                {
                        $minl10 = $temp[4];
                }
                if ($temp[4]>$maxl10)
                {
                        $maxl10 = $temp[4];
                }


                #line 16 <3
                $text[16+$add] =~ s/ +/ /;
                my @temp = split(" ",$text[16+$add]);
                $total_map_l3 = $total_map_l3+$temp[4];
                if ($temp[4]<$minl3)
                {
                        $minl3 = $temp[4];
                }
                if ($temp[4]>$maxl3)
                {
                        $maxl3 = $temp[4];
                }


                #line 17 unmapped
                $text[17+$add] =~ s/ +/ /;
                my @temp = split(" ",$text[17+$add]);
                $total_unmap = $total_unmap+$temp[2];
                #print "Unmap = $temp[2]  $text[17]\n";
                if ($temp[2]<$minunmap)
                {
                        $minunmap = $temp[2];
                }
                if ($temp[2]>$maxunmap)
                {
                        $maxunmap = $temp[2];
                }


                #line 18 reads
                $text[18+$add] =~ s/ +/ /;
                my @temp = split(" ",$text[18+$add]);
               # print "Reads = $temp[1]\n";
                $total_reads = $total_reads+$temp[1];
                if ($temp[1]<$minreads)
                {
                        $minreads = $temp[1];
                }
                if ($temp[1]>$maxreads)
                {
                        $maxreads = $temp[1];
                }

        }

        print "Total sample files = $fcount\n";
        print "Average reads per sample     : ".(int($total_reads/$fcount))." ($minreads .. $maxreads)\n";
        print "Average p/c alignment mapq>30: ".(int($total_map_g30/$fcount))."% ($ming30 .. $maxg30)\n";
        print "Average p/c alignment mapq<30: ".(int($total_map_l30/$fcount))."% ($minl30 .. $maxl30)\n";
        print "Average p/c alignment mapq<20: ".(int($total_map_l20/$fcount))."% ($minl20 .. $maxl20)\n";
        print "Average p/c alignment mapq<10: ".(int($total_map_l10/$fcount))."% ($minl10 .. $maxl10)\n";
        print "Average p/c alignment mapq<3 : ".(int($total_map_l3/$fcount))."% ($minl3 .. $maxl3)\n";
        print "Average p/c alignment unmap  : ".(int($total_unmap/$fcount))."% ($minunmap .. $maxunmap)\n";



}
