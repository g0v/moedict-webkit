window.isCordova = isCordova = document.URL isnt /^https?:/
window.isMoedictDesktop = isMoedictDesktop = true if window.moedictDesktop
const DEBUGGING = (!isCordova and !!window.cordova?require)
const STANDALONE = window.STANDALONE || false

{any, map, unique} = require('prelude-ls')
window.$ = window.jQuery = require \jquery

React = require \react
React.View = require \./view.ls
window.React = React

unless window.PRERENDER_LANG
  $ -> React.View.result = React.render React.View.Result!, $(\#result).0

LANG = STANDALONE || window.PRERENDER_LANG || getPref(\lang) || (if document.URL is /twblg/ then \t else \a)
MOE-ID = getPref(\prev-id) || {a: \萌 t: \發穎 h: \發芽 c: \萌}[LANG]
$ ->
  $('body').addClass("lang-#LANG")
  React.render React.createElement(React.View.Links), $(\#links).0
  React.render React.createElement(React.View.UserPref), $(\#user-pref).0
  React.render React.createElement(React.View.Nav, {STANDALONE}), $(\#nav).0, ->
    $('.lang-active').text $(".lang-option.#LANG:first").text!
    if navigator.userAgent is /MSIE|Trident/
      $('form[id=lookback]').remove!
    else
      $('form[id=lookback]').attr \accept-charset \big5
      if window.PRERENDER_ID
        $('form[id=lookback] input[id=cond]').val "^#{window.PRERENDER_ID}$"
        $('#query').val window.PRERENDER_ID

const XREF-LABEL-OF = {a: \華, t: \閩, h: \客, c: \陸, ca: \臺}
const TITLE-OF = {a: '', t: \臺語, h: \客語, c: \兩岸}

HASH-OF = {a: \#, t: "#'", h: \#:, c: \#~}

if (isCordova or DEBUGGING) and not window.ALL_LANGUAGES
  if STANDALONE
    HASH-OF = {"#STANDALONE": HASH-OF[STANDALONE]}
  else
    delete HASH-OF.c

window.STARRED = STARRED = {[key, getPref("starred-#key") || ""] for key of HASH-OF}
LRU = {[key, getPref("lru-#key") || ""] for key of HASH-OF}

isQuery = location.search is /^\?q=/
if location.search is /\?_escaped_fragment_=(.+)/
  isQuery = true
  MOE-ID = decodeURIComponent RegExp.$1
  LANG = \t
isDroidGap = isCordova and location.href is /android_asset/
isDeviceReady = not isCordova
isCordova = true if DEBUGGING
isMobile = isCordova or \ontouchstart of window or \onmsgesturechange of window
isApp = true if isCordova or try window.locationbar?visible is false
isWebKit = navigator.userAgent is /WebKit/
isGecko = navigator.userAgent is /\bGecko\/\b/
isChrome = navigator.userAgent is /\bChrome\/\b/
isPrerendered = window.PRERENDER_LANG
width-is-xs = -> $ \body .width! < 768
entryHistory = []
INDEX = { t: '', a: '', h: '', c: '' }
XREF = {
  t: {a: '"發穎":"萌,抽芽,發芽,萌芽"'}
  a: {t: '"萌":"發穎"' h: '"萌":"發芽"' }
  h: {a: '"發芽":"萌,萌芽"'}
  tv: {t: ''}
}

if isCordova and STANDALONE isnt \c and not window.ALL_LANGUAGES
  delete HASH-OF.c
  delete INDEX.c
  $ -> $('.nav .c').remove!

# Return an object of all matched with {key: [words]}.
function xref-of (id, src-lang=LANG, tgt-lang-only)
  rv = {}
  if typeof XREF[src-lang] is \string
    parsed = {}
    for chunk in XREF[src-lang].split \}
      [tgt-lang, words] = chunk.split \":{
      parsed[tgt-lang.slice(-1)] = words if words
    XREF[src-lang] = parsed
  for tgt-lang, words of XREF[src-lang]
    continue if tgt-lang-only and tgt-lang isnt tgt-lang-only
    idx = words.indexOf('"' + id + '":')
    rv[tgt-lang] = if idx < 0 then [] else
      part = words.slice(idx + id.length + 4);
      idx = part.indexOf \"
      part.=slice 0 idx
      [ x || id for x in part / /,+/ ]
    return rv[tgt-lang] if tgt-lang-only
  return rv

CACHED = {}
add-to-lru = ->
  key = "\"#it\"\n"
  LRU[LANG] = key + (LRU[LANG] -= "#key")
  lru = LRU[LANG] / '\n'
  if lru.length > 5000
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
  $ \#loading .text \載入中，請稍候……
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
    urls.unshift url.replace(/(ogg|opus)$/ \mp3) if url is /(ogg|opus)$/ and can-play-mp3!
    audio = new window.Howl { +buffer, +html5, src: urls, urls, onend: done, onloaderror: done, onplay: -> $el.removeClass('icon-play').removeClass('icon-spinner').addClass('icon-stop').show!
    }
    audio.play!
    player := audio
  return play! if window.Howl

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
    window.IS_GOOGLE_AFS_IFRAME_ = true
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
      $('.gsc-input').attr \placeholder \Search
      isQuery := no
    setTimeout poll-gsc, 500ms

  unless isApp or width-is-xs!
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
    window.press-quit! if isDroidGap and entryHistory.length <= 1
    cur = entryHistory[*-1]
    while entryHistory[*-1] is cur
      entryHistory.pop!
      window.press-quit! if isDroidGap and entryHistory.length < 1
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
    navigator.app.exit-app!

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

    if isApp =>
      $ \body .on \touchstart '#gcse a.gs-title' ->
        $(@).removeAttr \href
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

    $ \body
    .on \click '#btn-starred' ->
      if $(\#query).val! is '=*'
        window.press-back!
      else
        grok-val("#{HASH-OF[LANG]}=*" - /^#/)
      return false

    .on \click '#btn-pref' (e) ->
      e.preventDefault!
      $ \#user-pref .slideToggle!

    .on \click '#user-pref .btn-close' ->
      $ \#user-pref .slideUp!

    .on \click 'a\[for="starred-record--history"\]' ->
      $ '.result nav li.active' .removeClass \active
      $ this .parent \li .addClass \active
      $ \.starred-record--fav .hide!
      $ \.starred-record--history .show!

    .on \click 'a\[for="starred-record--fav"\]' ->
      $ '.result nav li.active' .removeClass \active
      $ this .parent \li .addClass \active
      $ \.starred-record--fav .show!
      $ \.starred-record--history .hide!

    unless \onhashchange of window
      $ \body .on \click \a ->

    $ \body .on \click '#btn-clear-lru' ->
      return unless confirm("確定要清除瀏覽紀錄？")
      $('#lru').prevAll('br')remove!
      $('#lru').nextAll!remove!
      $('#lru').fadeOut \fast
      unless isCordova
        lru = LRU[LANG] / '\n'
        for word in lru
          rmPref "GET #LANG/#{encodeURIComponent(word.slice(1, -1))}.json"
      LRU[LANG] = []
      setPref "lru-#LANG" ''

    onFollow = ->
        return if it.metaKey or it.ctrlKey
        val = $(@).attr(\href)
        return true if val is \#
        if $('.dropdown.open').length
          $ \.navbar .css \position \fixed
          $ \.dropdown.open .removeClass \open
        val -= /[^#]*(\.\/|\#)+/ if val
        val ||= $(@).text!
        window.grok-val val
        return false
    if isCordova or not \onhashchange of window
      $ '#result, .dropdown-menu' .on \click 'a[href^="#"]:not(.mark)' onFollow
    else
      $ '#result, .dropdown-menu' .on \click 'a[href^="./"]:not([href^="#"]):not(.mark)' onFollow

    unless isDroidGap => window.onpopstate = ->
      return window.press-back! if isDroidGap
      state = decodeURIComponent "#{location.pathname}".slice(1)
      return grok-hash! unless state is /\S/
      grok-val state

    return if isPrerendered
    return if window.grok-hash!
    if isCordova
      fill-query MOE-ID
      $ \#query .val ''
    else if location.hash isnt /^#./
      fetch MOE-ID

  window.grok-val = grok-val = (val) ->
    stop-audio!
    val -= /[\\"]/g
    val = val.replace /`(.+)~$/ '$1'
    return if val is /</ or val is /^\s+$/ or val is /index.html/
    if val in <[ '=諺語 !=諺語 :=諺語 ]> and not width-is-xs!
      <- setTimeout _, 500ms
      $(\#query).autocomplete(\search)
    lang = \a
    if "#val" is /^['!]/ => lang = \t; val.=substr 1
    if "#val" is /^:/ => lang = \h; val.=substr 1
    if "#val" is /^~/ => lang = \c; val.=substr 1
    $('.lang-active').text $(".lang-option.#lang:first").text!
    if lang isnt LANG
      return setTimeout (-> window.press-lang lang, val), 1ms
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
    $('form[id=lookback] input[id=cond]').val "^#{title}$" unless isCordova
    input = $ \#query .get 0
    if isMobile
      try $(\#query).autocomplete \close
      try $(\#query).blur! if width-is-xs
    else
      input.focus!
      try input.select!
    lookup title
    return true

  prevId = prevVal = window.PRERENDER_ID
  window.press-lang = (lang='', id='') ->
    id -= /#/g
    return if STANDALONE
    return if lang is LANG and !id
    prevId := null
    prevVal := null
    if HASH-OF.c
      LANG := lang || switch LANG | \a => \t | \t => \h | \h => \c | \c => \a
    else
      LANG := lang || switch LANG | \a => \t | \t => \h | \h => \a
    $ \#query .val ''
    $('.ui-autocomplete li').remove!
    $('iframe').fadeIn \fast
    $('.lang-active').text $(".lang-option.#LANG:first").text!
    setPref \lang LANG
    for {lang, words} in (React.View.result?props.xrefs || []) | lang is LANG
      id ||= words.0
    id ||= LRU[LANG]?replace(/[\\\n][\d\D]*/, '')
    id ||= {a: \萌 t: \發穎 h: \發芽 c: \萌}[LANG]
    id -= /[\\"~`]/g
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
    $('form[id=lookback] input[id=cond]').val "^#{title}$" unless isCordova
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
      if isPrerendered or document.URL is /^https:\/\/(?:www.)?moedict.tw/i
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

    id = it
    React.View.result?replaceProps { id, type: \spin }
    <~ setTimeout _, 1ms
    return fill-json MOE, \萌 if id is \萌 and LANG is \a
    return load-json id

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

  window.bind-html-actions = bind-html-actions = ->
    $result = $ \#result
    $h1 = $result.find('h1, .h1')
    $tooltip = $ '.ui-tooltip'
    $('#strokes').fadeOut(\fast -> $('#strokes').html(''); window.scroll-to 0 0) if $('#strokes').is(\:visible) and not $('body').hasClass('autodraw')
    do
      $tooltip.remove!
      <- setTimeout _, 125ms
      $tooltip.remove!
      <- setTimeout _, 125ms
      $tooltip.remove!

    <- React.render React.createElement(React.View.UserPref), $(\#user-pref).0

    $('.share .btn').each ->
      $(@).attr href: $(@).data(\href).replace(/__TEXT__/, prevId) + encodeURIComponent encodeURIComponent "#{ HASH-OF[LANG].replace(/^#/, '') }#prevId"

    window.scroll-to 0 0
    $h1
    .css \visibility \visible
      .find 'a[word-id]'
      .each !->
        return if isCordova
        $it = $ @
        html = @.cloneNode().outerHTML
        ci = document.createTextNode $it.text!
        $it
          .closest \ru
          .wrap html 
          .end!
        .replace-with ci
      .end!
    .on \mouseover, 'a[word-id]' !->
      $it = $ @
      i = $it.attr \word-id
      $it.parents 'h1, .h1' .find 'a[word-id=' + i + ']' .addClass \hovered
    .on \mouseout, 'a.hovered' !->
      $h1.find \a .removeClass \hovered

    $('#result .part-of-speech a').attr \href, null
    set-pinyin-bindings!
    cache-loading := no

    vclick = if isMobile then 'touchstart click' else \click
    $ '.results .star' .on vclick, ->
      $star = $(@)hide!
      key = "\"#prevId\"\n"
      if $(@).hasClass \icon-star-empty
        STARRED[LANG] = key + STARRED[LANG]
        $(@).attr \title \已加入記錄簿
      else
        STARRED[LANG] -= "#key"
        $(@).attr \title \加入字詞記錄簿
      $(@).toggleClass \icon-star-empty .toggleClass \icon-star
      $('#btn-starred a').fadeOut \fast ->
        $(@).css(\background \#ddd)fadeIn ->
          $(@).css(\background \transparent)
          $star.fadeIn \fast
      setPref "starred-#LANG" STARRED[LANG]

    $ '.results .stroke' .on vclick, ->
      $('#historical-scripts').fadeIn!
      return ($('#strokes').fadeOut \fast -> $('#strokes').html(''); window.scroll-to 0 0) if $('#strokes').is \:visible
      window.scroll-to 0 0
      strokeWords($('h1:first').data(\title) - /[（(].*/) # Strip the english part and draw the strokes

    $ '.results .playAudio' .click ->
      window.playAudio @, $(@).find("meta[itemprop='contentURL']").attr('content')

    if isCordova and not DEBUGGING
      try navigator.splashscreen.hide!
      $('#result .playAudio').on \touchstart -> $(@).click! if $(@).hasClass('icon-play')
      return

    $('#result .trs.pinyin').tooltip tooltipClass: \bpmf

    $('#result a[href]:not(.xref)').tooltip {
      +disabled, tooltipClass: "prefer-pinyin-#{ true /* !!getPref \prefer-pinyin */ }", show: 100ms, hide: 100ms, items: \a,
      open: ->
        id = $(@).attr \href .replace /^(\.\/)?#?['!:~]?/, ''
        if entryHistory.length and entryHistory[*-1] == id
          try $(@).tooltip \close
          return
      content: (cb) ->
        id = $(@).attr \href .replace /^(\.\/)?#?['!:~]?/, ''
        callLater ->
          if htmlCache[LANG][id]
            cb htmlCache[LANG][id]
            return
          load-json id, -> cb it
        return
    }
    $('#result a[href]:not(.xref)').hoverIntent do
        timeout: 250ms
        over: ->
          <~ setTimeout _, 50ms
          $('.ui-tooltip').remove!
          unless $(\#loading).length
            try $(@).tooltip \open
        out: -> try $(@).tooltip \close

  fill-json = (part, id, cb) ->
    part = React.View.decodeLangPart LANG, part
    reactProps = null
    if part is /^\[\s*\[/
      reactProps = { id, type: \radical, terms: part, H: HASH-OF[LANG] }
    else if part is /^\[/
      reactProps = { id, type: \list, terms: part, H: HASH-OF[LANG], LRU: LRU[LANG] }
    else
      xrefs = [ { lang, words } for lang, words of xref-of id | words.length ]
      reactProps = { id, xrefs, LANG, type: \term, H: HASH-OF[LANG] } <<< $.parseJSON part
    return cb React.renderToString React.View.Result(reactProps) if cb
    return React.View.result?replaceProps reactProps, bind-html-actions if React.View.result
    React.View.result = React.render React.View.Result(reactProps), $(\#result).0, bind-html-actions

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
    for let lang of HASH-OF
      GET "#lang/xref.json", (-> XREF[lang] = it; init! if lang is LANG), \text
      p1 <- GET "#lang/index.1.json", _, \text
      p2 <- GET "#lang/index.2.json", _, \text
      INDEX[lang] = p1 + p2
      init-autocomplete! if lang is LANG
  else
    GET "#LANG/xref.json", (-> XREF[LANG] = it; init!), \text
    GET "#LANG/index.json", (-> INDEX[LANG] = it; init-autocomplete!), \text
    for let lang of HASH-OF | lang isnt LANG
      GET "#lang/xref.json", (-> XREF[lang] = it), \text

  unless STANDALONE
    GET "t/variants.json", (-> XREF.tv = {t: it}), \text

  for let lang of HASH-OF | lang isnt \h
    return if STANDALONE and lang isnt STANDALONE
    GET "#lang/=.json", (->
      $ul = render-taxonomy lang, $.parseJSON it
      if STANDALONE
        return $(".taxonomy.#lang").parent!replaceWith $ul.children!
      $(".taxonomy.#lang").after $ul
    ), \text

function render-taxonomy (lang, taxonomy)
  $ul = $(\<ul/> class: \dropdown-menu)
  $ul.css bottom: 0 top: \auto if lang is \c and not STANDALONE
  for taxo in (if taxonomy instanceof Array then taxonomy else [taxonomy])
    if typeof taxo is \string
      $ul.append $(\<li/> role: \presentation).append $(
        \<a/> class: "lang-option #lang" href: "#{
          if isCordova or not \onhashchange of window then '#' else './'
        }#{ HASH-OF[lang] }=#taxo"
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
      return pinyin_lookup(term, cb) if term is /^[a-zA-Z1-4 ']+$/
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
      results ||= xref-of(term, (if LANG is \a then \t else \a), LANG)
      if LANG is \h and term is \我
        results.unshift \𠊎
      if LANG is \t => for v in xref-of(term, \tv, \t).reverse!
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

PUA2UNI = {
### TWBLG
  \⿰𧾷百 : \𬦰
  \⿸疒哥 : \𰣻
### Hakka
  \⿰亻恩 : \𫣆
  \⿰虫念 : \𬠖
  \⿺皮卜 : \󿕅
}
trs_lookup = (term,cb) ->
  data <- GET "https://www.moedict.tw/lookup/trs/#{term}"
  data.=replace /[⿰⿸⿺](?:𧾷|.)./g -> PUA2UNI[it]
  cb( unique(data / '|') )

pinyin_lookup = (query,cb) !->
  res = []
  pinyin_type = localStorage?getItem("pinyin_#{LANG}") || \HanYu
  query = query.replace(/((?:a(?:ir|n[gr]|[inor])|b(?:a(?:ir|n(?:gr|[gr])|or|[inor])|e(?:ir|n(?:gr|[gr])|[inr])|i(?:a(?:nr|or|[nor])|er|ng|[enr])|or|ur|[aiou])|c(?:a(?:ir|n[gr]|or|[inor])|e(?:ngr?|[nr])|h(?:a(?:ngr?|or|[inor])|e(?:n(?:gr|[gr])|[nr])|ir|o(?:ngr?|u)|u(?:a(?:ir|n(?:gr|[gr])|[inr])|or|[ainor])|[aeiu])|ir|o(?:ngr?|ur|u)|u(?:a(?:nr|[nr])|er|nr|or|[ino])|[aeiu])|d(?:a(?:ir|n(?:gr|[gr])|or|[inor])|e(?:ngr?|[inr])|i(?:a(?:nr|or|[nor])|er|ngr?|ur|[eru])|o(?:ngr?|ur|u)|u(?:a(?:nr|[nr])|er|ir|nr|or|[inor])|[aeiu])|e(?:ng|[nr])|f(?:a(?:n(?:gr|[gr])|[nr])|e(?:n(?:gr|[gr])|[inr])|ou|ur|[aou])|g(?:a(?:ir|n(?:gr|[gr])|or|[inor])|e(?:n(?:gr|[gr])|[inr])|o(?:ngr?|ur|u)|u(?:a(?:ir|n(?:gr|[gr])|[inr])|er|ir|nr|or|[ainor])|[aeu])|h(?:a(?:ir|n[gr]|or|[inor])|e(?:ir|ngr?|[inr])|o(?:ng|ur|u)|u(?:a(?:ir|n(?:gr|[gr])|[inr])|er|ir|nr|or|[ainor])|[aeu])|j(?:i(?:a(?:n[gr]|or|[nor])|er|n(?:gr|[gr])|ong|ur|[aenru])|u(?:a(?:nr|[nr])|er|[enr])|[iu])|k(?:a(?:ir|n[gr]|[inor])|e(?:ngr?|[nr])|o(?:ngr?|ur|u)|u(?:a(?:ir|n[gr]|[inr])|er|nr|[ainor])|[aeu])|l(?:a(?:n(?:gr|[gr])|or|[inor])|e(?:ngr?|[ir])|i(?:a(?:n(?:gr|[gr])|or|[nor])|er|ngr?|ur|[aenru])|o(?:ngr?|ur|u)|u(?:a(?:nr|[nr])|er|nr|or|[enor])|[aeiou])|m(?:a(?:n[gr]|or|[inor])|e(?:ir|n(?:gr|[gr])|[inr])|i(?:a(?:nr|or|[nor])|er|ngr?|[enru])|o[ru]|ur|[aeiou])|n(?:a(?:ngr?|or|[inor])|e(?:ng|[in])|i(?:a(?:n(?:gr|[gr])|or|[nor])|ng|ur|[enu])|o(?:ngr?|u)|u(?:a(?:nr|[nr])|er|[enor])|[aeiu])|ou|p(?:a(?:ir|n(?:gr|[gr])|or|[inor])|e(?:ir|n(?:gr|[gr])|[inr])|i(?:a(?:nr|or|[nor])|er|ng|[aenr])|o[ru]|ur|[aiou])|q(?:i(?:a(?:n(?:gr|[gr])|or|[nor])|er|n(?:gr|[gr])|ongr?|ur|[aenru])|u(?:a(?:nr|[nr])|er|[enr])|[iu])|r(?:a(?:ngr?|[no])|e(?:n[gr]|[nr])|ir|o(?:ng|ur|u)|u(?:a(?:nr|[nr])|[ino])|[eiu])|s(?:a(?:n(?:gr|[gr])|[inor])|e(?:ngr?|[inr])|h(?:a(?:ir|n(?:gr|[gr])|or|[inor])|e(?:n(?:gr|[gr])|[inr])|ir|our?|u(?:a(?:ngr?|[in])|er|ir|nr|or|[ainor])|[aeiu])|ir|o(?:ng|u)|u(?:an|er|ir|[ino])|[aeiu])|t(?:a(?:ir|n(?:gr|[gr])|or|[inor])|e(?:ngr?|r)|i(?:a(?:nr|or|[nor])|er|ngr?|[er])|o(?:ngr?|ur|u)|u(?:a(?:nr|[nr])|er|ir|[inor])|[aeiu])|w(?:a(?:n(?:gr|[gr])|[inr])|e(?:ir|n[gr]|[inr])|or|ur|[aou])|x(?:i(?:a(?:n(?:gr|[gr])|or|[nor])|er|n(?:gr|[gr])|ong|ur|[aenru])|u(?:a(?:nr|[nr])|er|nr|[enr])|[iu])|y(?:a(?:n(?:gr|[gr])|or|[inor])|er|i(?:n(?:gr|[gr])|[nr])|o(?:ng|ur|u)|u(?:a(?:nr|[nr])|er|[enr])|[aeiou])|z(?:a(?:ng|or|[inor])|e(?:ngr?|[inr])|h(?:a(?:n(?:gr|[gr])|or|[inor])|e(?:n(?:gr|[gr])|[inr])|ir|o(?:ngr?|ur|u)|u(?:a(?:n(?:gr|[gr])|[inr])|er|ir|nr|or|[ainor])|[aeiu])|ir|o(?:ngr?|u)|u(?:a(?:nr|[nr])|er|ir|or|[inor])|[aeiu])|[aeoq]))/g, '$1 ') if LANG in <[ a c ]> and pinyin_type is \HanYu
  terms = query.replace(/^\s+/,"").replace(/\s+$/,"").split(/[\s']+/)
  for term in terms
    data <- GET "lookup/pinyin/#{LANG}/#{pinyin_type}/#{term}.json"
    res.push( $.parseJSON(data) )
    if res.length == terms.length
      seen = {}
      for titles in res
        for t in titles
          if !seen[t]?
            seen[t] = 0
          seen[t]++
      x=[]
      for t of seen
        if (seen[t] == terms.length)
          x.push(t)
      if x.length == 0
        cb(["無符合之詞"])
      else
        cb(x)

const SIMP-TRAD = require('./js/simp-trad.js')

function b2g (str='')
  return str.replace(/台([北中南東灣語])/g '臺$1') unless LANG in <[ a c ]> and str isnt /^@/
  return str if " 叁 勅 疎 効 嘷 凥 凟 擧 彛 煅 厮 勠 叶 湼 袴 飱 顋 呪 蟮 眦 幷 滙 庄 鼗 厠 彠 覩 歺 唣 廵 榘 幞 郄 峯 恒 迹 麽 羣 讁 攵 緜 浜 彡 夊 夂 厶 广 廴 丶 台 ".index-of(str) >= 0
  rv = ''
  for char in (str / '')
    idx = SIMP-TRAD.index-of(char)
    rv += if idx % 2 then char else SIMP-TRAD[idx + 1]
  return rv.replace(/台([北中南東灣語])/g '臺$1')

function can-play-mp3
  return CACHED.can-play-mp3 if CACHED.can-play-mp3?
  a = document.createElement \audio
  CACHED.can-play-mp3 = !!(a.canPlayType?('audio/mpeg;') - /^no$/)

window.can-play-ogg = function can-play-ogg
  return CACHED.can-play-ogg if CACHED.can-play-ogg?
  a = document.createElement \audio
  CACHED.can-play-ogg = !!(a.canPlayType?('audio/ogg; codecs="vorbis"') - /^no$/)

function can-play-opus
  return CACHED.can-play-opus if CACHED.can-play-opus?
  a = document.createElement \audio
  CACHED.can-play-opus = !!(a.canPlayType?('audio/ogg; codecs="opus"') - /^no$/)

http-map =
  a: \203146b5091e8f0aafda-15d41c68795720c6e932125f5ace0c70.ssl.cf1.rackcdn.com
  h: \a7ff62cf9d5b13408e72-351edcddf20c69da65316dd74d25951e.ssl.cf1.rackcdn.com
  t: \1763c5ee9859e0316ed6-db85b55a6a3fbe33f09b9245992383bd.ssl.cf1.rackcdn.com
  'stroke-json': \829091573dd46381a321-9e8a43b8d3436eaf4353af683c892840.ssl.cf1.rackcdn.com
  stroke: \/626a26a628fa127d6a25-47cac8eba79cfb787dbcc3e49a1a65f1.ssl.cf1.rackcdn.com

function http
  return "http://#it" unless location.protocol is \https:
  return "https://#{ it.replace(/^([^.]+)\.[^\/]+/, (xs,x) -> http-map[x] or xs ) }"

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
      for let outline in doc.getElementsByTagName 'Outline'
        <- setTimeout _, timeout += delay
        drawOutline(paper,outline,pathAttrs)
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
      <~ setTimeout _, 1ms
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
