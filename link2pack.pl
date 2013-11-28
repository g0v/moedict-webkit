#!/usr/bin/perl
use utf8;
use 5.008;
use Encode;
my $lang = shift;
unless ($lang =~ /^[tahcp]/ and not -t STDIN) {
    die << '.';
Please invoke this as one of:
    perl link2pack.pl a < a.txt
    perl link2pack.pl t < t.txt
    perl link2pack.pl h < h.txt
    perl link2pack.pl c < c.txt
    perl link2pack.pl p < p.txt
.
}
binmode STDIN, ':raw';
my %prepack;
my %seen;
mkdir $lang;
mkdir "p${lang}ck";
while (<STDIN>) {
    print STDERR "$.\n" unless $. % 10000;
    chomp;
    s/^(\d+) (\S+) // or die $_;
    # s/\x{fffb}\K([^"]*)/$1 =~ s![`~]!!gr/eg;
    my $bucket = $1;
    my $title = $2;
    /"t":"([^"]+)"/ or die;
    my $file = Encode::decode_utf8($1);
    $file =~ s![`~]!!g;
    next if $file =~ /[⿰⿸⿺]/;
    next if $seen{$file}++;
    s/`\{~/{/g;
    unless (-e "$lang/$file.json" and read_file("$lang/$file.json") eq $_) {
        write_file("$lang/$file.json", $_);
    }
    if ($prepack{$bucket}) {
        $prepack{$bucket} .= qq<\n,"$title":$_>
    }
    else {
        $prepack{$bucket} = qq<{"$title":$_>;
    }
}

mkdir "p${lang}ck" unless -e "p${lang}ck";
mkdir "ios/www/p${lang}ck" unless -e "ios/www/p${lang}ck";
while (my ($k, $v) = each %prepack) {
    $v .= "\n}\n";
    write_file("p${lang}ck/$k.txt", $v);
}

sub write_file { open my $fh, '>', shift(@_) or die "Cannot write to: @_ - $!"; print $fh @_; }
sub read_file { local $/; open my $fh, '<', shift(@_) or die $!; <$fh>; }
