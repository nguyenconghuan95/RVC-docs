#!/usr/bin/perl

#=====================================================================
#DBG_TSU[0] : Control when to force the interrupt
#DBG_TSU[1] : Line number in the checklist
#DBG_STU[2] : Active level
#DBG_TSU[3] : Merging cases (only value 0 if there is no merge logic)
#=====================================================================

system("rm -f int_force_all.v");
system("touch int_force_all.v");
open(FILE, "<", "list_path");
open(OUT, ">>", "int_force_all.v");
while (my $line = <FILE>) {
    my @ pattern = split(/\t/, $line);
    my $index = $pattern[0];
    my $case  = $pattern[1];
    my $sig   = $pattern[2];
    my $clk   = $pattern[3];
    my $pul   = $pattern[4];
    print OUT  "always @(tb.sim_user.DBG_REG_TSU[0] or tb.sim_user.DBG_REG_TSU[1]) begin\n";
    print OUT  "    @(posedge tb.AIPOC_2N.cpuss.cr8_0.STANBYWFI or posedge tb.AIPOC_2N.cpuss.cr8_1.STANBYWFI);\n";
    print OUT  "    if ((tb.sim_user.DBG_REG_TSU[0] == 32'hACCE5501) && (tb.sim_user.DBG_REG_TSU[1] == $index) && (tb.sim_user.DBG_REG_TSU[3] == $case)) begin\n";
    if ($clk != "Async") {
        print OUT "     @(posedge $clk) force $sig = tb.sim_user.DBG_REG_TSU[2];\n";
        if ($pul == "Pulse") {
            print OUT "     repeat (18) @(posedge $clk) release $sig;\n";
            print OUT " end\n";
            print OUT "end\n"
        }
        else {
            print OUT " end\n";
            print OUT " else begin\n";
            print OUT "     release $sig;\n";
            print OUT " end\n";
            print OUT "end\n";
        }
    }
    else {
        print OUT "     force $sig = tb.sim_user.DBG_REG_TSU[2]\n";
        if ($pul == "Pulse") {
            print OUT "     repeat (18) @(posedge tb.AIPOC_2N....) release $sig;\n";
            print OUT " end\n";
            print OUT "end\n"
        }
        else {
            print OUT " end\n";
            print OUT " else begin\n";
            print OUT "     release $sig;\n";
            print OUT " end\n";
            print OUT "end\n";
        }
    }
}
close(FILE);
close(OUT);