open FH, '<:raw', 'autolinked.txt';
my %prepack;
while (<FH>) {
    chomp;
    s/^(\d+) (\S+) // or die $_;
    my $bucket = $1;
    my $title = $2;
#    s/"title":"(.+)"/'"title":"'.quote($1).'"'/e or die $_;
#    s!<a href='#([^']+)'>\1</a>!<a>$1</a>!g;
    if ($prepack{$bucket}) {
        $prepack{$bucket} .= qq<\n,"$title":$_>
    }
    else {
        $prepack{$bucket} = qq<{"$title":$_>;
    }
}
require File::Slurp;
while (my ($k, $v) = each %prepack) {
    $v .= "\n}\n";
    File::Slurp::write_file("pack/$k.txt", $v);
}
sub quote {
    $_[0] =~ s!([\x00-\x7f]|[\xc2-\xdf][\x80-\xbf]|[\xe0-\xef][\x80-\xbf]{2}|[\xf0-\xf4][\x80-\xbf]{3})!<a href='#$1'>$1</a>!gr;
}
