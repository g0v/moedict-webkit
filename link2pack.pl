#!/usr/bin/perl
use 5.14.0;
use utf8;
use Encode;
use File::Slurp;
open FH, '<:raw', 'autolinked.txt';
my %prepack;
my %seen;
while (<FH>) {
    chomp;
    s/^(\d+) (\S+) // or die $_;
    # s/\x{fffb}\K([^"]*)/$1 =~ s![`~]!!gr/eg;
    my $bucket = $1;
    my $title = $2;
    /"t":"([^"]+)"/ or die;
    my $file = (Encode::decode_utf8($1) =~ s![`~]!!gr);
    next if $file =~ /[⿰⿸]/;
    next if $seen{$file}++;
    File::Slurp::write_file("t/$file.json", $_);
    if ($prepack{$bucket}) {
        $prepack{$bucket} .= qq<\n,"$title":$_>
    }
    else {
        $prepack{$bucket} = qq<{"$title":$_>;
    }
}
while (my ($k, $v) = each %prepack) {
    $v .= "\n}\n";
    File::Slurp::write_file("pack/$k.txt", $v);
}
sub quote {
    $_[0] =~ s!([\x00-\x7f]|[\xc2-\xdf][\x80-\xbf]|[\xe0-\xef][\x80-\xbf]{2}|[\xf0-\xf4][\x80-\xbf]{3})!<a href='#$1'>$1</a>!gr;
}
