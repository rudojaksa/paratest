# ------------------------------------------------------------------------- READ JOURNAL

# mine values from journal
# note: no level-1 aggregation for journals yet
sub readjournal {
  my $p  = $_[0]; # path
  my $kv = $_[1]; # output-ref for key-values
  my $ku = $_[2]; # output-ref for key-units

  # check
  if(-f $p) { verbose "journal file","$CG_$p$CD_" if $VERBOSE; }
  else      { error "missing journal",$p; return; }

  # read journal file
  foreach my $line (split /\n/,`cat $p`) {
    next if $line =~ /^\h*\#/;
    next if not $line =~ /^\h*([^:]*?):\h*([^\h]+?)(\h+(.*?))?\h*$/;
    my ($k,$v,$u) = ($1,$2,$4); # key,value,unit
    $k =~ s/\h+/_/g;

    # store
    my $ok = 0;
    foreach my $kx (@KEYS) {
      my $kk = $kx; $kk = $1 if $kx =~ /^(.*)~([0-9]+)$/;
      if($kk eq $k) {
	$ok = 1;
	$$kv{$kx} = $v;
	$$ku{$kx} = $u; }}

    # report
    if($VERBOSE) {
      my $ck = $CK_;
      my $cv = $CK_;
      if($ok) { $ck = $CW_; $cv = $CD_; }
      verbose $ck,$k,"$cv$v $CK_$u$CD_" if $ck ne $CK_ or $DEBUG; }}}

# --------------------------------------------------------------------------------------
