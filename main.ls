const DEBUGGING = no

LANG = getPref(\lang) || (if document.URL is /twblg/ then \t else \a)
MOE-ID = getPref(\prev-id) || {a: \萌 t: \發穎 h: \發芽}[LANG]
$ -> $('body').addClass("lang-#LANG")

isCordova = document.URL isnt /^https?:/
isDeviceReady = not isCordova
isCordova = true if DEBUGGING
isMobile = isCordova or navigator.userAgent is /Android|iPhone|iPad|Mobile/
isWebKit = navigator.userAgent is /WebKit/
entryHistory = []
Index = null
XREF = { t: '"發穎":"萌,抽芽,發芽,萌芽"', a: '"萌":"發穎"' }

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
  if document.URL is /http:\/\/(?:www.)?moedict.tw/i
    url = "https://www.moedict.tw/"
    url += location.hash if location.hash is /^#./
    location.replace url
  else
    window.do-load!
    if navigator.user-agent is /MSIE\s+[678]/
      <- $.getScript \https://ajax.googleapis.com/ajax/libs/chrome-frame/1/CFInstall.min.js
      window.gcfnConfig = do
        imgpath: 'https://raw.github.com/atomantic/jquery.ChromeFrameNotify/master/img/'
        msgPre: ''
        msgLink: '敬請安裝 Google 內嵌瀏覽框，以取得更完整的萌典功能。'
        msgAfter: ''
      <- $.getScript \https://raw.github.com/atomantic/jquery.ChromeFrameNotify/master/jquery.gcnotify.min.js

function setPref (k, v) => try localStorage?setItem(k, JSON?stringify(v))
function getPref (k) => try JSON?parse(localStorage?getItem(k) ? \null)

window.show-info = ->
  ref = window.open \Android.html \_blank \location=no
  on-stop = ({url}) -> ref.close! if url is /quit\.html/
  on-exit = ->
    ref.removeEventListener \loadstop on-stop
    ref.removeEventListener \exit     on-exit
  ref.addEventListener \loadstop on-stop
  ref.addEventListener \exit     on-exit

callLater = -> setTimeout it, if isMobile then 10ms else 1ms

window.press-down = ->
  if navigator.user-agent is /Android\s*[12]\./
    alert "抱歉，Android 2.x 版僅能於上方顯示搜尋框。"
    return
  $('body').removeClass "prefer-down-#{ !!getPref \prefer-down }"
  val = !getPref \prefer-down
  setPref \prefer-down val
  $('body').addClass "prefer-down-#{ !!getPref \prefer-down }"

