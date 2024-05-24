#!/usr/bin/env perl
# Configure a NodeJS repl with both readline and completion
# https://stackoverflow.com/a/43677273

use lib ($ENV{RLWRAP_FILTERDIR} or ".");
use RlwrapFilter;
use strict;

my $filter = new RlwrapFilter;

$filter -> completion_handler( sub {
  my($line, $prefix, @completions) = @_;
  my $command = "rlwrap_complete('$prefix')";
  my $completion_list = $filter -> cloak_and_dagger($command, "> ", 0.1); # read until we see a new prompt "> "
  my @new_completions =  grep /^$prefix/, split /\r\n/, $completion_list; # split on CRNL and weed out rubbish
  return (@completions, @new_completions);
 });

$filter -> run;
