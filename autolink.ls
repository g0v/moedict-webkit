require! <[ fs ]>
precomputed = fs.read-file-sync \precomputed.json
pre2 = fs.read-file-sync \lenToRegex.json
LTM-regexes = []
Threads = require \webworker-threads
pool = Threads.create-pool 8
pool.all.eval("var precomputed = #precomputed;")
pool.all.eval("var pre2 = #pre2;")
pool.all.eval("var abbrevToTitle, lenToRegex, LTMRegexes = [];")
pool.all.eval(init);
pool.all.eval('init()');
pool.all.eval(proc);

{ abbrevToTitle, lenToRegex } = JSON.parse precomputed
function proc (struct, title, idx)
  chunk = JSON.stringify(struct)
  for re in LTM-regexes
    #chunk.=replace(re, -> escape """<a href='##{ (abbrevToTitle[it] || it) }'>#it</a>""")
    chunk.=replace(re, -> escape "`#it~")
  esc = escape title
  title .= replace(
    LTM-regexes[*-1]
    #-> """<a href='##{ abbrevToTitle[it] || it}'>#it</a>"""
    -> "`#it~"
  ) unless title.length is 1
  return "#idx #esc " + unescape(chunk).replace(/"t":""/, """
    "t":"#title"
  """)

function init ()
  abbrevToTitle := precomputed.abbrevToTitle
  lenToRegex := pre2.lenToRegex
  lens = []
  for len of lenToRegex
    lens.push len
    lenToRegex[len] = new RegExp lenToRegex[len], \g
  lens.sort (a, b) -> b - a
  for len in lens => LTM-regexes.push lenToRegex[len]

##############
grok = -> JSON.parse(
  "#{fs.read-file-sync it}"
    .replace(/"bopomofo2": "[^"]*",/g '')
    .replace(/"heteronyms"/g                \"h")
    .replace(/"bopomofo"/g                  \"b")
    .replace(/"pinyin"/g                    \"p")
    .replace(/"definitions"/g               \"d")
    .replace(/"stroke_count"/g              \"c")
    .replace(/"non_radical_stroke_count"/g  \"n")
    .replace(/"def"/g                       \"f")
    .replace(/"title"/g                     \"t")
    .replace(/"radical"/g                   \"r")
    .replace(/"example"/g                   \"e")
    .replace(/"link"/g                      \"l")
    .replace(/"synonyms"/g                  \"s")
    .replace(/"antonyms"/g                  \"a")
    .replace(/"quote"/g                     \"q")
    .replace(/"trs"/g                       \"T")
    .replace(/"alt"/g                       \"A")
    .replace(/"vernacular"/g                \"V")
    .replace(/"combined"/g                  \"C")
    .replace(/"dialects"/g                  \"D")
    .replace(/"id"/g                        \"_")
)
entries = grok(\dict-twblg.json) ++ grok(\dict-twblg-ext.json)
prefix = {}
i = 0
for {t:title, h:heteronyms}:entry in entries
  continue if title is /\{\[[0-9a-f]{4}\]\}/ # Unsubstituted
  continue if title is /\uDB40[\uDD00-\uDD0F]/ # Variant
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
  entry.t = ""
  title.=replace(
    LTM-regexes[*-1]
    #-> """<a href='##{ ( abbrevToTitle[it] || it) }'>#it</a>"""
    -> "`#it~"
  )
  idx = code % 1024
  chunk = JSON.stringify entry
  pool.any.eval "proc(#chunk, \"#title\", #idx)", (,x) -> console.log x
