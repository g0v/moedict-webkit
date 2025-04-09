#!/usr/bin/env lsc
require! <[ livescript fs ]>
require("babel/register")({ stage: 0 })
LTM-regexes = {}

index-body = fs.read-file-sync \index.html
index-body -= /^[\s\S]*<\/head>/
index-body -= /<\/html>/
index-body -= /<noscript>[\s\S]*<\/noscript>/g
index-body -= /<script\b[^>]*data-cfasync="true"[^>]*><\/script>/g
index-body.=replace /\s*<center\b[\s\S]*<\/center>\s*/, '<!-- RESULT -->'

React = require \react
{Result, decodeLangPart} = require \./view.ls

XREF = {}

for let lang in <[ a t h c ]>
  json = fs.read-file-sync "#lang/xref.json"
  XREF[lang] = JSON.parse json
  json = fs.read-file-sync "#lang/lenToRegex.json"
  try
    {lenToRegex} = JSON.parse json
    lens = []
    for len of lenToRegex
      lens.push len
      lenToRegex[len] = new RegExp lenToRegex[len], \g
    lens.sort (a, b) -> b - a
    LTM-regexes[lang] = [ lenToRegex[len] for len in lens ]

function xref-of (id, src-lang)
  rv = {}
  for tgt-lang, words of XREF[src-lang] | words[id]?
    rv[tgt-lang] = [ x || id for x in words[id] / /,+/ ]
  return rv

