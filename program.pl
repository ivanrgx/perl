#!/usr/bin/perl
# next.plx
use strict;
use warnings;
my @array = (8, 3, 0, 2, 12, 0);
for my $x(@array) {
if ($x == 0) {
print "Skipping zero element.\n";
next;
}
print "48 over $x is ", 48/$x, "\n";
}
