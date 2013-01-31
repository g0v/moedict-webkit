#!/usr/bin/env perl
# perl xml2data.pl < moedict-mac/moedict_templates/MoeDictionary.xml
use utf8;
use strict;
my %idToTitle;
my $curId;
my $out = '';
my $count = 0;
while (<>) {
    if (/<d:entry id="(\d+)" d:title="([^"]+)">/) {
        $count++;
        print "$count\n" unless $count % 100;
        $idToTitle{$1} = $2;
        my $dir = $1 % 100; 
        # $dir = "0$dir" unless $dir > 9;
        mkdir "data/$dir" unless -d "data/$dir";
        open FH, '>:utf8', "data/$dir/$1.html";
    }
    elsif (m{</div></d:entry>}) {
        if ($out =~ /㊀/) {
            my @chunks = sort split(/<h1 class="title">/, $out);
            $out = join q/<h1 class="title">/, @chunks;
        }
        print FH $out;
        close FH;
        $out = '';
    }
    else {
        s{<d:index d:value="[^"]*"/>}{};
        $out .= $_;
    }
}
