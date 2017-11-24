#!/usr/bin/perl
#logfile.plx
use warnings;
use strict;

open INPUT, ">test.txt" or die "Could not open file test.txt";
print INPUT "HOLA MUNDO";
