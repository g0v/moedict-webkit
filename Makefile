run ::
	lsc -cw main.ls &
	static-here

all :: data/0/100.html
	tar jxf data.tar.bz2
