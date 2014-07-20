{p, i, a, h1, div, main, span, br, h3, table, tr, td, th, input} = React.DOM

inline = (props = {}, ...args) ->
  div ({ style: { display: \inline } } <<< props), ...args

Result = React.createClass render: ->
  switch @props.type
  | \list => List @props
  | \html => inline { dangerouslySetInnerHTML: { __html: @props.html } }
  | _     => div {}

List = React.createClass do
  render: ->
    {terms, id, h, lru} = @props
    return div {} unless terms

    id -= /^[@=]/
    terms -= /^[^"]*/
    list = [ h1 { itemProp: \name } id ]

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
    return inline {}, ...list

$ ->
  React{}.View.result = React.renderComponent Result!, $(\#result).0