window.do-load = ->
  return unless isDeviceReady
  $('body').addClass \cordova if isCordova
  $('body').addClass \web unless isCordova
  $('body').addClass \ios if isCordova and location.href isnt /android_asset/
  $('body').addClass \android if isCordova and location.href is /android_asset/
  if navigator.user-agent is /Android\s*[12]\./
    $('body').addClass \overflow-scrolling-false
    $('body').addClass "prefer-down-false"
  else
    $('body').addClass "prefer-down-#{ !!getPref \prefer-down }"
  $('#result').addClass "prefer-pinyin-#{ !!getPref \prefer-pinyin }"

  fontSize = getPref(\font-size) || 14
  $('body').bind \pinch (, {scale}) ->
    $('body').css('font-size', Math.max(14, Math.min(22, (scale * fontSize))) + 'pt')
  saveFontSize = (, {scale}) ->
    setPref \font-size fontSize := Math.max(14, Math.min(22, (scale * fontSize)))
    $('body').css('font-size', fontSize + 'pt')
  $('body').bind \pinchclose saveFontSize
  $('body').bind \pinchopen saveFontSize
  window.adjust-font-size = (offset) ->
    setPref \font-size fontSize := Math.max(14, Math.min(22, (fontSize + offset)))
    $('body').css('font-size', fontSize + 'pt')
  window.adjust-font-size 0

  cache-loading = no
  window.press-about = press-about = ->
    location.href = \about.html unless location.href is /android_asset/
  window.press-erase = press-erase = ->
    $ \#query .val '' .focus!
    $ \.lang .show!
    $ \.erase .hide!
  window.press-back = press-back = ->
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

  try document.addEventListener \backbutton, (!->
    if entryHistory.length <= 1 then window.press-quit! else window.press-back!
  ), false

  window.press-quit = -> callLater -> navigator.app.exit-app!

  init = ->
    $ \#query .keyup lookup .change lookup .keypress lookup .keydown lookup .on \input lookup
    $ \#query .on \focus -> @select!
    $ \#query .show!
    $ \#query .focus! unless isCordova

    unless ``('onhashchange' in window)``
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
    else if location.hash isnt /^#./
      fetch MOE-ID

  window.grok-hash = grok-hash = ->
    return false unless location.hash is /^#./
    try
      val = decodeURIComponent location.hash.substr 1
      lang = \a
      if val.0 is \!
        lang = \t
        val.=substr 1
      if lang isnt LANG
        LANG := LANG
        prevVal = ''
        return window.press-lang lang, val
      return true if val is prevVal
      $ \#query .show!
      fill-query val
      fetch val
      return true if val is prevVal
    return false

  window.fill-query = fill-query = ->
    title = decodeURIComponent(it) - /[（(].*/
    title -= /^!/
    return if title is /^</
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
  window.press-lang = (lang='', id='') ->
    $('.ui-autocomplete li').remove!
    $ \#query .val ''
    prevId := null
    prevVal := null
    LANG := lang || (if LANG is \a then \t else \a)
    id ||= {a: \萌 t: \發穎 h: \發芽}[LANG]
    $.get "#LANG/xref.json", null, (-> XREF[LANG] = it), \text unless XREF[LANG].length > 100
    $.get "#LANG/index.json", null, (->
      init-autocomplete it
      $('body').removeClass("lang-t")
      $('body').addClass("lang-#LANG")
      $ \#query .val id
      window.do-lookup id
      setPref \lang LANG
    ), \text

  lenToRegex = {}

  bucket-of = ->
    code = it.charCodeAt(0)
    if 0xD800 <= code <= 0xDBFF
      code = it.charCodeAt(1) - 0xDC00
    return code % 1024

  lookup = ->
    if $(\#query).val!
      $(\.erase).show!
      $(\.lang).hide!
      return do-lookup b2g that
    $(\.lang).show!
    $(\.erase).hide!

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

  htmlCache = {t:[], a:[]}
  fetch = ->
    return unless it
    prevId := it
    prevVal := it
    setPref \prev-id prevId
    hash = "#{ if LANG is \a then \# else \#! }#it"
    try history.pushState null, null, hash unless "#{location.hash}" is hash
    if isMobile
      $('#result div, #result span, #result h1:not(:first)').hide!
      $('#result h1:first').text(it).show!
    else
      $('#result div, #result span, #result h1:not(:first)').css \visibility \hidden
      $('#result h1:first').text(it).css \visibility \visible
      window.scroll-to 0 0
    return if load-cache-html it
    return fill-json MOE, \萌 if it is \萌
    return load-json it

  load-json = (id, cb) ->
    return $.get("#LANG/#{ encodeURIComponent(id - /\(.*/)}.json", null, (-> fill-json it, id, cb), \text) unless isCordova
    # Cordova
    bucket = bucket-of id
    return fill-bucket id, bucket if bucketCache[LANG][bucket]
    json <- $.get "p#{LANG}ck/#bucket.txt"
    bucketCache[LANG][bucket] = json
    return fill-bucket id, bucket

  set-pinyin-bindings = ->
    $('#result.prefer-pinyin-true .bopomofo .bpmf, #result.prefer-pinyin-false .bopomofo .pinyin').unbind(\click).click ->
      val = !getPref \prefer-pinyin
      setPref \prefer-pinyin val
      $('#result').removeClass "prefer-pinyin-#{!val}" .addClass "prefer-pinyin-#val"
      callLater set-pinyin-bindings

  set-html = (html) -> callLater ->
    $ \#result .html html
    $('#result .part-of-speech a').attr \href, null
    set-pinyin-bindings!

    cache-loading := no
    return if isCordova
    $('#result .trs.pinyin').each(-> $(@).attr \title trs2bpmf $(@).text!).tooltip tooltipClass: \bpmf

    $('#result a[href]:not(.xref)').tooltip {
      +disabled, tooltipClass: "prefer-pinyin-#{ !!getPref \prefer-pinyin }", show: 100ms, hide: 100ms, items: \a, content: (cb) ->
        id = $(@).text!
        callLater ->
          if htmlCache[LANG][id]
            cb htmlCache[LANG][id]
            return
          load-json id, -> cb it
        return
    }
    $('#result a[href]:not(.xref)').hoverIntent do
        timeout: 250ms
        over: -> try $(@).tooltip \open
        out: -> try $(@).tooltip \close
    <- setTimeout _, 250ms
    $('.ui-tooltip').remove!
    <- setTimeout _, 250ms
    $('.ui-tooltip').remove!

  load-cache-html = ->
    html = htmlCache[LANG][it]
    return false unless html
    set-html html
    return true

  fill-json = (part, id, cb=set-html) ->
    while part is /"`辨~\u20DE&nbsp`似~\u20DE"[^}]*},{"f":"([^（]+)[^"]*"/
      part.=replace /"`辨~\u20DE&nbsp`似~\u20DE"[^}]*},{"f":"([^（]+)[^"]*"/ '"辨\u20DE 似\u20DE $1"'
    part.=replace /"`(.)~\u20DE"[^}]*},{"f":"([^（]+)[^"]*"/g '"$1\u20DE $2"'
    part.=replace /"([hbpdcnftrelsaqTAVCD_])"/g (, k) -> keyMap[k]
    h = "#{ if LANG is \a then \# else \#! }"
    part.=replace /`([^~]+)~/g (, word) -> "<a href='#h#word'>#word</a>"
    if JSON?parse?
      html = render JSON.parse part
    else
      html = eval "render(#part)"
    html.=replace /(.)\u20DE/g          "</span><span class='part-of-speech'>$1</span><span>"
    html.=replace //<a[^<]+>#id<\/a>//g "#id"
    html.=replace //<a>([^<]+)</a>//g   "<a href='#{h}$1'>$1</a>"
    html.=replace //(>[^<]*)#id//g      "$1<b>#id</b>"
    html.=replace(/\uFFF9/g '<span class="ruby"><span class="rb"><span class="ruby"><span class="rb">').replace(/\uFFFA/g '</span><br><span class="rt trs pinyin">').replace(/\uFFFB/g '</span></span></span></span><br><span class="rt mandarin">').replace(/<span class="rt mandarin">\s*<\//g '</')

    idx = XREF[LANG].indexOf('"' + id + '":')
    if idx >= 0
      part = XREF[LANG].slice(idx + id.length + 4);
      idx = part.indexOf('"')
      part = part.slice(0, idx)
      html += '<div class="xrefs">'
      html += """
          <div class="xref-line">
              <span class='xref'><span class='part-of-speech'>#{
                if LANG is \t then \華 else \閩
              }</span>
      """
      html += (for word in part / \,
        word ||= id
        h = "#{ if LANG is \t then \# else \#! }"
        "<a class='xref' href='#h#word'>#word</a>"
      ) * \、
      html += '</span></div></div>'
    cb(htmlCache[LANG][id] = html)
    return

  bucketCache = {t:{}, a:{}}

  keyMap = {
    h: \"heteronyms" b: \"bopomofo" p: \"pinyin" d: \"definitions"
    c: \"stroke_count" n: \"non_radical_stroke_count" f: \"def"
    t: \"title" r: \"radical" e: \"example" l: \"link" s: \"synonyms"
    a: \"antonyms" q: \"quote" _: \"id"

    T: \"trs" A: \"alt" V: \"vernacular", C: \"combined" D: \"dialects"
  }

  fill-bucket = (id, bucket) ->
    raw = bucketCache[LANG][bucket]
    key = escape id
    idx = raw.indexOf('"' + key + '"');
    return if idx is -1
    part = raw.slice(idx + key.length + 3);
    idx = part.indexOf('\n')
    part = part.slice(0, idx)
    fill-json part

  $.get "#LANG/xref.json", null, (-> XREF[LANG] = it), \text unless XREF[LANG].length > 100
  $.get "#LANG/index.json", null, init-autocomplete, \text
  return init!

const MOE = '{"h":[{"b":"ㄇㄥˊ","d":[{"f":"`草木~`初~`生~`的~`芽~。","q":["`說文解字~：「`萌~，`艸~`芽~`也~。」","`唐~．`韓愈~、`劉~`師~`服~、`侯~`喜~、`軒轅~`彌~`明~．`石~`鼎~`聯句~：「`秋~`瓜~`未~`落~`蒂~，`凍~`芋~`強~`抽~`萌~。」"],"type":"`名~"},{"f":"`事物~`發生~`的~`開端~`或~`徵兆~。","q":["`韓非子~．`說~`林~`上~：「`聖人~`見~`微~`以~`知~`萌~，`見~`端~`以~`知~`末~。」","`漢~．`蔡邕~．`對~`詔~`問~`灾~`異~`八~`事~：「`以~`杜漸防萌~，`則~`其~`救~`也~。」"],"type":"`名~"},{"f":"`人民~。","e":["`如~：「`萌黎~」、「`萌隸~」。"],"l":["`通~「`氓~」。"],"type":"`名~"},{"f":"`姓~。`如~`五代~`時~`蜀~`有~`萌~`慮~。","type":"`名~"},{"f":"`發芽~。","e":["`如~：「`萌芽~」。"],"q":["`楚辭~．`王~`逸~．`九思~．`傷~`時~：「`明~`風~`習習~`兮~`龢~`暖~，`百草~`萌~`兮~`華~`榮~。」"],"type":"`動~"},{"f":"`發生~。","e":["`如~：「`故態復萌~」。"],"q":["`管子~．`牧民~：「`惟~`有道~`者~，`能~`備~`患~`於~`未~`形~`也~，`故~`禍~`不~`萌~。」","`三國演義~．`第一~`回~：「`若~`萌~`異心~，`必~`獲~`惡報~。」"],"type":"`動~"}],"p":"méng"}],"n":8,"r":"`艸~","c":12,"t":"萌"}'

function init-autocomplete (text)
  Index := text
  $.widget "ui.autocomplete", $.ui.autocomplete, {
    _close: -> @menu.element.addClass \invisible
    _resizeMenu: ->
      ul = @menu.element;
      ul.outerWidth Math.max(
        ul.width( "" ).outerWidth() + 1
        this.element.outerWidth()
      )
      ul.removeClass \invisible
    _value: ->
      fill-query it if it
      @valueMethod.apply @element, arguments
  }
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
      results = try Index.match(//#{ b2g regex }//g)
      return cb [''] unless results
      do-lookup(results.0 - /"/g) if results.length is 1
      MaxResults = 255 # (if isCordova then 100 else 1000)
      if results.length > MaxResults
        more = "(僅顯示前 #MaxResults 筆)"
        results.=slice(0, MaxResults)
        results.push more
      return cb ((results.join(',') - /"/g) / ',')

const CJK-RADICALS = '⼀一⼁丨⼂丶⼃丿⼄乙⼅亅⼆二⼇亠⼈人⼉儿⼊入⼋八⼌冂⼍冖⼎冫⼏几⼐凵⼑刀⼒力⼓勹⼔匕⼕匚⼖匸⼗十⼘卜⼙卩⼚厂⼛厶⼜又⼝口⼞囗⼟土⼠士⼡夂⼢夊⼣夕⼤大⼥女⼦子⼧宀⼨寸⼩小⼪尢⼫尸⼬屮⼭山⼮巛⼯工⼰己⼱巾⼲干⼳幺⼴广⼵廴⼶廾⼷弋⼸弓⼹彐⼺彡⼻彳⼼心⼽戈⼾戶⼿手⽀支⽁攴⽂文⽃斗⽄斤⽅方⽆无⽇日⽈曰⽉月⽊木⽋欠⽌止⽍歹⽎殳⽏毋⽐比⽑毛⽒氏⽓气⽔水⽕火⽖爪⽗父⽘爻⽙爿⺦丬⽚片⽛牙⽜牛⽝犬⽞玄⽟玉⽠瓜⽡瓦⽢甘⽣生⽤用⽥田⽦疋⽧疒⽨癶⽩白⽪皮⽫皿⽬目⽭矛⽮矢⽯石⽰示⽱禸⽲禾⽳穴⽴立⽵竹⽶米⽷糸⺰纟⽸缶⽹网⽺羊⽻羽⽼老⽽而⽾耒⽿耳⾀聿⾁肉⾂臣⾃自⾄至⾅臼⾆舌⾇舛⾈舟⾉艮⾊色⾋艸⾌虍⾍虫⾎血⾏行⾐衣⾑襾⾒見⻅见⾓角⾔言⻈讠⾕谷⾖豆⾗豕⾘豸⾙貝⻉贝⾚赤⾛走⾜足⾝身⾞車⻋车⾟辛⾠辰⾡辵⻌辶⾢邑⾣酉⾤釆⾥里⾦金⻐钅⾧長⻓长⾨門⻔门⾩阜⾪隶⾫隹⾬雨⾭靑⾮非⾯面⾰革⾱韋⻙韦⾲韭⾳音⾴頁⻚页⾵風⻛风⾶飛⻜飞⾷食⻠饣⾸首⾹香⾺馬⻢马⾻骨⾼高⾽髟⾾鬥⾿鬯⿀鬲⿁鬼⿂魚⻥鱼⻦鸟⿃鳥⿄鹵⻧卤⿅鹿⿆麥⻨麦⿇麻⿈黃⻩黄⿉黍⿊黑⿋黹⿌黽⻪黾⿍鼎⿎鼓⿏鼠⿐鼻⿑齊⻬齐⿒齒⻮齿⿓龍⻰龙⿔龜⻳龟⿕龠'

const SIMP-TRAD = window.SIMP-TRAD ? ''

function b2g (str)
  return str if LANG is \t
  rv = ''
  for char in (str / '')
    idx = SIMP-TRAD.index-of(char)
    rv += if idx % 2 then char else SIMP-TRAD[idx + 1]
  return rv

function render-radical (char)
  idx = CJK-RADICALS.index-of(char)
  return char if idx % 2
  return CJK-RADICALS[idx + 1]

function render ({ title, heteronyms, radical, non_radical_stroke_count: nrs-count, stroke_count: s-count})
  char-html = if radical then "<div class='radical'><span class='glyph'>#{
    render-radical(radical - /<\/?a[^>]*>/g)
  }</span><span class='count'><span class='sym'>+</span>#{ nrs-count }</span><span class='count'> = #{ s-count }</span> 畫</div>" else ''
  result = ls heteronyms, ({id, bopomofo, pinyin, trs, definitions=[], antonyms, synonyms}) ->
    pinyin ?= trs
    bopomofo ?= trs2bpmf "#pinyin"
    """#char-html
      <h1 class='title'>#{ h title }#{ if isWebKit and id then "<audio src='#{
          "http://twblg.dict.edu.tw/holodict_new/audio/#{
            ((100000 + Number id) - /^1/)
          }.mp3"
      }' controls></audio>" else ''}</h1>#{
        if bopomofo then "<div class='bopomofo'>#{
            if pinyin then "<span class='pinyin'>#{ h pinyin
              .replace(/（.*）/, '')
            }</span>" else ''
          }<span class='bpmf'>#{ h bopomofo
            .replace(/ /g, '\u3000')
            .replace(/([ˇˊˋ])\u3000/g, '$1 ')
          }</span></div>" else ''
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
            #{ ls example, -> "<span class='example'>#{ h it }</span></span>" }
            #{ ls quote,   -> "<span class='quote'>#{   h it }</span>" }
            #{ ls link,    -> "<span class='link'>#{    h it }</span>" }
            #{ if synonyms then "<span class='synonyms'><span class='part-of-speech'>似</span> #{
              h(synonyms.replace(/,/g '、'))
            }</span>" else '' }
            #{ if antonyms then "<span class='antonyms'><span class='part-of-speech'>反</span> #{
              h(antonyms.replace(/,/g '、'))
            }</span>" else '' }
        </p></li>"""}</ol></div>
      """}
      #{ if synonyms then "<span class='synonyms'><span class='part-of-speech'>似</span> #{
        h(synonyms.replace(/,/g '、'))
      }</span>" else '' }
      #{ if antonyms then "<span class='antonyms'><span class='part-of-speech'>反</span> #{
        h(antonyms.replace(/,/g '、'))
      }</span>" else '' }
      </div>
    """
  return result
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
    if isCordova then text.replace(/\u030d/g '\u0358') else text
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


const Consonants = { p:\ㄅ b:\ㆠ ph:\ㄆ m:\ㄇ t:\ㄉ th:\ㄊ n:\ㄋ l:\ㄌ k:\ㄍ g:\ㆣ kh:\ㄎ ng:\ㄫ h:\ㄏ tsi:\ㄐ ji:\ㆢ tshi:\ㄑ si:\ㄒ ts:\ㄗ j:\ㆡ tsh:\ㄘ s:\ㄙ }
const Vowels = { a:\ㄚ an: \ㄢ ang: \ㄤ ann:\ㆩ oo:\ㆦ onn:\ㆧ o:\ㄜ e:\ㆤ enn:\ㆥ ai:\ㄞ ainn:\ㆮ au:\ㄠ aunn:\ㆯ am:\ㆰ om:\ㆱ m:\ㆬ ong:\ㆲ ng:\ㆭ i:\ㄧ inn:\ㆪ u:\ㄨ unn:\ㆫ ing:\ㄧㄥ in:\ㄧㄣ un:\ㄨㄣ }
const Tones = { p:\ㆴ t:\ㆵ k:\ㆶ h:\ㆷ p$:"ㆴ\u0358" t$:"ㆵ\u0358" k$:"ㆶ\u0358" h$:"ㆷ\u0358" "\u0300":\˪ "\u0301":\ˋ "\u0302":\ˊ "\u0304":\˫ "\u030d":\$ }
re = -> Object.keys(it).sort(-> &1.length - &0.length).join \|
const C = re Consonants
const V = re Vowels
function trs2bpmf (trs)
  return trs if LANG is \a
  trs.replace(/[A-Za-z\u0300-\u030d]+/g ->
    tone = ''
    it.=toLowerCase!
    it.=replace //([\u0300-\u0302\u0304\u030d])// -> tone := Tones[it]; ''
    it.=replace //^(tsh?|[sj])i// '$1ii'
    it.=replace //^(#C)((?:#V)+[ptkh]?)$// -> Consonants[&1] + &2
    it.=replace //[ptkh]$// -> tone := Tones[it+tone]; ''
    it.=replace //(#V)//g -> Vowels[it]
    it + (tone || '\uFFFD')
  ).replace(/[- ]/g '').replace(/\uFFFD/g ' ').replace(/\. ?/g \。).replace(/\? ?/g \？).replace(/\! ?/g \！).replace(/\, ?/g \，)

