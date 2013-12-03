require! fs
LTM-regexes = {}
for let lang in <[ a t h c ]>
  err, json <- fs.read-file "#lang/lenToRegex.json"
  try
    {lenToRegex} = JSON.parse json
    lens = []
    for len of lenToRegex
      lens.push len
      lenToRegex[len] = new RegExp lenToRegex[len], \g
    lens.sort (a, b) -> b - a
    LTM-regexes[lang] = [ lenToRegex[len] for len in lens ]

trim = -> (it ? '').replace /[`~]/g ''
def-of = (lang, title, cb) ->
  err, json <~ fs.readFile("#lang/#title.json")
  payload = try JSON.parse json unless err
  def = ''
  for {d} in payload?h || [] => for {f, l} in d => def += (f || l)
  cb(trim def)

const HASH-OF = {a: \#, t: \#!, h: \#:, c: \#~}

const wt2font = { wt002: \HanWangMingMedium wt009: \HanWangYenHeavy wt006: \HanWangYenLight wt071: \HanWangShinSuMedium wthc06: \HanWangGB06 wt014: \HanWangHeiHeavy wt001: \HanWangMingLight wt011: \HanWangHeiLight wt024: \HanWangFangSongMedium wt003: \HanWangMingBold wt005: \HanWangMingBlack wt064: \HanWangYanKai wt004: \HanWangMingHeavy wtcc02: \HanWangCC02 wt021: \HanWangLiSuMedium wt028: \HanWangKanDaYan wt034: \HanWangKanTan wtcc15: \HanWangCC15 wt040: \HanWangZonYi }
const font2name = { HanWangMingMedium: \中明體 HanWangYenHeavy: \特圓體 HanWangYenLight: \細圓體 HanWangShinSuMedium: \中行書 HanWangGB06: \鋼筆行楷 HanWangHeiHeavy: \特黑體 HanWangMingLight: \細明體 HanWangHeiLight: \細黑體 HanWangFangSongMedium: \中仿宋 HanWangMingBold: \粗明體 HanWangMingBlack: \超明體 HanWangYanKai: \顏楷體 HanWangMingHeavy: \特明體 HanWangCC02: \酷儷海報 HanWangLiSuMedium: \中隸書 HanWangKanDaYan: \空疊圓 HanWangKanTan: \勘亭流 HanWangCC15: \酷正海報 HanWangZonYi: \綜藝體 }

font-of = ->
  return 'TW-Sung' if it is /sung/i
  return 'EBAS' if it is /ebas/i
  return wt2font[it] || 'TW-Kai'

require(\zappajs) ->
  @get '/:text.png': ->
    @response.type \image/png
    font = font-of @query.font
    text2png(@params.text.replace(/^[!~:]/, ''), font).pipe @response
  @get '/styles.css': -> @response.type \text/css; @response.sendfile \styles.css
  @get '/images/:file.png': -> @response.type \image/png; @response.sendfile "images/#{@params.file}.png"
  @get '/:text': ->
    @response.type \text/html
    text = val = (@params.text - /.html$/)
    font = font-of @query.font
    png-suffix = '.png'
    png-suffix += "?font=#{ @query.font }" if @query.font
    lang = \a
    if "#val" is /^!/ => lang = \t; val.=substr 1
    if "#val" is /^:/ => lang = \h; val.=substr 1
    if "#val" is /^~/ => lang = \c; val.=substr 1
    err, json <~ fs.readFile("#lang/#val.json")
    isWord = not err
    err = true if @query.font
    isBot = @query.bot or @request.headers['user-agent'] is /\b(?:Google|Twitterbot)\b/
    isCLI = @query.bot or @request.headers['user-agent'] isnt /\bMozilla\b/
    payload = if err then {} else try JSON.parse(json)
    payload = null if payload instanceof Array
    payload ?= { t: val }
    payload = { layout: 'layout', text, isBot, isCLI, png-suffix, wt2font, font2name, isWord } <<< payload
    if err
      chunk = val - /[`~]/g
      for re in LTM-regexes[lang]
        chunk.=replace(re, -> escape "`#it~")
      parts = [ part for part in unescape(chunk).split(/[`~]+/) | part.length ]
      segments = []
      do iter = ~> if parts.length then
        part = parts.pop!
        def <- def-of lang, part
        href = "https://www.moedict.tw/#{ HASH-OF[lang] }#part" if def
        if part is "９７２"
          href = "http://ly.g0v.tw/bills/1150L15359"
          def = \擬具「民法親屬編、繼承編部分條文修正草案」，請審議案。
        else if part is "１３３"
          href = "http://law.moj.gov.tw/LawClass/LawSingle.aspx?Pcode=A0000001&FLNO=133"
          def = \被選舉人得由原選舉區依法罷免之。
        segments.unshift {def, part, href}
        iter!
      else @render index: payload <<< { segments }
    else
      @render index: payload

  @view index: ->
    trim = -> (it ? '').replace /[`~]/g ''
    def = ''
    for {d} in (@h || {d:[{f: @t}]})
      for {f, l} in d => def += (f || l)
    def = trim def || [def for {def} in @segments || []].join('') || (@text+'。')
    doctype 5
    png-suffix = @png-suffix
    suffix = png-suffix.slice(4)
    suffix = '' if suffix is '?font=kai' and not @isWord
    png-suffix.=replace /\?font=kai$/ ''
    og-image = "https://www.moedict.tw/#{ encodeURIComponent @text.replace(/^[!~:]/, '') }#png-suffix"
    html {prefix:"og: http://ogp.me/ns#"} -> head ->
      meta charset:\utf-8
      meta name:"twitter:card" content:"summary"
      meta name:"twitter:site" content:"@moedict"
      meta name:"twitter:creator" content:"@audreyt"
      meta property:"og:url" content:"https://www.moedict.tw/#{ encodeURIComponent @text }#suffix"
      meta property:"og:image" content:og-image
      meta property:"og:image:type" content:"image/png"
      len = @text.length <? 50
      w = len
      w = Math.ceil(len / Math.sqrt(len * 0.5)) if w > 4
      meta property:"og:image:width" content:"#{ w * 375 }"
      meta property:"og:image:height" content:"#{ w * 375 }"
      t = trim @t
      if t and not @isBot and not (@isCLI and not @segments) and not suffix
        meta 'http-equiv':"refresh" content:"0;url=https://www.moedict.tw/##{ @text }"
      t += " (#{ @english })" if @english
      t ||= @text
      t = t.slice(1) if t is /^[!~:]/
      title "#t - 萌典"
      meta name:"og:title" content:"#t - 萌典"
      meta name:"twitter:title" content:"#t - 萌典"
      meta property:"og:description" content:def
      meta name:"description" content:def
      link href:'styles.css' rel:'stylesheet'
      base target:\_blank
    if @isBot or (@isCLI and not @segments)
      h = ''
      h = @text.slice(0, 1) if @text is /^[!~:]/
      body -> h1 @text.replace(/^[!~:]/ ''); for {d, T, b} in (@h || {d:[{f: @t}]})
        p trim(b || T)
        dl -> for {f='', l='', s='', e='', l='', q=[], a=''} in d => li ->
          S = if s then "<br>似:[#s]" else ''
          A = if a then "<br>反:[#a]" else ''
          dt -> h3 "#f#l".replace /`([^~]+)~/g (, word) -> "<a href='#h#word'>#word</a>"
          dd "#{ q.join('<br>') }#S#A".replace /`([^~]+)~/g (, word) -> "<a href='#h#word'>#word</a>"
      return
    body -> center ->
      return unless @segments
      img src:"#{ @text.replace(/^[!~:]/, '') }#png-suffix" width:320 height:320, style: '''
        margin-top: -50px;
        margin-bottom: -50px;
      '''
      uri = encodeURIComponent encodeURIComponent @text
      uri += suffix
      form class:'hidden-xs' style:'''
        top: 0;
        right: 0;
        background: rgba(200, 200, 200, 0.5);
        border-radius: 5px;
        padding: 5px 15px;
        position: absolute;
      ''', ->
        span '再寫幾個字：'
        select id:'lang' name:'lang', ->
          option value:'', \國語
          option selected:(@text is /^!/), value:\!, \臺語
          option selected:(@text is /^:/), value:\:, \客語
        select id:'font' name:'font', ->
          option value:'?font=kai', \楷書
          option selected:(png-suffix is '.png?font=sung'), value:\?font=sung, \宋體
          option selected:(png-suffix is '.png?font=ebas'), value:\?font=ebas, \篆文
          for wt, font of @wt2font
            option selected:(png-suffix is ".png?font=#wt"), value:"?font=#wt", @font2name[font]
        input id:'in' name: 'in' autofocus:true size:10 value: @text.replace(/^[!~:]/, '')
        input type:'submit' value:'送出' class:'btn btn-default' onclick:"var x; if (x = document.getElementById('in').value) {location.href = document.getElementById('lang').value + encodeURIComponent(x.replace(/ /g, '\u3000').replace(/[\u0020-\u007E]/g, function(it){ return String.fromCharCode(it.charCodeAt(0) + 0xFEE0); })) + document.getElementById('font').value }; return false"
      div class:'share' style:'margin: 15px', ->
        a class:'share-f btn btn-default' title:'Facebook 分享' style:'margin-right: 10px; background: #3B579D; color: white' 'href':"https://www.facebook.com/sharer/sharer.php?u=https%3A%2F%2Fwww.moedict.tw%2F#uri", ->
          i class:\icon-share; span ' '; i class:\icon-facebook, ' 臉書'
        a class:'share-t btn btn-default' title:'Twitter 分享' style:'background: #00ACED; color: white' 'href':"https://twitter.com/share?url=https%3A%2F%2Fwww.moedict.tw%2F#uri&text=#{ encodeURIComponent @text.replace(/^[!~:]/, '') }", ->
          i class:\icon-share; span ' '; i class:\icon-twitter, ' 推特'
        a class:'share-g btn btn-default' title:'Google+ 分享' style:'margin-left: 10px; background: #D95C5C; color: white' 'href':"https://plus.google.com/share?url=https%3A%2F%2Fwww.moedict.tw%2F#uri", ->
          i class:\icon-share; span ' '; i class:\icon-google-plus, ' 分享'
      table style:'''
        max-width: 90%;
        background: #eee;
        border: 24px #f9f9f9 solid !important;
        box-shadow: #d4d4d4 0 3px 3px;
      ''', -> for {href, part, def} in @segments || [] => tr ->
        td ->
          a {href} -> img style:'''
            vertical-align: top;
            background: white;
            border-radius: 10px;
            boder: 1px solid #999;
            box-shadow: #d4d4d4 0 3px 3px;
            margin: 10px;
          ''' class: 'btn btn-default' src: "#part#png-suffix" width:160 height:160 alt:part
        td -> a {style: 'color: #006', href}, def

function text2dim (len)
  len <?= 50
  w = len
  w = Math.ceil(len / Math.sqrt(len * 0.5)) if w > 4
  h = Math.ceil(len / w) <? w
  return [w, h]

function text2png (text, font)
  text.=slice(0, 50)
  [w, h] = text2dim text.length
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
      ctx.font = "355px TW-Kai" if ch is /[\u3000\uFF01-\uFF5E]/ and font is /EBAS/
      while text.length and text.0 is /[\u0300-\u036F\u1DC0-\u1DFF\u20D0-\u20FF\uFE20-\uFE2F]/
        ctx.font = '355px Arial Unicode MS'
        ch += text.0
        text.=slice 1
      drawBackground ctx, (margin + idx * 360), (10 + (padding + row - 1) * 375), 355
      offset = if ch is /[\u3000\uFF01-\uFF5E]/ then 0.17 else 0.23
      ctx.fillText ch, (margin + idx * 360), (padding + row - offset) * 375
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
