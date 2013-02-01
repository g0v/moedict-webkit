@do-load = ->
  $(window).on \hashchange -> grok-hash!

  init = ->
    fetch 18979 unless grok-hash!
    $ \#query .keyup lookup .change lookup .keypress lookup .keydown lookup .on \input lookup
    $ \#query .on \focus -> @select!
    $ \#query .show!.focus!
    $ \a .live \click ->
      fill-query $(@).text!
      return false

  grok-hash = ->
    return false unless location.hash is /^#./
    try
      val = decodeURIComponent location.hash.substr 1
      return true if val is prevVal
      $ \#query .show!.focus!
      fill-query val
      return true
    return false

  fill-query = ->
    try
      $ \#query .val it
      unless navigator.userAgent is /Android|iPhone|iPad|Mobile/
        $ \#query .focus!
        $ \#query .get 0 .select!
      lookup!
      return true
    return false

  prevId = prevVal = titleToId = titleRegex = charRegex = null

  lookup = ->
    val = $ \#query .val!
    return true if prevVal is val
    prevVal := val
    id = titleToId[val]
    return true if prevId is id or not id
    prevId := id
    try history.pushState null, null, "##val" unless "#{location.hash}" is "##val"
    fetch id
    return true

  fetch = ->
    html <- $.get "data/#{ it % 100 }/#it.html"
    $ \#result .html (for chunk in html.split(//(</?div>)//)
      chunk.replace do
        if chunk is /<h1/ then charRegex else titleRegex
        -> """<a href="##it">#it</a>"""
    ) * ""

  <- setTimeout _, 1ms

  data <- $.get \options.html

  titleToId := JSON.parse "#{
    data.replace(/<option value=/g \,)
        .replace(/ (?:data-)?id=/g \:)
        .replace(/ \/>/g           '')
        .replace(/,/               \{)
  }}"

  titles = [k.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&") for k of titleToId]
  titles.sort (a, b) -> b.length - a.length
  titleRegex := new RegExp((titles * \|), \g)

  chars = [ re for re in titles | re.length is 1 ]
  charRegex := new RegExp((chars * \|), \g)

  if navigator.userAgent is /Chrome/ and navigator.userAgent isnt /Android/
    $ \#toc .html data

  init!
