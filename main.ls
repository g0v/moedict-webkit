@do-load = ->
  $(window).on \hashchange -> grok-hash!

  init = ->
    fetch 18979 unless grok-hash!
    $ \#query .keyup lookup .change lookup .keypress lookup .keydown lookup .on \input lookup
    $ \#query .show!.focus!

  grok-hash = ->
    return false unless location.hash is /^#./
    try
      $ \#query .val decodeURIComponent location.hash.substr 1
      $ \#query .show!.focus!
      $ \#query .get 0 .select!
      lookup!
      return true
    return false

  prevId = prevVal = titleToId = null

  lookup = ->
    val = $ \#query .val!
    return true if prevVal is val
    prevVal := val
    id = titleToId[val]
    return true if prevId is id or not id
    prevId := id
    try history.pushState null, null, "##val"
    fetch id
    return true

  fetch = ->
    $ \#result .load "data/#{ it % 100 }/#it.html"

  <- setTimeout _, 1ms

  data <- $.get \options.html

  titleToId := JSON.parse "#{
    data.replace(/<option value=/g \,)
        .replace(/ (?:data-)?id=/g \:)
        .replace(/ \/>/g           '')
        .replace(/,/               \{)
  }}"

  if navigator.userAgent is /Chrome/ and navigator.userAgent isnt /Android/
    $ \#toc .html data

  init!
