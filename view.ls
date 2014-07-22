React = window?React || require \react
{p, i, a, h1, div, main, span, br, h3, table,
tr, td, th, input, hr, meta, ol, li, ruby, small} = React.DOM

{any, map} = require \prelude-ls

withProperties = (tag, def-props={}) ->
  (props = {}, ...args) ->
    tag ({} <<< def-props <<< props), ...args

div-inline = div `withProperties` { style: { display: \inline } }
h1-name    = h1  `withProperties` { itemProp: \name }
nbsp       = '\u00A0'
CurrentId  = null

Result = React.createClass do
  render: -> switch @props.type
    | \term    => Term @props
    | \list    => List @props
    | \radical => RadicalTable @props
    | \spin    => div-inline { id: \loading, style: { marginTop: \19px, marginLeft: \1px } }, h1 {} @props.id
    | \html    => div-inline { dangerouslySetInnerHTML: { __html: @props.html } }
    | _        => div {}

Term = React.createClass do
  render: ->
    { LANG, H=HASH-OF[LANG], title, english, heteronyms, radical, translation, non_radical_stroke_count: nrs-count, stroke_count: s-count, pinyin: py, xrefs } = @props
    CurrentId := @props.id # Used in h()
    a-stroke = a { className: 'iconic-circle stroke icon-pencil', title: \筆順動畫, style: { color: \white } }
    $char = if radical
      div { className: \radical },
        RadicalGlyph { H, char: radical - /<\/?a[^>]*>/g }
        span { className: \count },
          span { className: \sym }, \+
          nrs-count
        span { className: \count }, " = #s-count"
        nbsp, a-stroke
    else div { className: \radical }, a-stroke
    list = for props in heteronyms
      Heteronym { $char, H, LANG, title, py, english } <<< props
    list ++= XRefs { LANG, xrefs } if xrefs?length
    list ++= Translations { translation } if translation
    return div-inline {}, ...list

