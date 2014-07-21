{p, i, a, h1, div, main, span, br, h3, table, tr, td, th, input, hr} = React.DOM

withProperties = (tag, def-props={}) ->
  (props = {}, ...args) ->
    tag ({} <<< def-props <<< props), ...args

div-inline = div `withProperties` { style: { display: \inline } }
h1-name    = h1  `withProperties` { itemProp: \name }

Result = React.createClass do
  render: -> switch @props.type
    | \list    => List @props
    | \radical => Radical @props
    | \spin    => div-inline { style: { marginTop: \19px, marginLeft: \1px } }, h1 {} @props.id
    | \html    => div-inline { dangerouslySetInnerHTML: { __html: @props.html } }
    | _        => div {}

Radical = React.createClass do
  render: ->
    {terms, id, h} = @props
    id -= /^[@=]/
    if id is /\S/
      title = h1-name {}, "#id ", a { className: \xref, href: \#, title: \部首表 }, \部
    else
      h += '@'
      title = h1-name {}, \部首表
    rows = $.parseJSON terms
    list = []
    for chars, strokes in rows | chars?length
      chs = []
      for ch in chars
        chs ++= a { className: \stroke-char, href: "#h#ch" }, ch
        chs ++= ' '
      list ++= span { className: \stroke-count }, strokes
      list ++= span { className: \stroke-list }, chs
      list ++= hr { style: { margin: 0, padding: 0, height: 0 } }
    return div-inline {}, title, div { className: \list }, ...list

List = React.createClass do
  render: ->
    {terms, id, h, lru} = @props
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
          '\u00B7', a { href: "#h#it" } it

    if terms is /^";/
      re = /";([^;"]+);([^;"]+)"[^"]*/g
      list ++= table {},
        tr {}, ...for it in <[ 臺 陸 ]>
          th { width: 200 }, span { className: \part-of-speech } it
        ...while t = re.exec(terms)
          tr { style: { borderTop: '1px solid #ccc' } },
            ...for it in [ t.1, t.2 ]
              td {}, a { href: "#h#it" } it
    else
      list ++= str-to-list terms

    if id is \字詞紀錄簿 and lru
      re = /"([^"]+)"[^"]*/g
      list ++= do
        br {}
        h3 { id: \lru }, \最近查閱過的字詞, input {
          id: \btn-clear-lru, type: \button, className: 'btn-default btn btn-tiny'
          value: \清除, style: { marginLeft: \10px }
        }
      list ++= str-to-list lru
    return div-inline {}, ...list

$ ->
  React{}.View.Result = Result
  React.View.result = React.renderComponent Result!, $(\#result).0
