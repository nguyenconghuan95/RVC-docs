#!/usr/bin/perl

open(LIST_FILE, "<./instance_list") or die "Can't open instance_list\n";
system("rm -f ./connection_ICB.sv");
system("touch ./connection_ICB.sv");

while (my $line = <LIST_FILE>) {
  my @patterns = split(/,/,$line);
  
  my $instance_name   = $patterns[0];
  my $connection_file = $patterns[1];
  my $if_name         = $patterns[2];
  $if_name =~ s/\n//g;

  system("grep 'if\\[' $connection_file > tmp.v");

  open(CONNECT_FILE, "<./tmp.v");
  while (my $connection = <CONNECT_FILE>) {
    $connection =~ s/\s+//g;
    @patterns     = split(/\(/,$connection);
    my $signal    = "$instance_name$patterns[0]";
    @patterns     = split(/\)/,$patterns[1]);
    my $model_sig = $patterns[0];
    my $model_sig = "${if_name}_${model_sig}";
    open(RESULT, ">>./connection_ICB.sv");
    print RESULT "assign $model_sig = $signal;\n";
    close RESULT; 

  }
  close CONNECT_FILE;
  #unlink("./tmp.v");
}

close LIST_FILE;
