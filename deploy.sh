#!/bin/bash
# Deploy moedict to remote
DST=ckhis.ck.tp.edu.tw:public_html/moedict/

rm -f p/index.json
rm -f n/index.json
cp nan/util/index.json n/
cp amis-data/index.json p/

rsync -avz --delete a about.html config.rb cordova.js css fonts h images index.html js main.js sass styles.css t p n $DST