trim = -> (it ? '').replace /[`~]/g ''
def-of = (lang, title, cb) ->
  err, json <~ fs.readFile("#lang/#title.json")
  payload = try JSON.parse json unless err
  def = ''
  for {d} in payload?h || [] => for {f, l} in d => def += (f || l)
  cb(trim def)

const HASH-OF = {a: \#, t: \#', h: \#:, c: \#~}

const wt2font = {
  wt071: \HanWangShinSuMedium
  wt024: \HanWangFangSongMedium
  wt021: \HanWangLiSuMedium
  wt001: \HanWangMingLight
  wt002: \HanWangMingMedium
  wt003: \HanWangMingBold
  wt005: \HanWangMingBlack
  wt004: \HanWangMingHeavy
  wt006: \HanWangYenLight
  wt009: \HanWangYenHeavy
  wt011: \HanWangHeiLight
  wt014: \HanWangHeiHeavy
  wt064: \HanWangYanKai
  wt028: \HanWangKanDaYan
  wt034: \HanWangKanTan
  wt040: \HanWangZonYi
  wtcc02: \HanWangCC02
  wtcc15: \HanWangCC15
  wthc06: \HanWangGB06
}
const font2name = { HanWangMingMedium: \中明體 HanWangYenHeavy: \特圓體 HanWangYenLight: \細圓體 HanWangShinSuMedium: \中行書 HanWangGB06: \鋼筆行楷 HanWangHeiHeavy: \特黑體 HanWangMingLight: \細明體 HanWangHeiLight: \細黑體 HanWangFangSongMedium: \中仿宋 HanWangMingBold: \粗明體 HanWangMingBlack: \超明體 HanWangYanKai: \顏楷體 HanWangMingHeavy: \特明體 HanWangCC02: \酷儷海報 HanWangLiSuMedium: \中隸書 HanWangKanDaYan: \空疊圓 HanWangKanTan: \勘亭流 HanWangCC15: \酷正海報 HanWangZonYi: \綜藝體 ShuoWen: \說文標篆}

font-of = ->
  return 'TW-Sung' if it is /sung/i
  return 'EBAS' if it is /ebas/i
  return 'ShuoWen' if it is /shuowen/i
  return 'cwTeXQMing' if it is /cwming/i
  return 'cwTeXQHei' if it is /cwhei/i
  return 'cwTeXQYuan' if it is /cwyuan/i
  return 'cwTeXQKai' if it is /cwkai/i
  return 'cwTeXQFangsong' if it is /cwfangsong/i
  return 'SourceHanSansTCExtraLight' if it is /srcx/i
  return 'SourceHanSansTCLight' if it is /srcl/i
  return 'SourceHanSansTCNormal' if it is /srcn/i
  return 'SourceHanSansTCRegular' if it is /srcr/i
  return 'SourceHanSansTCMedium' if it is /srcm/i
  return 'SourceHanSansTCBold' if it is /srcb/i
  return 'SourceHanSansTCHeavy' if it is /srch/i
  return 'SourceHanSerifTCExtraLight' if it is /shsx/i
  return 'SourceHanSerifTCLight' if it is /shsl/i
  return 'SourceHanSerifTCMedium' if it is /shsm/i
  return 'SourceHanSerifTCRegular' if it is /shsr/i
  return 'SourceHanSerifTCSemiBold' if it is /shss/i
  return 'SourceHanSerifTCBold' if it is /shsb/i
  return 'SourceHanSerifTCHeavy' if it is /shsh/i
  return 'GenWanMin TW EL' if it is /gwmel/i
  return 'GenWanMin TW L' if it is /gwml/i
  return 'GenWanMin TW R' if it is /gwmr/i
  return 'GenWanMin TW M' if it is /gwmm/i
  return 'GenWanMin TW SB' if it is /gwmsb/i
  return 'Typography' if it is /rxkt/i
  return 'jf-openhuninn-1.1' if it is /openhuninn/i
  return wt2font[it] || 'TW-Kai'

iconv = require \iconv-lite
fix-mojibake = ->
  return it unless /^[\u0080-\u00FF]/.test it
  return iconv.decode iconv.encode(it, \latin1), \utf8

<- fs.mkdir \png
require(\zappajs) {+disable_io} ->
  @get '/:text.png': ->
    @params.text = fix-mojibake @params.text
    @response.type \image/png
    font = font-of @query.font
    text2png(@params.text.replace(/^['!~:]/, ''), font).pipe @response
  @get '/': -> @response.type \text/html; @response.sendfile \index.html
  @get '/index.html': -> @response.type \text/html; @response.sendfile \index.html
  @get '/styles.css': -> @response.type \text/css; @response.sendfile \styles.css
  @get '/cordova.js': -> @response.type \application/json; @response.send ''
  @get '/css/:path/:file.css': -> @response.type \text/css; @response.sendfile "css/#{@params.path}/#{@params.file}.css"
  @get '/styles.css': -> @response.type \text/css; @response.sendfile \styles.css
  @get '/favicon.ico': -> @response.type \image/vnd.microsoft.icon; @response.sendfile \favicon.ico
  @get '/manifest.appcache': -> @response.type \text/cache-manifest; @response.sendfile \manifest.appcache
  @get '/images/:file.png': -> @response.type \image/png; @response.sendfile "images/#{@params.file}.png"
  @get '/images/:file.jpg': -> @response.type \image/jpeg; @response.sendfile "images/#{@params.file}.jpg"
  @get '/:path/:file.json': -> @response.type \application/json; @response.sendfile "#{@params.path}/#{@params.file}.json"
  @get '/js/:path/:file.js': -> @response.type \application/javascript; @response.sendfile "js/#{@params.path}/#{@params.file}.js"
  @get '/js/:file.js': -> @response.type \application/javascript; @response.sendfile "js/#{@params.file}.js"
  @get '/:file.js': -> @response.type \application/javascript; @response.sendfile "#{@params.file}.js"
  @get '/fonts/:file.ttf': -> @response.type \application/x-font-ttf; @response.sendfile "fonts/#{@params.file}.ttf"
  @get '/fonts/:file.woff': -> @response.type \application/x-font-woff; @response.sendfile "fonts/#{@params.file}.woff"
  @get '/:text/:idx': ->
    @params.text = fix-mojibake @params.text
    @response.type \text/html
    text = val = (@params.text - /.html$/)
    lang = \a
    if "#val" is /^['!]/ => lang = \t; val.=substr 1
    if "#val" is /^:/ => lang = \h; val.=substr 1
    if "#val" is /^~/ => lang = \c; val.=substr 1
    err, json <~ fs.readFile("#lang/#val.json")
    payload = if err then {} else try JSON.parse(json)
    payload = { layout: 'layout', text, +isBot, +isCLI, png-suffix: '.png', wt2font, font2name, -isWord, idx:@params.idx } <<< payload
    @render index: payload
  @get '/:text.json': ->
    @params.text = fix-mojibake @params.text
    @response.type \application/json
    val = @params.text
    lang = \a
    if "#val" is /^['!]/ => lang = \t; val.=substr 1
    if "#val" is /^:/ => lang = \h; val.=substr 1
    if "#val" is /^~/ => lang = \c; val.=substr 1
    err, json <~ fs.readFile("#lang/#val.json")
    if err
      chunk = val - /[`~]/g
      for re in LTM-regexes[lang] ? []
        chunk.=replace(re, -> escape "`#it~")
      terms = [ part for part in unescape(chunk).split(/[`~]+/) | part.length ]
      return @response.json(404, { terms }) if err
    props = JSON.parse(decodeLangPart lang, (json || '{}').toString!)
    props.xrefs = [ { lang: l, words } for l, words of xref-of val, lang | words.length ]
    @response.json(props)
  @get '/:text': ->
    return @response.redirect "##{ @params.text }" if @params.text is /^[~:!]?=\*/
    @response.type \text/html
    text = val = (@params.text - /.html$/)
    font = font-of @query.font
    png-suffix = '.png'
    png-suffix += "?font=#{ @query.font }" if @query.font
    lang = \a
    if "#val" is /^['!]/ => lang = \t; val.=substr 1
    if "#val" is /^:/ => lang = \h; val.=substr 1
    if "#val" is /^~/ => lang = \c; val.=substr 1
    err, json <~ fs.readFile("#lang/#val.json")
    isWord = not err
    err = true if @query.font
    err = false if val is '=*'
    isBot = @query.bot or @request.headers['user-agent'] is /\b(?:Google|Twitterbot)\b/
    payload = if err then {} else try JSON.parse(json)
    payload = null if payload instanceof Array
    payload ?= { t: val }
    payload = { layout: 'layout', text, isBot, -isCLI, png-suffix, wt2font, font2name, isWord } <<< payload
    chars = text.replace(/^['!~:]/, '')
    chars.=slice(0, 50)
    png-file = "png/#chars.#font.png"
    if fs.existsSync png-file
      png = fs.createReadStream \/dev/null
      png-stream = fs.createWriteStream \/dev/null
    else
      png = text2png(chars, font)
      png-stream = fs.createWriteStream png-file
    <~ png.pipe(png-stream).on \close
    if err
      chunk = val - /[`~]/g
      for re in LTM-regexes[lang] ? []
        chunk.=replace(re, -> escape "`#it~")
      parts = [ part for part in unescape(chunk).split(/[`~]+/) | part.length ]
      segments = []
      do iter = ~> if parts.length then
        part = parts.pop!
        def <- def-of lang, part
        href = "https://www.moedict.tw/#{ HASH-OF[lang] }#part" if def
        if part is /^[9９][7７][2２]$/
          href = "http://ly.g0v.tw/bills/1150L15359"
          def = \擬具「民法親屬編、繼承編部分條文修正草案」，請審議案。
        else if part is /^[1１][3３][3３]$/
          href = "http://law.moj.gov.tw/LawClass/LawSingle.aspx?Pcode=A0000001&FLNO=133"
          def = \被選舉人得由原選舉區依法罷免之。
        segments.unshift {def, part, href}
        iter!
      else @render index: payload <<< { segments }
    else
      xrefs = [ { lang: l, words } for l, words of xref-of val, lang | words.length ]
      @render index: payload <<< { index-body, React, Result, decodeLangPart, json, xrefs }

  @view index: ->
    expand-def = (def) ->
      def.replace(
        /^\s*<(\d)>\s*([介代副助動名歎嘆形連]?)/, (_, num, char) -> "#{
          String.fromCharCode(0x327F + parseInt num)
        }#{ if char then "#char\u20DE" else '' }"
      ).replace(
        /<(\d)>/g (_, num) -> String.fromCharCode(0x327F + parseInt num)
      ).replace(
        /\{(\d)\}/g (_, num) -> String.fromCharCode(0x2775 + parseInt num)
      ).replace(
        /[（(](\d)[)）]/g (_, num) -> String.fromCharCode(0x2789 + parseInt num)
      ).replace(/\(/g, '（').replace(/\)/g, '）')
    trim = -> (it ? '').replace /[`~]/g ''
    def = ''
    for {d} in (@h || {d:[{f: @t}]})
      for {f, l} in d => def += (f || l)
    def = expand-def(trim def || [def for {def} in @segments || []].join('') || (@text+'。'))
    doctype 5
    png-suffix = @png-suffix
    suffix = png-suffix.slice(4)
    suffix = '' if suffix is '?font=kai' and not @isWord
    png-suffix.=replace /\?font=kai$/ ''
    og-image = "https://www.moedict.tw/#{ encodeURIComponent @text.replace(/^['!~:]/, '') }#png-suffix"

    TITLE-OF = {a: '', t: \台語, h: \客語, c: \兩岸}
    SYM-OF = {'!': \t, ':': \h, '~': \c, "'": \t}
    LANG = 'a'
    LANG = SYM-OF[@text.slice(0, 1)] if @text is /^['!~:]/

    attrs = { prefix: "og: http://ogp.me/ns#", lang: 'zh-Hant', 'xml:lang': 'zh-Hant' }
    attrs.manifest = \manifest.appcache unless @segments or @idx
    html attrs, -> head ->
      meta charset:\utf-8
      meta name:\robots content:\noindex
      meta name:"twitter:card" content:"summary"
      meta name:"twitter:site" content:"@moedict"
      meta name:"twitter:creator" content:"@audreyt"
      meta property:"og:url" content:"https://www.moedict.tw/#{ encodeURIComponent @text }#suffix"
      meta property:"og:image" content:og-image
      meta property:"og:image:type" content:"image/png"
      meta name:'viewport' content:'user-scalable=no, initial-scale=1, maximum-scale=1, minimum-scale=1'
      len = @text.length <? 50
      w = len
      w = Math.ceil(len / Math.sqrt(len * 0.5)) if w > 4
      meta property:"og:image:width" content:"#{ w * 375 }"
      meta property:"og:image:height" content:"#{ w * 375 }"
      t = trim @t
      # if t and not @isBot and not (@isCLI and not @segments) and not suffix
      #   meta 'http-equiv':"refresh" content:"0;url=https://www.moedict.tw/##{ @text }"
      t += " (#{ @english })" if @english
      t ||= @text
      t = t.slice(1) if t is /^['!~:]/
      Title = "#t - #{ TITLE-OF[LANG] }萌典"
      esc = -> it.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/'/g, "&apos;").replace(/"/g, "&quot;")
      title esc Title
      meta name:"og:title" content:esc Title
      meta name:"twitter:title" content:esc Title
      meta property:"og:description" content:esc def
      meta name:"description" content:esc def
      link href:'/styles.css' rel:'stylesheet'
      link href:'/css/cupertino/jquery-ui-1.10.4.custom.css' rel:'stylesheet'
      base target:\_blank if @segments
      word = @text.replace(/^['!~:]/ '').replace(/["\n]/g '')
      if not @segments
        h = ''
        h = @text.slice(0, 1) if @text is /^['!~:]/
        h = \' if h is \!
        id = trim @t

        if @idx => return body {+itemscope, itemtype:\http://schema.org/ScholarlyArticle}, ->
          idx = 0
          (if @isCLI then (-> div class:'result', it) else (-> div id:'result' class:'hide', it)) <| ~>
            meta itemprop:"image" content:esc og-image
            h1 {itemprop:\name}, "<a href='/#h#{ esc word }'>#{ esc word }</a>"
            div {itemprop:\articleBody}, -> for {d, t, b, T, p:P} in (@h || {d:[{f: @t}]})
              p trim(b || t || T || "#P".replace(/\u20DE/g ' '))
              ol -> for {f='', l='', s='', e='', l='', q=[], a=''} in d => li ->
                s = if s then "<br>似:[#s]" else ''
                a = if a then "<br>反:[#a]" else ''
                dl ->
                  dt -> h3 class:"#{ if ++idx is +@idx then 'alert alert-success' else '' }", "#{ expand-def f }#l".replace /`([^~]+)~/g (, word) -> "<a href='/#h#word'>#word</a>"
                  dd -> "#{ q.join('<br>') }#s#a".replace /`([^~]+)~/g (, word) -> "<a href='/#h#word'>#word</a>"
          script "if (/MSIE\\s+[678]/.exec(navigator.userAgent)) { document.getElementById('result').setAttribute('class', 'result') } else { location.hash = \"##h#word\" }" unless @isCLI

        fill-props = ~>
          props.id = id
          props.xrefs = @xrefs
          props.LANG = LANG
          props.H = h
          props.type = \term
        props = {}
        str = (@json || '').toString!
        if str is /^\[\s*\[/
          props = { id, type: \radical, terms: str, H: h }
        else if str is /^\[/
          props = { id, type: \list, terms: str, H: h }
        else
          props = JSON.parse(@decodeLangPart h, str)
          fill-props!
        text "<script>window.PRERENDER_LANG = '#LANG'; window.PRERENDER_ID = '#id';</script>"
        html = @index-body
        html.=replace('<!-- RESULT -->', @React.renderToString @Result props)
        #html.=replace('<!-- DROPDOWN -->', @React.renderToString @DropDown!)
        text html.replace(/&nbsp;/g '\u00A0')
        props.H = h
        text """<!--[if gt IE 8]><!--><script>$(function(){
          window.PRERENDER_JSON = #{ JSON.stringify props,,2 };
          React.View.result = React.render(React.View.Result(
            window.PRERENDER_JSON
          ), $('\#result')[0], window.bindHtmlActions);
        })</script><!--<![endif]-->"""
        return
      body {+itemscope, itemtype:\http://schema.org/ItemList}, -> center ->
        meta itemprop:"name" content:esc word
        meta itemprop:"image" content:og-image
        meta itemprop:"itemListOrder" content:\Unordered
        attrs = class:'moedict' src:"#word#png-suffix" width:240 height:240 alt:word, title:word
        if word.length > 1
          attrs <<< style:'margin-top: -50px; margin-bottom: -50px;' width:320 height:320
        img attrs
        uri = encodeURIComponent encodeURIComponent @text
        uri += suffix
        div class:'share' style:'margin: 15px', ->
          a class:'share-f btn btn-default' title:'Facebook 分享' style:'margin-right: 10px; background: #3B579D; color: white' 'href':"https://www.facebook.com/sharer/sharer.php?u=https%3A%2F%2Fwww.moedict.tw%2F#uri", ->
            i class:\icon-share; span ' '; i class:\icon-facebook, ' 臉書'
          a class:'share-t btn btn-default' title:'Twitter 分享' style:'background: #00ACED; color: white' 'href':"https://twitter.com/share?url=https%3A%2F%2Fwww.moedict.tw%2F#uri&text=#{ encodeURIComponent @text.replace(/^['!~:]/, '') }", ->
            i class:\icon-share; span ' '; i class:\icon-twitter, ' 推特'
        table class:'moetext' style:'''
          max-width: 90%;
          background: #eee;
          border: 24px #f9f9f9 solid !important;
          box-shadow: #d4d4d4 0 3px 3px;
        ''', -> for {href, part, def} in @segments || [] => tr ->
          td ->
            meta itemprop:"itemListElement" content:esc part
            a {href} -> img style:'''
              vertical-align: top;
              background: white;
              border-radius: 10px;
              boder: 1px solid #999;
              box-shadow: #d4d4d4 0 3px 3px;
              margin: 10px;
            ''' class: 'btn btn-default' src: esc("#part#png-suffix"), width:160 height:160 alt:esc(part), title:esc(part)
          td -> a {style: 'color: #006', href}, expand-def def
        form id:'frm' style:'''
          top: 0;
          right: 0;
          background: rgba(200, 200, 200, 0.5);
          border-radius: 5px;
          padding: 5px 15px;
          position: absolute;
        ''', ->
          select id:'lang' name:'lang' onchange:"document.getElementById('submit').click()", ->
            option value:'', \臺灣華語
            option selected:(@text is /^['!]/), value:\', \臺灣台語
            option selected:(@text is /^:/), value:\:, \臺灣客語
          select id:'font' name:'font' onchange:"document.getElementById('submit').click()", ->
            optgroup label:'全字庫', ->
              option value:'?font=kai', \楷書
              option selected:(png-suffix is '.png?font=sung'), value:\?font=sung, \宋體
              option selected:(png-suffix is '.png?font=ebas'), value:\?font=ebas, \篆文
            optgroup label:'源雲明體', ->
              option selected:(png-suffix is '.png?font=gwmel'), value:\?font=gwmel, \特細
              option selected:(png-suffix is '.png?font=gwml'), value:\?font=gwml, \細體
              option selected:(png-suffix is '.png?font=gwmr'), value:\?font=gwmr, \標準
              option selected:(png-suffix is '.png?font=gwmm'), value:\?font=gwmm, \正明
              option selected:(png-suffix is '.png?font=gwmsb'), value:\?font=gwmsb, \中明
            optgroup label:'Justfont', ->
              option selected:(png-suffix is '.png?font=openhuninn'), value:\?font=openhuninn, 'Open 粉圓'
            optgroup label:'逢甲大學', ->
              option selected:(png-suffix is '.png?font=shuowen'), value:\?font=shuowen, \說文標篆
            optgroup label:'cwTeX Q', style:'font-family: Helvetica, sans-serif', ->
              option selected:(png-suffix is '.png?font=cwming'), value:\?font=cwming, \明體
              option selected:(png-suffix is '.png?font=cwhei'), value:\?font=cwhei, \黑體
              option selected:(png-suffix is '.png?font=cwyuan'), value:\?font=cwyuan, \圓體
              option selected:(png-suffix is '.png?font=cwkai'), value:\?font=cwkai, \楷書
              option selected:(png-suffix is '.png?font=cwfangsong'), value:\?font=cwfangsong, \仿宋
            optgroup label:'思源宋體', ->
              option selected:(png-suffix is '.png?font=shsx'), value:\?font=shsx, \特細
              option selected:(png-suffix is '.png?font=shsl'), value:\?font=shsl, \細體
              option selected:(png-suffix is '.png?font=shsr'), value:\?font=shsr, \標準
              option selected:(png-suffix is '.png?font=shsm'), value:\?font=shsm, \正宋
              option selected:(png-suffix is '.png?font=shss'), value:\?font=shss, \中宋
              option selected:(png-suffix is '.png?font=shsb'), value:\?font=shsb, \粗體
              option selected:(png-suffix is '.png?font=shsh'), value:\?font=shsh, \特粗
            optgroup label:'思源黑體', ->
              option selected:(png-suffix is '.png?font=srcx'), value:\?font=srcx, \特細
              option selected:(png-suffix is '.png?font=srcl'), value:\?font=srcl, \細體
              option selected:(png-suffix is '.png?font=srcn'), value:\?font=srcn, \標準
              option selected:(png-suffix is '.png?font=srcr'), value:\?font=srcr, \正黑
              option selected:(png-suffix is '.png?font=srcm'), value:\?font=srcm, \中黑
              option selected:(png-suffix is '.png?font=srcb'), value:\?font=srcb, \粗體
              option selected:(png-suffix is '.png?font=srch'), value:\?font=srch, \特粗
            optgroup label:'王漢宗', ->
              for wt, font of @wt2font
                option selected:(png-suffix is ".png?font=#wt"), value:"?font=#wt", @font2name[font]
          input id:'in' name:'in' class:'form-control' style:'width: auto; display: inline; width: 150px' autofocus:true size:10 onfocus:'this.select()' value: word
          button id:'submit' type:'submit' class:'btn btn-default' onclick:"var x; if (x = document.getElementById('in').value) {location.href = document.getElementById('lang').value + encodeURIComponent(x.replace(/ /g, '\u3000').replace(/[\u0020-\u007E]/g, function(it){ return String.fromCharCode(it.charCodeAt(0) + 0xFEE0); })) + document.getElementById('font').value }; return false", -> i class:'icon-pencil'

function text2dim (len)
  len <?= 50
  w = len
  w = Math.ceil(len / Math.sqrt(len * 0.5)) if w > 4
  h = Math.ceil(len / w) <? w
  return [w, h]

function text2png (text, font)
  text.=slice(0, 50)
  png-file = "png/#text.#font.png"
  return fs.createReadStream png-file if fs.existsSync png-file

  [w, h] = text2dim (text - /[\uDC00-\uDFFF]/g).length
  padding = (w - h) / 2

  Canvas = require \canvas
  canvas = new Canvas (w * 375) , (w * 375)

  margin = (w * 15) / 2
  ctx = canvas.getContext \2d
  row = 1
  while text.length
    idx = 0
    while idx < w and text.length
      ch = text.slice 0, 1
      text.=slice 1
      ctx.font = "355px #font"
      ctx.font = '355px "Source Han Serif TC"' if font is /SourceHanSerifTCRegular/
      ctx.font = 'bold 355px "Source Han Serif TC"' if font is /SourceHanSerifTCBold/
      ctx.font = "355px TW-Kai" if ch is /[\u3000\uFF01-\uFF5E]/ and font is /EBAS|ShuoWen/
      while text.length and text.0 is /[\uDC00-\uDFFF]/ # lower surrogate
        ctx.font = "355px #font, SourceHanSansTCRegular, SourceHanSansTCRegular, TWBLG, HanaMinA, HanaMinB, Apple Color Emoji"
        ch += text.0
        ch += text.1
        text.=slice 2
      while text.length and text.0 is /[\u0300-\u036F\u1DC0-\u1DFF\u20D0-\u20FF\uFE20-\uFE2F]/ # combining
        ctx.font = "355px Arial Unicode MS, #font"
        ch += text.0
        text.=slice 1
      drawBackground ctx, (margin + idx * 360), (10 + (padding + row - 1) * 375), 355
      offset = if ch is /[\u3000\uFF01-\uFF5E]/ then 0.17 else 0.23
      x = (margin + idx * 360)
      y = (padding + row - offset) * 375
      x += 90 if ch is /[0-9a-zA-Z]/
      if font is /ShuoWen/ and ch isnt /[\u3000\uFF01-\uFF5E]/
        x += 50
        y += 45
      if font is /Typography/ and ch isnt /[\u3000\uFF01-\uFF5E]/
        x += 25
        y += 5
      if font is /jf-openhuninn-1.1/ and ch isnt /[\u3000\uFF01-\uFF5E]/
        y += 20
      if font is /cwTeXQ/ and ch isnt /[\u3000\uFF01-\uFF5E]/
        x += 15
        y += 15
      if font is /SourceHanSerif/ and ch isnt /[\u3000\uFF01-\uFF5E]/
        y += 30
      if font is /SourceHanSans/ and ch isnt /[\u3000\uFF01-\uFF5E]/
        y += 30
      if font is /GenWanMin/ and ch isnt /[\u3000\uFF01-\uFF5E]/
        y += 30
      ctx.fillText ch, x, y
      idx++
    row++
  return canvas.pngStream!

function drawBackground (ctx, x, y, dim)
  ctx.strokeStyle = \#A33
  ctx.fillStyle = \#F9F6F6
  ctx.beginPath!
  ctx.lineWidth = 8
  ctx.moveTo(x, y)
  ctx.lineTo(x, y+ dim)
  ctx.lineTo(x+ dim, y+ dim)
  ctx.lineTo(x+ dim, y)
  ctx.lineTo(x - (ctx.lineWidth / 2), y)
  ctx.stroke!
  ctx.fill!
  ctx.fillStyle = \#000
  ctx.beginPath!
  ctx.lineWidth = 2
  ctx.moveTo(x, y+ dim / 3)
  ctx.lineTo(x+ dim, y+ dim / 3)
  ctx.moveTo(x, y+ dim / 3 * 2)
  ctx.lineTo(x+ dim, y+ dim / 3 * 2)
  ctx.moveTo(x+ dim / 3, y)
  ctx.lineTo(x+ dim / 3, y+ dim)
  ctx.moveTo(x+ dim / 3 * 2, y)
  ctx.lineTo(x+ dim / 3 * 2, y+ dim)
  ctx.stroke!
