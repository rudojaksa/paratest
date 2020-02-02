# ---------------------------------------------------------------------------- AGGREGATE

# single-level aggregate
sub aggregate {
  my  $arr = $_[0]; # array reference
  my $mode = $_[1]; # mode: min/max/avg

  # init
  my $res = $$arr[0];
     $res = 0 if $mode eq "avg";

  # aggregate
  foreach my $v (@{$arr}) {
    if   ($mode eq "avg") { $res += $v; }
    elsif($mode eq "max") { $res = $v if $v > $res; }
    elsif($mode eq "min") { $res = $v if $v < $res; }}

  # finish
  if($mode eq "avg") { $res /= scalar(@{$arr}); }

  return $res; }

# level-2 and level-3 aggregator
sub aggregator {
  my $gkv = $_[0];

  # aggregated values for each key
  my %agg;
  foreach my $k (@KEYS) {
    (my $kk=$k) =~ s/~([0-9]*)$/$CK_$1$CW_/;

    # aggregate from all files 
    my @tests;
    foreach my $test (@{$$gkv{$k}}) {
      my $v = aggregate $test,$KM2{$k};
      verbose "${CK_}l2 $KM2{$k} $CS_$kk","$v $CK_<- @{$test}$CD_" if $VERBOSE and $#{$test}>0;
      push @tests,$v; }

    # aggregate from all tests
    my $v = aggregate \@tests,$KM3{$k};
    verbose "${CK_}l3 $KM3{$k} $CL_$kk","$v $CK_<- @tests$CD_" if $VERBOSE and $#tests>0;
    $agg{$k} = $v; }

  return %agg; }

# ------------------------------------------------------------------------------- HEADER

sub mkheader {
  my $gkv = $_[0];
  my $gka = $_[1];

  # parameter A
  my $s = "# a ";

  # result keys
  foreach my $k (@KEYS) {
    (my $kk=$k)=~s/~//;
    $s.=" $kk"; }

  # no details output
  return $s if not $ALLOUT;

  # A-parameters of individual tests (possibly randomized)
  if($#{@gka}) {
    $s .= " ";
    for(my $i=0; $i<=$#{$gka}; $i++) {
      my $ii = $i+1;
      $s .= " a$ii"; }}

  # individual groups of results for each key
  foreach my $k (@KEYS) {
    (my $kk=$k)=~s/~//;

    # compute number of results for key $k
    my $j=0; foreach(@{$$gkv{$k}}) { $j++ foreach @{$_}; }

    # print indexed key-names in the form key_1a key_1b key_2a
    # where 1,2 are tests indexes and a,b are files indexes
    if($j>1) {
      $s .= " ";
      for(my $ti=0; $ti<=$#{$$gkv{$k}}; $ti++) {
	my $tii = $ti+1; $tii="" if $#{$$gkv{$k}} == 0;
	for(my $i=0; $i<=$#{$$gkv{$k}[$ti]}; $i++) {
	  my $ii = chr(ord('a')+$i); $ii="" if $#{$$gkv{$k}[$ti]} == 0;
	  $s .= " ${kk}_$tii$ii"; }}}}

  return $s; }

# ------------------------------------------------------------------- NUMBERS FORMATTING

# numbers formatting: hard n decimal places
sub Dfmt {
  my $num = $_[0];  # number
  my $dec = $_[1];  # decimal places
  my $res = sprintf "%.${dec}f",$num;
  return $res; }

# numbers formatting: soft n decimal places
sub dfmt {
  my $num = $_[0];  # number
  my $dec = $_[1];  # decimal places
  my $res = sprintf "%.${dec}f",$num;
  $res =~ s/0+$// if $res =~ /\./;
  $res =~ s/\.$//;
  return $res; }

# numbers formatting, formats:
# f3d = max 3 decimal points
# f3D = exactly 3 decimal points, zero padded
sub nfmt {
  my $num = $_[0];
  my $fmt = $_[1];
  my $res;
  if   ($fmt =~ /([0-9]+)d/)			{ $res = dfmt $num,$1; }
  elsif($fmt =~ /([0-9]+)D/)			{ $res = Dfmt $num,$1; }
  elsif($num =~ /^[+-]?[0-9]*(\.[0-9]*)?$/)	{ $res = dfmt $num,5; }
  else						{ $res = $num; }
  return $res; }

# ------------------------------------------------------------------------------ DETAILS

sub details {
  my $gkv = $_[0];
  my $gka = $_[1];
  my $s;

  # A-parameters of individual tests
  if($#{$gka}) {
    $s .= " ";
    $s .= " $_" foreach @{$gka}; }

  # individual groups of results for each key
  foreach my $k (@KEYS) {

    # compute number of results for key $k
    my $j=0; foreach(@{$$gkv{$k}}) { $j++ foreach @{$_}; }

    # individual results in groups for each key
    if($j>1) {
      $s .= " ";
      foreach(@{$$gkv{$k}}) { $s .= " " . nfmt $_,$KFMT{$k} foreach @{$_}; }}}

  return $s; }

# ------------------------------------------------------------------------------ LOGLINE
our $OUN = 1;		# actual number of log lines
our $OUT = "$NAME.log";	# log-file name
$OUT =~ s/ /-/g;
verbose("results",$OUT);

sub logline {
  my   $a = $_[0]; # the A value
  my $gkv = $_[1]; # arrays of arrays of all (multiple-files multiple-tests) values for each key
  my $gka = $_[2]; # array A-values for all tests
  my %agg = aggregator $gkv;

  # add aggregated values to the output line
  my $s .= "$a ";
  foreach my $k (@KEYS) {
    $s .= " " . nfmt $agg{$k},$KFMT{$k}; }

  # verbose without header and details
  verbose "line $OUN",$s if $VERBOSE;

  # add detailed all-tests outputs
  $s .= details $gkv,$gka if $ALLOUT;

  # add header before the 1st line
  if($OUN == 1) {
    my $h = mkheader $gkv,$gka; # this is based on the 1st line only
    $s = "$h\n$s"; }
  $OUN++;

  # save the line
  open OUT,">>$OUT";
  print OUT "$s\n";
  close OUT; }

# --------------------------------------------------------------------------------------
