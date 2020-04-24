#!/usr/bin/perl -w
use strict;
use warnings;
use Getopt::Long;
use FindBin qw($Bin);
=head1 Name
    bins_process.pl
=head1 Description
    This is a perl script to process the result of checkm "merge" action and put all bins which meet the criteria to one single folder.
=head1 Contact
    Author: Margaret C
    Email: zhujiahui@genomics.cn
    Test Past Date: 2018.08.07
=cut

my ($merger,$lineage,$comp,$cont,$bin,$output);
GetOptions(
    'merger=s' => \$merger,
    'lineage=s' => \$lineage,
    'comp=i' => \$comp,
    'cont=i' => \$cont,
    'bin=s' => \$bin,
    'output=s' => \$output,
);

if (! -d $output) {system ("mkdir $output");}

#screen the merger table and merge bins which meet our criteria.
sub merge{ 
    my ($merger,$comp,$cont,$bin,$output)=@_;
    open MERL,"$merger";
    <MERL>;
    while(<MERL>){
        chomp;
        my @arr = split /\t/, $_;
        if($arr[-2]>$comp && $arr[-1]<$cont){
            `cat $bin/$arr[0].fa $bin/$arr[1].fa >$output/$arr[0]_$arr[1].fa`;
        }
    }
    close MERL;
}

sub filter{
    my ($lineage,$comp,$cont,$bin,$output)=@_;
    open LINL,"$lineage";
    <LINL>;<LINL>;<LINL>;
    while(<LINL>){
        chomp;
		last if /^-/;
        my @arr=split /\s+/,;
        if($arr[-3]>$comp && $arr[-2]<$cont){
		#	print "$arr[1]\t$arr[-3]\t$arr[-2]\n";
            system("cp $bin/$arr[1].fa $output");
        }
    }
    close LINL;
}
merge($merger,$comp,$cont,$bin,$output);
filter($lineage,$comp,$cont,$bin,$output);
