#!/usr/bin/env perl
use v5.14;
use utf8;
use JSON;
use File::Slurp;
use Unicode::Normalize;

my $JSON = JSON->new->utf8->canonical;

sub insert_index {
    my ($ctx, $title, $terms) = @_;
    my $idx = $ctx->{pinyin_sans_tone};

    my (%pos, %freq);
    for (my $i = 0; $i < @$terms; $i++) {
        my $t = $terms->[$i];
        $freq{$t}++;
        push @{$pos{$t}},$i;
    }
    for my $t (keys %freq) {
        $idx->{$t}{$title} //= [$pos{$t}[0], 0];
        $idx->{$t}{$title}[1] += $freq{$t};
    }
}

sub sort_index {
    my ($ctx) = @_;
    my $idx = $ctx->{pinyin_sans_tone};
    reset(%$idx);
    while (my ($term, $docs) = each %$idx) {
        my @rows = map {
            [ $_, $docs->{$_}[0], $docs->{$_}[1] ]
        } sort {
            length($a) <=> length($b)
            || $docs->{$a}[0] <=> $docs->{$b}[0]
            || $docs->{$b}[1] <=> $docs->{$a}[1]
        } keys %$docs;
        $idx->{$term} = \@rows;
    }
}

sub produce_lookup {
    my ($ctx) = @_;
    my $idx = $ctx->{pinyin_sans_tone};

    reset(%$idx);
    while (my ($term, $docs) = each %$idx) {
        my $content = $JSON->encode([ map { $_->[0] } @$docs ]);
        write_file("lookup/pinyin/$ctx->{lang}/${term}.json", $content);
    }
}

my $lang = shift;
unless ($lang =~ /^[tahc]$/) {
    die << '.';
Please invoke this as one of:
    perl build-pinyin-lookup.pl a
    perl build-pinyin-lookup.pl t
    perl build-pinyin-lookup.pl h
    perl build-pinyin-lookup.pl c
.
}

my $dict_file = {
    a => "dict-revised.unicode.json",
    t => "dict-twblg.json",
    h => "dict-hakka.json",
    c => "dict-csld.json",
}->{$lang};
    
binmode STDERR, ":utf8";
mkdir "lookup";
mkdir "lookup/pinyin";
mkdir "lookup/pinyin/$lang";

my $dict = from_json(scalar read_file $dict_file, { binmode => ":utf8" });

my %ctx = (
    lang => $lang,
    pinyin_sans_tone => {},
);

my %pinyin_sans_tone;

my %tones = ( "\x{304}" => 1 , "\x{301}" => 2, "\x{30c}" => 3 , "\x{300}" => 4 );
my $tone_re = "(" . join("|", keys %tones) . ")";

for (my $i = 0; $i < @$dict; $i++) {
    my $entry = $dict->[$i];
    my $title = $entry->{title};
    for my $heteronym (@{ $entry->{heteronyms} }) {
        next unless $heteronym->{pinyin};

        my @pinyin_tokens = map {
            split(/\s+/, $_)
        } grep {
            $_ ne '';
        } map {
            $_ = NFD($_);
            s/ɑ/a/g;
            s/([bcdfghjklmnpqrstwxyz])/ $1/ig;
            s/^ +//;
            $_;
        } map {
            split(/(?:\p{Punct}|<br>|陸⃝|陸|臺|-|[又語讀]音)/, $_)
        } split /\s*\(變\)\s*/, $heteronym->{pinyin};

        for my $p (@pinyin_tokens) {
            my $p0 = $p =~ s! $tone_re !!xgr =~ s/u\x{308}/v/gr;

            my $p1 = $p =~ s! $tone_re !$tones{$1}!xgr =~ s/u\x{308}/v/gr;
            $p1 =~ s{([1234])(\S+)}{$2$1}g;

            if ($p1 !~ /\A[ a-z1234]+\z/) {
                say STDERR "This looks weird: $title $p";
            } else {
                insert_index( \%ctx, $title, [$p0]);
            }
        }
    }
}

sort_index( \%ctx );
produce_lookup( \%ctx );

