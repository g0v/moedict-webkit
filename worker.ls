require! \worker

lenToRegex = {}
lens = []
LTMRegexes = []

lang = process.env.lang || process.argv.2
require! fs
pre2 = JSON.parse fs.read-file-sync "#lang/lenToRegex.json"
init!

worker.dedicated({ proc })

function init ()
  lenToRegex := pre2.lenToRegex
  lens := []
  for len of lenToRegex
    lens.push len
    lenToRegex[len] = new RegExp lenToRegex[len], \g
  lens.sort (a, b) -> b - a
  for len in lens => LTM-regexes.push lenToRegex[len]

function proc (chunk, title, idx)
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
