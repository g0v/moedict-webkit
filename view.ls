require! <[
  ./scripts/Links.jsx
  ./scripts/Nav.jsx
  ./scripts/UserPref.jsx
]>

React = require('react')
window.isMoedictDesktop = isMoedictDesktop = true if window?moedictDesktop
$body = window?$('body') || { hasClass: -> false }

{p, i, a, b, form, h1, div, main, span, br, h3, h4, button, label, table, nav,
tr, td, th, input, hr, meta, ul, ol, li, ruby, small} = React.DOM

{any, map} = require \prelude-ls

createClass = React.createFactory << React.createClass
withProperties = (tag, def-props={}) ->
  (props = {}, ...args) ->
    tag ({} <<< def-props <<< props), ...args

div-inline = div `withProperties` { style: { display: \inline } }
h1-name    = h1  `withProperties` { itemProp: \name }
cjk        = '([\uD800-\uDBFF][\uDC00-\uDFFF]|[^，、；。－—<>])'
r-cjk-one  = new RegExp "^#{cjk}$"
r-cjk-g    = new RegExp cjk, \g
nbsp       = '\u00A0'
CurrentId  = null


Result = createClass do
  render: -> switch @props?type
    | \term    => Term @props
    | \list    => List @props
    | \radical => RadicalTable @props
    | \spin    => div-inline { id: \loading, style: { marginTop: \19px, marginLeft: \1px } }, h1 {} @props.id
    | \html    => div-inline { dangerouslySetInnerHTML: { __html: @props.html } }
    | _        => div {}

Term = createClass do
  render: ->
    { LANG, H=HASH-OF[LANG], title, english, heteronyms, radical, translation, non_radical_stroke_count: nrs-count, stroke_count: s-count, pinyin: py, xrefs } = @props
    H -= /^#/
    H = "./##H"
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
    list = for props, key in heteronyms
      Heteronym { key, $char, H, LANG, title, py, english, CurrentId } <<< props
    list ++= XRefs { LANG, xrefs } if xrefs?length
    list ++= Translations { translation } if translation
    return div-inline {}, ...list

