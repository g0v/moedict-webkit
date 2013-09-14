const DEBUGGING = on

LANG = getPref(\lang) || (if document.URL is /twblg/ then \t else \a)
MOE-ID = getPref(\prev-id) || {a: \萌 t: \發穎 h: \發芽}[LANG]
$ ->
  $('body').addClass("lang-#LANG")
  $('.lang-active').text $(".lang-option.#LANG:first").text!

const HASH-OF = {a: \#, t: \#!, h: \#:}
const XREF-LABEL-OF = {a: \華, t: \閩, h: \客}

window.isCordova = isCordova = document.URL isnt /^https?:/
isDroidGap = isCordova and location.href is /android_asset/
isDeviceReady = not isCordova
isCordova = true if DEBUGGING
isMobile = isCordova or navigator.userAgent is /Android|iPhone|iPad|Mobile/
isWebKit = navigator.userAgent is /WebKit/
width-is-xs = -> $ \body .width! < 768
entryHistory = []
INDEX = { t: '', a: '', h: '' }
XREF = {
  t: {a: '"發穎":"萌,抽芽,發芽,萌芽"'}
  a: {t: '"萌":"發穎"' h: '"萌":"發芽"'}
  h: {a: '"發芽":"萌,萌芽"'}
  tv: {t: ''}
}
# Return an object of all matched with {key: [words]}.
function xref-of (id, src-lang=LANG)
  rv = {}
  if typeof XREF[src-lang] is \string
    parsed = {}
    for chunk in XREF[src-lang].split \}
      [tgt-lang, words] = chunk.split \":{
      parsed[tgt-lang.slice(-1)] = words if words
    XREF[src-lang] = parsed
  for tgt-lang, words of XREF[src-lang]
    idx = words.indexOf('"' + id + '":')
    rv[tgt-lang] = if idx < 0 then [] else
      part = words.slice(idx + id.length + 4);
      idx = part.indexOf \"
      part.=slice 0 idx
      [ x || id for x in part / \, ]
  return rv

CACHED = {}
GET = (url, data, onSuccess, dataType) ->
  if data instanceof Function
    [data, dataType, onSuccess] = [null, onSuccess, data]
  return onSuccess(CACHED[url]) if CACHED[url]
  $.get(url, data, (->
    onSuccess(CACHED[url] = it)
  ), dataType).fail ->

try
  throw unless isCordova and not DEBUGGING
  document.addEventListener \deviceready (->
    try navigator.splashscreen.hide!
    isDeviceReady := yes
    window.do-load!
  ), false
  document.addEventListener \pause (-> stop-audio!), false
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
      $('.navbar, .query-box').hide!
      $('#result').css \margin-top \50px
      <- getScript \https://ajax.googleapis.com/ajax/libs/chrome-frame/1/CFInstall.min.js
      window.gcfnConfig = do
        imgpath: 'https://raw.github.com/atomantic/jquery.ChromeFrameNotify/master/img/'
        msgPre: ''
        msgLink: '敬請安裝 Google 內嵌瀏覽框，以取得完整的萌典功能。'
        msgAfter: ''
      <- getScript \js/jquery.gcnotify.min.js

function setPref (k, v) => try localStorage?setItem(k, JSON?stringify(v))
function getPref (k) => try $.parseJSON(localStorage?getItem(k) ? \null)

/*
if isMobile
  class window.Howl
    ({ urls, onplay, onend, onloaderror }) ->
      @el = document.createElement \audio
      @el.set-attribute \src urls.0
      @el.set-attribute \type if urls.0 is /mp3$/ then \audio/mpeg else \audio/ogg
      @el.set-attribute \autoplay true
      @el.set-attribute \controls true
      @el.add-event-listener \playing ~> onplay!; @unload!
      @el.add-event-listener \error ~> onloaderror!; @unload!
      @el.add-event-listener \ended ~> onend!; @unload!
    play: -> @el.play!
    stop: -> @el?pause?!; @el?currentTime = 0.0; @unload!
    unload: -> try $(@el).remove!; @el = null
  */

var playing, player, seq
seq = 0
get-el = -> $("\#player-#seq")
window.stop-audio = ->
  $el = get-el!
  if $el.length
    $el.parent('.audioBlock').removeClass('playing')
    $el.removeClass('icon-stop').removeClass('icon-spinner').show!
    $el.addClass('icon-play')
  player?unload!
  player := null
  playing := null
