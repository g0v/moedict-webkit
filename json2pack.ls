require! <[ fs ]>
entries = JSON.parse fs.read-file-sync \output.unicode.json
prefix = {}
defs = {}
buckets = {}
for {title, heteronyms} in entries
  continue if title is /\{\[[0-9a-f]{4}\]\}/
  continue unless heteronyms.0.bopomofo
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
  defs[title] ?= []
  defs[title].=concat heteronyms
  idx = code % 1024
  buckets[idx] ?= {}
  buckets[idx][title] = defs[title]
  fs.write-file-sync "api/data/#idx/#title.json" JSON.stringify defs[title]

fs.write-file-sync \prefix.json JSON.stringify prefix

for k, v of buckets
  console.log "#k => #{ Object.keys(v).length }"
  fs.write-file-sync "pack/#k.json" "{\n#{(for title, desc of v => """
    "#{ escape title }":"#{ escape JSON.stringify desc }"
  """) * ",\n"}\n}"
