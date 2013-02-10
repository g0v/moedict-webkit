require! <[ fs ]>
precomputed = fs.read-file-sync \precomputed.json
LTM-regexes = []
Threads = require \webworker-threads
pool = Threads.create-pool 8
pool.all.eval("var precomputed = #precomputed;")
pool.all.eval("var abbrevToTitle, lenToRegex, LTMRegexes = [];")
pool.all.eval(init);
pool.all.eval('init()');
pool.all.eval(proc);

{ abbrevToTitle, lenToRegex } = JSON.parse precomputed
function proc (struct, title, idx)
  chunk = JSON.stringify struct
  for re in LTM-regexes
    chunk.=replace(re, -> escape """<a href='##{ (abbrevToTitle[it] || it) }'>#it</a>""")
  title .= replace(
    LTM-regexes[*-1]
    -> """<a href='##{ abbrevToTitle[it] || it}'>#it</a>"""
  ) unless title.length is 1
  return "#idx " + unescape(chunk).replace(/"title":""/, """
    "title":"#title"
  """)

function init ()
  abbrevToTitle := precomputed.abbrevToTitle
  lenToRegex := precomputed.lenToRegex
  lens = []
  for len of lenToRegex
    lens.push len
    lenToRegex[len] = new RegExp lenToRegex[len], \g
  lens.sort (a, b) -> b - a
  for len in lens => LTM-regexes.push lenToRegex[len]


##############
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
  entry.title = ""
  title.=replace(
    LTM-regexes[*-1]
    -> """<a href='##{ ( abbrevToTitle[it] || it) }'>#it</a>"""
  )
  idx = code % 1024
  chunk = JSON.stringify entry
  pool.any.eval "proc(#chunk, \"#title\", #idx)", (,x) ->
    console.log x
    # console.log i unless i++ % 100
  /*
    console.log idx, x
    process.exit!
  );
  */
  /*
  entry.title = title
  defs[title] ?=[]
  defs[title] .=concat entry
  idx = code % 1024
  buckets[idx] ?= {}
  buckets[idx][title] = defs[title]
  */
#  fs.write-file-sync "api/data/#idx/#title.json" JSON.stringify defs[title]

/*
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
*/
