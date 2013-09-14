use strict;
use Encode;
for my $special (qw[ = @ ]) {
    for my $lang (qw[ a ]) {
        my @files = sort glob("$lang/$special*.json") or next;
        open my $out, '>:raw', "p${lang}ck/$special.txt";
        select $out;
        print "{";
        for my $file (@files) {
            my $payload = do { open my $fh, '<:raw', $file; local $/; <$fh>; };
            my $escaped = $file;
            $escaped =~ s!.*/!!;
            $escaped =~ s!\.json!!;
            $escaped =~ s!=!%3D!g;
            Encode::_utf8_on($escaped);
            $escaped =~ s!([^\x00-\xff])!sprintf '%%u%04X', ord $1!eg;
            Encode::_utf8_off($escaped);
            print "," unless $file eq $files[0];
            print qq["$escaped":$payload\n];
        }
        print "}\n";
        close $out;
    }
}
