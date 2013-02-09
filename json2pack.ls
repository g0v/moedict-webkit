require! <[ fs ]>
entries = JSON.parse fs.read-file-sync \dict-revised.pua.json
prefix = {}
defs = {}
buckets = {}
i = 0
for {title, heteronyms}:entry in entries
  continue if title is /\{\[[0-9a-f]{4}\]\}/
  pre = title.slice(0, 1)
  code = pre.charCodeAt(0)
  if 0xD800 <= code <= 0xDBFF
    pre = title.slice(0, 2)
    code = pre.charCodeAt(1) - 0xDC00
    post = title.slice(2)
  else
    post = title.slice(1)
  prefix[pre] ?= ''
  prefix[pre] += "|#post" if post.length
  if defs[title]
    continue unless heteronyms?0?bopomofo
    defs[title] = [] unless defs[title].heteronyms?0?bopomofo
  defs[title] =concat entry
  idx = code % 1024
  buckets[idx] ?= {}
  buckets[idx][title] = defs[title]
#  fs.write-file-sync "api/data/#idx/#title.json" JSON.stringify defs[title]
  console.log i unless i++ % 1000

fs.write-file-sync \prefix.json JSON.stringify prefix

trie = prefix
abbrevToTitle = {}
lenToTitles = {}
lenToRegex = {}
lens = []
for k, v of trie
  prefix-length = k.length
  for suffix in v / '|'
    abbrevIndex = suffix.indexOf '('
    if abbrevIndex >= 0
      orig = suffix
      suffix.=slice(0, abbrevIndex)
      abbrevToTitle["#k#suffix"] = "#k#orig"
    (lenToTitles[prefix-length + suffix.length] ?= []).push "#k#suffix"

for len, titles of lenToTitles
  lens.push len
  titles.sort!
  lenToRegex[len] = (titles * \|).replace(/[-[\]{}()*+?.,\\#\s]/g, "\\$&")

fs.write-file-sync \precomputed.json JSON.stringify {
  abbrevToTitle
  lenToRegex
}

process.exit!
for k, v of buckets
  console.log "#k => #{ Object.keys(v).length }"
  fs.write-file-sync "pack/#k.json" "{\n#{(for title, desc of v => """
    "#{ escape title }":"#{ escape JSON.stringify desc }"
  """) * ",\n"}\n}"

