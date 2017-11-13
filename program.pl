#!/usr/bin/perl
# badprefix.plx
use warnings;
use strict;

my %dir=(
ivan => "27337019",
papa => 25756332);


for (keys %dir){
print "$_ =>", $dir{$_},"\n"; 

}
print length "hola";
