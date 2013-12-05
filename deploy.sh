#!/bin/bash
# Deploy moedict to remote
DST=ckhis.ck.tp.edu.tw:public_html/moedict/

rsync -avz --delete a about.html config.rb cordova.js fonts h images index.html js main.js sass styles.css t p n $DST
