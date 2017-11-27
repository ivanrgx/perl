#!/usr/bin/perl
#logfile.plx
use warnings;
use strict;

my @arr = (1,2,3);

my $ref_arr = \@arr;


print(ref($ref_arr));
