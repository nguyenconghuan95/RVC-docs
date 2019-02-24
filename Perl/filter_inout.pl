#!/usr/bin/perl

use lib "./lib";
use Spreadsheet::ParseExcel;
use Spreadsheet::ParseExcel::SaveParser;
use Spreadsheet::WriteExcel;
use File::Basename;

my $parser = new Spreadsheet::ParseExcel::SaveParser;
my $template = $parser -> Parse('test.xls');

my $list = $ARGV[0];

if (not defined $list) {
    die "You need to define the list RTL\n";
}

open(LIST_FILE, "<$list") or die "Can't open $list\n";
while (my $rtl = <LIST_FILE>) {
    my $bus_name = basename($rtl,".v");
    chomp($bus_name);
    preFormat($bus_name);
    print "Parsing $rtl...\n";
    open(RTL_FILE, "<$rtl");
    #Starting data row is 5
    my $data_row = 5;
    while (my $line = <RTL_FILE>) {
        if ($line =~ /input|output|inout/) {
            my $line = $line =~ s/input/I/r;
            my $line = $line =~ s/output/O/r;
            my $line = $line =~ s/inout/IO/r;
            my @split_pattern = split(/\s/,$line);

            #Initialize msb,lsb variables
            my $msb = 0;
            my $lsb = 0;

            my $dir    = $split_pattern[0];
            my $width  = $split_pattern[1];
            my $signal = $split_pattern[scalar($split_pattern)-1] =~ s/\;|,//r;
            if ($width =~ /:/) {
                $width = $width =~ s/\]//r;
                $width = $width =~ s/\[//r;
                my @bit_width = split(/:/, $width);
                $msb = $bit_width[0];
                $lsb = $bit_width[1];
            }
            else {
                $msb = "";
                $lsb = "";
            }
            my $data_col = 1;
            my @extracted_values = ("$signal", "$dir", "$msb", "$lsb");
            my $sheet = $template -> worksheet("$bus_name");
            foreach (@extracted_values) {
                $sheet -> AddCell($data_row, $data_col, $_);
                $data_col = $data_col + 1;
            }
            #Found one match so increase the row num
            $data_row = $data_row + 1;
         }
    }
    close RTL_FILE;
}
close LIST_FILE;

$template -> SaveAs('test.xls');

sub preFormat {
    my ($bus_name) = @_;
    chomp($bus_name);
    print "Adding sheet $bus_name\n";
    my $sheet = $template -> AddWorksheet("$bus_name");
    my @cell_values = ("component:", "$bus_name");
    my $row = 2;
    my $col = 0;
    foreach (@cell_values) {
        $sheet -> AddCell($row, $col, $_);
        $col = $col + 1;
    }
    $row = 3;
    $col = 0;
    @cell_values = ("name(actual_name)", "signal", "direction", "msb", "lsb");
    foreach (@cell_values) {
        $sheet -> AddCell($row, $col, $_);
        $col = $col + 1;
    }

}
