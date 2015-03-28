#!/usr/bin/env python
# -*- coding: utf-8 -*-

import codecs
import json
import re
import csv
import json

twblg_entries_file = "moedict-data-twblg/uni/詞目總檔.csv"
attrs = ["1", "2", "5", "25"]

f = codecs.open(twblg_entries_file, "r", "utf-8", 'ignore')

def unicode_csv_reader(unicode_csv_data, dialect=csv.excel, **kwargs):
    csv_reader = csv.reader(utf_8_encoder(unicode_csv_data),
                            dialect=dialect, **kwargs)
    for row in csv_reader:
        yield [unicode(cell, 'utf-8') for cell in row]

def utf_8_encoder(unicode_csv_data):
    for line in unicode_csv_data:
        yield line.encode('utf-8')

entries = []
for row in unicode_csv_reader(f):
    if row[1] in attrs and re.search(ur"[⿰⿸]+", row[2], re.UNICODE) == None:
        entries.append((u' ' + row[2]).encode('utf-8').strip())

json.dump(sorted(entries), open("./t/index.json", "w"), ensure_ascii = False, encoding="utf-8", separators = (',', ':'), indent = 1)

