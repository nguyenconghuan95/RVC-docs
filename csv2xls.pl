#!/run/pkg/TWW-perl-/5.8.8/bin/perl -w
     use strict;
     use warnings; 
     use Spreadsheet::WriteExcel;
     use Text::CSV::Simple;
     use Spreadsheet::ParseExcel::Format
my $infile = "/project/ls1socdft_nobackup/rev2.0/user/Shah-       B53654/dft/dfta/perl/pattern_qa/output_0/xls_info.csv";
#usage()  unless defined $infile && -f $infile;
  my $parser = Text::CSV::Simple->new; 
  my @data = $parser->read_file($infile);
  my $headers = shift @data;

   my $outfile = shift || "/project/ls1socdft_nobackup/rev2.0/user/Shah-B53654/dft/dfta/perl/pattern_qa/output_0/xls_info.xls";
my $subject = shift || 'worksheet';

 my $workbook = Spreadsheet::WriteExcel->new($outfile);
my $bold = $workbook->add_format();
$bold->set_bold(1) ;
 my $color =$workbook->add_format(); 
 $color->set_bg_color('green'); 
 my $color1=$workbook->add_format();
 $color1->set_bg_color('red');
import_data($workbook, $subject, $headers, \@data);

# Add a worksheet
 sub import_data {
my $workbook  = shift;
my $base_name = shift ;
my $colums    = shift;
my $data      = shift;
my $limit     = shift || 50_000;
my $start_row = shift ||1;
my $worksheet = $workbook->add_worksheet($base_name);
$worksheet->add_write_handler(qr[\w], \&store_string_widths);
my $w = 1;
$worksheet->write('A' . $start_row, $colums,$bold);
my $i = $start_row;
my $qty = 0;
for my $row (@$data) {
    $qty++;
    if ($i > $limit) {
         $i = $start_row;
         $w++;
         $worksheet = $workbook->add_worksheet("$base_name - $w");
                     $worksheet->write('A1', $colums);

          }

$worksheet->write(1+$i++,0, $row);}

   autofit_columns($worksheet);
warn "Convereted $qty rows.";
return $worksheet;
  }
 sub store_string_widths {

my $worksheet = shift;
my $col       = $_[1];
my $token     = $_[2];

# Ignore some tokens that we aren't interested in.
return if not defined $token;       # Ignore undefs.
return if $token eq '';             # Ignore blank cells.
return if ref $token eq 'ARRAY';    # Ignore array refs.
return if $token =~ /^=/;           # Ignore formula

# Ignore numbers
#return if $token =~ /^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d++))?$/;

# Ignore various internal and external hyperlinks. In a real scena+rio
# you may wish to track the length of the optional strings used wi+th
# urls.
return if $token =~ m{^[fh]tt?ps?://};
return if $token =~ m{^mailto:};
return if $token =~ m{^(?:in|ex)ternal:};


# We store the string width as data in the Worksheet object. We us+e
# a double underscore key name to avoid conflicts with future name +s.
#
my $old_width    = $worksheet->{__col_widths}->[$col];
my $string_width = string_width($token);

if (not defined $old_width or $string_width > $old_width) {
    # You may wish to set a minimum column width as follows.
    #return undef if $string_width < 10;

    $worksheet->{__col_widths}->[$col] = $string_width;
  }


# Return control to write();
return undef;
  }


sub string_width {

  return length $_[0];
   }
  sub autofit_columns {

my $worksheet = shift;
my $col       = 0;

for my $width (@{$worksheet->{__col_widths}}) {

    $worksheet->set_column($col, $col, $width) if $width;
    $col++;
}
 }
excel perl csv
shareimprove this question
edited May 7 '15 at 6:29
asked May 7 '15 at 6:24
