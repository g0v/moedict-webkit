const DEBUGGING = off

const MOE-ID = "萌"
isCordova = location.href is /^file:...android_asset/
isDeviceReady = not isCordova
document.addEventListener \deviceready (->
  try navigator.splashscreen.hide!
  isDeviceReady := yes
  window.do-load!
), false

window.show-info = ->
  ref = window.open \Android.html \_blank \location=no
  on-stop = ({url}) -> ref.close! if url is /quit\.html/
  on-exit = ->
    ref.removeEventListener \loadstop on-stop
    ref.removeEventListener \exit     on-exit
  ref.addEventListener \loadstop on-stop
  ref.addEventListener \exit     on-exit

window.do-load = ->
  return unless isDeviceReady
  $(window).on \hashchange -> grok-hash!
  $('body').addClass \cordova if isCordova

  init = ->
    $ \#query .keyup lookup .change lookup .keypress lookup .keydown lookup .on \input lookup
    $ \#query .on \focus -> @select!
    $ \#query .show!.focus!
    $ \a .on \click ->
      fill-query $(@).text!
      return false
    return if grok-hash!
    if isCordova or DEBUGGING
      fill-query MOE-ID
      $ \#query .val ''
    else
      fetch MOE-ID

  grok-hash = ->
    return false unless location.hash is /^#./
    try
      val = decodeURIComponent location.hash.substr 1
      return true if val is prevVal
      $ \#query .show!.focus!
      fill-query val
      return true if val is prevVal
    return false

  fill-query = ->
    $ \#query .val it
    input = $ \#query .get 0
    unless DEBUGGING or isCordova or navigator.userAgent is /Android|iPhone|iPad|Mobile/
      input.focus!
      try input.select!
    do-lookup it
    return true

  prevId = prevVal = null
  LTM-regexes = []
  lenToRegex = {}
  abbrevToTitle = {}

  lookup = -> do-lookup $(\#query).val!

  bucket-of = ->
    code = it.charCodeAt(0)
    if 0xD800 <= code <= 0xDBFF
      code = it.charCodeAt(1) - 0xDC00
    return code % 1024

  do-lookup = (val) ->
    return true if prevVal is val
    prevVal := val
    title = val - /\(.*/
    matched = title.match lenToRegex[title.length]
    return true unless matched
    id = matched.0
    id = abbrevToTitle[id] || id
    return true if prevId is id or id isnt val
    prevId := id
    try history.pushState null, null, "##val" unless "#{location.hash}" is "##val"
    fetch id
    return true

  htmlCache = {}
  fetch = ->
    return unless it
    return fill-json MOE if it is MOE-ID
    return if load-cache-html it
    $('#result div, #result span, #result h1').css \visibility \hidden
    $('#result h1:first').text(it).css \visibility \visible
    $.getJSON "api/data/#{ bucket-of it }/#it.json" fill-json

  load-cache-html = ->
    html = htmlCache[it]
    return false unless html
    $ \#result .html html
    window.scroll-to 0 0
    return true

  fill-html = (html) ->
    html.=replace(/(.)\u20DE/g, "</span><span class='part-of-speech'>$1</span><span>")
    $ \#result .html html
    $('#result h1').html (_, chunk) -> chunk.replace(
      LTM-regexes[*-1]
      -> """<a href="##{ abbrevToTitle[it] || it }">#it</a>"""
    )
    window.scroll-to 0 0
    spans = $('#result span').get!
    do-step = ->
      unless spans.length
        htmlCache[prevId || MOE-ID] = $('#result').html!
        return
      $span = $(spans.shift!)
      $span.html (_, chunk) ->
        for re in LTM-regexes
          chunk.=replace(re, -> escape """<a href="##{ abbrevToTitle[it] || it }">#it</a>""")
        unescape chunk
      setTimeout do-step, 1ms
    setTimeout do-step, 1ms

  fill-json = (struct) ->
    html = render(prevId || MOE-ID, struct)
    fill-html html

  bucketCache = {}

  fill-bucket = (id, bucket) ->
    raw = bucketCache[bucket]
    key = escape id
    idx = raw.indexOf "\"#key\""
    part = raw.slice(idx + key.length + 4)
    part = part.slice(0, part.indexOf '"')
    fill-json JSON.parse unescape part

  if isCordova or DEBUGGING => fetch = (id) ->
    return if load-cache-html id
    return fill-json MOE if id is MOE-ID
    bucket = bucket-of id
    return fill-bucket id, bucket if bucketCache[bucket]
    $('#result div, #result span, #result h1').css \visibility \hidden
    $('#result h1:first').text(id).css \visibility \visible
    txt <- $.get "pack/#bucket.json.gz.txt"
    json = ungzip txt
    bucketCache[bucket] = json
    return fill-bucket id, bucket

  trie <- $.getJSON \prefix.json

  lenToTitles = {}

  for k, v of trie
    prefix-length = k.length
    for suffix in v / '|'
      abbrevIndex = suffix.indexOf '('
      if abbrevIndex >= 0
        orig = suffix
        suffix.=slice(0, abbrevIndex)
        abbrevToTitle["#k#suffix"] = "#k#orig"
      (lenToTitles[prefix-length + suffix.length] ?= []).push "#k#suffix"

  lens = []
  for len, titles of lenToTitles
    lens.push len
    lenToRegex[len] = new RegExp (titles * \|).replace(/[-[\]{}()*+?.,\\#\s]/g, "\\$&"), \g

  lens.sort (a, b) -> b - a
  for len in lens => LTM-regexes.push lenToRegex[len]

  prefixEntries = {}
  prefixRegexes = {}

  $(\#query).autocomplete do
    position:
      my: "left bottom"
      at: "left top"
    select: (e, {item}) ->
      fill-query item.value if item?value
      return not(isCordova or DEBUGGING)
    change: (e, {item}) ->
      fill-query item.value if item?value
      return not(isCordova or DEBUGGING)
    source: ({term}, cb) ->
      return cb [] unless term.length
      pre = term.slice(0, 1)
      pre = term.slice(0, 2) if 0xD800 <= pre.charCodeAt(0) <= 0xDBFF
      return cb [] unless trie[pre]
      entries = prefixEntries[pre] ||= ["#pre#post" for post in trie[pre] / '|']
      return cb entries if term is pre
      regex = prefixRegexes[pre] ||= new RegExp "^#{
        trie[pre].replace(/[-[\]{}()*+?.,\\^$#\s]/g, "\\$&")
      }"
      while term.length
        return cb entries if term is pre
        continue unless regex.test term
        results = [ e for e in entries | e.index-of(term) is 0 ]
        if results.length is 1
          do-lookup results.0
          return cb []
        return cb results if results.length
        term = term.slice 0, -1
      return cb []
  return init!

const MOE = [{"bopomofo":"ㄇㄥˊ", "bopomofo2":"méng", "definitions":[ {"definition":"草木初生的芽。","pos":"名","quote":["說文解字：「萌，艸芽也。」","唐．韓愈､劉師服､侯喜､軒轅彌明．石鼎聯句：「秋瓜未落蒂，凍芋強抽萌。」"]},{"definition":"事物發生的開端或徵兆。","pos":"名","quote":["韓非子．說林上：「聖人見微以知萌，見端以知末。」","漢．蔡邕．對詔問灾異八事：「以杜漸防萌，則其救也。」"]},{"definition":"人民。通「氓」。如：「萌黎」､「萌隸」。","pos":"名"},{"definition":"姓。如五代時蜀有萌慮。","pos":"名"},{"definition":"發芽。","example":["如：「萌芽」。"],"pos":"動","quote":["楚辭．王逸．九思．傷時：「明風習習兮龢暖，百草萌兮華榮。」"]},{"definition":"發生。","example":["如：「故態復萌」。"],"pos":"動","quote":["管子．牧民：「惟有道者，能備患於未形也，故禍不萌。」","三國演義．第一回：「若萌異心，必獲惡報。」"]}],"hanyu_pinyin":"méng"} ]

function render (title, struct)
  return ls(for {bopomofo='', definitions=[]} in struct
    """
      <h1 class='title'>#{ h title }</h1>#{
        if bopomofo then "<div class='bopomofo'>#{
          h bopomofo
            .replace(/ /g, '\u3000')
            .replace(/([ˇˊˋ])\u3000/g, '$1 ')
      }</div>" else ''
      }<div>
      #{ls(for defs in groupBy \pos definitions.slice!
        """<div>
        #{ if defs.0.pos then "<span class='part-of-speech'>#{
          defs.0.pos
        }</span>" else ''}
        <ol>
        #{ls(for { pos, definition: def, quote=[], example=[], link=[] } in defs
          """<li><p class='definition'>
            <span class="def">#{
              (h expand-def def).replace(
                /([：。」])([\u278A-\u2793\u24eb-\u24f4])/g
                '$1</span><span class="def">$2'
              )
            }</span>
            #{ ls ["<span class='example'>#{ h x }</span>" for x in example] }
            #{ ls ["<span class='quote'>#{ h x }</span>" for x in quote] }
            #{ ls ["<span class='link'>#{ h x }</span>" for x in link] }
        </p></li>""")}</ol></div>
      """)}</div>
    """)
  function expand-def (def)
    def.replace(
      /^\s*<(\d)>\s*([介代副助動名嘆形連]?)/, (_, num, char) -> "#{
        String.fromCharCode(0x327F + parseInt num)
      }#{ if char then "#char\u20DE" else '' }"
    ).replace(
      /<(\d)>/g (_, num) -> String.fromCharCode(0x327F + parseInt num)
    ).replace(
      /[（(](\d)[)）]/g (_, num) -> String.fromCharCode(0x2789 + parseInt num)
    ).replace(/\(/g, '（').replace(/\)/g, '）')
  function ls (lines)
    lines.join ""
  function h (text='')
    text.replace(/</g '&lt;').replace(/>/g '&gt;')
  function groupBy (prop, xs)
    return [xs] if xs.length <= 1
    x = xs.shift!
    x[prop] ?= ''
    pre = [x]
    while xs.length
      y = xs.shift!
      y[prop] ?= ''
      break unless x[prop] is y[prop]
      pre.push y
    return [pre] unless xs.length
    return [pre, ...groupBy(prop, xs)]
