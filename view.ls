{p, a, h1, div, main, span} = React.DOM

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
    title = h1 { itemProp: \name } id
    terms -= /^[^"]*/
    if id is \字詞紀錄簿
      terms += "<p class='bg-info'>（請按詞條右方的 <i class='icon-star-empty'></i> 按鈕，即可將字詞加到這裡。）</p>" unless terms
    if terms is /^";/
      terms = "<table border=1 bordercolor=\#ccc><tr><td><span class='part-of-speech'>臺</span></td><td><span class='part-of-speech'>陸</span></td></tr>#terms</table>"
      terms.=replace /";([^;"]+);([^;"]+)"[^"]*/g """<tr><td><a href=\"#{h}$1\">$1</a></td><td><a href=\"#{h}$2\">$2</a></td></tr>"""
    else if id is \字詞紀錄簿
      terms.=replace(/"([^"]+)"[^"]*/g "<span style='clear: both; display: block'>\u00B7 <a href=\"#{h}$1\">$1</a></span>")
    else
      re = /"([^"]+)"[^"]*/g
      list = while t = re.exec(terms)
        t = t.1
        span { style: { clear: \both display: \block visibility: \visible } },
          '\u00B7', a { href: "#h#t" } t
      return inline {}, ...[title, ...list]
    if id is \字詞紀錄簿 and lru
      terms += "<br><h3 id='lru'>最近查閱過的字詞"
      terms += "<input type='button' id='btn-clear-lru' class='btn-default btn btn-tiny' value='清除' style='margin-left: 10px'>"
      terms += "</h3>\n"
      terms += lru.replace(/"([^"]+)"[^"]*/g "<span style='clear: both; display: block'>\u00B7 <a href=\"#{h}$1\">$1</a></span>")
    return inline {}, title, div { dangerouslySetInnerHTML: { __html: terms } }

$ ->
  React{}.View.result = React.renderComponent Result!, $(\#result).0
