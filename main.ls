window.isCordova = isCordova = document.URL isnt /^https?:/
const DEBUGGING = (!isCordova and !!window.cordova?require)
const STANDALONE = window.STANDALONE || false

{map} = require('prelude-ls')

LANG = STANDALONE || getPref(\lang) || (if document.URL is /twblg/ then \t else \a)
MOE-ID = getPref(\prev-id) || {a: \萌 t: \發穎 h: \發芽 c: \萌}[LANG]
$ ->
  $('body').addClass("lang-#LANG")
  $('.lang-active').text $(".lang-option.#LANG:first").text!

const XREF-LABEL-OF = {a: \華, t: \閩, h: \客, c: \陸, ca: \臺}
const TITLE-OF = {a: '', t: \臺語, h: \客語, c: \兩岸}

HASH-OF = {a: \#, t: "#'", h: \#:, c: \#~}

if isCordova or DEBUGGING
  if STANDALONE
    HASH-OF = {"#STANDALONE": HASH-OF[STANDALONE]}
  else
    delete HASH-OF.c

STARRED = {[key, getPref("starred-#key") || ""] for key of HASH-OF}
LRU = {[key, getPref("lru-#key") || ""] for key of HASH-OF}

isQuery = location.search is /^\?q=/
if location.search is /\?_escaped_fragment_=(.+)/
  isQuery = true
  MOE-ID = decodeURIComponent RegExp.$1
  LANG = \t
isDroidGap = isCordova and location.href is /android_asset/
isDeviceReady = not isCordova
isCordova = true if DEBUGGING
isMobile = isCordova or \ontouchstart of window or \onmsgesturechange in window
isApp = true if isCordova or try window.locationbar?visible is false
isWebKit = navigator.userAgent is /WebKit/
isGecko = navigator.userAgent is /\bGecko\/\b/
isChrome = navigator.userAgent is /\bChrome\/\b/
width-is-xs = -> $ \body .width! < 768
entryHistory = []
INDEX = { t: '', a: '', h: '', c: '' }
XREF = {
  t: {a: '"發穎":"萌,抽芽,發芽,萌芽"'}
  a: {t: '"萌":"發穎"' h: '"萌":"發芽"' }
  h: {a: '"發芽":"萌,萌芽"'}
  tv: {t: ''}
}

if isCordova and STANDALONE isnt \c
  delete HASH-OF.c
  delete INDEX.c
  $ -> $('.nav .c').remove!

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
add-to-lru = ->
  key = "\"#it\"\n"
  LRU[LANG] = key + (LRU[LANG] -= "#key")
  lru = LRU[LANG] / '\n'
  if lru.length > 50
    rmPref "GET #LANG/#{encodeURIComponent(lru.pop!slice(1, -1))}.json" unless isCordova
    LRU[LANG] = (lru * '\n') + '\n'
  setPref "lru-#LANG" LRU[LANG]
GET = (url, data, onSuccess, dataType) ->
  if data instanceof Function
    [data, dataType, onSuccess] = [null, onSuccess, data]
  return onSuccess(that) if CACHED[url]
  dataType ?= \text
  success = ->
    if url is /^[a-z]\/([^-a-z@=].+)\.json$/
      add-to-lru decodeURIComponent RegExp.$1
      setPref "GET #url" it unless isCordova
    onSuccess(CACHED[url] = it)
  error = -> onSuccess(CACHED[url] = that) if getPref "GET #url"
  beforeSend = -> it.override-mime-type 'text/plain; charset=UTF-8' if dataType is \text
  $.ajax { url, data, dataType, success, error, beforeSend }

try
  throw unless isCordova and not DEBUGGING
  document.addEventListener \deviceready (->
    isDeviceReady := yes
    $ \body .on \click 'a[target]' ->
      href = $(@).attr \href
      window.open href, \_system
      return false
    window.do-load!
  ), false
  document.addEventListener \pause (-> stop-audio!), false
catch
  <- $
  $ \#F9868 .html '&#xF9868;'
  $ \#loading .text \載入中，請稍候…
  if document.URL is /^http:\/\/(?:www.)?moedict.tw/i
    url = "https://www.moedict.tw/"
    url += location.hash if location.hash is /^#./
    location.replace url
  else
    if navigator.userAgent is /MSIE\s+[678]/
      $ '.navbar, .query-box' .hide!
      $ '#result' .css \margin-top \50px
    window.do-load!

function setPref (k, v) => try localStorage?setItem(k, JSON?stringify(v))
function getPref (k) => try $.parseJSON(localStorage?getItem(k) ? \null)
function rmPref (k) => try localStorage?removeItem(k)

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
    urls.unshift url.replace(/(ogg|opus)$/ 'mp3') if url is /(ogg|opus)$/ and can-play-mp3! and not isGecko
    audio = new window.Howl { +buffer, urls, onend: done, onloaderror: done, onplay: -> $el.removeClass('icon-play').removeClass('icon-spinner').addClass('icon-stop').show!
    }
    audio.play!
    player := audio
  return play! if window.Howl
  <- getScript \js/howler.js
  return play!

window.show-info = ->
  ref = window.open \about.html \_blank \location=no
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
  $('body').addClass \app if isApp
  $('body').addClass \web unless isApp
  $('body').addClass \ios if isCordova and not isDroidGap
  $('body').addClass \desktop unless isMobile or isApp
  $('body').addClass \android if isDroidGap

  unless STANDALONE and isDroidGap
    <- setTimeout _, 1ms
    cx = '007966820757635393756:sasf0rnevk4';
    gcse = document.createElement('script')
    gcse.type = 'text/javascript'
    gcse.async = true
    gcse.src = "#{
      if document.location.protocol is 'https:' then 'https:' else 'http:'
    }//www.google.com/cse/cse.js?cx=#cx"
    s = document.getElementsByTagName('script')[0];
    s.parentNode.insertBefore(gcse, s);
    poll-gsc = ->
      return setTimeout poll-gsc, 500ms unless $('.gsc-input').length
      $('.gsc-input').attr \placeholder \全文檢索
      isQuery := no
    setTimeout poll-gsc, 500ms

  unless isMobile or isApp or width-is-xs!
    <- setTimeout _, 1ms
    ``!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+"://platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");``

  if navigator.user-agent is /Android\s*[12]\./
    $('body').addClass \overflow-scrolling-false
    $('body').addClass "prefer-down-false"
  else
    $('body').addClass \overflow-scrolling-true
    $('body').addClass "prefer-down-false"
  $('#result').addClass "prefer-pinyin-true" # !!getPref \prefer-pinyin

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
  window.press-about = press-about = -> location.href = \about.html
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
    $ \body .on \dblclick \.entry ->
      return
      return unless LANG is \c
      $(@).css {borderRadius: \10px background: \#eeeeff} .attr \contentEditable true
      $ \#sendback .fadeIn!
    $ \body .on \shown.bs.dropdown \.navbar -> if width-is-xs!
      $(@).css \position \absolute
      $(@).hide!
      $(@).fadeIn 0ms
    $ \body .on \hidden.bs.dropdown \.navbar -> $(@).css \position \fixed

    if isApp => $ \body .on \click '#gcse a.gs-title' ->
      it.preventDefault!
      val = $('#gcse input:visible').val!
      url = $(@).data('ctorig') || ($(@).attr('href') - /^.*?q=/ - /&.*$/)
      setTimeout (->
        $('#gcse input:visible').val val
        grok-val decode-hash(url -= /^.*\//)
      ), 1ms
      $ \.gsc-results-close-btn .click!
      return false

    $ \body .on \click 'li.dropdown-submenu > a' ->
      $(@).next(\ul).slide-toggle \fast if width-is-xs!
      return false

    $ \body .on \click '#btn-starred' ->
      if $(\#query).val! is '=*'
        window.press-back!
      else
        grok-val("#{HASH-OF[LANG]}=*" - /^#/)
      return false

    unless \onhashchange of window
      $ \body .on \click \a ->
        val = $(@).attr(\href)
        val -= /.*\#/ if val
        val ||= $(@).text!
        window.grok-val val
        return false
    window.onpopstate = ->
      state = decodeURIComponent "#{location.pathname}".slice(1)
      return grok-hash! unless state is /\S/
      grok-val state

    return set-html $(\#result).html! if $('#result h1').length
    return if window.grok-hash!
    if isCordova
      fill-query MOE-ID
      $ \#query .val ''
    else if location.hash isnt /^#./
      fetch MOE-ID

  window.grok-val = grok-val = (val) ->
    stop-audio!
    return if val is /</ or val is /^\s+$/
    if val in <[ '=諺語 !=諺語 :=諺語 ]> and not width-is-xs!
      <- setTimeout _, 500ms
      $(\#query).autocomplete(\search)
    lang = \a
    if "#val" is /^['!]/ => lang = \t; val.=substr 1
    if "#val" is /^:/ => lang = \h; val.=substr 1
    if "#val" is /^~/ => lang = \c; val.=substr 1
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

  window.decode-hash = ->
    it = decodeURIComponent it if it is /%/
    it = decodeURIComponent escape it if escape(it) is /%[A-Fa-f]/
    return it

  window.grok-hash = grok-hash = ->
    return false unless location.hash is /^#./
    try
      grok-val decode-hash("#{location.hash}" - /^#+/)
      return true
    return false

  window.fill-query = fill-query = ->
    title = decodeURIComponent(it) - /[（(].*/
    title -= /^[':!~]/
    return if title is /^</
    if title is /^→/
      $(\#query).blur! if isMobile and width-is-xs!
      <- setTimeout _, 500ms
      $(\#query).autocomplete(\search)
      return
    $ \#query .val title
    $ \#cond .val "^#{title}$" unless isCordova
    input = $ \#query .get 0
    if isMobile
      try $(\#query).autocomplete \close
      try $(\#query).blur! if width-is-xs
    else
      input.focus!
      try input.select!
    lookup title
    return true

  prevId = prevVal = null
  window.press-lang = (lang='', id='') ->
    prevId := null
    prevVal := null
    LANG := lang || switch LANG | \a => \t | \t => \h | \h => \c | \c => \a
    $ \#query .val ''
    $('.ui-autocomplete li').remove!
    $('iframe').fadeIn \fast
    $('.lang-active').text $(".lang-option.#LANG:first").text!
    setPref \lang LANG
    id ||= {a: \萌 t: \發穎 h: \發芽 c: \萌}[LANG]
    unless isCordova
      GET "#LANG/xref.json" (-> XREF[LANG] = it), \text
      GET "#LANG/index.json" (-> INDEX[LANG] = it), \text
    $('body').removeClass("lang-t")
    $('body').removeClass("lang-a")
    $('body').removeClass("lang-h")
    $('body').removeClass("lang-c")
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
    Index = INDEX[LANG]
    if title is /^[=@]/ => # pass through...
    else if isCordova or not Index
      return if title is /object/
      return true if Index and Index.indexOf("\"#title\"") is -1
    else
      return true if prevVal is val
      prevVal := val
      return true unless Index.indexOf("\"#title\"") >= 0
    id = title
    return true if prevId is id or (id - /\(.*/) isnt (val - /\(.*/)
    $ \#cond .val "^#{title}$"
    hist = "#{ HASH-OF[LANG].slice(1) }#title"
    entryHistory.push hist unless entryHistory.length and entryHistory[*-1] is hist
    if isApp or LANG isnt \a or title is /^[=@]/
      $(\.back).hide!
    else
      $(\.back).show!
    fetch title
    return true

  htmlCache = {[key, []] for key of HASH-OF}
  fetch = ->
    return unless it
    return if prevId is it
    prevId := it
    prevVal := it
    setPref \prev-id prevId
    hash = "#{ HASH-OF[LANG] }#it"
    unless isQuery
      if document.URL is /^https:\/\/(?:www.)?moedict.tw/i
        page = hash.slice 1
        if "#{decodeURIComponent location.pathname}" isnt "/#page"
          if history.replaceState
            if "#{location.hash}".length > 1
              history.replaceState null, null, page
            else => history.pushState null, null, page
          else => location.replace hash if ("#{location.hash}" - /^#/) isnt page
      else if "#{location.hash}" isnt hash
        try history.pushState null, null, hash
        catch => location.replace hash
      location.search = '' if location.search is /^\?q=/
    try document.title = "#it - #{ TITLE-OF[LANG] }萌典"
    $('.share .btn').each ->
      $(@).attr href: $(@).data(\href).replace(/__TEXT__/, prevId) + encodeURIComponent encodeURIComponent hash.substr(1)
    if isMobile
      $('#result div, #result span, #result h1:not(:first)').hide!
      $('#result h1:first').text(it - /^[@=]/).show!
    else
      $('#result div, #result span, #result h1:not(:first)').css \visibility \hidden
      $('#result h1:first').text(it - /^[@=]/).css \visibility \visible
      window.scroll-to 0 0
    return if load-cache-html it
    return fill-json MOE, \萌 if it is \萌 and LANG is \a
    return load-json it

  load-json = (id, cb) ->
    return fill-json("[#{ STARRED[LANG] }]", '字詞紀錄簿', cb) if id is /^=\*/
    return GET("#LANG/#{ encodeURIComponent(id - /\(.*/)}.json", null, (-> fill-json it, id, cb), \text) unless isCordova
    # Cordova
    bucket = bucket-of id
    return fill-bucket id, bucket, cb

  set-pinyin-bindings = ->
    return
    $('#result.prefer-pinyin-true .bopomofo .bpmf, #result.prefer-pinyin-false .bopomofo .pinyin').unbind(\click).click ->
      val = !getPref \prefer-pinyin
      setPref \prefer-pinyin val
      $('#result').removeClass "prefer-pinyin-#{!val}" .addClass "prefer-pinyin-#val"
      callLater set-pinyin-bindings

  set-html = (html) -> callLater ->
    $('#strokes').fadeOut(\fast -> $('#strokes').html(''); window.scroll-to 0 0) if $('svg, canvas').length and not $('body').hasClass('autodraw')

    html.=replace '<!-- STAR -->' if ~STARRED[LANG].indexOf("\"#prevId\"")
      then "<a class='star iconic-color icon-star' title='已加入記錄簿'></a>"
      else "<a class='star iconic-color icon-star-empty' title='加入字詞記錄簿'></a>"
    $ \#result .html html .ruby!
    _pua!

    $('#result h1 rb[word]') .each ->
      _h = HASH-OF[LANG]
      _i = $ @ .attr 'word-order'
      _ci = $ @ .attr 'word'
      $ @ .wrap $('<a/>').attr({
        'word-order': _i
        'href': _h + _ci
      })
      .on 'mouseover' ->
        _i = $ this .attr 'word-order'
        $('#result h1 a[word-order=' + _i + ']').addClass \hovered
      .on 'mouseout' ->
        $('#result h1 a') .removeClass \hovered

    $('#result .part-of-speech a').attr \href, null
    set-pinyin-bindings!
 
    cache-loading := no

    vclick = if isMobile then \touchstart else \click
    $ '.results .star' .on vclick, ->
      key = "\"#prevId\"\n"
      if $(@).hasClass \icon-star-empty then STARRED[LANG] = key + STARRED[LANG] else STARRED[LANG] -= "#key"
      $(@).toggleClass \icon-star-empty .toggleClass \icon-star
      $(\#btn-starred).fadeOut \fast -> $(@).css(\background \#ddd)fadeIn -> $(@).css(\background \transparent)
      setPref "starred-#LANG" STARRED[LANG]

    $ '.results .stroke' .on vclick, ->
      return ($('#strokes').fadeOut \fast -> $('#strokes').html(''); window.scroll-to 0 0) if $('svg, canvas').length
      window.scroll-to 0 0
      strokeWords($('h1:first').data(\title) - /[（(].*/) # Strip the english part and draw the strokes


    if isCordova and not DEBUGGING
      try navigator.splashscreen.hide!
      $('#result .playAudio').on \touchstart -> $(@).click! if $(@).hasClass('icon-play')
      return

    $('#result .trs.pinyin').each(-> $(@).attr \title trs2bpmf $(@).text!).tooltip tooltipClass: \bpmf

    $('#result a[href]:not(.xref)').tooltip {
      +disabled, tooltipClass: "prefer-pinyin-#{ true /* !!getPref \prefer-pinyin */ }", show: 100ms, hide: 100ms, items: \a,
      open: ->
        $('.ui-tooltip-content h1').ruby!
        _pua!
      content: (cb) ->
        id = $(@).attr \href .replace /^#['!:~]?/, ''
        callLater ->
          if htmlCache[LANG][id]
            cb htmlCache[LANG][id]
            return
          load-json id, -> cb it
        return
    }
    $('#result a[href]:not(.xref)').hoverIntent do
        timeout: 250ms
        over: -> $('.ui-tooltip').remove! ; try $(@).tooltip \open
        out: -> try $(@).tooltip \close
    setTimeout _, 125ms ->
      $('.ui-tooltip').remove!
      setTimeout _, 125ms -> $('.ui-tooltip').remove!

    function _pua
      $('hruby rb[annotation]').each ->
        a = $ @ .attr \annotation

        if isDroidGap or isChrome
          a .= replace /([aeiou])\u030d/g (m, v) ->
            return      if v is \a then \\uDB80\uDC61
                   else if v is \e then \\uDB80\uDC65
                   else if v is \i then \\uDB80\uDC69
                   else if v is \o then \\uDB80\uDC6F
                   else if v is \u then \\uDB80\uDC75
        else
          a .= replace /i\u030d/g \\uDB80\uDC69

        if a is /(<span[^<]*<\/span>)/
          $(RegExp.$1).appendTo $(\<span/> class: \specific_to).appendTo $(@).parents('h1')
        $ @ .attr \annotation, a - /<span[^<]*<\/span>/g

      $('hruby rb[diao]').each ->
        d = $ @ .attr \diao
        d .= replace /([\u31B4-\u31B7])[\u0358|\u030d]/g (m, j) ->
          return      if j is \\u31B4 then \\uDB8C\uDDB4
                 else if j is \\u31B5 then \\uDB8C\uDDB5
                 else if j is \\u31B6 then \\uDB8C\uDDB6
                 else if j is \\u31B7 then \\uDB8C\uDDB7
        $ @ .attr \diao, d

  load-cache-html = ->
    html = htmlCache[LANG][it]
    return false unless html
    set-html html
    return true

  fill-json = (part, id, cb=set-html) ->
    while part is /"`辨~\u20DE&nbsp`似~\u20DE"[^}]*},{"f":"([^（]+)[^"]*"/
      part.=replace /"`辨~\u20DE&nbsp`似~\u20DE"[^}]*},{"f":"([^（]+)[^"]*"/ '"辨\u20DE 似\u20DE $1"'
    part.=replace /"`(.)~\u20DE"[^}]*},{"f":"([^（]+)[^"]*"/g '"$1\u20DE $2"'
    part.=replace /"([hbpdcnftrelsaqETAVCDS_=])":/g (, k) -> keyMap[k] + \:
    h = HASH-OF[LANG]
    part.=replace /([「【『（《])`([^~]+)~([。，、；：？！─…．·－」』》〉]+)/g (, pre, word, post) -> "<span class='punct'>#pre<a href=\\\"#h#word\\\">#word</a>#post</span>"
    part.=replace /([「【『（《])`([^~]+)~/g (, pre, word) -> "<span class='punct'>#pre<a href=\\\"#h#word\\\">#word</a></span>"
    part.=replace /`([^~]+)~([。，、；：？！─…．·－」』》〉]+)/g (, word, post) -> "<span class='punct'><a href=\\\"#h#word\\\">#word</a>#post</span>"
    part.=replace /`([^~]+)~/g (, word) -> "<a href=\\\"#h#word\\\">#word</a>"
    part.=replace /([)）])/g "$1\u200B"
    if part is /^\[\s*\[/
      html = render-strokes part, id
    else if part is /^\[/
      html = render-list part, id
    else
      html = render $.parseJSON part
    html.=replace /(.)\u20DD/g          "<span class='regional part-of-speech'>$1</span>"
    html.=replace /(.)\u20DE/g          "</span><span class='part-of-speech'>$1</span><span>"
    html.=replace /(.)\u20DF/g          "<span class='specific'>$1</span>"
    html.=replace /(.)\u20E3/g          "<span class='variant'>$1</span>"
    html.=replace //<a[^<]+>#id<\/a>//g "#id"
    html.=replace //<a>([^<]+)</a>//g   "<a href=\"#{h}$1\">$1</a>"
    html.=replace //(>[^<]*)#id(?!</(?:h1|rb)>)//g      "$1<b>#id</b>"
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
                XREF-LABEL-OF["#LANG#tgt-lang"] || XREF-LABEL-OF[tgt-lang]
              }</span>
              <span class='xref' itemprop='citation'>
      """
      html += (for word in words
        h = HASH-OF[tgt-lang]
        if word is /`/
          word.replace /`([^~]+)~/g (, word) -> "<a class='xref' href=\"#h#word\">#word</a>"
        else
          "<a class='xref' href=\"#h#word\">#word</a>"
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
    S: \"specific_to"
  }

  fill-bucket = (id, bucket, cb) ->
    raw <- GET "p#{LANG}ck/#bucket.txt"
    key = escape id
    idx = raw.indexOf('"' + key + '"');
    return if idx is -1
    part = raw.slice(idx + key.length + 3);
    idx = part.indexOf('\n')
    part = part.slice(0, idx)
    add-to-lru id
    fill-json part, id, cb

  if isCordova
    for lang of HASH-OF => let lang
      GET "#lang/xref.json", (-> XREF[lang] = it; init! if lang is LANG), \text
      p1 <- GET "#lang/index.1.json", _, \text
      p2 <- GET "#lang/index.2.json", _, \text
      INDEX[lang] = p1 + p2
      init-autocomplete! if lang is LANG
  else
    GET "#LANG/xref.json", (-> XREF[LANG] = it; init!), \text
    GET "#LANG/index.json", (-> INDEX[LANG] = it; init-autocomplete!), \text
    for lang in HASH-OF | lang isnt LANG => let lang
      GET "#lang/xref.json", (-> XREF[lang] = it), \text

  unless STANDALONE
    GET "t/variants.json", (-> XREF.tv = {t: it}), \text

  for lang of HASH-OF | lang isnt \h => let lang
    GET "#lang/=.json", (->
      $ul = render-taxonomy lang, $.parseJSON it
      if STANDALONE
        $('.nav .lang-option.c:first').parent!prevAll!remove!
        return $(".taxonomy.#lang").parent!replaceWith $ul.children!
      $(".taxonomy.#lang").after $ul
    ), \text

function render-taxonomy (lang, taxonomy)
  $ul = $(\<ul/> class: \dropdown-menu)
  $ul.css bottom: 0 top: \auto if lang is \c and not STANDALONE
  for taxo in (if taxonomy instanceof Array then taxonomy else [taxonomy])
    if typeof taxo is \string
      $ul.append $(\<li/> role: \presentation).append $(
        \<a/> class: "lang-option #lang" href: "#{ HASH-OF[lang] }=#taxo"
      ).text(taxo)
    else for label, submenu of taxo
      $ul.append $(\<li/> class: \dropdown-submenu).append(
        $(\<a/> href: \#).text(label)
      ).append(render-taxonomy lang, submenu)
  return $ul

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
      if item?value is /^▶/
        val = $(\#query).val!replace(/^→列出含有「/ '').replace(/」的詞$/ '')
        if LANG is \c
          window.open "mailto:xldictionary@gmail.com?subject=建議收錄：#val&body=出處及定義：", \_system
        else
          window.open "https://www.moedict.tw/#{ HASH-OF[LANG].slice(1) }#val", \_system
        return false
      return false if item?value is /^\(/
      fill-query item.value if item?value
      return true
    change: (e, {item}) ->
      return if $ \#query .data \changing
      return false if item?value is /^\(/
      return $ \#query .data { +changing }
      fill-query item.value if item?value
      return $ \#query .data { -changing }
      return true
    source: ({term}, cb) ->
      term = "。" if term is \=諺語 and LANG is \t
      term = "，" if term is \=諺語 and LANG is \h
      $('iframe').fadeOut \fast
      return cb [] unless term.length
      return trs_lookup(term, cb) unless LANG isnt \t or term is /[^\u0000-\u00FF]/ or term is /[,;0-9]/
      return cb ["→列出含有「#{term}」的詞"] if width-is-xs! and term isnt /[「」。，?.*_% ]/
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
      return cb ["▶找不到。建議收錄？"] if LANG is \c and not results?length
      return cb ["▶找不到。分享這些字？"] if LANG isnt \c and not results?length
      return cb [''] unless results?length
      do-lookup(results.0 - /"/g) if results.length is 1
      MaxResults = if width-is-xs! then 400 else 1024
      if results.length > MaxResults
        more = "(僅顯示前 #MaxResults 筆)"
        results.=slice(0, MaxResults)
        results.push more
      return cb (map (- /"/g), results)
      #return cb ((results.join(',') - /"/g) / ',')

trs_lookup = (term,cb) -> GET("https://www.moedict.tw/lookup/trs/#{term}",((data)-> cb (data / '|' )) )


const CJK-RADICALS = '⼀一⼁丨⼂丶⼃丿⼄乙⼅亅⼆二⼇亠⼈人⼉儿⼊入⼋八⼌冂⼍冖⼎冫⼏几⼐凵⼑刀⼒力⼓勹⼔匕⼕匚⼖匸⼗十⼘卜⼙卩⼚厂⼛厶⼜又⼝口⼞囗⼟土⼠士⼡夂⼢夊⼣夕⼤大⼥女⼦子⼧宀⼨寸⼩小⼪尢⼫尸⼬屮⼭山⼮巛⼯工⼰己⼱巾⼲干⼳幺⼴广⼵廴⼶廾⼷弋⼸弓⼹彐⼺彡⼻彳⼼心⼽戈⼾戶⼿手⽀支⽁攴⽂文⽃斗⽄斤⽅方⽆无⽇日⽈曰⽉月⽊木⽋欠⽌止⽍歹⽎殳⽏毋⽐比⽑毛⽒氏⽓气⽔水⽕火⽖爪⽗父⽘爻⽙爿⺦丬⽚片⽛牙⽜牛⽝犬⽞玄⽟玉⽠瓜⽡瓦⽢甘⽣生⽤用⽥田⽦疋⽧疒⽨癶⽩白⽪皮⽫皿⽬目⽭矛⽮矢⽯石⽰示⽱禸⽲禾⽳穴⽴立⽵竹⽶米⽷糸⺰纟⽸缶⽹网⽺羊⽻羽⽼老⽽而⽾耒⽿耳⾀聿⾁肉⾂臣⾃自⾄至⾅臼⾆舌⾇舛⾈舟⾉艮⾊色⾋艸⾌虍⾍虫⾎血⾏行⾐衣⾑襾⾒見⻅见⾓角⾔言⻈讠⾕谷⾖豆⾗豕⾘豸⾙貝⻉贝⾚赤⾛走⾜足⾝身⾞車⻋车⾟辛⾠辰⾡辵⻌辶⾢邑⾣酉⾤釆⾥里⾦金⻐钅⾧長⻓长⾨門⻔门⾩阜⾪隶⾫隹⾬雨⾭靑⾮非⾯面⾰革⾱韋⻙韦⾲韭⾳音⾴頁⻚页⾵風⻛风⾶飛⻜飞⾷食⻠饣⾸首⾹香⾺馬⻢马⾻骨⾼高⾽髟⾾鬥⾿鬯⿀鬲⿁鬼⿂魚⻥鱼⻦鸟⿃鳥⿄鹵⻧卤⿅鹿⿆麥⻨麦⿇麻⿈黃⻩黄⿉黍⿊黑⿋黹⿌黽⻪黾⿍鼎⿎鼓⿏鼠⿐鼻⿑齊⻬齐⿒齒⻮齿⿓龍⻰龙⿔龜⻳龟⿕龠'

const SIMP-TRAD = window.SIMP-TRAD ? ''

function b2g (str='')
  return str unless LANG in <[ a c ]> and str isnt /^@/
  rv = ''
  for char in (str / '')
    idx = SIMP-TRAD.index-of(char)
    rv += if idx % 2 then char else SIMP-TRAD[idx + 1]
  return rv.replace(/台([北中南東灣語])/g '臺$1')

function render-radical (char)
  idx = CJK-RADICALS.index-of(char)
  char = CJK-RADICALS[idx+1] unless idx % 2
  return char unless LANG in <[ a c ]>
  h = HASH-OF[LANG]
  return "<a title='部首檢索' class='xref' style='color: white' href=\"#h@#char\"> #char</a>"

function can-play-mp3
  return CACHED.can-play-mp3 if CACHED.can-play-mp3?
  a = document.createElement \audio
  CACHED.can-play-mp3 = !!(a.canPlayType?('audio/mpeg;') - /^no$/)

function can-play-ogg
  return CACHED.can-play-ogg if CACHED.can-play-ogg?
  a = document.createElement \audio
  CACHED.can-play-ogg = !!(a.canPlayType?('audio/ogg; codecs="vorbis"') - /^no$/)

function can-play-opus
  return CACHED.can-play-opus if CACHED.can-play-opus?
  a = document.createElement \audio
  CACHED.can-play-opus = !!(a.canPlayType?('audio/ogg; codecs="opus"') - /^no$/)

function render-strokes (terms, id)
  h = HASH-OF[LANG]
  id -= /^[@=]/
  if id is /^\s*$/
    title = "<h1 itemprop='name'>部首表</h1>"
    h += '@'
  else
    title = "<h1 itemprop='name'>#id <a class='xref' href=\"#\@\" title='部首表'>部</a></h1>"
  rows = $.parseJSON terms
  list = ''
  for chars, strokes in rows | chars?length
    list += "<span class='stroke-count'>#strokes</span><span class='stroke-list'>"
    for ch in chars
      list += "<a class='stroke-char' href=\"#h#ch\">#ch</a> "
    list += "</span><hr style='margin: 0; padding: 0; height: 0'>"
  return "#title<div class='list'>#list</div>"

function render-list (terms, id)
  h = HASH-OF[LANG]
  id -= /^[@=]/
  title = "<h1 itemprop='name'>#id</h1>"
  terms -= /^[^"]*/
  if id is \字詞紀錄簿
    terms += "（請按詞條右方的 <i class='icon-star-empty'></i> 按鈕，即可將字詞加到這裡。）" unless terms
  if terms is /^";/
    terms = "<table border=1 bordercolor=\#ccc><tr><td><span class='part-of-speech'>臺</span></td><td><span class='part-of-speech'>陸</span></td></tr>#terms</table>"
    terms.=replace /";([^;"]+);([^;"]+)"[^"]*/g """<tr><td><a href=\"#{h}$1\">$1</a></td><td><a href=\"#{h}$2\">$2</a></td></tr>"""
  else
    terms.=replace(/"([^"]+)"[^"]*/g "<span style='clear: both; display: block'>\u00B7 <a href=\"#{h}$1\">$1</a></span>")
  if id is \字詞紀錄簿 and LRU[LANG]
    terms += "<br><h3>最近查閱過的字詞</h3>\n"
    terms += LRU[LANG].replace(/"([^"]+)"[^"]*/g "<span style='clear: both; display: block'>\u00B7 <a href=\"#{h}$1\">$1</a></span>")
  return "#title<div class='list'>#terms</div>"

http-map =
  a: \203146b5091e8f0aafda-15d41c68795720c6e932125f5ace0c70.ssl.cf1.rackcdn.com
  h: \a7ff62cf9d5b13408e72-351edcddf20c69da65316dd74d25951e.ssl.cf1.rackcdn.com
  t: \1763c5ee9859e0316ed6-db85b55a6a3fbe33f09b9245992383bd.ssl.cf1.rackcdn.com
  'stroke-json': \829091573dd46381a321-9e8a43b8d3436eaf4353af683c892840.ssl.cf1.rackcdn.com
  stroke: \/626a26a628fa127d6a25-47cac8eba79cfb787dbcc3e49a1a65f1.ssl.cf1.rackcdn.com

function http
  return "http://#it" unless location.protocol is \https:
  return "https://#{ it.replace(/^([^.]+)\.[^\/]+/, (xs,x) -> http-map[x] or xs ) }"

function render (json)
  { title, english, heteronyms, radical, translation, non_radical_stroke_count: nrs-count, stroke_count: s-count, pinyin: py } = json
  char-html = if radical then "<div class='radical'><span class='glyph'>#{
    render-radical(radical - /<\/?a[^>]*>/g)
  }</span><span class='count'><span class='sym'>+</span>#{ nrs-count }</span><span class='count'> = #{ s-count }</span>&nbsp;<a class='iconic-circle stroke icon-pencil' title='筆順動畫' style='color: white'></a></div>" else "<div class='radical'><a class='iconic-circle stroke icon-pencil' title='筆順動畫' style='color: white'></a></div>"
  result = ls heteronyms, ({id, audio_id=id, bopomofo, pinyin=py, trs='', definitions=[], antonyms, synonyms, variants, specific_to, alt}) ->
    pinyin ?= trs
    pinyin = (pinyin - /<[^>]*>/g - /（.*）/) unless LANG is \c
    if audio_id and LANG is \h
      pinyin.=replace /(.)\u20DE/g (_, $1) ->
        variant = " 四海大平安".indexOf($1)
        mp3 = http "h.moedict.tw/#{variant}-#audio_id.ogg"
        mp3.=replace(/ogg$/ \mp3) if mp3 and not can-play-ogg!
        """
        </span><span class="audioBlock"><div onclick='window.playAudio(this, \"#mp3\")' class='icon-play playAudio part-of-speech'>#{$1}</div>
      """
    bopomofo ?= trs2bpmf "#pinyin"

    bopomofo -= /<[^>]*>/g unless LANG is \c
    pinyin .= replace /ɡ/g \g
    pinyin .= replace /ɑ/g \a
    pinyin .= replace /，/g ', '

    youyin = if bopomofo is /^（[語|讀|又]音）/
             then bopomofo.replace /（([語|讀|又]音)）.*/, '$1'
    b-alt = if bopomofo is /[變|\/]/
                  then bopomofo.replace /.*[\(變\)​|\/](.*)/, '$1'
                  else if bopomofo is /.+（又音）.+/
                  then bopomofo.replace /.+（又音）/, ''
                  else ''
    b-alt .= replace(/ /g, '\u3000').replace(/([ˇˊˋ])\u3000/g, '$1 ')
    p-alt = if pinyin is /[變|\/]/
              then pinyin.replace /.*[\(變\)​|\/](.*)/, '$1'
              else if bopomofo is /.+（又音）.+/
              then do ->
                _py = pinyin.split ' '
                for i from 0 to _py.length/2-1
                    _py.shift()
                return _py.join ' '
              else ''

    bopomofo .= replace /([^ ])(ㄦ)/g, '$1 $2' .replace /([ ]?[\u3000][ ]?)/g, ' '
    bopomofo .= replace /([ˇˊˋ˪˫])[ ]?/g, '$1 ' .replace /([ㆴㆵㆶㆷ][̍͘]?)/g, '$1 '

    ruby = do ->
      if LANG is \h
        return

      t = title.replace /<a[^>]+>/g '`' .replace /<\/a>/g '~'
      t -= /<[^>]+>/g

      b = bopomofo.replace /\s?[，、；。－—,\.;]\s?/g, ' '
      b .= replace /（[語|讀|又]音）[\u200B]?/, ''
      b .= replace /\(變\)​\/.*/, ''
      b .= replace /\/.*/, ''
      b .= replace /<br>.*/, ''
      b -= /.\u20DF/g

      if t is /^([\uD800-\uDBFF][\uDC00-\uDFFF]|.)$/
        ruby = '<rbc><div class="stroke" title="筆順動畫"><rb>' + t + '</rb></div></rbc>'
      else
        ruby = '<rbc>' + t.replace( /([^`~]+)/g, (m, ci, o, s) ->
          return if ( ci is /^([\uD800-\uDBFF][\uDC00-\uDFFF]|[^，、；。－—])$/ )
                 then '<rb word="' + ci + '">' + ci + '</rb>'
                 else ci.replace(/([\uD800-\uDBFF][\uDC00-\uDFFF]|[^，、；。－—])/g, '<rb word="' + ci + '" word-order="' + o + '">$1</rb>')
        ).replace(/([`~])/g, '') + '</rbc>'

      p = pinyin.replace /[,\.;，、；。－—]\s?/g, ' '
      p .= replace /\(變\)​.*/, ''
      p .= replace /\/.*/, ''
      p .= replace /<br>.*/, ''
      p .= split ' '

      for yin in p
        unless yin == ''
          span = # 閩南語典，按隔音符計算字數
                 if LANG is \t and yin is /\-/g
                 then ' rbspan="'+ (yin.match /[\-]+/g .length+1) + '"'

                 # 國語兒化音
                 else if LANG != \t && yin is /^[^eēéěè].*r$/g
                 then ' rbspan="2"'

                 # 兩岸詞典，按元音群計算字數
                 else if LANG != \t and yin is /[aāáǎàeēéěèiīíǐìoōóǒòuūúǔùüǖǘǚǜ]+/g
                 then ' rbspan="'+ yin.match /[aāáǎàeēéěèiīíǐìoōóǒòuūúǔùüǖǘǚǜ]+/g .length + '"'
                 else ''
          p[i$] = '<rt' + span + '>' + yin + '</rt>'

      ruby += '<rtc class="zhuyin"><rt>' + b.replace(/[ ]+/g, '</rt><rt>') + '</rt></rtc>'
      ruby += '<rtc class="romanization">'
      ruby += p.join ''
      ruby += '</rtc>'
      return ruby

    cn-specific = ''
    cn-specific = \cn-specific if bopomofo is /陸/ #and bopomofo isnt /<br>/

    if LANG is \c 
      if bopomofo is /<br>/
        pinyin .= replace /.*<br>/ '' .replace /陸./ '' .replace /\s?([,\.;])\s?/g '$1 '
        bopomofo .= replace /.*<br>/ '' .replace /陸./ '' .replace /\s?([，。；])\s?/g '$1'
        bopomofo .= replace(/ /g, '\u3000').replace(/([ˇˊˋ])\u3000/g, '$1 ')
      else
        pinyin = ''
        bopomofo = ''
    else if LANG is \h
      bopomofo = ''

    unless title is /</
      title := "<div class='stroke' title='筆順動畫'>#title</div>"

    """
      <!-- STAR -->
      <meta itemprop="image" content="#{ encodeURIComponent(h(title) - /<[^>]+>/g) }.png" />
      <meta itemprop="name" content="#{ h(title) - /<[^>]+>/g }" />
      #char-html
      <h1 class='title' data-title="#{ h(title) - /<[^>]+>/g }">
      #{
        unless LANG is \h then """
          <ruby class="rightangle">#ruby</ruby>
        """
        else title
      }#{
        if youyin then """
          <small class='youyin'>#youyin</small>
        """ else ''
      }#{
        if audio_id and (can-play-ogg! or can-play-mp3!)
          if LANG is \t and not (20000 < audio_id < 50000)
            basename = (100000 + Number audio_id) - /^1/
            mp3 = http "t.moedict.tw/#basename.ogg"
          else if LANG is \a
            mp3 = http "a.moedict.tw/#audio_id.ogg" # TODO: opus
          mp3.=replace(/opus$/ \ogg) if mp3 is /opus$/ and not can-play-opus!
          mp3.=replace(/(opus|ogg)$/ \mp3) if mp3 is /(opus|ogg)$/ and not can-play-ogg!
        if mp3 then """
          <i itemscope itemtype="http://schema.org/AudioObject"
            class='icon-play playAudio' onclick='window.playAudio(this, \"#mp3\")'><meta
            itemprop="name" content="#{ mp3 - /^.*\// }" /><meta
            itemprop="contentURL" content="#mp3" /></i>
        """ else ''
      }#{
        if b-alt then """
          <small class='alternative'><span class='pinyin'>#p-alt</span><span class='bopomofo'>#b-alt</span></small>
        """ else ''
      }#{
        if english then "<span lang='en' class='english'>#english</span>" else ''
      }#{
        if specific_to then "<span class='specific_to'>#specific_to</span>" else ''
      }
      </h1>
      <div class="bopomofo">
      #{
        if alt? then """
          <div lang="zh-Hans" class="cn-specific">
            <span class='xref part-of-speech'>简</span>
            <span class='xref'>#{ alt - /<[^>]*>/g }</span>
          </div>
        """ else ''
      }#{
        if cn-specific then """
          <small class="alternative cn-specific">
            <span class='pinyin'>#pinyin</span>
            <span class='bopomofo'>#bopomofo</span>
          </small>
        """ else if LANG is \h then """
          <span class='pinyin'>#pinyin</span>
        """ else ''
      }
      </div>
      <div class="entry" itemprop="articleBody">
      #{ls groupBy(\type definitions.slice!), (defs) ->
        """
        <div class="entry-item">
        #{
          if defs.0?type
          then [ "<span class='part-of-speech'>#t</span>" for t in defs.0.type / \, ] * '&nbsp;'
          else ''
        }
          <ol>
          #{ls defs, ({ type, def, quote=[], example=[], link=[], antonyms, synonyms }) ->
          """
            <li><p class='definition'>
              <span class="def">
              #{
                (h expand-def def).replace(
                  /([：。」])([\u278A-\u2793\u24eb-\u24f4])/g
                  '$1</span><span class="def">$2'
                )
              }</span>
              #{ ls example, -> "<span class='example'>#{ h it }</span></span>" }
              #{ ls quote,   -> "<span class='quote'>#{   h it }</span>" }
              #{ ls link,    -> "<span class='link'>#{    h it }</span>" }
              #{
                if synonyms
                then "<span class='synonyms'><span class='part-of-speech'>似</span> #{
                  h((synonyms - /^,/).replace(/,/g '、'))
                }</span>" else ''
              }#{
                if antonyms
                then "<span class='antonyms'><span class='part-of-speech'>反</span> #{
                  h((antonyms - /^,/).replace(/,/g '、'))
                }</span>" else ''
              }
            </p></li>
          """
          }
          </ol></div>
        """
      }#{
        if synonyms
        then "<span class='synonyms'><span class='part-of-speech'>似</span> #{
          h((synonyms - /^,/).replace(/,/g '、'))
        }</span>" else ''
      }#{
        if antonyms
        then "<span class='antonyms'><span class='part-of-speech'>反</span> #{
          h((antonyms - /^,/).replace(/,/g '、'))
        }</span>" else ''
      }#{
        if variants
        then "<span class='variants'><span class='part-of-speech'>異</span> #{
          h(variants.replace(/,/g '、'))
        }</span>" else ''
      }
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
      /\{(\d)\}/g (_, num) -> String.fromCharCode(0x2775 + parseInt num)
    ).replace(
      /[（(](\d)[)）]/g (_, num) -> String.fromCharCode(0x2789 + parseInt num)
    ).replace(/\(/g, '（').replace(/\)/g, '）')
  function ls (entries=[], cb)
    [cb x for x in entries].join ""
  function h (text='')
    if LANG is \t
      text.=replace /([\u31B4-\u31B7])([^\u0358])/g "<span class='u31bX'>$1</span>$2"
      text.=replace /(\u31B4)\u0358/g "<span class='u31b4-0358'>$1\u0358</span>"
      text.=replace /(\u31B5)\u0358/g "<span class='u31b5-0358'>$1\u0358</span>"
      text.=replace /(\u31B6)\u0358/g "<span class='u31b6-0358'>$1\u0358</span>"
      text.=replace /(\u31B7)\u0358/g "<span class='u31b7-0358'>$1\u0358</span>"
      if isDroidGap or isChrome
        text.=replace /([aieou])\u030d/g "<span class='vowel-030d $1-030d'>$1\u030d</span>"
      else
        text.=replace /([i])\u030d/g "<span class='vowel-030d $1-030d'>$1\u030d</span>"
    text.replace(/[\uFF0E\u2022]/g '\u00B7')
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
    $.get((if isCordova then http "stroke.moedict.tw/" else "utf8/") + code.toLowerCase() + ".xml", cb, "xml")
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
        else url = http \stroke-json.moedict.tw/ # Android <4 has no DataView support
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
