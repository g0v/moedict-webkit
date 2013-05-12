run ::
	node ./static-here.js 8888 | lsc -cw main.ls | sass --watch styles.scss:styles.css 

upload ::
	rsync -avzP main.* styles.css index.html js moe0:code/
	rsync -avzP main.* styles.css index.html js moe1:code/

deps ::
	npm install webworker-threads

checkout ::
	-git clone --depth 1 https://github.com/g0v/moedict-data.git
	-git clone --depth 1 https://github.com/g0v/moedict-data-twblg.git
	-git clone https://github.com/g0v/moedict-epub.git

moedict-data :: checkout

offline :: moedict-data deps
	ln -fs ../moedict-data/dict-revised.json moedict-epub/dict-revised.json
	cd moedict-epub && perl json2unicode.pl             > dict-revised.unicode.json
	cd moedict-epub && perl json2unicode.pl sym-pua.txt > dict-revised.pua.json
	ln -fs moedict-epub/dict-revised.unicode.json          dict-revised.unicode.json
	ln -fs moedict-epub/dict-revised.pua.json              dict-revised.pua.json
	ln -fs moedict-data-twblg/dict-twblg.json              dict-twblg.json 
	ln -fs moedict-data-twblg/dict-twblg-ext.json          dict-twblg-ext.json 
	lsc json2prefix.ls a
	lsc autolink.ls a > a.txt
	perl link2pack.pl a < a.txt
	lsc json2prefix.ls t
	lsc autolink.ls t > t.txt
	perl link2pack.pl t < t.txt

all :: data/0/100.html
	tar jxf data.tar.bz2