window.play-audio = (el, url) ->
  done = -> stop-audio!
  play = ->
    $el = get-el!
    if playing is url
      if $el.hasClass('icon-stop') => stop-audio!; done!
      return
    stop-audio!
    seq++
    $(el).attr \id "player-#seq"
    $el = get-el!
    playing := url
    $('#result .playAudio').show!
    $('.audioBlock').removeClass('playing')
    $el.removeClass('icon-play').addClass('icon-spinner')
    $el.parent('.audioBlock').addClass('playing')
    urls = [url]
    urls.unshift url.replace(/ogg$/ 'mp3') if url is /ogg$/ and can-play-mp3!
    audio = new window.Howl { +buffer, urls, onend: done, onloaderror: done, onplay: -> $el.removeClass('icon-play').removeClass('icon-spinner').addClass('icon-stop').show!
    }
    audio.play!
    player := audio
  return play! if window.Howl
  <- getScript \js/howler.js
  return play!

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
  $('body').addClass \ios if isCordova and not isDroidGap
  $('body').addClass \desktop unless isMobile
  $('body').addClass \android if isDroidGap
  if navigator.user-agent is /Android\s*[12]\./
    $('body').addClass \overflow-scrolling-false
    $('body').addClass "prefer-down-false"
  else
    $('body').addClass \overflow-scrolling-true
    $('body').addClass "prefer-down-false"
  $('#result').addClass "prefer-pinyin-#{ !!getPref \prefer-pinyin }"

  fontSize = getPref(\font-size) || 14
  $('body').bind \pinch (, {scale}) ->
    $('body').css('font-size', Math.max(10, Math.min(42, (scale * fontSize))) + 'pt')
  saveFontSize = (, {scale}) ->
    setPref \font-size fontSize := Math.max(10, Math.min(42, (scale * fontSize)))
    $('body').css('font-size', fontSize + 'pt')
  $('body').bind \pinchclose saveFontSize
  $('body').bind \pinchopen saveFontSize
  window.adjust-font-size = (offset) ->
    setPref \font-size fontSize := Math.max(10, Math.min(42, (fontSize + offset)))
    $('body').css('font-size', fontSize + 'pt')
  window.adjust-font-size 0

  cache-loading = no
  window.press-about = press-about = ->
    if isDroidGap then show-info! else location.href = \about.html
  window.press-erase = press-erase = ->
    $ \#query .val '' .focus!
    $ \.erase-box .hide!
  window.press-back = press-back = ->
    stop-audio!
    if isDroidGap and not(
      $ \.ui-autocomplete .hasClass \invisible
    ) and width-is-xs!
      try $(\#query).autocomplete \close
      return
    return if cache-loading
    entryHistory.pop!
    token = Math.random!
    cache-loading := token
    setTimeout (-> cache-loading := no if cache-loading is token), 10000ms
    callLater ->
      id = if entryHistory.length then entryHistory[*-1] else MOE-ID
      window.grok-val id
    return false

  try document.addEventListener \backbutton, (!->
    if entryHistory.length <= 1 then window.press-quit! else window.press-back!
  ), false

  window.press-quit = ->
    stop-audio!
    callLater -> navigator.app.exit-app!

  init = ->
    $ \#query .keyup lookup .change lookup .keypress lookup .keydown lookup .on \input lookup
    $ \#query .on \focus -> @select!
    $ \#query .on \click ->
      try $(\#query).autocomplete \search if $(\#query).val!
    $ \#query .show!
    $ \#query .focus! unless isCordova

    # Toggle submenu visibility.
    $ \.navbar .on \shown.bs.dropdown -> $(@).css \position \absolute if width-is-xs!
    $ \.navbar .on \hidden.bs.dropdown -> $(@).css \position \fixed

    $ \body .on \click 'li.dropdown-submenu > a' ->
      if width-is-xs!
        $(@).next(\ul).slide-toggle \fast
        return false

    $ \body .on \click '.results .stroke' ->
      return ($('#strokes').fadeOut \fast -> $('#strokes').html(''); window.scroll-to 0 0) if $('svg, canvas').length
      strokeWords($('h1:first').text! - /[（(].*/) # Strip the english part and draw the strokes

    unless ``('onhashchange' in window)``
      $ \body .on \click \a ->
        val = $(@).attr(\href)
        val -= /.*\#/ if val
        val ||= $(@).text!
        window.grok-val val
        return false
    return if window.grok-hash!
    if isCordova
      fill-query MOE-ID
      $ \#query .val ''
    else if location.hash isnt /^#./
      fetch MOE-ID

  window.grok-val = grok-val = (val) ->
    stop-audio!
    return if val is /</
    if val is /[，。]$/
      <- setTimeout _, 500ms
      $(\#query).autocomplete(\search)
    lang = \a
    if "#val" is /^!/
      lang = \t
      val.=substr 1
    if "#val" is /^:/
      lang = \h
      val.=substr 1
    $('.lang-active').text $(".lang-option.#lang:first").text!
    if lang isnt LANG
      LANG := LANG
      prevVal = ''
      return window.press-lang lang, val
    val = b2g val
    return true if val is prevVal
    $ \#query .show!
    fill-query val
    fetch val
    return true if val is prevVal
    return false

  window.grok-hash = grok-hash = ->
    return false unless location.hash is /^#./
    decode = ->
      it = decodeURIComponent it if it is /%/
      it = decodeURIComponent escape it if escape(it) is /%[A-Fa-f]/
      return it
    try grok-val decode location.hash.substr 1
    return false

  window.fill-query = fill-query = ->
    title = decodeURIComponent(it) - /[（(].*/
    title -= /^[:!]/
    return if title is /^</
    if title is /^→/
      <- setTimeout _, 500ms
      $(\#query).autocomplete(\search)
      return
    $ \#query .val title
    $ \#cond .val "^#{title}$" unless isCordova
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
    prevId := null
    prevVal := null
    LANG := lang || switch LANG | \a => \t | \t => \h | \h => \a
    $ \#query .val ''
    $('.ui-autocomplete li').remove!
    $('.lang-active').text $(".lang-option.#LANG:first").text!
    setPref \lang LANG
    id ||= {a: \萌 t: \發穎 h: \發芽}[LANG]
    unless isCordova
      GET "#LANG/xref.json" (-> XREF[LANG] = it), \text
      GET "#LANG/index.json" (-> INDEX[LANG] = it), \text
    $('body').removeClass("lang-t")
    $('body').removeClass("lang-a")
    $('body').removeClass("lang-h")
    $('body').addClass("lang-#LANG")
    $ \#query .val id
    window.do-lookup id

  bucket-of = ->
    return it.0 if it is /^[=@]/
    code = it.charCodeAt(0)
    if 0xD800 <= code <= 0xDBFF
      code = it.charCodeAt(1) - 0xDC00
    return code % (if LANG is \a then 1024 else 128)

  lookup = ->
    if $(\#query).val!
      $(\.erase-box).show!
      return do-lookup b2g that
    $(\.erase-box).hide!

  window.do-lookup = do-lookup = (val) ->
    title = val - /[（(].*/
    if location.search is /draw/ and not $('body').hasClass('autodraw')
      $('body').addClass \autodraw
      strokeWords title
    return fetch title if title is /^[=@]/
    Index = INDEX[LANG]
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
    hist = "#{ HASH-OF[LANG].slice(1) }#title"
    entryHistory.push hist unless entryHistory.length and entryHistory[*-1] is hist
    if isCordova or LANG isnt \a
      $(\.back).hide!
    else
      $(\.back).show!
    fetch title
    return true

  htmlCache = { t:[], a:[], h:[] }
  fetch = ->
    return unless it
    return if prevId is it
    prevId := it
    prevVal := it
    setPref \prev-id prevId
    hash = "#{ HASH-OF[LANG] }#it"
    if "#{location.hash}" isnt hash => try history.pushState null, null, hash
      catch => location.replace hash
    if isMobile
      $('#result div, #result span, #result h1:not(:first)').hide!
      $('#result h1:first').text(it - /^[@=]/).show!
    else
      $('#result div, #result span, #result h1:not(:first)').css \visibility \hidden
      $('#result h1:first').text(it - /^[@=]/).css \visibility \visible
      window.scroll-to 0 0
    return if load-cache-html it
    return fill-json MOE, \萌 if it is \萌
    return load-json it

  load-json = (id, cb) ->
    return GET("#LANG/#{ encodeURIComponent(id - /\(.*/)}.json", null, (-> fill-json it, id, cb), \text) unless isCordova
    # Cordova
    bucket = bucket-of id
    return fill-bucket id, bucket, cb

  set-pinyin-bindings = ->
    $('#result.prefer-pinyin-true .bopomofo .bpmf, #result.prefer-pinyin-false .bopomofo .pinyin').unbind(\click).click ->
      val = !getPref \prefer-pinyin
      setPref \prefer-pinyin val
      $('#result').removeClass "prefer-pinyin-#{!val}" .addClass "prefer-pinyin-#val"
      callLater set-pinyin-bindings

  set-html = (html) -> callLater ->
    $('#strokes').fadeOut(\fast -> $('#strokes').html(''); window.scroll-to 0 0) if $('svg, canvas').length and not $('body').hasClass('autodraw')
    $ \#result .html html
    $('#result .part-of-speech a').attr \href, null
    set-pinyin-bindings!

    cache-loading := no

    if isCordova and not DEBUGGING
      $('#result .playAudio').on \touchstart -> $(@).click! if $(@).hasClass('icon-play')
      return

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
    part.=replace /"([hbpdcnftrelsaqETAVCD_=])":/g (, k) -> keyMap[k] + \:
    h = HASH-OF[LANG]
    part.=replace /([「【『（《])`([^~]+)~([。，、；：？！─…．·－」』》〉]+)/g (, pre, word, post) -> "<span class='punct'>#pre<a href='#h#word'>#word</a>#post</span>"
    part.=replace /([「【『（《])`([^~]+)~/g (, pre, word) -> "<span class='punct'>#pre<a href='#h#word'>#word</a></span>"
    part.=replace /`([^~]+)~([。，、；：？！─…．·－」』》〉]+)/g (, word, post) -> "<span class='punct'><a href='#h#word'>#word</a>#post</span>"
    part.=replace /`([^~]+)~/g (, word) -> "<a href='#h#word'>#word</a>"
    if part is /^\[\s*\[/
      html = render-strokes part
    else if part is /^\[/
      html = render-list part
    else
      html = render $.parseJSON part
    html.=replace /(.)\u20DE/g          "</span><span class='part-of-speech'>$1</span><span>"
    html.=replace /(.)\u20E3/g          "<span class='variant'>$1</span>"
    html.=replace //<a[^<]+>#id<\/a>//g "#id"
    html.=replace //<a>([^<]+)</a>//g   "<a href='#{h}$1'>$1</a>"
    html.=replace //(>[^<]*)#id//g      "$1<b>#id</b>"
    html.=replace(/¹/g \<sup>1</sup>)
    html.=replace(/²/g \<sup>2</sup>)
    html.=replace(/³/g \<sup>3</sup>)
    html.=replace(/⁴/g \<sup>4</sup>)
    html.=replace(/⁵/g \<sup>5</sup>)
    html.=replace(/\uFFF9/g '<span class="ruby"><span class="rb"><span class="ruby"><span class="rb">').replace(/\uFFFA/g '</span><br><span class="rt trs pinyin">').replace(/\uFFFB/g '</span></span></span></span><br><span class="rt mandarin">').replace(/<span class="rt mandarin">\s*<\//g '</')

    has-xrefs = false
    for tgt-lang, words of xref-of id | words.length
      html += '<div class="xrefs">' unless has-xrefs++
      html += """
          <div class="xref-line">
              <span class='xref part-of-speech'>#{
                XREF-LABEL-OF[tgt-lang]
              }</span>
              <span class='xref'>
      """
      html += (for word in words
        h = HASH-OF[tgt-lang]
        if word is /`/
          word.replace /`([^~]+)~/g (, word) -> "<a class='xref' href='#h#word'>#word</a>"
        else
          "<a class='xref' href='#h#word'>#word</a>"
      ) * \、
      html += '</span></div>'
    html += '</div>' if has-xrefs
    cb(htmlCache[LANG][id] = html)
    return

  keyMap = {
    h: \"heteronyms" b: \"bopomofo" p: \"pinyin" d: \"definitions"
    c: \"stroke_count" n: \"non_radical_stroke_count" f: \"def"
    t: \"title" r: \"radical" e: \"example" l: \"link" s: \"synonyms"
    a: \"antonyms" q: \"quote" _: \"id" '=': \"audio_id" E: \"english"
    T: \"trs" A: \"alt" V: \"vernacular", C: \"combined" D: \"dialects"
  }

  fill-bucket = (id, bucket, cb) ->
    raw <- GET "p#{LANG}ck/#bucket.txt"
    key = escape id
    idx = raw.indexOf('"' + key + '"');
    return if idx is -1
    part = raw.slice(idx + key.length + 3);
    idx = part.indexOf('\n')
    part = part.slice(0, idx)
    fill-json part, id, cb

  if isCordova
    for lang in <[ a t h ]> => let lang
      GET "#lang/xref.json", (-> XREF[lang] = it; init! if lang is LANG), \text
      p1 <- GET "#lang/index.1.json", _, \text
      p2 <- GET "#lang/index.2.json", _, \text
      INDEX[lang] = p1 + p2
      init-autocomplete! if lang is LANG
  else
    GET "#LANG/xref.json", (-> XREF[LANG] = it; init!), \text
    GET "#LANG/index.json", (-> INDEX[LANG] = it; init-autocomplete!), \text
    for lang in <[ a t h ]> | lang isnt LANG => let lang
      GET "#lang/xref.json", (-> XREF[lang] = it), \text

  GET "t/variants.json", (-> XREF.tv = {t: it}), \text

const MOE = '{"n":8,"t":"萌","r":"`艸~","c":12,"h":[{"d":[{"q":["`說文解字~：「`萌~，`艸~`芽~`也~。」","`唐~．`韓愈~、`劉~`師~`服~、`侯~`喜~、`軒轅~`彌~`明~．`石~`鼎~`聯句~：「`秋~`瓜~`未~`落~`蒂~，`凍~`芋~`強~`抽~`萌~。」"],"type":"`名~","f":"`草木~`初~`生~`的~`芽~。"},{"q":["`韓非子~．`說~`林~`上~：「`聖人~`見~`微~`以~`知~`萌~，`見~`端~`以~`知~`末~。」","`漢~．`蔡邕~．`對~`詔~`問~`灾~`異~`八~`事~：「`以~`杜漸防萌~，`則~`其~`救~`也~。」"],"type":"`名~","f":"`事物~`發生~`的~`開端~`或~`徵兆~。"},{"type":"`名~","l":["`通~「`氓~」。"],"e":["`如~：「`萌黎~」、「`萌隸~」。"],"f":"`人民~。"},{"type":"`名~","f":"`姓~。`如~`五代~`時~`蜀~`有~`萌~`慮~。"},{"q":["`楚辭~．`王~`逸~．`九思~．`傷~`時~：「`明~`風~`習習~`兮~`龢~`暖~，`百草~`萌~`兮~`華~`榮~。」"],"type":"`動~","e":["`如~：「`萌芽~」。"],"f":"`發芽~。"},{"q":["`管子~．`牧民~：「`惟~`有道~`者~，`能~`備~`患~`於~`未~`形~`也~，`故~`禍~`不~`萌~。」","`三國演義~．`第一~`回~：「`若~`萌~`異心~，`必~`獲~`惡報~。」"],"type":"`動~","e":["`如~：「`故態復萌~」。"],"f":"`發生~。"}],"p":"méng","b":"ㄇㄥˊ","=":"0676"}],"translation":{"francais":["germer"],"Deutsch":["Leute, Menschen  (S)","Meng  (Eig, Fam)","keimen, sprießen, knospen, ausschlagen "],"English":["to sprout","to bud","to have a strong affection for (slang)","adorable (loanword from Japanese `萌~え moe, slang describing affection for a cute character)"]}}'

function init-autocomplete
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
      return cb [] unless term is /[^\u0000-\u00FF]/ or term is /[-,;]/
      return cb ["→列出含有「#{term}」的詞"] if term.length is 1 and width-is-xs!
      return do-lookup(term) if term is /^[@=]/
      term.=replace(/^→列出含有「/ '')
      term.=replace(/」的詞$/ '')
      term.=replace(/\*/g '%')
      term.=replace(/[-—]/g    \－)
      term.=replace(/[,﹐]/g   \，)
      term.=replace(/[;﹔]/g   \；)
      term.=replace(/[﹒．]/g  \。)
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
      try results = INDEX[LANG].match(//#{ b2g regex }//g)
      results ||= xref-of(term, if LANG is \a then \t else \a)[LANG]
      if LANG is \t => for v in xref-of(term, \tv).t.reverse!
        results.unshift v unless v in results
      return cb [''] unless results?length
      do-lookup(results.0 - /"/g) if results.length is 1
      MaxResults = 400
      if results.length > MaxResults
        more = "(僅顯示前 #MaxResults 筆)"
        results.=slice(0, MaxResults)
        results.push more
      return cb ((results.join(',') - /"/g) / ',')

const CJK-RADICALS = '⼀一⼁丨⼂丶⼃丿⼄乙⼅亅⼆二⼇亠⼈人⼉儿⼊入⼋八⼌冂⼍冖⼎冫⼏几⼐凵⼑刀⼒力⼓勹⼔匕⼕匚⼖匸⼗十⼘卜⼙卩⼚厂⼛厶⼜又⼝口⼞囗⼟土⼠士⼡夂⼢夊⼣夕⼤大⼥女⼦子⼧宀⼨寸⼩小⼪尢⼫尸⼬屮⼭山⼮巛⼯工⼰己⼱巾⼲干⼳幺⼴广⼵廴⼶廾⼷弋⼸弓⼹彐⼺彡⼻彳⼼心⼽戈⼾戶⼿手⽀支⽁攴⽂文⽃斗⽄斤⽅方⽆无⽇日⽈曰⽉月⽊木⽋欠⽌止⽍歹⽎殳⽏毋⽐比⽑毛⽒氏⽓气⽔水⽕火⽖爪⽗父⽘爻⽙爿⺦丬⽚片⽛牙⽜牛⽝犬⽞玄⽟玉⽠瓜⽡瓦⽢甘⽣生⽤用⽥田⽦疋⽧疒⽨癶⽩白⽪皮⽫皿⽬目⽭矛⽮矢⽯石⽰示⽱禸⽲禾⽳穴⽴立⽵竹⽶米⽷糸⺰纟⽸缶⽹网⽺羊⽻羽⽼老⽽而⽾耒⽿耳⾀聿⾁肉⾂臣⾃自⾄至⾅臼⾆舌⾇舛⾈舟⾉艮⾊色⾋艸⾌虍⾍虫⾎血⾏行⾐衣⾑襾⾒見⻅见⾓角⾔言⻈讠⾕谷⾖豆⾗豕⾘豸⾙貝⻉贝⾚赤⾛走⾜足⾝身⾞車⻋车⾟辛⾠辰⾡辵⻌辶⾢邑⾣酉⾤釆⾥里⾦金⻐钅⾧長⻓长⾨門⻔门⾩阜⾪隶⾫隹⾬雨⾭靑⾮非⾯面⾰革⾱韋⻙韦⾲韭⾳音⾴頁⻚页⾵風⻛风⾶飛⻜飞⾷食⻠饣⾸首⾹香⾺馬⻢马⾻骨⾼高⾽髟⾾鬥⾿鬯⿀鬲⿁鬼⿂魚⻥鱼⻦鸟⿃鳥⿄鹵⻧卤⿅鹿⿆麥⻨麦⿇麻⿈黃⻩黄⿉黍⿊黑⿋黹⿌黽⻪黾⿍鼎⿎鼓⿏鼠⿐鼻⿑齊⻬齐⿒齒⻮齿⿓龍⻰龙⿔龜⻳龟⿕龠'

const SIMP-TRAD = window.SIMP-TRAD ? ''

function b2g (str)
  return str unless LANG is \a
  rv = ''
  for char in (str / '')
    idx = SIMP-TRAD.index-of(char)
    rv += if idx % 2 then char else SIMP-TRAD[idx + 1]
  return rv

function render-radical (char)
  idx = CJK-RADICALS.index-of(char)
  return char if idx % 2
  return CJK-RADICALS[idx + 1]

function can-play-mp3
  return CACHED.can-play-mp3 if CACHED.can-play-mp3?
  a = document.createElement \audio
  CACHED.can-play-mp3 = !!(a.canPlayType?('audio/mpeg') - /no/)

function can-play-ogg
  return CACHED.can-play-ogg if CACHED.can-play-ogg?
  a = document.createElement \audio
  CACHED.can-play-ogg = !!(a.canPlayType?('audio/ogg') - /no/)

function render-strokes (terms)
  h = HASH-OF[LANG]
  title = "<h1>#{ $(\#query).val! - /^[@=]/ } 部</h1>"
  rows = $.parseJSON terms
  list = ''
  for chars, strokes in rows | chars?length
    list += "\u00A0#strokes."
    for ch in chars
      list += "\u00A0<a href='#h#ch'>#ch</a>"
    list += "<br>\n"
  return "#title<div class='list'>#list</div>"

function render-list (terms)
  h = HASH-OF[LANG]
  title = "<h1>#{ $(\#query).val! - /^[@=]/ }</h1>"
  terms -= /^[^"]*/
  terms.=replace(/"([^"]+)"[^"]*/g "\u00B7 <a href='#{h}$1'>$1</a><br>\n")
  return "#title<div class='list'>#terms</div>"

function render (json)
  { title, english, heteronyms, radical, translation, non_radical_stroke_count: nrs-count, stroke_count: s-count, pinyin: py } = json
  char-html = if radical then "<div class='radical'><span class='glyph'>#{
    render-radical(radical - /<\/?a[^>]*>/g)
  }</span><span class='count'><span class='sym'>+</span>#{ nrs-count }</span><span class='count'> = #{ s-count }</span>&nbsp;<span class='iconic-circle stroke icon-pencil' title='筆順動畫'></span></div>" else "<div class='radical'><span class='iconic-circle stroke icon-pencil' title='筆順動畫'></span></div>"
  result = ls heteronyms, ({id, audio_id=id, bopomofo, pinyin=py, trs='', definitions=[], antonyms, synonyms, variants}) ->
    pinyin ?= trs
    pinyin = (pinyin - /<[^>]*>/g - /（.*）/)
    if audio_id and LANG is \h
      pinyin.=replace /(.)\u20DE/g (_, $1) ->
        variant = " 四海大平安".indexOf($1)
        mp3 = "http://h.moedict.tw/#{variant}-#audio_id.ogg"
        mp3.=replace(/ogg$/ \mp3) if mp3 and not can-play-ogg!
        """
        </span><span class="audioBlock"><div onclick='window.playAudio(this, \"#mp3\")' class='icon-play playAudio part-of-speech'>#{$1}</div>
      """
    bopomofo ?= trs2bpmf "#pinyin"
    bopomofo = bopomofo.replace(/ /g, '\u3000').replace(/([ˇˊˋ])\u3000/g, '$1 ') - /<[^>]*>/g
    unless title is /</
      title := "<div class='stroke' title='筆順動畫'>#title</div>"
    """#char-html
      <h1 class='title'>#{ h title }#{
        if audio_id and (can-play-ogg! or can-play-mp3!)
          if LANG is \t and not (20000 < audio_id < 50000)
            basename = (100000 + Number audio_id) - /^1/
            mp3 = "http://t.moedict.tw/#basename.ogg"
          else if LANG is \a
            mp3 = "http://a.moedict.tw/#audio_id.ogg"
          mp3.=replace(/ogg$/ \mp3) if mp3 and not can-play-ogg!
        if mp3 then "<i class='icon-play playAudio' onclick='window.playAudio(this, \"#mp3\")'></i>" else ''
      }#{
        if english then "<span class='english'>(#english)</span>" else ''
      }</h1>#{
        if bopomofo then "<div class='bopomofo'>#{
            if pinyin then "<span class='pinyin'>#{ h pinyin }</span>" else ''
          }<span class='bpmf'>#{ h bopomofo }</span></div>" else ''
      }<div class="entry">
      #{ls groupBy(\type definitions.slice!), (defs) ->
        """<div class="entry-item">
        #{ if defs.0?type
          [ "<span class='part-of-speech'>#t</span>" for t in defs.0.type / \, ] * '&nbsp;'
        else '' }
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
              h((synonyms - /^,/).replace(/,/g '、'))
            }</span>" else '' }
            #{ if antonyms then "<span class='antonyms'><span class='part-of-speech'>反</span> #{
              h((antonyms - /^,/).replace(/,/g '、'))
            }</span>" else '' }
        </p></li>"""}</ol></div>
      """}
      #{ if synonyms then "<span class='synonyms'><span class='part-of-speech'>似</span> #{
        h((synonyms - /^,/).replace(/,/g '、'))
      }</span>" else '' }
      #{ if antonyms then "<span class='antonyms'><span class='part-of-speech'>反</span> #{
        h((antonyms - /^,/).replace(/,/g '、'))
      }</span>" else '' }
      #{ if variants then "<span class='variants'><span class='part-of-speech'>異</span> #{
        h(variants.replace(/,/g '、'))
      }</span>" else '' }
      </div>
    """
  return "#result#{ if translation then "<div class='xrefs'><span class='translation'>
    #{ if \English of translation then "<div class='xref-line'><span class='fw_lang'>英</span><span class='fw_def'>#{ (translation.English * ', ') - /, CL:.*/g - /\|(?:<\/?a[^>*]>|[^[,.(])+/g }</span></div>" else '' }
    #{ if \francais of translation then "<div class='xref-line'><span class='fw_lang'>法</span><span class='fw_def'>#{ translation.francais * ', ' }</span></div>" else '' }
    #{ if \Deutsch of translation then "<div class='xref-line'><span class='fw_lang'>德</span><span class='fw_def'>#{ translation.Deutsch * ', ' }</span></div>" else '' }
  </span></div>" else '' }"
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
    text.replace(/\uFF0E/g '\u00B7')
        .replace(/\u223C/g '\uFF0D')
        .replace(/\u0358/g '\u030d')
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
re = -> [k for k of it].sort((x, y) -> y.length - x.length).join \|
const C = re Consonants
const V = re Vowels
function trs2bpmf (trs)
  return ' ' if LANG is \h # TODO
  return trs if LANG is \a
  trs.replace(/[A-Za-z\u0300-\u030d]+/g ->
    tone = ''
    it.=toLowerCase!
    it.=replace //([\u0300-\u0302\u0304\u030d])// -> tone := Tones[it]; ''
    it.=replace //^(tsh?|[sj])i// '$1ii'
    it.=replace //ok$// 'ook'
    it.=replace //^(#C)((?:#V)+[ptkh]?)$// -> Consonants[&1] + &2
    it.=replace //[ptkh]$// -> tone := Tones[it+tone]; ''
    it.=replace //(#V)//g -> Vowels[it]
    it + (tone || '\uFFFD')
  ).replace(/[- ]/g '').replace(/\uFFFD/g ' ').replace(/\. ?/g \。).replace(/\? ?/g \？).replace(/\! ?/g \！).replace(/\, ?/g \，)

# draw.coffee from zh-stroke-data by @c9s
$ ->
  filterNodes = (childNodes) ->
    nodes = []
    for n in childNodes
      nodes.push n if n.nodeType == 1
    return nodes

  drawOutline = (paper, outline ,pathAttrs) ->
    path = []
    for node in outline.childNodes
      continue if node.nodeType != 1
      a = node.attributes
      continue unless a
      switch node.nodeName
        when "MoveTo"
          path.push [ "M", parseFloat(a.x.value) , parseFloat(a.y.value) ]
        when "LineTo"
          path.push [ "L", parseFloat(a.x.value) , parseFloat(a.y.value) ]
        when "CubicTo"
          path.push [ "C", parseFloat(a.x1.value) , parseFloat(a.y1.value), parseFloat(a.x2.value), parseFloat(a.y2.value), parseFloat(a.x3.value), parseFloat(a.y3.value) ]
        when "QuadTo"
          path.push [ "Q", parseFloat(a.x1.value) , parseFloat(a.y1.value), parseFloat(a.x2.value), parseFloat(a.y2.value) ]
    stroke = paper.path(path).attr(pathAttrs).transform("s0.1,0.1,0,0")
    stroke.node.setAttribute "class" "fade"
    <- setTimeout _, 1ms
    stroke.node.setAttribute "class" "fade in"

  fetchStrokeXml = (code, next, cb) ->
    $.get((if isCordova then "http://stroke.moedict.tw/" else "utf8/") + code.toLowerCase() + ".xml", cb, "xml")
     .fail -> $('svg:last').fadeOut \fast -> $('svg:last').remove!; next!

  strokeWord = (word, cb, timeout) ->
    return unless $('#strokes').is \:visible
    window.scroll-to 0 0
    utf8code = escape(word).replace(/%u/ , "")
    id = "stroke-#{ "#{Math.random!}" - /^../ }"
    div = $('<div/>', { id, css: { display: \inline-block } }).appendTo $('#strokes')
    paper = Raphael id, 204 204
    grid-lines = [
      "M68,0 L68,204"
      "M136,0 L136,204"
      "M0,68 L204,68"
      "M0,136 L204,136"
    ]
    for line in grid-lines
      paper.path line .attr 'stroke-width': 1 stroke: \#a33

    fetchStrokeXml utf8code, (-> cb timeout), (doc) ->
      window.scroll-to 0 0
      color = "black"
      pathAttrs = { stroke: color, "stroke-width": 0, "stroke-linecap": "round", "fill": color }
      delay = 350ms
      for outline in doc.getElementsByTagName 'Outline' => let
        setTimeout (->
          drawOutline(paper,outline,pathAttrs)
        ), timeout += delay
      cb (timeout + delay)

  window.strokeWords = (words) ->
    $('#strokes').html('').show!
    if (try document.createElement('canvas')?getContext('2d'))
      <- getScript \js/raf.min.js
      <- getScript \js/gl-matrix-min.js
      <- getScript \js/sax.js
      <- getScript \js/jquery.strokeWords.js
      url = \./json/
      dataType = \json
      if isCordova
        if window.DataView and window.ArrayBuffer
          url = \./bin/
          dataType = \bin
        else url = \http://stroke-json.moedict.tw/ # Android <4 has no DataView support
      $('#strokes').strokeWords(words, {url, dataType, -svg})
    else
      <- getScript \js/raphael.js
      ws = words.split ''
      step = -> strokeWord(ws.shift!, step, it) if ws.length
      step 0

LoadedScripts = {}
function getScript (src, cb)
  return cb! if LoadedScripts[src]
  LoadedScripts[src] = true
  $.ajax do
    type: \GET
    url: src
    dataType: \script
    cache: yes
    crossDomain: yes
    complete: cb
