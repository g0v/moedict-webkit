const DEBUGGING = no
const MOE-ID = "萌"
isCordova = document.URL isnt /^https?:/
isDeviceReady = not isCordova
isCordova = true if DEBUGGING
isMobile = isCordova or navigator.userAgent is /Android|iPhone|iPad|Mobile/
entryHistory = []
Index = null

try
  throw unless isCordova and not DEBUGGING
  document.addEventListener \deviceready (->
    try navigator.splashscreen.hide!
    isDeviceReady := yes
    window.do-load!
  ), false
catch
  <- $
  $ \#F9868 .html '&#xF9868;'
  $ \#loading .text \載入中，請稍候…
  window.do-load!

window.show-info = ->
  ref = window.open \Android.html \_blank \location=no
  on-stop = ({url}) -> ref.close! if url is /quit\.html/
  on-exit = ->
    ref.removeEventListener \loadstop on-stop
    ref.removeEventListener \exit     on-exit
  ref.addEventListener \loadstop on-stop
  ref.addEventListener \exit     on-exit

callLater = -> setTimeout it, if isMobile then 10ms else 1ms

window.do-load = ->
  return unless isDeviceReady
  $('body').addClass \cordova if isCordova
  $('body').addClass \web unless isCordova
  $('body').addClass \ios if isCordova and window.device?platform? is /iOS|iPhone/

  cache-loading = no
  try document.addEventListener \backbutton (->
    return if cache-loading
    entryHistory.pop!
    token = Math.random!
    cache-loading := token
    setTimeout (-> cache-loading := no if cache-loading is token), 10000ms
    callLater ->
      id = if entryHistory.length then entryHistory[*-1] else MOE-ID
      $ \#query .val id
      $ \#cond .val "^#{id}$"
      fetch id
    return false
  ), false

  init = ->
    $ \#query .keyup lookup .change lookup .keypress lookup .keydown lookup .on \input lookup
    $ \#query .on \focus -> @select!
    $ \#query .show!.focus!

    if \onhashchange not in window
      $ \body .on \click \a ->
        val = $(@).attr(\href)
        val -= /.*\#/ if val
        val ||= $(@).text!
        return if val is $ \#query .val!
        $ \#query .val val
        $ \#cond .val "^#{val}$"
        fill-query val
        return false
    return if window.grok-hash!
    if isCordova
      fill-query MOE-ID
      $ \#query .val ''
    else
      fetch MOE-ID

  window.grok-hash = grok-hash = ->
    return false unless location.hash is /^#./
    try
      val = decodeURIComponent location.hash.substr 1
      return true if val is prevVal
      $ \#query .show!
      fill-query val
      return true if val is prevVal
    return false

  window.fill-query = fill-query = ->
    title = decodeURIComponent(it) - /[（(].*/
    $ \#query .val title
    $ \#cond .val "^#{title}$"
    input = $ \#query .get 0
    if isMobile
      try $(\#query).autocomplete \close
    else
      input.focus!
      try input.select!
    lookup title
    return true

  prevId = prevVal = null
  lenToRegex = {}

  bucket-of = ->
    code = it.charCodeAt(0)
    if 0xD800 <= code <= 0xDBFF
      code = it.charCodeAt(1) - 0xDC00
    return code % 1024

  lookup = -> do-lookup $(\#query).val!

  window.do-lookup = do-lookup = (val) ->
    title = val - /[（(].*/
    if isCordova or not Index
      return if title is /object/
      return true if Index and Index.indexOf("\"#title\"") is -1
      id = title
    else
      return true if prevVal is val
      prevVal := val
      return true unless Index.indexOf("\"#title\"") >= 0
      id = title
    return true if prevId is id or (id - /\(.*/) isnt (val - /\(.*/)
    $ \#cond .val "^#{title}$"
    entryHistory.push title
    $(\.back).show! if isCordova
    fetch title
    return true

  htmlCache = {}
  fetch = ->
    return unless it
    prevId := it
    prevVal := it
    try history.pushState null, null, "##it" unless "#{location.hash}" is "##it"
    if isMobile
      $('#result div, #result span, #result h1:not(:first)').hide!
      $('#result h1:first').text(it).show!
    else
      $('#result div, #result span, #result h1:not(:first)').css \visibility \hidden
      $('#result h1:first').text(it).css \visibility \visible
      window.scroll-to 0 0
    return if load-cache-html it
    return fill-json MOE if it is MOE-ID
    return load-json it

  load-json = (id) ->
    return $.get("a/#{ encodeURIComponent(id - /\(.*/)}.json", null, fill-json, \text) unless isCordova
    # Cordova
    bucket = bucket-of id
    return fill-bucket id, bucket if bucketCache[bucket]
    json <- $.get "pack/#bucket.txt"
    bucketCache[bucket] = json
    return fill-bucket id, bucket


  load-cache-html = ->
    html = htmlCache[it]
    return false unless html
    callLater ->
      $ \#result .html html
      cache-loading := no
    return true

  fill-html = (html) ->
    html.=replace /(.)\u20DE/g        "</span><span class='part-of-speech'>$1</span><span>"
    html.=replace //<a>([^<]+)</a>//g "<a href='\#$1'>$1</a>"
    id = prevId || MOE-ID
    htmlCache[id] = html
    callLater ->
      $ \#result .html html
      $('#result .part-of-speech a').attr \href, null
      cache-loading := no
    return

  fill-json = (part) ->
    part.=replace /"`辨~\u20DE&nbsp`似~\u20DE"[^}]*},{"f":"([^（]+)[^"]*"/g '"辨\u20DE 似\u20DE $1"'
    part.=replace /"([hbpdcnftrelsaq])"/g (, k) -> keyMap[k]
    part.=replace /`([^~]+)~/g (, word) -> "<a href='\##word'>#word</a>"
    if JSON?parse?
      html = render JSON.parse part
    else
      html = eval "render(#part)"
    fill-html html

  bucketCache = {}

  keyMap = {
    h: \"heteronyms" b: \"bopomofo" p: \"pinyin" d: \"definitions"
    c: \"stroke_count" n: \"non_radical_stroke_count" f: \"def"
    t: \"title" r: \"radical" e: \"example" l: \"link" s: \"synonyms"
    a: \"antonyms" q: \"quote"
  }

  fill-bucket = (id, bucket) ->
    raw = bucketCache[bucket]
    key = escape id
    idx = raw.indexOf('"' + key + '"');
    return if idx is -1
    part = raw.slice(idx + key.length + 3);
    idx = part.indexOf('\n')
    part = part.slice(0, idx)
    fill-json part

  $.get "a/index.json", null, init-autocomplete, \text
  return init!

const MOE = '{"h":[{"b":"ㄇㄥˊ","d":[{"f":"`草木~`初~`生~`的~`芽~。","q":["`說文解字~：「`萌~，`艸~`芽~`也~。」","`唐~．`韓愈~、`劉~`師~`服~、`侯~`喜~、`軒轅~`彌~`明~．`石~`鼎~`聯句~：「`秋~`瓜~`未~`落~`蒂~，`凍~`芋~`強~`抽~`萌~。」"],"type":"`名~"},{"f":"`事物~`發生~`的~`開端~`或~`徵兆~。","q":["`韓非子~．`說~`林~`上~：「`聖人~`見~`微~`以~`知~`萌~，`見~`端~`以~`知~`末~。」","`漢~．`蔡邕~．`對~`詔~`問~`灾~`異~`八~`事~：「`以~`杜漸防萌~，`則~`其~`救~`也~。」"],"type":"`名~"},{"f":"`人民~。","e":["`如~：「`萌黎~」、「`萌隸~」。"],"l":["`通~「`氓~」。"],"type":"`名~"},{"f":"`姓~。`如~`五代~`時~`蜀~`有~`萌~`慮~。","type":"`名~"},{"f":"`發芽~。","e":["`如~：「`萌芽~」。"],"q":["`楚辭~．`王~`逸~．`九思~．`傷~`時~：「`明~`風~`習習~`兮~`龢~`暖~，`百草~`萌~`兮~`華~`榮~。」"],"type":"`動~"},{"f":"`發生~。","e":["`如~：「`故態復萌~」。"],"q":["`管子~．`牧民~：「`惟~`有道~`者~，`能~`備~`患~`於~`未~`形~`也~，`故~`禍~`不~`萌~。」","`三國演義~．`第一~`回~：「`若~`萌~`異心~，`必~`獲~`惡報~。」"],"type":"`動~"}],"p":"méng"}],"n":8,"r":"`艸~","c":12,"t":"萌"}'

function init-autocomplete (text)
  Index := text
  $(\#query).autocomplete do
    position:
      my: "left bottom"
      at: "left top"
    select: (e, {item}) ->
      return false if item?value is /^\(/
      fill-query item.value if item?value
      return true
    change: (e, {item}) ->
      return false if item?value is /^\(/
      fill-query item.value if item?value
      return true
    source: ({term}, cb) ->
      return cb [] unless term.length
      return cb [] unless term is /[^\u0000-\u00FF]/
      term.=replace(/\*/g '%')
      regex = term
      if term is /\s$/ or term is /\^/
        regex -= /\^/g
        regex -= /\s*$/g
        regex = '"' + regex
      else
        regex = '[^"]*' + regex unless term is /[?._%]/
      if term is /^\s/ or term is /\$/
        regex -= /\$/g
        regex -= /\s*/g
        regex += '"'
      else
        regex = regex + '[^"]*' unless term is /[?._%]/
      regex -= /\s/g
      if term is /[%?._]/
        regex.=replace(/[?._]/g, '[^"]')
        regex.=replace(/%/g '[^"]*')
        regex = "\"#regex\""
      regex.=replace(/\(\)/g '')
      results = try Index.match(//#regex//g)
      return cb [''] unless results
      do-lookup(results.0 - /"/g) if results.length is 1
      MaxResults = 255 # (if isCordova then 100 else 1000)
      if results.length > MaxResults
        more = "( 僅示前 #MaxResults 筆 )"
        results.=slice(0, MaxResults)
        results.push more
      return cb ((results.join(',') - /"/g) / ',')

function render ({ title, heteronyms, radical, non_radical_stroke_count: nrs-count, stroke_count: s-count})
  char-html = if radical then "<div class='radical'><span class='glyph'>#{
    radical - /<\/?a[^>]*>/g
  }</span><span class='count'><span class='sym'>+</span>#{ nrs-count }</span><span class='count'> = #{ s-count }</span> 畫</div>" else ''
  return ls heteronyms, ({bopomofo, pinyin, definitions=[]}) ->
    """#char-html
      <h1 class='title'>#{ h title }</h1>#{
        if bopomofo then "<div class='bopomofo'>#{
            if pinyin then "<span class='pinyin'>#{ h pinyin
              .replace(/（.*）/, '')
            }</span>" else ''
          }#{ h bopomofo
            .replace(/ /g, '\u3000')
            .replace(/([ˇˊˋ])\u3000/g, '$1 ')
          }</div>" else ''
      }<div class="entry">
      #{ls groupBy(\type definitions.slice!), (defs) ->
        """<div>
        #{ if defs.0.type then "<span class='part-of-speech'>#{
          defs.0.type
        }</span>" else ''}
        <ol>
        #{ls defs, ({ type, def, quote=[], example=[], link=[], antonyms, synonyms }) ->
          """<li><p class='definition'>
            <span class="def">#{
              (h expand-def def).replace(
                /([：。」])([\u278A-\u2793\u24eb-\u24f4])/g
                '$1</span><span class="def">$2'
              )
            }</span>
            #{ ls example, -> "<span class='example'>#{ h it }</span>" }
            #{ ls quote,   -> "<span class='quote'>#{   h it }</span>" }
            #{ ls link,    -> "<span class='link'>#{    h it }</span>" }
            #{ if synonyms then "<span class='synonyms'><span class='part-of-speech'>似</span> #{
              h(synonyms.replace(/,/g '、'))
            }</span>" else '' }
            #{ if antonyms then "<span class='antonyms'><span class='part-of-speech'>反</span> #{
              h(antonyms.replace(/,/g '、'))
            }</span>" else '' }
        </p></li>"""}</ol></div>
      """}</div>
    """
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
  function ls (entries=[], cb)
    [cb x for x in entries].join ""
  function h (text='')
    # text.replace(/</g '&lt;').replace(/>/g '&gt;')
    text
  function groupBy (prop, xs)
    return [xs] if xs.length <= 1
    x = xs.shift!
    x[prop] ?= ''
    pre = [x]
    while xs.length
      y = xs.0
      y[prop] ?= ''
      break unless x[prop] is y[prop]
      pre.push xs.shift!
    return [pre] unless xs.length
    return [pre, ...groupBy(prop, xs)]