Translations = React.createClass do
  render: ->
    {translation} = @props
    div { className: \xrefs }, span { className: \translation },
      ...for key, val of { English: \英, francais: \法, Deutsch: \德 } | translation[key]
        div { className: \xref-line },
          span { className: \fw_lang }, val
          span { className: \fw_def },
            untag((translation[key] * ', ') - /, CL:.*/g - /\|(?:<\/?a[^>*]>|[^[,.(])+/g)

const HASH-OF = {a: \#, t: "#'", h: \#:, c: \#~}
const XREF-LABEL-OF = {a: \華, t: \閩, h: \客, c: \陸, ca: \臺}
XRefs = React.createClass do
  render: ->
    { LANG, xrefs } = @props
    div { className: \xrefs }, ...for { lang, words } in xrefs
      H = HASH-OF[lang]
      div { className: \xref-line },
        span { className: 'xref part-of-speech' },
          XREF-LABEL-OF["#LANG#lang"] || XREF-LABEL-OF[lang]
        nbsp
        span { className: 'xref', itemProp: \citation },
          ...intersperse \、, for word in words
            word -= /[`~]/g
            a { className: \xref, href: "#H#word" } word

Heteronym = React.createClass do
  render: ->
    { $char, H, LANG, title, english,
    id, audio_id=id, bopomofo, trs='', py, pinyin=py||trs||'',
    definitions=[], antonyms, synonyms, variants, specific_to, alt
    } = @props
    if audio_id and LANG is \h
      re = /(.)\u20DE(\S+)/g
      pinyin-list = []
      while t = re.exec(pinyin)
        variant = " 四海大平安".indexOf(t.1)
        mp3 = http "h.moedict.tw/#{variant}-#audio_id.ogg"
        mp3.=replace(/ogg$/ \mp3) if mp3 and not can-play-ogg!
        pinyin-list ++= span { className: \audioBlock },
          div { className: 'icon-play playAudio part-of-speech' },
            meta { itemProp: \name, content: mp3 - /^.*\// }
            meta { itemProp: \contentURL, content: mp3 }
            t.1
        __html = t.2.replace(/¹/g \<sup>1</sup>).replace(/²/g \<sup>2</sup>).replace(/³/g \<sup>3</sup>)
                    .replace(/⁴/g \<sup>4</sup>).replace(/⁵/g \<sup>5</sup>)
        pinyin-list ++= span { dangerouslySetInnerHTML: { __html } }

    title = "<div class='stroke' title='筆順動畫'>#title</div>" unless title is /</
    # <!-- STAR -->
    t = untag h title
    { ruby: title-ruby, youyin, b-alt, p-alt, cn-specific, bopomofo, pinyin } = decorate-ruby @props unless LANG is \h
    list = [ if title-ruby
      ruby { className: \rightangle, dangerouslySetInnerHTML: { __html: h title-ruby } }
    else
      span { dangerouslySetInnerHTML: { __html: title } }
    ]
    list ++= small { className: \youyin } youyin if youyin
    mp3 = ''
    if audio_id and (can-play-ogg! or can-play-mp3!)
      if LANG is \t and not (20000 < audio_id < 50000)
        basename = (100000 + Number audio_id) - /^1/
        mp3 = http "t.moedict.tw/#basename.ogg"
      else if LANG is \a
        mp3 = http "a.moedict.tw/#audio_id.ogg" # TODO: opus
      mp3.=replace(/opus$/ \ogg) if mp3 is /opus$/ and not can-play-opus!
      mp3.=replace(/(opus|ogg)$/ \mp3) if mp3 is /(opus|ogg)$/ and not can-play-ogg!
    if mp3 => list ++= i { +itemScope, itemType: \http://schema.org/AudioObject, className: 'icon-play playAudio' },
      meta { itemProp: \name, content: mp3 - /^.*\// }
      meta { itemProp: \contentURL, content: mp3 }
    if b-alt
      list ++= small { className: \alternative },
        span { className: \pinyin } p-alt
        span { className: \bopomofo } b-alt
    list ++= span { lang: \en, className: \english } english if english
    list ++= span { className: \specific_to, dangerouslySetInnerHTML: { __html: h specific_to } } if specific_to

    return div-inline {},
      meta { itemProp: \image, content: encodeURIComponent(t) + ".png" }
      meta { itemProp: \name, content: t }
      $char
      h1 { className: \title, 'data-title': t, style: { visibility: \hidden } }, ...list
      if bopomofo or pinyin-list then div { className: "bopomofo #cn-specific" },
        if alt? then div { lang: \zh-Hans, className: \cn-specific },
          span { className: 'xref part-of-speech' }, \简
          span { className: \xref }, untag alt
        if cn-specific and pinyin and bopomofo then small { className: 'alternative cn-specific' },
          span { className: \pinyin } pinyin
          span { className: \bopomofo } bopomofo
        if pinyin-list then
          span { className: \pinyin } ...pinyin-list
      div { className: \entry, itemProp: \articleBody },
        ...for defs in groupBy(\type definitions.slice!)
          DefinitionList { LANG, H, defs, synonyms, antonyms, variants }

decorate-ruby = ({ LANG, title, bopomofo, py, pinyin=py, trs }) ->
  pinyin ?= trs
  pinyin = (pinyin - /<[^>]*>/g - /（.*）/) unless LANG is \c
  bopomofo ?= trs2bpmf LANG, "#pinyin"
  bopomofo -= /<[^>]*>/g unless LANG is \c
  pinyin .= replace /ɡ/g \g
  pinyin .= replace /ɑ/g \a
  pinyin .= replace /，/g ', '
  youyin = bopomofo.replace /（([語|讀|又]音)）.*/, '$1' if bopomofo is /^（[語|讀|又]音）/
  b-alt = if bopomofo is /[變|\/]/
                then bopomofo.replace /.*[\(變\)\u200B|\/](.*)/, '$1'
                else if bopomofo is /.+（又音）.+/
                then bopomofo.replace /.+（又音）/, ''
                else ''
  b-alt .= replace(/ /g, '\u3000').replace(/([ˇˊˋ])\u3000/g, '$1 ')
  p-alt = if pinyin is /[變|\/]/
            then pinyin.replace /.*[\(變\)\u200B|\/](.*)/, '$1'
            else if bopomofo is /.+（又音）.+/
            then do ->
              _py = pinyin.split ' '
              for i from 0 to _py.length/2-1
                  _py.shift()
              return _py.join ' '
            else ''
  bopomofo .= replace /([^ ])(ㄦ)/g, '$1 $2' .replace /([ ]?[\u3000][ ]?)/g, ' '
  bopomofo .= replace /([ˇˊˋ˪˫])[ ]?/g, '$1 ' .replace /([ㆴㆵㆶㆷ][̍͘]?)/g, '$1 '
  cn-specific = ''
  cn-specific = \cn-specific if bopomofo is /陸/ #and bopomofo isnt /<br>/
  t = title.replace /<a[^>]+>/g '`' .replace /<\/a>/g '~'
  t -= /<[^>]+>/g
  b = bopomofo.replace /\s?[，、；。－—,\.;]\s?/g, ' '
  b .= replace /（[語|讀|又]音）[\u200B]?/, ''
  b .= replace /\(變\)\u200B\/.*/, ''
  b .= replace /\/.*/, ''
  cn-specific-bpmf = b - /.*<br>陸./ if b is /<br>陸/
  b .= replace /<br>(.*)/, ''
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
  p .= replace /\(變\)\u200B.*/, ''
  p .= replace /\/.*/, ''
  p .= replace /<br>.*/, ''
  p .= split ' '
  for yin, idx in p | yin
    span = # 閩南語典，按隔音符計算字數
           if LANG is \t and yin is /\-/g
           then ' rbspan="'+ (yin.match /[\-]+/g .length+1) + '"'
           # 國語兒化音
           else if LANG != \t && yin is /^[^eēéěè].*r$/g
           then
             if cn-specific-bpmf
               cns = cn-specific-bpmf / /\s+/
               tws = b / /\s+/
               tws[*-2] = cns[*-2]
               b-alt = b.replace(/ /g, '\u3000').replace(/\sㄦ$/, 'ㄦ')
               b = tws * ' '
             ' rbspan="2"'
           # 兩岸詞典，按元音群計算字數
           else if LANG != \t and yin is /[aāáǎàeēéěèiīíǐìoōóǒòuūúǔùüǖǘǚǜ]+/g
           then ' rbspan="'+ yin.match /[aāáǎàeēéěèiīíǐìoōóǒòuūúǔùüǖǘǚǜ]+/g .length + '"'
           else ''
    p[idx] = "<rt#span>#yin</rt>"
  ruby += '<rtc class="zhuyin"><rt>' + b.replace(/[ ]+/g, '</rt><rt>') + '</rt></rtc>'
  ruby += '<rtc class="romanization">'
  ruby += p.join ''
  ruby += '</rtc>'
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
  return { ruby, youyin, b-alt, p-alt, cn-specific, pinyin, bopomofo }

DefinitionList = React.createClass do
  render: ->
    { H, LANG, defs } = @props
    list = []
    if defs.0?type
      list ++= intersperse nbsp, for t in defs.0.type.split \,
        span { className: \part-of-speech }, untag t
    list ++= ol {}, ...for d in defs
      Definition { H, LANG, defs } <<< d
    list ++= decorate-nyms @props
    return div { className: \entry-item }, ...list

function decorate-nyms (props)
  list = []
  re = />([^,<]+)</g
  for key, val of { synonyms: \似, antonyms: \反, variants: \異 } | props[key]
    list ++= span { className: key },
      span { className: \part-of-speech }, val
      nbsp
      ...intersperse \、, while t = re.exec(props[key])
        a { href: "#{ props.H }#{ t.1 }" }, t.1
  return list

Definition = React.createClass do
  render: ->
    {LANG, type, def, defs, antonyms, synonyms} = @props
    if def is /∥/
      $after-def = div { style: { margin: "0 0 22px -44px" }, dangerouslySetInnerHTML: { __html: h(def - /^[^∥]+/) } }
      def -= /∥.*/
    is-colon-def = LANG is \c and (def is /[:：]<\/span>$/) and not(any (.def is /^\s*\(\d+\)/), defs)
    def-string = h(expand-def def).replace do
      /([：。」])([\u278A-\u2793\u24eb-\u24f4])/g
      '$1\uFFFC$2'
    list = for it in def-string.split '\uFFFC'
      span { className: \def, dangerouslySetInnerHTML: { __html: h it } }
    for key in <[ example quote link ]> | @props[key]
      list ++= for it in @props[key]
        span { className: key, dangerouslySetInnerHTML: { __html: h it } }
    list ++= decorate-nyms @props
    list ++= $after-def if $after-def
    style = if is-colon-def then { marginLeft: \-28px } else {}
    wrapper = if def is /^\s*\(\d+\)/ or is-colon-def then (-> it) else (-> li {}, it)
    wrapper p { className: \definition, style }, ...list

const CJK-RADICALS = '⼀一⼁丨⼂丶⼃丿⼄乙⼅亅⼆二⼇亠⼈人⼉儿⼊入⼋八⼌冂⼍冖⼎冫⼏几⼐凵⼑刀⼒力⼓勹⼔匕⼕匚⼖匸⼗十⼘卜⼙卩⼚厂⼛厶⼜又⼝口⼞囗⼟土⼠士⼡夂⼢夊⼣夕⼤大⼥女⼦子⼧宀⼨寸⼩小⼪尢⼫尸⼬屮⼭山⼮巛⼯工⼰己⼱巾⼲干⼳幺⼴广⼵廴⼶廾⼷弋⼸弓⼹彐⼺彡⼻彳⼼心⼽戈⼾戶⼿手⽀支⽁攴⽂文⽃斗⽄斤⽅方⽆无⽇日⽈曰⽉月⽊木⽋欠⽌止⽍歹⽎殳⽏毋⽐比⽑毛⽒氏⽓气⽔水⽕火⽖爪⽗父⽘爻⽙爿⺦丬⽚片⽛牙⽜牛⽝犬⽞玄⽟玉⽠瓜⽡瓦⽢甘⽣生⽤用⽥田⽦疋⽧疒⽨癶⽩白⽪皮⽫皿⽬目⽭矛⽮矢⽯石⽰示⽱禸⽲禾⽳穴⽴立⽵竹⽶米⽷糸⺰纟⽸缶⽹网⽺羊⽻羽⽼老⽽而⽾耒⽿耳⾀聿⾁肉⾂臣⾃自⾄至⾅臼⾆舌⾇舛⾈舟⾉艮⾊色⾋艸⾌虍⾍虫⾎血⾏行⾐衣⾑襾⾒見⻅见⾓角⾔言⻈讠⾕谷⾖豆⾗豕⾘豸⾙貝⻉贝⾚赤⾛走⾜足⾝身⾞車⻋车⾟辛⾠辰⾡辵⻌辶⾢邑⾣酉⾤釆⾥里⾦金⻐钅⾧長⻓长⾨門⻔门⾩阜⾪隶⾫隹⾬雨⾭靑⾮非⾯面⾰革⾱韋⻙韦⾲韭⾳音⾴頁⻚页⾵風⻛风⾶飛⻜飞⾷食⻠饣⾸首⾹香⾺馬⻢马⾻骨⾼高⾽髟⾾鬥⾿鬯⿀鬲⿁鬼⿂魚⻥鱼⻦鸟⿃鳥⿄鹵⻧卤⿅鹿⿆麥⻨麦⿇麻⿈黃⻩黄⿉黍⿊黑⿋黹⿌黽⻪黾⿍鼎⿎鼓⿏鼠⿐鼻⿑齊⻬齐⿒齒⻮齿⿓龍⻰龙⿔龜⻳龟⿕龠'

RadicalGlyph = React.createClass do
  render: ->
    {char, H} = @props
    idx = CJK-RADICALS.index-of(char)
    char = CJK-RADICALS[idx+1] unless idx % 2
    #return char unless LANG in <[ a c ]>
    return span { className: \glyph },
      a { title: \部首檢索, className: \xref, href: "#H@#char" style: { color: \white } }, " #char"

RadicalTable = React.createClass do
  render: ->
    {terms, id, H} = @props
    id -= /^[@=]/
    if id is /\S/
      title = h1-name {}, "#id ", a { className: \xref, href: \#, title: \部首表 }, \部
    else
      H += '@'
      title = h1-name {}, \部首表
    rows = $.parseJSON terms
    list = []
    for chars, strokes in rows | chars?length
      chs = []
      for ch in chars
        chs ++= a { className: \stroke-char, href: "#H#ch" }, ch
        chs ++= ' '
      list ++= span { className: \stroke-count }, strokes
      list ++= span { className: \stroke-list }, chs
      list ++= hr { style: { margin: 0, padding: 0, height: 0 } }
    return div-inline {}, title, div { className: \list }, ...list

List = React.createClass do
  render: ->
    {terms, id, H, LRU} = @props
    return div {} unless terms

    id -= /^[@=]/
    terms -= /^[^"]*/
    list = [ h1-name {}, id ]

    if id is \字詞紀錄簿 and not terms
      const btn = i { className: \icon-star-empty }
      list ++= p { className: \bg-info }, "（請按詞條右方的 ", btn, " 按鈕，即可將字詞加到這裡。）"

    function str-to-list (str)
      re = /"([^"]+)"[^"]*/g
      while t = re.exec(str)
        it = t.1
        span { style: { clear: \both display: \block } },
          '\u00B7', a { href: "#H#it" } it

    if terms is /^";/
      re = /";([^;"]+);([^;"]+)"[^"]*/g
      list ++= table {},
        tr {}, ...for it in <[ 臺 陸 ]>
          th { width: 200 }, span { className: \part-of-speech } it
        ...while t = re.exec(terms)
          tr { style: { borderTop: '1px solid #ccc' } },
            ...for it in [ t.1, t.2 ]
              td {}, a { href: "#H#it" } it
    else
      list ++= str-to-list terms

    if id is \字詞紀錄簿 and LRU
      re = /"([^"]+)"[^"]*/g
      list ++= do
        br {}
        h3 { id: \lru }, \最近查閱過的字詞, input {
          id: \btn-clear-lru, type: \button, className: 'btn-default btn btn-tiny'
          value: \清除, style: { marginLeft: \10px }
        }
      list ++= str-to-list LRU
    return div-inline {}, ...list

http-map =
  a: \203146b5091e8f0aafda-15d41c68795720c6e932125f5ace0c70.ssl.cf1.rackcdn.com
  h: \a7ff62cf9d5b13408e72-351edcddf20c69da65316dd74d25951e.ssl.cf1.rackcdn.com
  t: \1763c5ee9859e0316ed6-db85b55a6a3fbe33f09b9245992383bd.ssl.cf1.rackcdn.com
  'stroke-json': \829091573dd46381a321-9e8a43b8d3436eaf4353af683c892840.ssl.cf1.rackcdn.com
  stroke: \/626a26a628fa127d6a25-47cac8eba79cfb787dbcc3e49a1a65f1.ssl.cf1.rackcdn.com

http = -> "https://#{ it.replace(/^([^.]+)\.[^\/]+/, (xs,x) -> http-map[x] or xs ) }"
can-play-mp3 = -> yes
can-play-ogg = -> no
can-play-opus = -> no
function h (it)
  id = CurrentId
  it += '</span></span></span></span>' if it is /\uFFF9/
  res = it.replace(/[\uFF0E\u2022]/g '\u00B7').replace(/\u223C/g '\uFF0D').replace(/\u0358/g '\u030d')
    .replace /(.)\u20DD/g          "<span class='regional part-of-speech'>$1</span> "
    .replace /(.)\u20DE/g          "</span><span class='part-of-speech'>$1</span><span>"
    .replace /(.)\u20DF/g          "<span class='specific'>$1</span>"
    .replace /(.)\u20E3/g          "<span class='variant'>$1</span>"
    .replace //<a[^<]+>#id<\/a>//g "#id"
    .replace //<a>([^<]+)</a>//g   "<a href=\"#{h}$1\">$1</a>"
    .replace //(>[^<]*)#id(?!</(?:h1|rb)>)//g      "$1<b>#id</b>"
    .replace(/\uFFF9/g '<span class="ruby"><span class="rb"><span class="ruby"><span class="rb">')
    .replace(/\uFFFA/g '</span><br><span class="rt trs pinyin">')
    .replace(/\uFFFB$/, '')
    .replace(/\uFFFB/g '</span></span></span></span><br><span class="rt mandarin">')
    .replace(/<span class="rt mandarin">\s*<\//g '</')
    .replace /(<span class="rt trs pinyin")>\s*([^<]+)/g, (_, pre, trs) -> """
      #pre title="#{ trs2bpmf \t trs }">#trs
    """
  return res

untag = (- /<[^>]*>/g)

groupBy = (prop, xs) ->
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
    /[（(](\d)[)）]/g (_, num) -> String.fromCharCode(0x2789 + parseInt num) + ' '
  ).replace(/\(/g, '（').replace(/\)/g, '）')
function intersperse (elm, xs)
  list = []
  for x in xs
    list.push elm if list.length
    list.push x
  return list

const Consonants = { p:\ㄅ b:\ㆠ ph:\ㄆ m:\ㄇ t:\ㄉ th:\ㄊ n:\ㄋ l:\ㄌ k:\ㄍ g:\ㆣ kh:\ㄎ ng:\ㄫ h:\ㄏ tsi:\ㄐ ji:\ㆢ tshi:\ㄑ si:\ㄒ ts:\ㄗ j:\ㆡ tsh:\ㄘ s:\ㄙ }
const Vowels = { a:\ㄚ an: \ㄢ ang: \ㄤ ann:\ㆩ oo:\ㆦ onn:\ㆧ o:\ㄜ e:\ㆤ enn:\ㆥ ai:\ㄞ ainn:\ㆮ au:\ㄠ aunn:\ㆯ am:\ㆰ om:\ㆱ m:\ㆬ ong:\ㆲ ng:\ㆭ i:\ㄧ inn:\ㆪ u:\ㄨ unn:\ㆫ ing:\ㄧㄥ in:\ㄧㄣ un:\ㄨㄣ }
const Tones = { p:\ㆴ t:\ㆵ k:\ㆶ h:\ㆷ p$:"ㆴ\u0358" t$:"ㆵ\u0358" k$:"ㆶ\u0358" h$:"ㆷ\u0358" "\u0300":\˪ "\u0301":\ˋ "\u0302":\ˊ "\u0304":\˫ "\u030d":\$ }
re = -> [k for k of it].sort((x, y) -> y.length - x.length).join \|
const C = re Consonants
const V = re Vowels
function trs2bpmf (LANG, trs)
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

const keyMap = {
  h: \"heteronyms" b: \"bopomofo" p: \"pinyin" d: \"definitions"
  c: \"stroke_count" n: \"non_radical_stroke_count" f: \"def"
  t: \"title" r: \"radical" e: \"example" l: \"link" s: \"synonyms"
  a: \"antonyms" q: \"quote" _: \"id" '=': \"audio_id" E: \"english"
  T: \"trs" A: \"alt" V: \"vernacular", C: \"combined" D: \"dialects"
  S: \"specific_to"
}
decodeLangPart = (LANG-OR-H, part='') ->
  while part is /"`辨~\u20DE&nbsp`似~\u20DE"[^}]*},{"f":"([^（]+)[^"]*"/
    part.=replace /"`辨~\u20DE&nbsp`似~\u20DE"[^}]*},{"f":"([^（]+)[^"]*"/ '"辨\u20DE 似\u20DE $1"'
  part.=replace /"`(.)~\u20DE"[^}]*},{"f":"([^（]+)[^"]*"/g '"$1\u20DE $2"'
  part.=replace /"([hbpdcnftrelsaqETAVCDS_=])":/g (, k) -> keyMap[k] + \:
  H = HASH-OF[LANG-OR-H] || LANG-OR-H
  part.=replace /([「【『（《])`([^~]+)~([。，、；：？！─…．·－」』》〉]+)/g (, pre, word, post) -> "<span class='punct'>#pre<a href=\\\"#H#word\\\">#word</a>#post</span>"
  part.=replace /([「【『（《])`([^~]+)~/g (, pre, word) -> "<span class='punct'>#pre<a href=\\\"#H#word\\\">#word</a></span>"
  part.=replace /`([^~]+)~([。，、；：？！─…．·－」』》〉]+)/g (, word, post) -> "<span class='punct'><a href=\\\"#H#word\\\">#word</a>#post</span>"
  part.=replace /`([^~]+)~/g (, word) -> "<a href=\\\"#H#word\\\">#word</a>"
  part.=replace /([)）])/g "$1\u200B"
  return part

if module?
  module?.exports = { Result, decodeLangPart }
else $ ->
  React{}.View.Result = Result
  React.View.decodeLangPart = decodeLangPart
  unless window.PRERENDER_LANG
    React.View.result = React.renderComponent Result!, $(\#result).0
