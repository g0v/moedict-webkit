const DEBUGGING = no

const MOE-ID = "萌"
isCordova = navigator?notification?alert?
isDeviceReady = not isCordova
isCordova = true if DEBUGGING
isMobile = isCordova or navigator.userAgent is /Android|iPhone|iPad|Mobile/
entryHistory = []

try document.addEventListener \deviceready (->
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

callLater = -> setTimeout it, if isMobile then 10ms else 1ms

window.do-load = ->
  return unless isDeviceReady
  $('body').addClass \cordova if isCordova
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
    return if grok-hash!
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
  LTM-regexes = []
  lenToRegex = {}
  abbrevToTitle = {}

  bucket-of = ->
    code = it.charCodeAt(0)
    if 0xD800 <= code <= 0xDBFF
      code = it.charCodeAt(1) - 0xDC00
    return code % 1024

  lookup = -> do-lookup $(\#query).val!

  window.do-lookup = do-lookup = (val) ->
    title = val - /[（(].*/
    if isCordova or LTM-regexes.length is 0
      return if title is /object/
      id = title
    else
      return true if prevVal is val
      prevVal := val
      regex = lenToRegex[title.length]
      switch typeof regex
      | \function => matched = regex title
      | \string   =>
        lenToRegex[title.length] = new RegExp regex, \g
        matched = lenToRegex[title.length].match regex
      | _         => matched = title.match regex
      return true unless matched
      id = matched?0
      id = abbrevToTitle[id] || id
    return true if prevId is id or (id - /\(.*/) isnt (val - /\(.*/)
    $ \#cond .val "^#{val}$"
    entryHistory.push val
    $(\.back).show! if isCordova
    fetch id
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
    load-json it

  load-json = (char) ->
    <- $.getJSON("pua/#{ encodeURIComponent char }.json" fill-json).fail
    <- $.getJSON("raw/#{ encodeURIComponent char }.json" fill-json).fail
    alert "錯誤：找不到詞「#{char}」"

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
    if html is /<\/a>/
      htmlCache[id] = html
      callLater ->
        $ \#result .html html
        $('#result .part-of-speech a').attr \href, null
        cache-loading := no
      return

    $ \#result .html html
    fill-autolink!

  fill-autolink = ->
    return call-later fill-autolink unless LTM-regexes.length
    $('#result h1').html (_, chunk) -> if chunk.length > 1 then chunk.replace(
      LTM-regexes[*-1]
      -> """<a href="##{ encodeURIComponent( abbrevToTitle[it] || it) }">#it</a>"""
    ) else chunk
    entries = $('#result .entry').get!
    do-step = ->
      unless entries.length
        $('#result .part-of-speech a').attr \href, null
        htmlCache[id] = $('#result').html! if prevId is id
        cache-loading := no
        return
      $entry = $(entries.shift!)
      $entry.html (_, chunk) ->
        for re in LTM-regexes
          chunk.=replace(re, -> escape """<a href="##{ encodeURIComponent(abbrevToTitle[it] || it) }">#it</a>""")
        unescape chunk
      callLater do-step
    callLater do-step

  fill-json = (struct) ->
    struct = struct.dict if struct.dict
    struct = struct.0 if struct.0
    html = render struct
    fill-html html

  bucketCache = {}

  fill-bucket = (id, bucket) ->
    raw = bucketCache[bucket]
    key = escape(abbrevToTitle[id] || id)
    idx = raw.indexOf("%22" + key + "%22");
    return if idx is -1
    part = raw.slice(idx + key.length + 9);
    idx = part.indexOf('%2C%0A')
    idx = part.indexOf('%0A') if idx is -1
    part = part.slice(0, idx)
    fill-json JSON.parse unescape part

  if isCordova
    load-json = (id) ->
      bucket = bucket-of id
      return fill-bucket id, bucket if bucketCache[bucket]
      txt <- $.get "pack/#bucket.json.gz.txt"
      json = ungzip txt
      bucketCache[bucket] = json
      return fill-bucket id, bucket
    $.getJSON \precomputed.json (blob) ->
      abbrevToTitle := blob.abbrevToTitle
      $.getJSON \prefix.json (trie) ->
        setup-autocomplete trie
    return init!

  init!
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
    titles.sort!
    try
      lenToRegex[len] = new RegExp (titles * \|).replace(/[-[\]{}()*+?.,\\#\s]/g, "\\$&"), \g
    catch
      $.ajax {
          type: \GET
          url: "lenToRegex.#len.json"
          async: false
          dataType: \json
          success: (data) -> lenToRegex[len] = new RegExp data[len], \g
      }

  lens.sort (a, b) -> b - a
  for len in lens => LTM-regexes.push lenToRegex[len]

  setup-autocomplete trie

const MOE = {"heteronyms":[{"bopomofo":"ㄇㄥˊ","bopomofo2":"méng","definitions":[{"def":"<a>草木</a><a>初</a><a>生</a><a>的</a><a>芽</a>。","quote":["<a>說文解字</a>：「<a>萌</a>，<a>艸</a><a>芽</a><a>也</a>。」","<a>唐</a>．<a>韓愈</a>、<a>劉</a><a>師</a><a>服</a>、<a>侯</a><a>喜</a>、<a>軒轅</a><a>彌</a><a>明</a>．<a>石</a><a>鼎</a><a>聯句</a>：「<a>秋</a><a>瓜</a><a>未</a><a>落</a><a>蒂</a>，<a>凍</a><a>芋</a><a>強</a><a>抽</a><a>萌</a>。」"],"type":"<a>名</a>"},{"def":"<a>事物</a><a>發生</a><a>的</a><a>開端</a><a>或</a><a>徵兆</a>。","quote":["<a>韓非子</a>．<a>說</a><a>林</a><a>上</a>：「<a>聖人</a><a>見</a><a>微</a><a>以</a><a>知</a><a>萌</a>，<a>見</a><a>端</a><a>以</a><a>知</a><a>末</a>。」","<a>漢</a>．<a>蔡邕</a>．<a>對</a><a>詔</a><a>問</a><a>灾</a><a>異</a><a>八</a><a>事</a>：「<a>以</a><a>杜漸防萌</a>，<a>則</a><a>其</a><a>救</a><a>也</a>。」"],"type":"<a>名</a>"},{"def":"<a>人民</a>。","example":["<a>如</a>：「<a>萌黎</a>」、「<a>萌隸</a>」。"],"link":["<a>通</a>「<a>氓</a>」。"],"type":"<a>名</a>"},{"def":"<a>姓</a>。<a>如</a><a>五代</a><a>時</a><a>蜀</a><a>有</a><a>萌</a><a>慮</a>。","type":"<a>名</a>"},{"def":"<a>發芽</a>。","example":["<a>如</a>：「<a>萌芽</a>」。"],"quote":["<a>楚辭</a>．<a>王</a><a>逸</a>．<a>九思</a>．<a>傷</a><a>時</a>：「<a>明</a><a>風</a><a>習習</a><a>兮</a><a>龢</a><a>暖</a>，<a>百草</a><a>萌</a><a>兮</a><a>華</a><a>榮</a>。」"],"type":"<a>動</a>"},{"def":"<a>發生</a>。","example":["<a>如</a>：「<a>故態復萌</a>」。"],"quote":["<a>管子</a>．<a>牧民</a>：「<a>惟</a><a>有道</a><a>者</a>，<a>能</a><a>備</a><a>患</a><a>於</a><a>未</a><a>形</a><a>也</a>，<a>故</a><a>禍</a><a>不</a><a>萌</a>。」","<a>三國演義</a>．<a>第一</a><a>回</a>：「<a>若</a><a>萌</a><a>異心</a>，<a>必</a><a>獲</a><a>惡報</a>。」"],"type":"<a>動</a>"}],"pinyin":"méng"}],"non_radical_stroke_count":"8","radical":"<a>艸</a>","stroke_count":"12","title":"萌"}

function setup-autocomplete (trie)
  prefixEntries = {}
  prefixRegexes = {}
  $(\#query).autocomplete do
    position:
      my: "left bottom"
      at: "left top"
    select: (e, {item}) ->
      fill-query item.value if item?value
      return true
    change: (e, {item}) ->
      fill-query item.value if item?value
      return true
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
