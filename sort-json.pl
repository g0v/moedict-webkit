#!/usr/bin/env perl
use v5.14;
use utf8;
use JSON;
my $JSON = JSON->new->utf8->canonical;
while (<>) {
    my ($batch, $code, $json) = split / /, $_, 3;
    say "$batch $code ", $JSON->encode($JSON->decode($json));
}
