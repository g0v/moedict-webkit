React = window?React || require \react
{p, i, a, b, form, h1, div, main, span, br, h3, h4, button, label, table, nav,
tr, td, th, input, hr, meta, ul, ol, li, ruby, small} = React.DOM

{any, map} = require \prelude-ls

withProperties = (tag, def-props={}) ->
  (props = {}, ...args) ->
    tag ({} <<< def-props <<< props), ...args

div-inline = div `withProperties` { style: { display: \inline } }
h1-name    = h1  `withProperties` { itemProp: \name }
nbsp       = '\u00A0'
CurrentId  = null

const share-buttons = [
  { id: \f, icon: \facebook, label: \Facebook, background: \#3B579D, href: \https://www.facebook.com/sharer/sharer.php?u=https%3A%2F%2Fwww.moedict.tw%2F }
  { id: \t, icon: \twitter, label: \Twitter, background: \#00ACED, href: \https://twitter.com/share?text=__TEXT__&url=https%3A%2F%2Fwww.moedict.tw%2F }
  { id: \g, icon: \google-plus, label: \Google+, background: \#D95C5C, href: \https://plus.google.com/share?url=https%3A%2F%2Fwww.moedict.tw%2F }
]

PrefList = React.createClass do
  getInitialState: ->
    for own key, selected of @props | key isnt \children
      return { key, selected }
  componentDidMount: -> @phoneticsChanged!
  componentDidUpdate: -> @phoneticsChanged!
  pinyin_aChanged: -> location.reload!
  phoneticsChanged: ->
    $('rb[order]').each ->
      attr = $(@).attr('annotation')
      $(@).data('annotation', attr) if attr
    $('rb[zhuyin]').each ->
      zhuyin = $(@).attr('zhuyin')
      yin = $(@).attr('yin')
      diao = $(@).attr('diao')
      $(@).data({ yin, zhuyin, diao }) if zhuyin
    restore-pinyin = -> $('rb[order]').each ->
      attr = $(@).data('annotation')
      $(@).attr('annotation', attr) if attr
    restore-zhuyin = -> $('rb[zhuyin]').each ->
      zhuyin = $(@).data('zhuyin')
      yin = $(@).data('yin')
      diao = $(@).data('diao')
      $(@).attr({ yin, zhuyin, diao }) if zhuyin
    clear-pinyin = -> $('rb[order]').attr('annotation', '')
    clear-zhuyin = -> $('rb[zhuyin]').attr({ yin: '', zhuyin: '', diao: '' })
    # new-ruby branch: bopomofo 改用 zhuyin 元素
    switch @state.selected
      | \rightangle => restore-pinyin!; restore-zhuyin!
      | \bopomofo   => clear-pinyin!; restore-zhuyin!
      | \pinyin     => restore-pinyin!; clear-zhuyin!
      | \none       => clear-pinyin!; clear-zhuyin!
  render: ->
    [ lbl, ...items ] = @props.children
    { key, selected=items.0.0 } = @state
    li { className: \btn-group },
      label {}, lbl
      button { className: 'btn btn-default btn-sm dropdown-toggle', type: \button, 'data-toggle': \dropdown },
        ...for let [val, ...els] in items
          if val is selected then els else ''
        nbsp
        span { className: \caret }
      ul { className: \dropdown-menu },
        ...for let [val, ...els] in items
          if val then
            li {}, a {
              style: { cursor: \pointer }
              className: if val is selected then \active else ''
              onClick: ~>
                localStorage?setItem key, val
                @setState { selected: val }
                @"#{key}Changed"?!
            }, ...els
          else
            li { className: \divider, role: \presentation }

UserPref = React.createClass do
  getDefaultProps: -> {
    simptrad: localStorage?getItem \simptrad
    phonetics: localStorage?getItem \phonetics
    pinyin_a: localStorage?getItem \pinyin_a
  }
  render: -> { phonetics, simptrad, pinyin_a } = @props; div {},
    h4 {}, \偏好設定
    button { className: 'close btn-close', type: \button, 'aria-hidden': true }, \×
    ul {},
      PrefList { pinyin_a }, \國語辭典拼音系統,
        [ \HanYu      \漢語拼音 ]
        [ \TongYong   \通用拼音 ] # , small {}, \（方言音） ]
        [ \WadeGiles  \威妥瑪拼音 ]
        [ \GuoYin     \國音二式 ]
      PrefList { phonetics }, \條目注音顯示方式,
        [ \rightangle \直角共同顯示 ]
        [ \bopomofo   \只顯示注音符號 ] # , small {}, \（方言音） ]
        [ \pinyin     \只顯示羅馬拼音 ]
        [] # li {}, a {}, \置於條目名稱下方
        [ \none       \關閉 ] /*
      li { className: \btn-group },
        label {}, \字詞查閱紀錄
        button { className: 'btn btn-default btn-sm dropdown-toggle', type: \button, 'data-toggle': \dropdown },
          '50 筆'
          span { className: \caret }
        ul { className: \dropdown-menu },
          li {}, a { className: \active }, '50 筆'
          li {}, a {}, '30 筆'
          li {}, a {}, '15 筆'
          li { className: \divider, role: \presentation }
          li {}, a {}, \關閉, small {}, \（將清除所有紀錄）
        button { className: 'btn btn-danger btn-sm', type: \button }, \清除

      PrefList { simptrad }, \「簡→繁」搜尋轉換,
        [ \no-variants  \避開通同字及異體字 ]
        [ \total        \完全轉換 ]
        []
        [ \none         \關閉 ] */
    button { className: 'btn btn-primary btn-block btn-close', type: \button } \關閉

Links = React.createClass do
  render: -> div {},
    # a { id: \sendback, className: 'btn btn-default small', title: \送回編修, style: { marginLeft: \50%, display: \none, background: \#333333, color: \white }, href: \mailto:xldictionary@gmail.com?subject=編修建議&body=出處及定義：, target: \_blank }, \送回編修
    a { className: 'visible-xs pull-left ebas btn btn-default', href: \#, title: \關於本站, style: { float: \left, marginTop: \-10px, marginLeft: \5px, marginBottom: \5px }, onClick: -> pressAbout! },
      span { className: \iconic-circle }, i { className: \icon-info }
      span {}, nbsp, \萌典
    div { className: \share, style: { float: \right, marginTop: \-10px, marginRight: \5px, marginBottom: \15px } },
      ...for { id, icon, label, background, href } in share-buttons
        a { id: "share-#id", className: "btn btn-default small", title: "#label 分享", style: { background, color: \white }, 'data-href': href, target: \_blank },
          i { className: \icon-share } nbsp
          i { className: "icon-#icon" }

Nav = React.createClass do
  render: -> nav { className: 'navbar navbar-inverse navbar-fixed-top', role: \navigation },
    div { className: \navbar-header },
      a { className: 'navbar-brand brand ebas', href: \./ }, \萌典
    ul { className: 'nav navbar-nav' },
      li { className: \dropdown },
        a { className: \dropdown-toggle, href: \#, 'data-toggle': \dropdown },
          i { className: \icon-book }, nbsp
          span { className: \lang-active, style: { margin: 0, padding: 0 }, itemProp: \articleSection }, \國語辭典
          b { className: \caret }
        DropDown { STANDALONE: @props.STANDALONE },
      li { id: \btn-starred },
        a { href: \#=*, style: { paddingLeft: \5px, paddingRight: \5px } },
          i { className: \icon-bookmark-empty }
      li { id: \btn-pref },
        a { href: \#=*, style: { paddingLeft: \5px, paddingRight: \5px } },
          i { className: \icon-cogs }
      li {},
        form { id: \lookback, className: \back, target: \_blank, acceptCharset: \big5, action: \http://dict.revised.moe.edu.tw/cgi-bin/newDict/dict.sh, style: { display: \none, margin: 0, padding: 0 } },
          input { type: \hidden, name: \idx, value: \dict.idx }
          input { type: \hidden, name: \fld, value: \1 }
          input { type: \hidden, name: \imgFont, value: \1 }
          input { type: \hidden, name: \cat, value: '' }
          input { id: \cond, type: \hidden, name: \cond, value: '^萌$' }
          input { className: \iconic-circle, type: \submit, value: \反, title: \反查來源（教育部國語辭典）, style: { fontFamily: \EBAS, marginTop: \12px, borderRadius: \20px, border: \0px } }
      li { className: 'resize-btn app-only', style: { position: \absolute, top: \2px, left: \8em, padding: \3px } },
        a { style: { paddingLeft: \5px, paddingRight: \5px, marginRight: \30px }, href: \#, onClick: -> adjustFontSize -1 },
          i { className: \icon-resize-small }
      li { className: 'resize-btn app-only', style: { position: \absolute, top: \2px, left: \8em, padding: \3px, marginLeft: \30px } },
        a { style: { paddingLeft: \5px, paddingRight: \5px}, href: \#, onClick: -> adjustFontSize 1 },
          i { className: \icon-resize-full }
    ul { className: 'nav pull-right hidden-xs' },
      li {},
        a { href: \about.html, title: \關於本站, onClick: -> pressAbout! },
          span { className: \iconic-circle },
            i { className: \icon-info }
    ul { className: 'nav pull-right hidden-xs' },
      li { className: \web-inline-only, style: { display: \inline-block } },
        a { href: \https://twitter.com/moedict, target: \_blank, title: '萌典 Twitter', style: { color: \#ccc } },
          i { className: \icon-twitter-sign }
      li { className: \web-inline-only, style: { display: \inline-block } },
        a { href: \https://play.google.com/store/apps/details?id=org.audreyt.dict.moe, target: \_blank, title: 'Google Play 下載', style: { color: \#ccc } },
          i { className: \icon-android }
      li { className: \web-inline-only, style: { display: \inline-block } },
        a { href: \https://itunes.apple.com/tw/app/meng-dian/id599429224, target: \_blank, title: 'App Store 下載', style: { color: \#ccc } },
          i { className: \icon-apple }

Taxonomy = React.createClass do
  render: ->
    {lang} = @props
    li { className: \dropdown-submenu },
      a { className: "#lang taxonomy", }, \…分類索引

MenuItem = React.createClass do
  render: ->
    {lang, href, children} = @props
    role = \menuitem if children.0 is \…
    li { role: \presentation },
      a { className: "#lang lang-option#{ if role then '' else " #lang\-idiom"}", role, href }, children

DropDown = React.createClass do
  render: ->
    list = []
    if @props.STANDALONE isnt \c => list ++= [
      MenuItem { lang: \a, href: \## }, \國語辭典
      Taxonomy { lang: \a }
      MenuItem { lang: \a, href: \#@ }, \…部首表
      MenuItem { lang: \t, href: \#! }, \臺灣閩南語
      Taxonomy { lang: \t }
      MenuItem { lang: \t, href: \#!=諺語 }, \…諺語
      MenuItem { lang: \h, href: \#: }, \臺灣客家語
      MenuItem { lang: \h, href: \#:=諺語 }, \…諺語
    ]
    list ++= [
      MenuItem { lang: \c, href: \#~ }, \兩岸詞典
      Taxonomy { lang: \c }
      MenuItem { lang: \c, href: \#~@ }, \…部首表
    ]
    ul { className: \dropdown-menu, role: \navigation }, ...list

Result = React.createClass do
  render: -> switch @props?type
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
    list = for props, key in heteronyms
      Heteronym { key, $char, H, LANG, title, py, english, CurrentId } <<< props
    list ++= XRefs { LANG, xrefs } if xrefs?length
    list ++= Translations { translation } if translation
    return div-inline {}, ...list

Translations = React.createClass do
  render: ->
    {translation} = @props
    div { className: \xrefs }, span { className: \translation },
      ...for let key, val of { English: \英, francais: \法, Deutsch: \德 } | translation[key]
        text = untag((translation[key] * ', ') - /, CL:.*/g - /\|(?:<\/?a[^>*]>|[^[,.(])+/g)
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
XRefs = React.createClass do
  render: ->
    { LANG, xrefs } = @props
    div { className: \xrefs }, ...for { lang, words } in xrefs
      H = HASH-OF[lang]
      div { key: lang, className: \xref-line },
        span { className: 'xref part-of-speech' },
          XREF-LABEL-OF["#LANG#lang"] || XREF-LABEL-OF[lang]
        nbsp
        span { className: 'xref', itemProp: \citation },
          ...intersperse \、, for word in words
            word -= /[`~]/g
            a { key: word, className: \xref, href: "#H#word" } word

Star = React.createClass do
  getDefaultProps: -> { STARRED: window?STARRED || {} }
  render: ->
    { CurrentId, STARRED, LANG } = @props
    return i {} unless STARRED[LANG]?
    if ~STARRED[LANG].indexOf("\"#CurrentId\"")
      return i { className: "star iconic-color icon-star", title: \已加入記錄簿 }
    return i { className: "star iconic-color icon-star-empty", title: \加入字詞記錄簿 }

Heteronym = React.createClass do
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
    t = untag h title
    { ruby: title-ruby, youyin, b-alt, p-alt, cn-specific, bopomofo, pinyin } = decorate-ruby @props unless LANG is \h
    list = [ if title-ruby
      ruby { style: { display: \inline-block, marginTop: \20px, marginBottom: \17px }, className: \rightangle, dangerouslySetInnerHTML: { __html: h title-ruby } }
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
        span { className: \pinyin } convert-pinyin p-alt
        span { className: \bopomofo } b-alt
    list ++= span { lang: \en, className: \english } english if english
    list ++= span { className: \specific_to, dangerouslySetInnerHTML: { __html: h specific_to } } if specific_to

    return div-inline {},
      meta { itemProp: \image, content: encodeURIComponent(t) + ".png" }
      meta { itemProp: \name, content: t }
      if key is 0 then # Only display Star for the first entry
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
        className: \part-of-speech
        title: \顯示歷代書體
        onClick: ->
          $('#strokes iframe').remove!
          for ch in CurrentId
            $('#strokes').append($('<iframe />', {
              src: "https://www.moedict.tw/clk/searchclk/srch_history/main/#{ encodeURIComponent ch }"
              css: { width: \1400px clear: \both transform: 'scale(0.6)' marginLeft: \-300px height: \250px marginTop: \-55px }
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
    yin = convert-pinyin yin
    span = # 閩南語典，按隔音符計算字數
           if LANG is \t and yin is /\-/g
           then ' rbspan="'+ (yin.match /[\-]+/g .length+1) + '"'
           # 國語兒化音
           else if LANG != \t && yin is /^[^eēéěè].*r\d?$/g
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
  ruby += '<rtc style="display: none" class="zhuyin"><rt>' + b.replace(/[ ]+/g, '</rt><rt>') + '</rt></rtc>'
  ruby += '<rtc style="display: none" class="romanization">'
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

function convert-pinyin (yin)
  return yin unless $?('body').hasClass('lang-a')
  system = localStorage?getItem \pinyin_a
  return yin unless system and PinYinMap[system]
  return [ convert-pinyin y for y in yin.split(/\s+/) ].join(' ') if yin is /\s/
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
  if yin is /r$/
    r = 'r'
    yin -= /r$/
  yin = PinYinMap[system][yin] || yin
  return "#yin#r#tone"

DefinitionList = React.createClass do
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
    if $?
      rows = $.parseJSON terms
    else
      rows = JSON.parse terms
    list = []
    for chars, strokes in rows | chars?length
      chs = []
      for ch in chars
        chs ++= a { key: ch, className: \stroke-char, href: "#H#ch" }, ch
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
  module?.exports = { Result, DropDown, Nav, Links, decodeLangPart }
else
  React{}.View.Result = Result
  React.View.Nav = Nav
  React.View.Links = Links
  React.View.DropDown = DropDown
  React.View.UserPref = UserPref
  React.View.decodeLangPart = decodeLangPart
  unless window.PRERENDER_LANG
    <- $
    React.View.result = React.renderComponent Result!, $(\#result).0

PinYinMap =
  "WadeGiles": {"mie":"mieh","bu":"pu","bin":"pin","cun":"tsun","can":"tsan","ben":"pen","qin":"chin","ruo":"jo","xian":"hsien","ran":"jan","yue":"yueh","rong":"jung","suo":"so","nuo":"no","tong":"tung","dou":"tou","xing":"hsing","ba":"pa","ye":"yeh","que":"chueh","ci":"tzu","da":"ta","duo":"to","zu":"tsu","chi":"chih","juan":"chuan","lve":"lueh","za":"tsa","dui":"tui","jun":"chun","bie":"pieh","zhang":"chang","ji":"chi","zhua":"chua","guo":"kuo","pie":"pieh","de":"te","dun":"tun","du":"tu","xiu":"hsiu","tie":"tieh","duan":"tuan","tian":"tien","jiong":"chiung","bo":"po","zhuo":"cho","gai":"kai","xiang":"hsiang","yong":"yung","lv":"lu","pian":"pien","cong":"tsung","zhuang":"chuang","ru":"ju","gong":"kung","xi":"hsi","yan":"yen","jie":"chieh","jing":"ching","bei":"pei","qiu":"chiu","cu":"tsu","biao":"piao","dai":"tai","gang":"kang","gei":"kei","dian":"tien","qun":"chun","ju":"chu","xia":"hsia","zheng":"cheng","qing":"ching","lian":"lien","shi":"shih","nie":"nieh","zui":"tsui","zao":"tsao","guai":"kuai","xin":"hsin","song":"sung","gao":"kao","cen":"tsen","ren":"jen","zhu":"chu","diang":"-","bi":"pi","zhen":"chen","kong":"kung","cang":"tsang","gou":"kou","chong":"chung","qie":"chieh","bing":"ping","jue":"chueh","lvan":"luan","bang":"pang","gen":"ken","lie":"lieh","ding":"ting","qu":"chu","zai":"tsai","cao":"tsao","kui":"kuei","er":"erh","you":"yu","xu":"hsu","diao":"tiao","guang":"kuang","gun":"kun","ge":"ke","run":"jun","quan":"chuan","gu":"ku","di":"ti","zhan":"chan","ca":"tsa","xie":"hsieh","nian":"nien","cuo":"tso","zha":"cha","mian":"mien","jiu":"chiu","ce":"tse","die":"tieh","zhei":"chei","nve":"nueh","jia":"chia","zan":"tsan","zuo":"tso","qiong":"chiung","zhao":"chao","cai":"tsai","zi":"tzu","guan":"kuan","deng":"teng","hong":"hung","dao":"tao","rou":"jou","zhong":"chung","qi":"chi","ze":"tse","qian":"chien","zhe":"che","bai":"pai","zou":"tsou","zhai":"chai","rang":"jang","nong":"nung","zhun":"chun","re":"je","dei":"tei","ruan":"juan","dong":"tung","bian":"pien","xuan":"hsuan","geng":"keng","dang":"tang","luo":"lo","si":"ssu","gua":"kua","rao":"jao","ga":"ka","cuan":"tsuan","qiang":"chiang","zeng":"tseng","zong":"tsung","zen":"tsen","zhi":"chih","zhuan":"chuan","diu":"tiu","rui":"jui","zuan":"tsuan","reng":"jeng","zhou":"chou","chuo":"cho","ceng":"tseng","jiang":"chiang","qia":"chia","cui":"tsui","ban":"pan","gan":"kan","nv":"nu","cou":"tsou","xun":"hsun","xue":"hsueh","long":"lung","zang":"tsang","zei":"tsei","qiao":"chiao","ri":"jih","xiong":"hsiung","beng":"peng","jin":"chin","xiao":"hsiao","jiao":"chiao","zun":"tsun","tuo":"to","bao":"pao","zhuai":"chuai","gui":"kuei","zhui":"chui","jian":"chien","dan":"tan"}
  "GuoYin": {"gui":"guei","zhao":"jau","zuo":"tzuo","niao":"niau","zan":"tzan","zou":"tzou","rong":"rung","tao":"tau","ci":"tsz","zong":"tzung","cuo":"tsuo","ao":"au","qiang":"chiang","miao":"miau","xuan":"shiuan","lv":"liu","chun":"chuen","sun":"suen","shi":"shr","kao":"kau","can":"tsan","diao":"diau","zu":"tzu","qun":"chiun","ca":"tsa","xing":"shing","zun":"tzuen","xian":"shian","diu":"diou","shun":"shuen","kun":"kuen","yao":"yau","kui":"kuei","jiong":"jiung","dui":"duei","hao":"hau","zen":"tzen","xun":"shiun","diang":"-","hui":"huei","cong":"tsung","xie":"shie","ju":"jiu","cou":"tsou","ceng":"tseng","jue":"jiue","zui":"tzuei","nve":"niue","zhuai":"juai","zhuang":"juang","cui":"tsuei","ce":"tse","yong":"yung","xi":"shi","cun":"tsuen","chao":"chau","zhui":"juei","xiu":"shiou","xiao":"shiau","xin":"shin","dong":"dung","qie":"chie","sui":"suei","zhun":"juen","zhai":"jai","xu":"shiu","si":"sz","qu":"chiu","zhen":"jen","shao":"shau","chi":"chr","cang":"tsang","qiu":"chiou","gao":"gau","xiang":"shiang","za":"tza","zang":"tzang","cu":"tsu","hong":"hung","zha":"ja","kong":"kung","bao":"bau","zhua":"jua","nv":"niu","cen":"tsen","dun":"duen","nong":"nung","liu":"liou","zao":"tzau","piao":"piau","xia":"shia","tun":"tuen","rao":"rau","jiao":"jiau","zhang":"jang","cuan":"tsuan","zhuo":"juo","qiao":"chiau","nun":"nuen","niu":"niou","qing":"ching","jiu":"jiou","zhu":"ju","sao":"sau","qi":"chi","zhan":"jan","zheng":"jeng","liao":"liau","juan":"jiuan","zhe":"je","cai":"tsai","tong":"tung","zhuan":"juan","zi":"tz","qia":"chia","lao":"lau","gun":"guen","zhou":"jou","tiao":"tiau","tui":"tuei","gong":"gung","zei":"tzei","rui":"ruei","lve":"liue","ze":"tze","xue":"shiue","chong":"chung","zeng":"tzeng","cao":"tsau","xiong":"shiung","hun":"huen","zai":"tzai","que":"chiue","biao":"biau","zhong":"jung","nao":"nau","zuan":"tzuan","song":"sung","qiong":"chiung","run":"ruen","long":"lung","chui":"chuei","zhi":"jr","pao":"pau","lun":"luen","qian":"chian","dao":"dau","quan":"chiuan","shui":"shuei","miu":"miou","lvan":"liuan","ri":"r","jun":"jiun","mao":"mau","zhei":"jei","qin":"chin"}
  "TongYong": {"shi":"shih","xuan":"syuan","lv":"lyu","liu":"liou","xia":"sia","zhua":"jhua","qiang":"ciang","nv":"nyu","zha":"jha","ci":"cih","xiang":"siang","qiu":"ciou","chi":"chih","zhao":"jhao","si":"sih","qu":"cyu","gui":"guei","zhen":"jhen","zhou":"jhou","hui":"huei","qia":"cia","feng":"fong","zi":"zih","xun":"syun","dui":"duei","zhuan":"jhuan","jiong":"jyong","kui":"kuei","juan":"jyuan","zhe":"jhe","zhu":"jhu","qi":"ci","zheng":"jheng","zhan":"jhan","diu":"diou","jiu":"jiou","qing":"cing","niu":"niou","xian":"sian","xing":"sing","qiao":"ciao","zhuo":"jhuo","zhang":"jhang","qun":"cyun","que":"cyue","wen":"wun","xiong":"syong","zhuang":"jhuang","cui":"cuei","zhuai":"jhuai","xue":"syue","nve":"nyue","zui":"zuei","lve":"lyue","jue":"jyue","rui":"ruei","xie":"sie","tui":"tuei","ju":"jyu","qin":"cin","zhai":"jhai","zhei":"jhei","xu":"syu","weng":"wong","jun":"jyun","zhun":"jhun","lvan":"lyuan","ri":"rih","sui":"suei","qie":"cie","shui":"shuei","miu":"miou","xin":"sin","quan":"cyuan","qian":"cian","xiu":"siou","xiao":"siao","zhi":"jhih","zhui":"jhuei","chui":"chuei","qiong":"cyong","zhong":"jhong","xi":"si"}
