# ------------------------------------------------------------------------ READ LOG-FILE

# mine values from log-file
sub readlog {
  my $p  = $_[0];
  my $kv = $_[1]; # output-ref for key-values

  # check
  if(-f $p) { verbose "log file","$CG_$p$CD_" if $VERBOSE; }
  else      { error "missing log",$p; return; }

  # read header of log file
  my $cat = `cat $p`;
  if(not $cat =~ /\#\h*(.*?)\h*(\n|$)/) { error "missing header",$p; return; }
  my @hdr = split /[ \t]+/,$1;

  # select columns
  my @idx; # indexes of keys to log or -1
  my @key; # keynames for given indexes
  my @km1; # 

  my $j=0; # index in indxexes array
  foreach my $k (@KEYS) {
    my $kk = $k; $kk = $1 if $k =~ /^(.*)~([0-9]+)$/;
    my $idx = -1;
    for(my $i=0; $i<=$#hdr; $i++) {
      if($kk eq $hdr[$i]) {
	$idx = $i; last; }}
    next if $idx < 0;
    $idx[$j] = $idx;
    $key[$j] = $k;
    $km1[$j] = $KM1{$k};
    $j++; }

  # report header
  if($VERBOSE) {
    my $hs;
    foreach my $h (@hdr) {
      my $c = $CK_;
      my $sp = "";
      if(inar \@key,$h) {
	$c = $CW_;
	for(my $i=0; $i<=$#idx; $i++) {
	  if($key[$i] =~ /^$h(~|$)/) {
	    $sp .= "$KM1{$key[$i]},"; }}
	$sp =~ s/.$//;
	$sp = "$CK_:$sp$CD_"; }
      $hs .= "$c$h$sp$CD_ "; }
    verbose "log header",$hs; }

  # collect values
  my @out;
  my $N=0;
  foreach my $line (split /\n/,$cat) {
    next if $line =~ /^\h*\#/;
    my @val = split /\h+/,$line;

    # init
    if(not $N) {
      for(my $i=0; $i<=$#idx; $i++) {
	if($km1[$i] eq "min" or $km1[$i] eq "max") { $out[$i] = $val[$idx[$i]]; }
	if($km1[$i] eq "avg") { $out[$i] = 0; }}}

    # level-1 aggregate
    for(my $i=0; $i<=$#idx; $i++) {
      my $v = $val[$idx[$i]];
      if   ($km1[$i] eq "avg") { $out[$i] += $v; }
      elsif($km1[$i] eq "max") { $out[$i] = $v if $v > $out[$i]; }
      elsif($km1[$i] eq "min") { $out[$i] = $v if $v < $out[$i]; }
      else { error("unknown spec","$key[$i]:$km1[$i]"); }}
    $N++; }

  # complete aggregation
  for(my $i=0; $i<=$#idx; $i++) {
    if($km1[$i] eq "avg") { $out[$i] /= $N; }}

  # store result
  for(my $i=0; $i<=$#idx; $i++) {
    my $kk = $key[$i]; $kk =~ s/~([0-9]*)$/$CK_$1$CW_/;
    verbose "$CK_$km1[$i]$CW_ $kk",$out[$i] if $VERBOSE;
    $$kv{$key[$i]} = $out[$i]; }}

# --------------------------------------------------------------------------------------
