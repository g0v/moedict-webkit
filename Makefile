run ::
	node ./static-here.js 8888 | lsc -cw main.ls | jade -Pw index.jade | compass watch

upload ::
	rsync -avzP main.* styles.css index.html js moe0:code/
	rsync -avzP main.* styles.css index.html js moe1:code/

deps ::
	npm install webworker-threads

checkout ::
	-git clone --depth 1 https://github.com/g0v/moedict-data.git
	-git clone --depth 1 https://github.com/g0v/moedict-data-twblg.git
	-git clone --depth 1 https://github.com/g0v/moedict-data-hakka.git
	-git clone --depth 1 https://github.com/g0v/moedict-data-csld.git
	-git clone https://github.com/g0v/moedict-epub.git
	-git clone --depth 1 https://github.com/miaoski/amis-data.git
	-hg clone https://bitbucket.org/pcchen/nan

moedict-data :: checkout

offline :: moedict-data deps translation
	ln -fs ../moedict-data/dict-revised-translated.json moedict-epub/dict-revised.json
	cd moedict-epub && perl json2unicode.pl             > dict-revised.unicode.json
	cd moedict-epub && perl json2unicode.pl sym-pua.txt > dict-revised.pua.json
	ln -fs moedict-epub/dict-revised.unicode.json          dict-revised.unicode.json
	ln -fs moedict-epub/dict-revised.pua.json              dict-revised.pua.json
	ln -fs moedict-data-twblg/dict-twblg.json              dict-twblg.json
	ln -fs moedict-data-twblg/dict-twblg-ext.json          dict-twblg-ext.json
	ln -fs moedict-data-hakka/dict-hakka.json              dict-hakka.json
	ln -fs moedict-data-csld/dict-csld.json                dict-csld.json
	cd amis-data && python moedict.py
	ln -fs amis-data/dict-amis.json                        dict-amis.json
	cd nan/util && ./moedict.sh
	ln -fs nan/util/dict-nan.json                          dict-nan.json
	lsc json2prefix.ls a
	lsc autolink.ls a > a.txt
	perl link2pack.pl a < a.txt
	lsc json2prefix.ls t
	lsc autolink.ls t > t.txt
	perl link2pack.pl t < t.txt
	lsc json2prefix.ls h
	lsc autolink.ls h > h.txt
	perl link2pack.pl h < h.txt
	-lsc json2prefix.ls c
	-lsc autolink.ls c > c.txt
	-perl link2pack.pl c < c.txt
	lsc json2prefix.ls p
	lsc autolink.ls p > p.txt
	perl link2pack.pl p < p.txt
	cd p && ln -fs ../amis-data/index.json                 index.json
	lsc json2prefix.ls n
	lsc autolink.ls n > n.txt
	perl link2pack.pl n < n.txt
	cd n && ln -fs ../nan/util/index.json                  index.json
	perl special2pack.pl

csld ::
	python translation-data/csld2json.py
	cp translation-data/csld-translation.json dict-csld.json
	lsc json2prefix.ls c
	lsc autolink.ls c > c.txt
	perl link2pack.pl c < c.txt

hakka ::
	cp ../hakka/dict-hakka.json .
	lsc json2prefix.ls h
	lsc autolink.ls h > h.txt
	perl link2pack.pl h < h.txt

twblg ::
	lsc json2prefix.ls t
	lsc autolink.ls t > t.txt
	perl link2pack.pl t < t.txt

nan ::
	lsc json2prefix.ls n
	lsc autolink.ls n > n.txt
	perl link2pack.pl n < n.txt

amis ::
	lsc json2prefix.ls p
	lsc autolink.ls p > p.txt
	perl link2pack.pl p < p.txt

translation :: moedict-data
	cd translation-data && curl http://www.mdbg.net/chindict/export/cedict/cedict_1_0_ts_utf-8_mdbg.txt.gz | gunzip > cedict.txt
	cd translation-data && curl http://www.handedict.de/handedict/handedict-20110528.tar.bz2 | tar -Oxvj -f - handedict-20110528/handedict_nb.u8 > handedict.txt
	cd translation-data && curl -O 'http://www.chine-informations.com/chinois/open/CFDICT/cfdict_xml.zip' && unzip cfdict_xml.zip && rm cfdict_xml.zip
	python translation-data/xml2txt.py
	python translation-data/txt2json.py
	cp translation-data/moe-translation.json moedict-data/dict-revised-translated.json

all :: data/0/100.html
	tar jxf data.tar.bz2
