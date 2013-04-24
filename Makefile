run ::
	node ./static-here.js 8888 | lsc -cw main.ls | sass --watch styles.scss:styles.css 

upload ::
	rsync -avzP main.* styles.css index.html js moe0:code/
	rsync -avzP main.* styles.css index.html js moe1:code/

all :: data/0/100.html
	tar jxf data.tar.bz2
