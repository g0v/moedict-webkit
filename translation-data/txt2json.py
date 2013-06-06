#!/usr/bin/env python
# -*- coding: utf8 -*-

import codecs
import json
import re
from collections import defaultdict as dd

fwdictRE = re.compile(ur"(?P<tradi>[^ ]+) +(?P<simpl>[^ ]+) +\[(?P<pinyin>[^\]]+)\] +(?P<def>\/.*)$",re.UNICODE)

cedictFile = "./translation-data/cedict.txt"
cfdictFile = "./translation-data/cfdict.txt"
handedictFile = "./translation-data/handedict.txt"
moedictFile = "./moedict-data/dict-revised.json"


#reading translation dictionnaries
def read_dict(infile):
    fwdict = dd(list)
    f = codecs.open(infile,"r","utf8")
    for l in f:
        l = l.strip()
        if l == "" or l[0] == "#":
            continue
        match = fwdictRE.search(l)
        if not match:
            print l
            continue
        fwdict[match.group("tradi")].extend(match.group("def").replace("(u.E.)","")[1:-1].split("/"))
    return fwdict

cedict = read_dict(cedictFile)
handedict = read_dict(handedictFile)
cfdict = read_dict(cfdictFile)

#loading moedict

moedict = json.load(open(moedictFile))

#injecting cedict in moedict
for i in range(0,len(moedict)):
    form = moedict[i]["title"]
    for lang,fwdict in [("English",cedict),("francais",cfdict),("Deutsch",handedict)]:
        if form in fwdict:
            if not "translation" in moedict[i]:
                moedict[i]["translation"] = {}
            moedict[i]["translation"][lang] = fwdict[form]
	    moedict[i][lang] = fwdict[form][0]

# saving
json.dump(moedict,open("./translation-data/moe-translation.json","w"))