Translations = createClass do
  render: ->
    {translation} = @props
    div { className: \xrefs }, span { className: \translation },
      ...for let key, val of { English: \英, francais: \法, Deutsch: \德 } | translation[key]
        text = untag(translation[key] * ', ') - /, CL:.*/g - /\|[^[,.()]+/g
        div { key, className: \xref-line },
          span { className: \fw_lang }, val
          span { className: \fw_def, onClick: ~> @onClick val, text }, text
  onClick: (val, text) -> try
    syn = window.speechSynthesis
    utt = window.SpeechSynthesisUtterance
    u = new utt(text - /\([A-Z]\)/g - /[^\u0000-\u00FF]/g)
    u.lang = switch val
      | \英 => \en-US
      | \法 => \fr-FR
      | \德 => \de-DE
    u.volume = 1.0
    u.rate = 1.0
    syn.speak u

const HASH-OF = {a: \#, t: "#'", h: \#:, c: \#~}
const XREF-LABEL-OF = {a: \華, t: \閩, h: \客, c: \陸, ca: \臺}
XRefs = createClass do
  render: ->
    { LANG, xrefs } = @props
    div { className: \xrefs }, ...for { lang, words } in xrefs
      H = "./#{ HASH-OF[lang] }"
      div { key: lang, className: \xref-line },
        span { className: 'xref part-of-speech' },
          XREF-LABEL-OF["#LANG#lang"] || XREF-LABEL-OF[lang]
        nbsp
        span { className: 'xref', itemProp: \citation },
          ...intersperse \、, for word in words
            word -= /[`~]/g
            a { key: word, className: \xref, href: "#H#word" } word

Star = createClass do
  render: ->
    { CurrentId, LANG } = @props
    STARRED = window?STARRED || {}
    if STARRED[LANG] and ~STARRED[LANG].indexOf("\"#CurrentId\"")
      return i { className: "star iconic-color icon-star", title: \已加入記錄簿 }
    return i { className: "star iconic-color icon-star-empty", title: \加入字詞記錄簿 }

Heteronym = createClass do
  render: ->
    { CurrentId, key, $char, H, LANG, title, english,
    id, audio_id=id, bopomofo, trs='', py, pinyin=py||trs||'',
    definitions=[], antonyms, synonyms, variants, specific_to, alt
    } = @props
    if audio_id and LANG is \h
      re = /(.)\u20DE(\S+)/g
      pinyin-list = []
      while t = re.exec(pinyin)
        variant = " 四海大平安".indexOf(t.1)
        mp3 = http "h.moedict.tw/#{variant}-#audio_id.ogg"
        pinyin-list ++= span { className: \audioBlock },
          div { className: 'icon-play playAudio part-of-speech' },
            meta { itemProp: \name, content: mp3 - /^.*\// }
            meta { itemProp: \contentURL, content: mp3 }
            t.1
        __html = t.2.replace(/¹/g \<sup>1</sup>).replace(/²/g \<sup>2</sup>).replace(/³/g \<sup>3</sup>)
                    .replace(/⁴/g \<sup>4</sup>).replace(/⁵/g \<sup>5</sup>)
        pinyin-list ++= span { dangerouslySetInnerHTML: { __html } }

    title = "<div class='stroke' title='筆順動畫'>#title</div>" unless title is /</
    t = untag h title
    { ruby: title-ruby, youyin, b-alt, p-alt, cn-specific, bopomofo, pinyin } = decorate-ruby @props unless LANG is \h
    list = [ if title-ruby
      ruby { className: "rightangle", dangerouslySetInnerHTML: { __html: h title-ruby } }
    else
      span { dangerouslySetInnerHTML: { __html: title } }
    ]
    list ++= small { className: \youyin } youyin if youyin
    mp3 = ''
    if audio_id
      if LANG is \t and not (20000 < audio_id < 50000)
        basename = (100000 + Number audio_id) - /^1/
        mp3 = http "t.moedict.tw/#basename.ogg"
      else if LANG is \a
        mp3 = http "a.moedict.tw/#audio_id.ogg" # TODO: opus
    if mp3 => list ++= i { itemType: \http://schema.org/AudioObject, className: 'icon-play playAudio' },
      meta { itemProp: \name, content: mp3 - /^.*\// }
      meta { itemProp: \contentURL, content: mp3 }
    if b-alt
      if localStorage?getItem("pinyin_#LANG") is /-/
        list ++= small { className: \alternative },
          span { className: \pinyin } p-alt
          span { className: \bopomofo, style: { margin: 0 padding: 0 marginTop: \4px } } b-alt
          span { className: \pinyin } convert-pinyin p-alt
      else
        list ++= small { className: \alternative },
          span { className: \pinyin } convert-pinyin p-alt
          span { className: \bopomofo } b-alt
    list ++= span { lang: \en, className: \english } english if english
    list ++= span { className: \specific_to, dangerouslySetInnerHTML: { __html: h specific_to } } if specific_to

    return div-inline {},
      meta { itemProp: \image, content: encodeURIComponent(t) + ".png" }
      meta { itemProp: \name, content: t }
      if (key ? 0)  is 0 then # Only display Star for the first entry
        Star { CurrentId, LANG } /* a { style: { color: \white cursor: \pointer }, className: \part-of-speech, title: \加入字詞記錄簿 } \甲
      a { style: { color: \white cursor: \pointer }, className: \part-of-speech, title: \加入字詞記錄簿 } \篆
      a { style: { color: \white cursor: \pointer }, className: \part-of-speech, title: \加入字詞記錄簿 } \金
      a { style: { color: \white cursor: \pointer }, className: \part-of-speech, title: \加入字詞記錄簿 } \隸
      a { style: { color: \white cursor: \pointer }, className: \part-of-speech, title: \加入字詞記錄簿 } \草
      a { style: { color: \white cursor: \pointer }, className: \part-of-speech, title: \加入字詞記錄簿 } \行
      a { style: { color: \white cursor: \pointer }, className: \part-of-speech, title: \加入字詞記錄簿 } \楷
      */
      a {
        style: { position: \absolute right: \41px top: \160px color: \white cursor: \pointer display: \none }
        id: 'historical-scripts'
        className: 'hidden-xs part-of-speech'
        title: "字體e筆書寫：張炳煌教授\n字體選用：郭晉銓博士"
        onClick: ->
          $('#strokes iframe').remove!
          for ch in CurrentId
            $('#strokes').append($('<iframe />', {
              src: "https://www.moedict.tw/clk/searchclk/srch_history/main/#{ encodeURIComponent ch }"
              scrolling: \no
              css: { width: \1400px clear: \both transform: 'scale(0.6)' marginLeft: \-290px marginRight: \-290px height: \250px marginTop: \-50px marginBottom: \-50px border: \0 }
            })) } \歷代書體
      $char
      h1 { className: \title, 'data-title': t }, ...list
      if bopomofo or alt or pinyin-list then div { className: "bopomofo #cn-specific" },
        if alt? then div { lang: \zh-Hans, className: \cn-specific },
          span { className: 'xref part-of-speech' }, \简
          span { className: \xref }, untag alt
        if cn-specific and pinyin and bopomofo then small { className: 'alternative cn-specific' },
          span { className: \pinyin } convert-pinyin pinyin
          span { className: \bopomofo } bopomofo
        if pinyin-list then
          span { className: \pinyin } ...pinyin-list
      div { className: \entry, itemProp: \articleBody },
        ...for defs, key in groupBy(\type definitions.slice!)
          DefinitionList { key, LANG, H, defs, synonyms, antonyms, variants }

decorate-ruby = ({ LANG, title='', bopomofo, py, pinyin=py, trs }) ->
  pinyin ?= trs ? ''
  pinyin = (pinyin - /<[^>]*>/g - /（.*）/) unless LANG is \c
  pinyin ||= ''
  bopomofo ?= trs2bpmf(LANG, "#pinyin") ? ''
  bopomofo -= /<[^>]*>/g unless LANG is \c
  bopomofo ||= ''
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
  b = bopomofo.replace /\s?[，、；。－—,\.;]\s?/g, ' '
  b .= replace /（[語|讀|又]音）[\u200B]?/, ''
  b .= replace /\(變\)\u200B\/.*/, ''
  b .= replace /\/.*/, ''
  cn-specific-bpmf = b - /.*<br>陸./ if b is /<br>陸/
  b .= replace /<br>(.*)/, ''
  b -= /.\u20DF/g
  if r-cjk-one.test title
    ruby = '<div class="stroke" title="筆順動畫"><rb>' + title + '</rb></div>'
  else
    r-cjk-ci = new RegExp "(<a href=\"(?:\./)?#?[':~]?(#cjk+)\")>\\2</a>" \g
    ruby = title
    .replace r-cjk-ci, ( mat, open-tag, ci, x, offset ) ->
      open-tag = "<rb>#open-tag word-id=\"#offset\">"
      close-tag = \</a></rb>
      ci .= replace r-cjk-g, "#{open-tag}$1#close-tag"
    # Deal with rare CJK not indexed, such as ○, 𤍤
    .replace new RegExp("<\/rb>(#cjk+)(<rb>)?", \g), ( mat, rare-cjk, x, open-tag ) ->
      open-tag = open-tag || ''
      rare-cjk .= replace r-cjk-g, \<rb>$1</rb>
      \</rb> + rare-cjk + open-tag
  p = pinyin #.replace /[,\.;，、；。－—]\s?/g, ' '
  p .= replace /\(變\)\u200B.*/, ''
  p .= replace /\/.*/, ''
  p .= replace /<br>.*/, ''
  converted-p = convert-pinyin(p)
  converted-p .= replace /[,\.;，、；。－—]\s?/g, ' '
  converted-p .= split ' '
  p .= replace /[,\.;，、；。－—]\s?/g, ' '
  p .= split ' '
  p-upper = [] 
  isParallel = localStorage?getItem(\pinyin_a) is /^HanYu-/ if $body.hasClass('lang-a')
  isParallel = localStorage?getItem(\pinyin_t) is /^TL-/ if $body.hasClass('lang-t')
  for yin, idx in p | yin
    yin = converted-p[idx]
    span = # 閩南語典，按隔音符計算字數
           if LANG is \t and yin is /[-\u2011]/g
           then ' rbspan="'+ (yin.match /[-\u2011]+/g .length+1) + '"'
           # 國語兒化音
           else if LANG != \t and yin is /^[^eēéěè].*r\d?$/ and yin isnt /^(j|ch|sh)r$/
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
    #yin = "#{ p[idx].replace(/-/g, '\u2011') }\n#yin" if 
    p-upper[idx] = if isParallel then "<rt#span>#{p[idx]}</rt>"
    p[idx] = "<rt#span>#yin</rt>"
  ruby += '<rtc class="zhuyin" hidden="hidden"><rt>' + b.replace(/[ ]+/g, '</rt><rt>') + '</rt></rtc>'
  ruby += '<rtc class="romanization" hidden="hidden">'
  ruby += p.join ''
  ruby += '</rtc>'
  if isParallel 
    ruby += '<rtc class="romanization" hidden="hidden">'
    ruby += p-upper.join ''
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

#p:\ㆴ t:\ㆵ k:\ㆶ h:\ㆷ p$:"ㆴ\u0358" t$:"ㆵ\u0358" k$:"ㆶ\u0358" h$:"ㆷ\u0358" 
const DT-Tones = {
  "\u0300": "\u0332"  # 3
  "\u0301": "\u0300"  # 2,6
  "\u0302": "\u0306"  # 5
  "\u0304": "\u0304"  "\u0305": "\u0305"  # 7
  "\u0306": "\u0301"  # 9
  "\u0307": "\u200B"  "\u030d": "\u200B"        # 8
}

# ptk(4) 變高入 (1)
# h(4) 變高降 (2)
# ptkh(8) 變低入 (4)
# ă(5) 直接轉 ā̱ (7+3) # 優勢腔變中平 ā (7)，台北變 a̲ (3)


function convert-pinyin-t (yin, isBody=true)
  system = localStorage?getItem(\pinyin_t) || \TL
  return yin if system is \TL
  if system is /DT$/
    yin2 = yin.replace(/-/g, '\u2011')
              .replace(/ph(\w)/g, 'PH$1').replace(/b(\w)/g, 'bh$1') # Consonants
              .replace(/p(\w)/g, 'b$1').replace(/PH(\w)/g, 'p$1')
              .replace(/tsh/g, 'c').replace(/ts/g, 'z')
              .replace(/th(\w)/g, 'TH$1').replace(/t(\w)/g, 'd$1').replace(/TH(\w)/g, 't$1')
              .replace(/kh(\w)/g, 'KH$1').replace(/g(\w)/g, 'gh$1')
              .replace(/k(\w)/g, 'g$1').replace(/KH(\w)/g, 'k$1')
              .replace(/j/g, 'r')
              .replace(/Ph(\w)/g, 'pH$1').replace(/B(\w)/g, 'Bh$1') # Consonants
              .replace(/P(\w)/g, 'B$1').replace(/pH(\w)/g, 'P$1')
              .replace(/Tsh/g, 'C').replace(/Ts/g, 'Z')
              .replace(/Th(\w)/g, 'tH$1').replace(/T(\w)/g, 'D$1').replace(/tH(\w)/g, 'T$1')
              .replace(/Kh(\w)/g, 'kH$1').replace(/G(\w)/g, 'Gh$1')
              .replace(/K(\w)/g, 'G$1').replace(/kH(\w)/g, 'K$1')
              .replace(/J/g, 'R')
              .replace(/o([^.!?,\w\s\u2011]*)o/g, 'O$1O').replace(/o([^.!?,\w\s\u2011]*)(?![^\w\s\u2011]*[knm])/g, 'o$1r').replace(/O([^\w\s\u2011]*)O/g, 'o$1')
              .replace(/O([^.!?,\w\s\u2011]*)o([^.!?,\w\s\u2011]*)r?/g, 'O$1$2')
              .replace(/([\u0300-\u0302\u0304\u0307\u030d])/g -> DT-Tones[it])
              .replace(/([aeiou])(r?[ptkh])/g, '$1\u0304$2')
              .replace(/\u200B/g, '')
              .replace(/[-\u2011][-\u2011]([aeiou])(?![\u0300\u0332\u0306\u0304])/g, '$1\u030A')
              .replace(/[-\u2011][-\u2011](ā|a\u0304)/g, '\u2011\u2011a\u030A')
              .replace(/[-\u2011][-\u2011](ō|o\u0304)/g, '\u2011\u2011o\u030A')
              .replace(/[-\u2011][-\u2011](ī|i\u0304)/g, '\u2011\u2011i\u030A')
              .replace(/[-\u2011][-\u2011](ē|e\u0304)/g, '\u2011\u2011e\u030A')
              .replace(/[-\u2011][-\u2011](ū|u\u0304)/g, '\u2011\u2011u\u030A')
              .replace(/nn($|[-\s])/g, 'ⁿ$1')
    if isBody
      # We're in examples; apply DT tone-sandhi across phrase boundaries
      # (delimited by punctuation) according to 呂富美's suggestion
      yin2.=replace(/((?:[^\.,!?]*(?:\w[^-\.,!?\w\s\u2011]*)[- \u2011])+)(\w)/g, (_, $1, $2) ->
        [ tone-sandhi seg for seg in $1.split(/([- \u2011\.,!?])/) ].join("") + $2)
    else
      # Title words; apply tone-sandhi only within a multi-syllable phrase
      yin2.=replace(/((?:\S*(?:\w[^\w\s\u2011]*)\u2011)+)(\w)/g, (_, $1, $2) ->
        [ tone-sandhi seg for seg in $1.split('\u2011') ].join("\u2011") + $2)
    # -仔 sandhi. We handle only the two obvious, non-contentious cases.
    yin2.=replace(/\u0332(\w*[ \u2011]a(?:[ -\u2011]|\u0300](?![-\w\u2011])))/g '\u0304$1')  # 3 -> 4
    yin2.=replace(/\u0300(\w*[ \u2011]a(?:[ -\u2011]|\u0300](?![-\w\u2011])))/g '$1')        # 2 -> 1
    return yin2
  # POJ Rules from: https://lukhnos.org/blog/zh/archives/472/
  return yin.replace(/o([^.!?,\w\s\u2011]*)o/g, 'o$1\u0358')
            .replace(/ts/g, 'ch')
            .replace(/Ts/g, 'Ch')
            .replace(/u([^‑-\w\s]*)a/g, 'o$1a')
            .replace(/u([^‑-\w\s]*)e/g, 'o$1e')
            .replace(/i([^‑-\w\s]*)k($|[-\s])/g, 'e$1k$2')
            .replace(/i([^‑-\w\s]*)ng/g, 'e$1ng')
            .replace(/nn($|[‑-\s])/g, 'ⁿ$1')
            .replace(/([ie])r/g, '$1\u0358')
            .replace(/\u030B/g, "\u0306") # 9th tone


const DT-Tones-Sandhi = {
    "\u0300": ""              # 2,6 ->  1
    "\u0332": "\u0300"        # 3   ->  2
    "\u0306": "\u0304"        # 5   ->  7
    "\u0304": "\u0332"        # 7   ->  3
}
function tone-sandhi (seg)
  return seg unless seg is /\w/
  if seg is /[aeiou]r?[hptk]/i
    return seg.replace(/([aioue])/i, '$1\u0332') # 8 -> 3
  if seg isnt /[\u0300\u0332\u0306\u0304]/
    if seg isnt /[aioue]/i
      return seg.replace(/([nm])/, '$1\u0304') # 1 -> 7
    return seg.replace(/([aioue])/i, '$1\u0304') # 1 -> 7
  if seg is /[aeiou]\u0304r?[ptk]/i
    return seg.replace(/\u0304/, '')            # 4(ptk) -> 8
  if seg is /[aeiou]\u0304r?[h]/i
    return seg.replace(/\u0304/, '\u0300')      # 4(h) -> 2
  return seg.replace(/([\u0300\u0332\u0306\u0304])/g -> DT-Tones-Sandhi[it])

function convert-pinyin (yin, isBody)
  yin.=replace(/-/g '\u2011')
  return convert-pinyin-t(yin, isBody) if $body.hasClass('lang-t')
  return yin unless $body.hasClass('lang-a')
  system = localStorage?getItem \pinyin_a
  return yin unless system and PinYinMap[system - /^HanYu-/]
  return [ convert-pinyin(y, isBody) for y in yin.split(/\s+/) ].join(' ') if yin is /\s/
  tone = 5
  tone = 1 if yin is /[āōēīūǖ]/
  tone = 2 if yin is /[áóéíúǘ]/
  tone = 3 if yin is /[ǎǒěǐǔǚ]/
  tone = 4 if yin is /[àòèìùǜ]/
  yin = yin.replace(/[āáǎà]/g, 'a')
           .replace(/[ōóǒò]/g, 'o')
           .replace(/[ēéěè]/g, 'e')
           .replace(/[īíǐì]/g, 'i')
           .replace(/[ūúǔù]/g, 'u')
           .replace(/[üǖǘǚǜ]/g, 'v')
  r = ''
  if yin is /^[^eēéěè].*r/
    r = 'r'
    yin -= /r$/
  yin = PinYinMap[system - /^HanYu-/][yin - /\u200b/g] || yin
  match yin
  | /a/   => yin.=replace /a/ "aāáǎàa"[tone]
  | /o/   => yin.=replace /o/ "oōóǒòo"[tone]
  | /e/   => yin.=replace /e/ "eēéěèe"[tone]
  | /ui/  => yin.=replace /i/ "iīíǐìi"[tone]
  | /u/   => yin.=replace /u/ "uūúǔùu"[tone]
  | /ü/   => yin.=replace /ü/ "üǖǘǚǜü"[tone]
  | /i/   => yin.=replace /i/ "iīíǐìi"[tone]

  return "#yin#r"

DefinitionList = createClass do
  render: ->
    { H, LANG, defs } = @props
    list = []
    if defs.0?type
      list ++= intersperse nbsp, for t, key in defs.0.type.split \,
        span { key, className: \part-of-speech }, untag t
    list ++= ol {}, ...for d, key in defs
      Definition { key, H, LANG, defs } <<< d
    list ++= decorate-nyms @props
    return div { className: \entry-item }, ...list

function decorate-nyms (props)
  list = []
  for key, val of { synonyms: \似, antonyms: \反, variants: \異 } | props[key]
    list ++= span { key, className: key },
      span { className: \part-of-speech }, val
      nbsp
      ...intersperse \、, for __html in props[key] / \,
        span { dangerouslySetInnerHTML: { __html } }
  return list

Definition = createClass do
  render: ->
    {LANG, type, def, defs, antonyms, synonyms} = @props
    if def is /∥/
      $after-def = div { style: { margin: "0 0 22px -44px" }, dangerouslySetInnerHTML: { __html: h(def - /^[^∥]+/) } }
      def -= /∥.*/
    is-colon-def = LANG is \c and (def is /[:：]<\/span>$/) and not(any (.def is /^\s*\(\d+\)/), defs)
    def-string = h(expand-def def).replace do
      /([：。」])([\u278A-\u2793\u24eb-\u24f4])/g
      '$1\uFFFC$2'
    list = for it, key in def-string.split '\uFFFC'
      span { key, className: \def, dangerouslySetInnerHTML: { __html: h it } }
    for let key in <[ example quote link ]> | @props[key]
      list ++= for it, idx in @props[key]
        span { "#key.#idx", className: key, dangerouslySetInnerHTML: { __html: h it } }
    list ++= decorate-nyms @props
    list ++= $after-def if $after-def
    style = if is-colon-def then { marginLeft: \-28px } else {}
    wrapper = if def is /^\s*\(\d+\)/ or is-colon-def then (-> it) else (-> li {}, it)
    wrapper p { className: \definition, style }, ...list

const CJK-RADICALS = '⼀一⼁丨⼂丶⼃丿⼄乙⼅亅⼆二⼇亠⼈人⼉儿⼊入⼋八⼌冂⼍冖⼎冫⼏几⼐凵⼑刀⼒力⼓勹⼔匕⼕匚⼖匸⼗十⼘卜⼙卩⼚厂⼛厶⼜又⼝口⼞囗⼟土⼠士⼡夂⼢夊⼣夕⼤大⼥女⼦子⼧宀⼨寸⼩小⼪尢⼫尸⼬屮⼭山⼮巛⼯工⼰己⼱巾⼲干⼳幺⼴广⼵廴⼶廾⼷弋⼸弓⼹彐⼺彡⼻彳⼼心⼽戈⼾戶⼿手⽀支⽁攴⽂文⽃斗⽄斤⽅方⽆无⽇日⽈曰⽉月⽊木⽋欠⽌止⽍歹⽎殳⽏毋⽐比⽑毛⽒氏⽓气⽔水⽕火⽖爪⽗父⽘爻⽙爿⺦丬⽚片⽛牙⽜牛⽝犬⽞玄⽟玉⽠瓜⽡瓦⽢甘⽣生⽤用⽥田⽦疋⽧疒⽨癶⽩白⽪皮⽫皿⽬目⽭矛⽮矢⽯石⽰示⽱禸⽲禾⽳穴⽴立⽵竹⽶米⽷糸⺰纟⽸缶⽹网⽺羊⽻羽⽼老⽽而⽾耒⽿耳⾀聿⾁肉⾂臣⾃自⾄至⾅臼⾆舌⾇舛⾈舟⾉艮⾊色⾋艸⾌虍⾍虫⾎血⾏行⾐衣⾑襾⾒見⻅见⾓角⾔言⻈讠⾕谷⾖豆⾗豕⾘豸⾙貝⻉贝⾚赤⾛走⾜足⾝身⾞車⻋车⾟辛⾠辰⾡辵⻌辶⾢邑⾣酉⾤釆⾥里⾦金⻐钅⾧長⻓长⾨門⻔门⾩阜⾪隶⾫隹⾬雨⾭靑⾮非⾯面⾰革⾱韋⻙韦⾲韭⾳音⾴頁⻚页⾵風⻛风⾶飛⻜飞⾷食⻠饣⾸首⾹香⾺馬⻢马⾻骨⾼高⾽髟⾾鬥⾿鬯⿀鬲⿁鬼⿂魚⻥鱼⻦鸟⿃鳥⿄鹵⻧卤⿅鹿⿆麥⻨麦⿇麻⿈黃⻩黄⿉黍⿊黑⿋黹⿌黽⻪黾⿍鼎⿎鼓⿏鼠⿐鼻⿑齊⻬齐⿒齒⻮齿⿓龍⻰龙⿔龜⻳龟⿕龠'

RadicalGlyph = createClass do
  render: ->
    {char, H} = @props
    idx = CJK-RADICALS.index-of(char)
    char = CJK-RADICALS[idx+1] unless idx % 2
    #return char unless LANG in <[ a c ]>
    return span { className: \glyph },
      a { title: \部首檢索, className: \xref, href: "#H@#char" style: { color: \white } }, " #char"

RadicalTable = createClass do
  render: ->
    {terms, id, H} = @props
    id -= /^[@=]/
    if id is /\S/
      title = h1-name {}, "#id ", a { className: \xref, href: \#, title: \部首表 }, \部
    else
      H += '@'
      title = h1-name {}, \部首表
    if $?
      rows = $.parseJSON terms
    else
      rows = JSON.parse terms
    list = []
    H = "./#H"
    for chars, strokes in rows | chars?length
      chs = []
      for ch in chars
        chs ++= a { key: ch, className: \stroke-char, href: "#H#ch" }, ch
        chs ++= ' '
      list ++= span { className: \stroke-count }, strokes
      list ++= span { className: \stroke-list }, chs
      list ++= hr { style: { margin: 0, padding: 0, height: 0 } }
    return div-inline {}, title, div { className: \list }, ...list

List = createClass do
  render: ->
    {terms, id, H, LRU} = @props
    return div {} unless terms
    H -= /^#/
    H = "./##H"
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

http-map <<< window.moedictDesktop.voices if isMoedictDesktop
http = -> "http#{if not isMoedictDesktop or it.match(/^([^.]+)\.[^\/]+/).1 not of window.moedictDesktop.voices then "s" else ""}://#{ it.replace(/^([^.]+)\.[^\/]+/, (xs,x) -> http-map[x] or xs ) }"
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
    .replace(/\uFFF9/g """
      <span class="ruby#{
        if $?('body').hasClass('lang-t') and localStorage?getItem(\pinyin_t) is "TL-DT" then " parallel" else ""
      }"><span class="rb"><span class="ruby"><span class="rb">
    """)
    .replace(/\uFFFA/g '</span><br><span class="rt trs pinyin">')
    .replace(/\uFFFB$/, '')
    .replace(/\uFFFB/g '</span></span></span></span><br><span class="rt mandarin">')
    .replace(/<span class="rt mandarin">\s*<\//g '</')
    .replace /(<span class="rt trs pinyin")>\s*([^<]+)/g, (_, pre, trs) -> """
      #pre title="#{ trs2bpmf \t trs }">#{
        if $?('body').hasClass('lang-t') and localStorage?getItem(\pinyin_t) is "TL-DT" then "<span class='upper'>#{
          trs.replace(/-/g "\u2011")
        }</span>" else ""
      }#{ convert-pinyin-t trs, yes }
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
    /^\s*<(\d)>\s*([介代副助動名歎嘆形連]?)/, (_, num, char) -> "#{
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
  H = "./#{ HASH-OF[LANG-OR-H] || LANG-OR-H }"
  part.=replace /([「【『（《])`([^~]+)~([。，、；：？！─…．·－」』》〉]+)/g (, pre, word, post) -> "<span class='punct'>#pre<a href=\\\"#H#word\\\">#word</a>#post</span>"
  part.=replace /([「【『（《])`([^~]+)~/g (, pre, word) -> "<span class='punct'>#pre<a href=\\\"#H#word\\\">#word</a></span>"
  part.=replace /`([^~]+)~([。，、；：？！─…．·－」』》〉]+)/g (, word, post) -> "<span class='punct'><a href=\\\"#H#word\\\">#word</a>#post</span>"
  part.=replace /`([^~]+)~/g (, word) -> "<a href=\\\"#H#word\\\">#word</a>"
  part.=replace /([)）])/g "$1\u200B"
  return part

module.exports = { UserPref, Result, Nav, Links, decodeLangPart }

PinYinMap =
  "WadeGiles": {"zha":"cha","cha":"ch'a","zhai":"chai","chai":"ch'ai","zhan":"chan","chan":"ch'an","zhang":"chang","chang":"ch'ang","zhao":"chao","chao":"ch'ao","zhe":"che","che":"ch'e","zhei":"chei","zhen":"chen","chen":"ch'en","zheng":"cheng","cheng":"ch'eng","ji":"chi","qi":"ch'i","jia":"chia","qia":"ch'ia","jiang":"chiang","qiang":"ch'iang","jiao":"chiao","qiao":"ch'iao","jie":"chieh","qie":"ch'ieh","jian":"chien","qian":"ch'ien","zhi":"chih","chi":"ch'ih","jin":"chin","qin":"ch'in","jing":"ching","qing":"ch'ing","jiu":"chiu","qiu":"ch'iu","jiong":"chiung","qiong":"ch'iung","zhuo":"cho","chuo":"ch'o","zhou":"chou","chou":"ch'ou","zhu":"chu","chu":"ch'u","zhua":"chua","chua":"ch'ua","zhuai":"chuai","chuai":"ch'uai","zhuan":"chuan","chuan":"ch'uan","zhuang":"chuang","chuang":"ch'uang","zhui":"chui","chui":"ch'ui","zhun":"chun","chun":"ch'un","zhong":"chung","chong":"ch'ung","ju":"chü","qu":"ch'ü","juan":"chüan","quan":"ch'üan","jue":"chüeh","que":"ch'üeh","jun":"chün","qun":"ch'ün","er":"erh","he":"ho","xi":"hsi","xia":"hsia","xiang":"hsiang","xiao":"hsiao","xie":"hsieh","xian":"hsien","xin":"hsin","xing":"hsing","xiu":"hsiu","xiong":"hsiung","xu":"hsü","xuan":"hsüan","xue":"hsüeh","xun":"hsün","hong":"hung","ran":"jan","rang":"jang","rao":"jao","re":"je","ren":"jen","reng":"jeng","ri":"jih","ruo":"jo","rou":"jou","ru":"ju","ruan":"juan","rui":"jui","run":"jun","rong":"jung","ga":"ka","ka":"k'a","gai":"kai","kai":"k'ai","gan":"kan","kan":"k'an","gang":"kang","kang":"k'ang","gao":"kao","kao":"k'ao","gei":"kei","gen":"ken","ken":"k'en","geng":"keng","keng":"k'eng","ge":"ko","ke":"k'o","gou":"kou","kou":"k'ou","gu":"ku","ku":"k'u","gua":"kua","kua":"k'ua","guai":"kuai","kuai":"k'uai","guan":"kuan","kuan":"k'uan","guang":"kuang","kuang":"k'uang","gui":"kuei","kui":"k'uei","gun":"kun","kun":"k'un","gong":"kung","kong":"k'ung","guo":"kuo","kuo":"k'uo","lie":"lieh","lian":"lien","luo":"lo","long":"lung","lv":"lü","lve":"lüeh","lvn":"lün","mie":"mieh","mian":"mien","nie":"nieh","nian":"nien","nuo":"no","nong":"nung","nv":"nü","nve":"nüeh","ba":"pa","pa":"p'a","bai":"pai","pai":"p'ai","ban":"pan","pan":"p'an","bang":"pang","pang":"p'ang","bao":"pao","pao":"p'ao","bei":"pei","pei":"p'ei","ben":"pen","pen":"p'en","beng":"peng","peng":"p'eng","bi":"pi","pi":"p'i","biao":"piao","piao":"p'iao","bie":"pieh","pie":"p'ieh","bian":"pien","pian":"p'ien","bin":"pin","pin":"p'in","bing":"ping","ping":"p'ing","bo":"po","po":"p'o","pou":"p'ou","bu":"pu","pu":"p'u","shi":"shih","shong":"shung","suo":"so","si":"ssu","song":"sung","da":"ta","ta":"t'a","dai":"tai","tai":"t'ai","dan":"tan","tan":"t'an","dang":"tang","tang":"t'ang","dao":"tao","tao":"t'ao","de":"te","te":"t'e","dei":"tei","den":"ten","deng":"teng","teng":"t'eng","di":"ti","ti":"t'i","diang":"tiang","diao":"tiao","tiao":"t'iao","die":"tieh","tie":"t'ieh","dian":"tien","tian":"t'ien","ding":"ting","ting":"t'ing","diu":"tiu","duo":"to","tuo":"t'o","dou":"tou","tou":"t'ou","za":"tsa","ca":"ts'a","zai":"tsai","cai":"ts'ai","zan":"tsan","can":"ts'an","zang":"tsang","cang":"ts'ang","zao":"tsao","cao":"ts'ao","ze":"tse","ce":"ts'e","zei":"tsei","zen":"tsen","cen":"ts'en","zeng":"tseng","ceng":"ts'eng","zuo":"tso","cuo":"ts'o","zou":"tsou","cou":"ts'ou","zu":"tsu","cu":"ts'u","zuan":"tsuan","cuan":"ts'uan","zui":"tsui","cui":"ts'ui","zun":"tsun","cun":"ts'un","zong":"tsung","cong":"ts'ung","du":"tu","tu":"t'u","duan":"tuan","tuan":"t'uan","dui":"tui","tui":"t'ui","dun":"tun","tun":"t'un","dong":"tung","tong":"t'ung","zi":"tzu","ci":"tz'u","yan":"yen","ye":"yeh","you":"yu","yong":"yung","yu":"yü","yuan":"yüan","yue":"yüeh","yun":"yün"}
  "GuoYin": {"gui":"guei","zhao":"jau","zuo":"tzuo","niao":"niau","zan":"tzan","zou":"tzou","rong":"rung","tao":"tau","ci":"tsz","zong":"tzung","cuo":"tsuo","ao":"au","qiang":"chiang","miao":"miau","xuan":"shiuan","lv":"liu","chun":"chuen","sun":"suen","shi":"shr","kao":"kau","can":"tsan","diao":"diau","zu":"tzu","qun":"chiun","ca":"tsa","xing":"shing","zun":"tzuen","xian":"shian","diu":"diou","shun":"shuen","kun":"kuen","yao":"yau","kui":"kuei","jiong":"jiung","dui":"duei","hao":"hau","zen":"tzen","xun":"shiun","diang":"-","hui":"huei","cong":"tsung","xie":"shie","ju":"jiu","cou":"tsou","ceng":"tseng","jue":"jiue","zui":"tzuei","nve":"niue","zhuai":"juai","zhuang":"juang","cui":"tsuei","ce":"tse","yong":"yung","xi":"shi","cun":"tsuen","chao":"chau","zhui":"juei","xiu":"shiou","xiao":"shiau","xin":"shin","dong":"dung","qie":"chie","sui":"suei","zhun":"juen","zhai":"jai","xu":"shiu","si":"sz","qu":"chiu","zhen":"jen","shao":"shau","chi":"chr","cang":"tsang","qiu":"chiou","gao":"gau","xiang":"shiang","za":"tza","zang":"tzang","cu":"tsu","hong":"hung","zha":"ja","kong":"kung","bao":"bau","zhua":"jua","nv":"niu","cen":"tsen","dun":"duen","nong":"nung","liu":"liou","zao":"tzau","piao":"piau","xia":"shia","tun":"tuen","rao":"rau","jiao":"jiau","zhang":"jang","cuan":"tsuan","zhuo":"juo","qiao":"chiau","nun":"nuen","niu":"niou","qing":"ching","jiu":"jiou","zhu":"ju","sao":"sau","qi":"chi","zhan":"jan","zheng":"jeng","liao":"liau","juan":"jiuan","zhe":"je","cai":"tsai","tong":"tung","zhuan":"juan","zi":"tz","qia":"chia","lao":"lau","gun":"guen","zhou":"jou","tiao":"tiau","tui":"tuei","gong":"gung","zei":"tzei","rui":"ruei","lve":"liue","ze":"tze","xue":"shiue","chong":"chung","zeng":"tzeng","cao":"tsau","xiong":"shiung","hun":"huen","zai":"tzai","que":"chiue","biao":"biau","zhong":"jung","nao":"nau","zuan":"tzuan","song":"sung","qiong":"chiung","run":"ruen","long":"lung","chui":"chuei","zhi":"jr","pao":"pau","lun":"luen","qian":"chian","dao":"dau","quan":"chiuan","shui":"shuei","miu":"miou","lvan":"liuan","ri":"r","jun":"jiun","mao":"mau","zhei":"jei","qin":"chin"}
  "TongYong": {"shi":"shih","xuan":"syuan","lv":"lyu","liu":"liou","xia":"sia","zhua":"jhua","qiang":"ciang","nv":"nyu","zha":"jha","ci":"cih","xiang":"siang","qiu":"ciou","chi":"chih","zhao":"jhao","si":"sih","qu":"cyu","gui":"guei","zhen":"jhen","zhou":"jhou","hui":"huei","qia":"cia","feng":"fong","zi":"zih","xun":"syun","dui":"duei","zhuan":"jhuan","jiong":"jyong","kui":"kuei","juan":"jyuan","zhe":"jhe","zhu":"jhu","qi":"ci","zheng":"jheng","zhan":"jhan","diu":"diou","jiu":"jiou","qing":"cing","niu":"niou","xian":"sian","xing":"sing","qiao":"ciao","zhuo":"jhuo","zhang":"jhang","qun":"cyun","que":"cyue","wen":"wun","xiong":"syong","zhuang":"jhuang","cui":"cuei","zhuai":"jhuai","xue":"syue","nve":"nyue","zui":"zuei","lve":"lyue","jue":"jyue","rui":"ruei","xie":"sie","tui":"tuei","ju":"jyu","qin":"cin","zhai":"jhai","zhei":"jhei","xu":"syu","weng":"wong","jun":"jyun","zhun":"jhun","lvan":"lyuan","ri":"rih","sui":"suei","qie":"cie","shui":"shuei","miu":"miou","xin":"sin","quan":"cyuan","qian":"cian","xiu":"siou","xiao":"siao","zhi":"jhih","zhui":"jhuei","chui":"chuei","qiong":"cyong","zhong":"jhong","xi":"si"}
