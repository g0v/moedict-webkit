require! <[ fs ]>
lang = process.argv.2
unless lang in <[ a t h ]>
  console.log "Please invoke this program with a single-letter argument, one of <[ a t h ]>."
  process.exit!
pre2 = fs.read-file-sync "#lang/lenToRegex.json"
audio-map = JSON.parse(fs.read-file-sync \dict-concised.audio.json \utf8) if lang is \a
for k, v of audio-map
  k = k.replace(/\.（.*?）/ \.) - /，/g - /（.*）.*/
  audio-map[k] = v
  k = k - /\..*/
  audio-map[k] = v
LTM-regexes = []
Threads = require \webworker-threads
pool = Threads.create-pool 8
pool.all.eval("var pre2 = #pre2;")
pool.all.eval("var lenToRegex, lens, LTMRegexes = [];")
pool.all.eval(init);
pool.all.eval('init()');
pool.all.eval(proc);

function proc (struct, title, idx)
  chunk = JSON.stringify(struct)
  for re in LTM-regexes
    chunk.=replace(re, -> escape "`#it~")
  esc = escape title
  codepoints-of = -> it.length - it.split( /[\uD800-\uDBFF][\uDC00-\uDFFF]/g ).length + 1
  title-codes = codepoints-of title
  for len in lens | len < title-codes
    title.=replace(lenToRegex[len], -> escape "`#it~")
  return "#idx #esc " + unescape(chunk).replace(/"t":""/, """
    "t":"#{ unescape title }"
  """)

lenToRegex = {}
lens = []
function init ()
  lenToRegex := pre2.lenToRegex
  lens := []
  for len of lenToRegex
    lens.push len
    lenToRegex[len] = new RegExp lenToRegex[len], \g
  lens.sort (a, b) -> b - a
  for len in lens => LTM-regexes.push lenToRegex[len]

##############
grok = -> JSON.parse(
  "#{fs.read-file-sync it}"
    .replace(/"bopomofo2": "[^"]*",/g        '')
    .replace(/"heteronyms":/g                \"h":)
    .replace(/"bopomofo":/g                  \"b":)
    .replace(/"pinyin":/g                    \"p":)
    .replace(/"definitions":/g               \"d":)
    .replace(/"stroke_count":/g              \"c":)
    .replace(/"non_radical_stroke_count":/g  \"n":)
    .replace(/"def":/g                       \"f":)
    .replace(/"title":/g                     \"t":)
    .replace(/"radical":/g                   \"r":)
    .replace(/"example":/g                   \"e":)
    .replace(/"link":/g                      \"l":)
    .replace(/"synonyms":/g                  \"s":)
    .replace(/"antonyms":/g                  \"a":)
    .replace(/"quote":/g                     \"q":)
    .replace(/"trs":/g                       \"T":)
    .replace(/"alt":/g                       \"A":)
    .replace(/"vernacular":/g                \"V":)
    .replace(/"combined":/g                  \"C":)
    .replace(/"dialects":/g                  \"D":)
    .replace(/"id":/g                        \"_":)
    .replace(/"audio_id":/g                  \"=":)
)

entries = switch lang
| \a => grok(\dict-revised.pua.json)
| \t => grok(\dict-twblg.json) ++ grok(\dict-twblg-ext.json)
| \h => grok(\dict-hakka.json)

i = 0
todo = 0
for {t:title, h:heteronyms}:entry in entries
  continue if title is /\{\[[0-9a-f]{4}\]\}/ # Unsubstituted
  continue if title is /\uDB40[\uDD00-\uDD0F]/ # Variant
  ++todo
  pre = title.slice(0, 1)
  code = pre.charCodeAt(0)
  if 0xD800 <= code <= 0xDBFF
    pre = title.slice(0, 2)
    code = pre.charCodeAt(1) - 0xDC00
  entry.t = ""
  idx = code % (if lang is \a then 1024 else 128)

  english-index = title.indexOf \(
  if english-index >= 0
    entry.english = title.slice(english-index + 1, -1)
    title = title.slice(0, english-index)
  if audio-map => for {b}, i in heteronyms
    break unless b
    b = b.replace(/ /g, '\u3000').replace(/([ˇˊˋ])\u3000/g, '$1').replace(/ /g, '\u3000')
    b = b - /^（.*）/ - /（.*）.*/
    title = title - /，/g
    audio-id = if i then audio-map["#title.#b"] else audio-map["#title.#b"] || audio-map[title]
    heteronyms[i] <<< {"=": audio-id} if audio-id
  delete entry<[ English francais Deutsch ]>
  chunk = JSON.stringify entry
  pool.any.eval "proc(#chunk, \"#title\", #idx)", (,x) ->
    console.log x
    process.exit! unless --todo
