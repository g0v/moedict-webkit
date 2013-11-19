#!/usr/bin/env python
# -*- coding: utf-8 -*-

import codecs
import json
import re
from lxml import etree
from collections import defaultdict as dd

pinyinRE = re.compile(ur"(?P<pinyin>[^\]1-5A-Z]+\d)", re.UNICODE)
alphaRE = re.compile(ur"(?P<alpha>[A-Z]+)", re.UNICODE)

cfdictXMLFile = "./translation-data/cfdict.xml"
cfdictFile = "./translation-data/cfdict.txt"

#reading xml translation dictionnaries
def read_xml_dict(infile):
	f = codecs.open(infile, "r", "utf-8", 'ignore')
	parser = etree.XMLParser(recover=True)
	tree = etree.parse(f, parser=parser)
	root = tree.getroot()
	words = []
	for word in root.iter('word'):
		parsed_word = dd(list)
		for ele in word.iter():
			if ele.tag != None:
				if ele.text != None:
					text = ele.text.strip(' ')
					if ele.tag == 'pinyin':
						text = pinyinRE.sub(ur"\g<pinyin> ", text, re.UNICODE)
						text = alphaRE.sub(ur"\g<alpha> ", text, re.UNICODE)
						text = text.rstrip(' ')
					parsed_word[ele.tag].append(text)
		words.append(parsed_word)

	f.close()
	return words

cfdict = read_xml_dict(cfdictXMLFile)

f = codecs.open(cfdictFile, 'w', 'utf-8')
for item in cfdict:
	if len(item['traditional']) > 0:
		line = item['traditional'][0] + " " + item['simplified'][0] + " [" + item['pinyin'][0] + "] "
		for trans in item['translation']:
			line = line + "/" + trans
		if len(item['translation']) > 0:
			line = line + "/"
   		f.write(line)
		f.write("\n")

f.close()

