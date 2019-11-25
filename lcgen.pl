#!/usr/bin/env perl

use strict;
use warnings;
use v5.26;

use Data::Dumper;

my %argnums = qw(
    not 1 nand 0 or 0 and 0 nor 0
    pos 1 neg 1);

my @st;
my @nest;

while (<STDIN>) {
    chomp;
    next if /^\s*$/ || /^#\s/;
    s/^\s*//; s/\s*$//;
    my @words = split(/\s/);
    if ($#nest == -1) {
        my @sta = ( \@words );
        push @st, \@sta;
        push @nest, \@sta;
    } elsif ($#nest == 0) {
        if ($words[0] eq "done") {
            pop @nest; 
            die "Oh no 1" unless $#words == 0;
            next;
        }
        my $elem = (\@nest)->[0];
        if ($elem->[0]->[0] eq "print") {
            push @$elem, $_;
            next;
        }
        die "Oh no 2" unless $#words == 2 and $words[2] eq "of";
        my $function = $words[0];
        my $result = $words[1];
        die "Oh no 3" unless $result =~ /(n?and|[nx]?or|not|jus|)/;
        my $sta = [ $function, $result ];
        push @$elem, $sta;
        push @nest, $sta;
    } elsif ($#nest == 1) {
        if ($words[0] eq "fo") {
            pop @nest;
            die "Oh no 4" unless $#words == 0;
            next;
        }
        my $sign = shift @words;
        die "Oh no 5" unless $sign =~ /(pos|neg)/;
        my $oper = shift @words;
        die "Oh no 6" unless $oper =~ s/(n?and|[nx]?or|not|jus|):/$1/;
        my $signoper = [ $sign, $oper ];
        push @{$nest[1]}, $signoper;
        foreach (@words) {
            /\A([+-])(.*)\Z/ or die "Oh no 7: ".Dumper($_);
            push @$signoper, $_;
        }
    } else { die "Oh no 8"; }
}
die "Oh no 9" unless $#nest == -1;
foreach my $paramtree (@st) {
    my $params = shift @$paramtree;
    if ($params->[0] eq "print") {
        # shift @$paramtree;
        foreach (@$paramtree) { say; }
        print "\n";
        next;
    }
    say (join "  ", @$params);
    say (join "  ", (("|") x (scalar @$params)));
    say Dumper($paramtree);
    print "\n\n";
}