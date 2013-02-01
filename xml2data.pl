#!/usr/bin/env perl
use utf8;
use strict;
die "Usage: perl xml2data.pl moedict-mac/moedict_templates/MoeDictionary.xml" unless @ARGV and -e $ARGV[0];
mkdir 'data';

my %titleToId;
my $curId;
my $out = '';
my $count = 0;
open my $XML, '<:utf8', $ARGV[0];
while (<$XML>) {
    if (/<d:entry id="(\d+)" d:title="([^"]+)">/) {
        $count++;
        print "$count\n" unless $count % 100;
        $titleToId{$2} = $1 unless $titleToId{$2} and $titleToId{$2} < $1;
        my $dir = $1 % 100; 
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
close $XML;

open my $OPTIONS, '>:utf8', "options.html";
for my $title (sort keys %titleToId) {
    my $id = $titleToId{$title};
    print $OPTIONS qq[<option value="$title" data-id="$id" />\n];
}
close $OPTIONS;
