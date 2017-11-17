#!/usr/bin/perl
# looploop3.plx
use warnings;
use strict;
my @getout = qw(usd mxn eur);
my $primo=0;


print "Enter number\n";
OUTER: while (<STDIN>) {
      chomp;
      OUTER2: for my $var(2..$_){
          print ("Checando numero $var\n");
          for my $x(1 .. $var){
                 if($var%$x==0){
                    $primo++;
                 } 
             }
          if($primo!=2){
          }
          else{
              print("Numero primo! $var\n");
          }
          $primo=0;
          last OUTER if $var == $_;
          } 
          #print "$var\n";
      }


