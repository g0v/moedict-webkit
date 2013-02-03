bz2 ::
	perl -e 'for (0..1023) { system("bzip2 -cz9 $$_.json | base64 > $$_.json.bz2.txt") }'

lz4 ::
	perl -e 'for (0..1023) { system("lz4demo.exe -c1 $$_.json | base64 > $$_.json.lz4.txt") }'

txt ::
	perl -e 'for (0..1023) { rename "$$_.json" => "$$_.json.txt" }'
