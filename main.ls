@do-load = ->
  $(window).on \hashchange -> grok-hash!

  init = ->
    fetch 18979 unless grok-hash!
    $ \#query .keyup lookup .change lookup .keypress lookup .keydown lookup .on \input lookup
    $ \#query .show!.focus!
    $ \a .live \click ->
      fill-query $(@).text!
      return false

  grok-hash = ->
    return false unless location.hash is /^#./
    return true if fill-query decodeURIComponent location.hash.substr 1
    return false

  fill-query = ->
    try
      $ \#query .val it
      $ \#query .show!.focus!
      $ \#query .get 0 .select!
      lookup!
      return true
    return false

  prevId = prevVal = titleToId = titleRegex = null

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
    $ \#result .html html.replace titleRegex, -> """
      <a href="#">#it</a>
    """

  <- setTimeout _, 1ms

  data <- $.get \options.html

  titleToId := JSON.parse "#{
    data.replace(/<option value=/g \,)
        .replace(/ (?:data-)?id=/g \:)
        .replace(/ \/>/g           '')
        .replace(/,/               \{)
  }}"

  titleRegex := [k.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&") for k of titleToId]
  titleRegex.sort (a, b) -> b.length - a.length
  titleRegex := new RegExp((titleRegex * \|), \g)

  if navigator.userAgent is /Chrome/ and navigator.userAgent isnt /Android/
    $ \#toc .html data

  init!
