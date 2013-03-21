run ::
	lsc -cw main.ls &
	static-here

upload ::
	rsync -avzP main.* styles.css index.html js moe0:code/
	rsync -avzP main.* styles.css index.html js moe1:code/

all :: data/0/100.html
	tar jxf data.tar.bz2
