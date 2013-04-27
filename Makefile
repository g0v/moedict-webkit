run ::
	node ./static-here.js 8888 | lsc -cw main.ls | sass --watch styles.scss:styles.css 

upload ::
	rsync -avzP main.* styles.css index.html js moe0:code/
	rsync -avzP main.* styles.css index.html js moe1:code/

moedict-data/dict-revised.json :: checkout


deps ::
	npm install webworker-threads

checkout ::
	-git clone https://github.com/g0v/moedict-data.git
	-git clone https://github.com/g0v/moedict-epub.git
	-git clone https://github.com/g0v/moedict-data-twblg.git

data :: moedict-data/dict-revised.json
	cd moedict-data && perl ../moedict-epub/json2unicode.pl > dict-revised.unicode.json
	cp -v moedict-data-twblg/dict-twblg.json .
	cp -v moedict-data-twblg/dict-twblg-ext.json .
	livescript json2prefix.ls

all :: data/0/100.html
	tar jxf data.tar.bz2
