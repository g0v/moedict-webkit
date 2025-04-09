run ::
	gulp run

dev ::
	gulp dev

build ::
	gulp build

deps ::
	npm i
	gulp build

worker.js :: worker.ls
	lsc -c worker.ls

js/deps.js ::
	gulp webpack:build

manifest :: js/deps.js
	perl -pi -e 's/# [A-Z].*\n/# @{[`date`]}/m' manifest.appcache

upload ::
	rsync -avzP server.* main.* view.* styles.css about.html index.html js root@moe0:code/

checkout ::
	-git clone --depth 1 https://github.com/g0v/moedict-data.git
	-git clone --depth 1 https://github.com/g0v/moedict-data-twblg.git
	-git clone --depth 1 https://github.com/g0v/moedict-data-hakka.git
	-git clone --depth 1 https://github.com/g0v/moedict-data-csld.git
	-git clone https://github.com/g0v/moedict-epub.git

moedict-data :: checkout symlinks pinyin

offline :: deps
	perl link2pack.pl a < a.txt
	perl link2pack.pl t < t.txt
	perl link2pack.pl h < h.txt
	-perl link2pack.pl c < c.txt
	perl special2pack.pl

symlinks :: translation
	ln -fs ../moedict-data/dict-revised-translated.json moedict-epub/dict-revised.json
	cd moedict-epub && perl json2unicode.pl             > dict-revised.unicode.json
	cd moedict-epub && perl json2unicode.pl sym-pua.txt > dict-revised.pua.json
	ln -fs moedict-epub/dict-revised.unicode.json          dict-revised.unicode.json
	ln -fs moedict-epub/dict-revised.pua.json              dict-revised.pua.json
	ln -fs moedict-data-twblg/dict-twblg.json              dict-twblg.json
	ln -fs moedict-data-twblg/dict-twblg-ext.json          dict-twblg-ext.json
	ln -fs moedict-data-hakka/dict-hakka.json              dict-hakka.json
	ln -fs moedict-data-csld/dict-csld.json                dict-csld.json

offline-dev :: offline moedict-data deps translation
	#lsc json2prefix.ls a
	#lsc autolink.ls a | perl sort-json.pl | env LC_ALL=C sort > a.txt
	#lsc json2prefix.ls t
	#lsc autolink.ls t | perl sort-json.pl | env LC_ALL=C sort > t.txt
	#lsc json2prefix.ls h
	#lsc autolink.ls h | perl sort-json.pl | env LC_ALL=C sort > h.txt
	#-lsc json2prefix.ls c
	#-lsc autolink.ls c | perl sort-json.pl | env LC_ALL=C sort > c.txt
	lsc cat2special.ls

csld :: worker.js
	python translation-data/csld2json.py
	cp translation-data/csld-translation.json dict-csld.json
	lsc json2prefix.ls c
	lsc autolink.ls c | perl sort-json.pl | env LC_ALL=C sort > c.txt
	perl link2pack.pl c < c.txt
	cp moedict-data-csld/index.json c/

hakka :: worker.js
	lsc json2prefix.ls h
	lsc autolink.ls h | perl sort-json.pl | env LC_ALL=C sort > h.txt
	perl link2pack.pl h < h.txt

twblg :: worker.js
	lsc json2prefix.ls t
	lsc autolink.ls t | perl sort-json.pl | env LC_ALL=C sort > t.txt
	perl link2pack.pl t < t.txt
	python twblg_index.py

pinyin ::
	perl build-pinyin-lookup.pl a
	perl build-pinyin-lookup.pl t
	perl build-pinyin-lookup.pl h
	perl build-pinyin-lookup.pl c

translation :: translation-data
	python translation-data/xml2txt.py
	python translation-data/txt2json.py
	cp translation-data/moe-translation.json moedict-data/dict-revised-translated.json

translation-data :: translation-data/handedict.txt translation-data/cedict.txt translation-data/cfdict.xml

translation-data/handedict.txt :
	cd translation-data && curl -L http://www.handedict.de/handedict/handedict-20110528.tar.bz2 | tar -Oxvj -f - handedict-20110528/handedict_nb.u8 > handedict.txt

translation-data/cedict.txt :
	cd translation-data && curl -L https://www.mdbg.net/chinese/export/cedict/cedict_1_0_ts_utf-8_mdbg.txt.gz | gunzip > cedict.txt

translation-data/cfdict.xml :
	cd translation-data && curl -L -O https://www.moedict.tw/translation-data/cfdict.xml

clean-translation-data ::
	rm -f translation-data/cfdict.xml translation-data/cedict.txt translation-data/handedict.txt

all :: data/0/100.html
	tar jxf data.tar.bz2

clean ::
	git clean -xdf

emulate ::
	make -C cordova emulate
