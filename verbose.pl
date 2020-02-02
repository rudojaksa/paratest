# -------------------------------------------------------------------- VERBOSE MESSAGING
$KLEN = 15;

# return length of string without escape sequences
sub esclen {
  my $s = $_[0];
  $s =~ s/\033\[[0-9]+m//g;
  return length $s; }

# left-pad string to given length
sub lpad {
  my $n = $_[0];
  my $s = $_[1];
  my $l = esclen $s;
  my $r;
  $r .= " " for $l..$n-1;
  $r .= $s;
  return $r; }

# format 1st/2nd/3rd numbers
sub fth {
  my $n = $_[0];
  my $s = $n;
  my $l = $n%10;
  if($n>3 and $n<21) { $s .= "th"; }
  elsif($l == 1) { $s .= "st"; }
  elsif($l == 2) { $s .= "nd"; }
  elsif($l == 3) { $s .= "rd"; }
  else           { $s .= "th"; }
  return $s; }

# --------------------------------------------------------------------------------------

sub verbose {
  my $c = $CC_;
  my $k = $_[0];
  my $v = $_[1];
  if($_[0] =~ /^\033\[[0-9]*m$/) {
    $c = $_[0];
    $k = $_[1];
    $v = $_[2]; }
  print STDERR $c;
  print STDERR lpad $KLEN,$k;
  print STDERR ":$CD_ $v\n"; }

sub error {
  printf STDERR "$CR_%${KLEN}s: %s$CD_\n",$_[0],$_[1]; }

# --------------------------------------------------------------------------------------
