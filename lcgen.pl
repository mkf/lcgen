#!/usr/bin/env perl

use strict;
use warnings;
use v5.26;
use feature qw(postderef);
no warnings qw(experimental::postderef);

use Data::Dumper;

my %argnums = qw(
    not 1 nand 0 or 0 and 0 nor 0
    pos 1 neg 1);

my @st;
my @nest;

my $isprint = 0;

while (<STDIN>) {
    chomp;
    next if /^\s*$/ || /^#\s/;
    unless ($isprint) {
        s/^\s*//; s/\s*$//;
    }
    my @words = split(/\s/);
    if ($#nest == -1) {
        my @sta = ( \@words );
        push @st, \@sta;
        push @nest, \@sta;
        $isprint = ($words[0] eq "print");
    } elsif ($#nest == 0) {
        if ($words[0] eq "done") {
            pop @nest; 
            die "Oh no 1" unless $#words == 0;
            $isprint = 0;
            next;
        }
        my $elem = (\@nest)->[0];
        if ($isprint or $elem->[0]->[0] eq "print") {
            push @$elem, $_;
            next;
        }
        $isprint = 0;
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
    my %paramsindices;
    @paramsindices{@$params} = 0..$#$params;
    my @secondcolumn;
    my @firstcolumn;
    my @paramreferences = (0) x $#$params;
    foreach (@$paramtree) {
        my $fname = $_->[0];
        my @farr = ( $fname, $_->[1], $#$_-1, 0 );
        push @secondcolumn, \@farr;
        foreach ($_->@[2..$#$_]) {
            my @firstcolumnentry = ($fname, $_->[0], $_->[1]);
            $farr[3]++;
            foreach ($_->@[2..$#$_]) {
                my ($sign, $word) = /\A([+-])(.*)\Z/;
                my $paramidx = $paramsindices{$word};
                my $paramsign;
                if ($sign eq '-') {
                    $paramsign = -1;
                } elsif ($sign eq '+') {
                    $paramsign = 1;
                } else {
                    die "oof";
                }
                push @firstcolumnentry, $paramsign * $paramidx;
                $paramreferences[$paramidx]++;
            }
            push @firstcolumn, \@firstcolumnentry;
        }
    }
    
    say Dumper($paramtree);
    say Dumper(\@secondcolumn);
    say Dumper(\@firstcolumn);
    say Dumper(\@paramreferences);
    print "\n\n";
}