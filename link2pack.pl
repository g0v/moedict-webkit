#!/usr/bin/perl
use 5.14.0;
use utf8;
my $lang = shift;
unless ($lang ~~ [qw[ t a ]] and not -t STDIN) {
    die << '.';
Please invoke this as one of:
    perl link2pack.pl a < a.txt
    perl link2pack.pl t < t.txt
.
}
use Encode;
use File::Slurp;
binmode STDIN, ':raw';
my %prepack;
my %seen;
mkdir $lang;
mkdir "p${lang}ck";
while (<STDIN>) {
    chomp;
    s/^(\d+) (\S+) // or die $_;
    # s/\x{fffb}\K([^"]*)/$1 =~ s![`~]!!gr/eg;
    my $bucket = $1;
    my $title = $2;
    /"t":"([^"]+)"/ or die;
    my $file = (Encode::decode_utf8($1) =~ s![`~]!!gr);
    next if $file =~ /[⿰⿸]/;
    next if $seen{$file}++;
    File::Slurp::write_file("$lang/$file.json", $_);
    if ($prepack{$bucket}) {
        $prepack{$bucket} .= qq<\n,"$title":$_>
    }
    else {
        $prepack{$bucket} = qq<{"$title":$_>;
    }
}

mkdir "p${lang}ck" unless -e "p${lang}ck";
while (my ($k, $v) = each %prepack) {
    $v .= "\n}\n";
    File::Slurp::write_file("p${lang}ck/$k.txt", $v);
}
