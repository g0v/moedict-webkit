require! <[ fs os ]>
lang = process.argv.filter((in <[ a t h c ]>)).0
unless lang in <[ a t h c ]>
  console.log "Please invoke this program with a single-letter argument, one of <[ a t h c ]>."
  process.exit!
audio-map = JSON.parse(fs.read-file-sync \dict-concised.audio.json \utf8) if lang is \a
for k, v of audio-map
  k = k.replace(/\.（.*?）/ \.) - /，/g - /（.*）.*/
  audio-map[k] = v
  k = k - /\..*/
  audio-map[k] = v
LTM-regexes = []

require! \worker
pool = worker.pool "#{__dirname}/worker.js", os.cpus!length, env: {lang}

lenToRegex = {}
lens = []
##############
PUA2UNI = {
  \⿰𧾷百 : \󾜅
  \⿸疒哥 : \󿗧
  \⿰亻恩 : \󿌇
  \⿰虫念 : \󿑂
  \⿺皮卜 : \󿕅
}

grok = -> JSON.parse(
  "#{fs.read-file-sync it, \utf8}"
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
    .replace(/"specific_to":/g               \"S":)
    .replace(/[⿰⿸⿺](?:𧾷|.)./g          -> PUA2UNI[it] or process.exit console.log(it))
)

entries = switch lang
| \a => grok(\dict-revised.pua.json)
| \t => grok(\dict-twblg.json) ++ grok(\dict-twblg-ext.json)
| \h => grok(\dict-hakka.json)
| \c => grok(\dict-csld.json)

i = 0
todo = 0
seen = {}
for {t:title, h:heteronyms}:entry in entries
  continue if seen[title]
  seen[title] = true
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
    audio-title = title - /，/g
    audio-id = if i then audio-map["#audio-title.#b"] else audio-map["#audio-title.#b"] || (audio-map[title] if title.length > 1)
    heteronyms[i] <<< {"=": audio-id} if audio-id
  delete! entry<[ English francais Deutsch ]>
  chunk = JSON.stringify(entry).replace(
    /.[\u20E3\u20DE\u20DF\u20DD]/g -> escape it
  )
  pool.run(\proc, [chunk, title, idx]).then ->
    console.log it
    process.exit! unless --todo
