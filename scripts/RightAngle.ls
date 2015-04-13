React = require \react

createClass = React.createFactory << React.createClass
module.exports = createClass do
  render: ->
    __html = """
      <hruby class="rightangle" rightangle="rightangle">#{
        ruby2hruby @props.html
      }</hruby>
    """
    React.createElement \span dangerouslySetInnerHTML: { __html }

# Algorithm and constants below are derived from
#   Han.css: the CSS typography framework optimised for Hanzi.
#   https://github.com/ethantw/Han
# Copyright (c) 2015 Chen Yijun (陳奕鈞，http://yijun.me/)
# MIT license: https://github.com/ethantw/Han/blob/master/LICENSE.md

const UNICODE = zhuyin: {
  base:    '[\u3105-\u312D\u31A0-\u31BA]',
  initial: '[\u3105-\u3119\u312A-\u312C\u31A0-\u31A3]',
  medial:  '[\u3127-\u3129]',
  final:   '[\u311A-\u3129\u312D\u31A4-\u31B3\u31B8-\u31BA]',
  tone:    '[\u02D9\u02CA\u02C5\u02C7\u02CB\u02EA\u02EB]',
  ruyun:   '[\u31B4-\u31B7][\u0358\u030d]?'
}
rZyS = UNICODE.zhuyin.initial
rZyJ = UNICODE.zhuyin.medial
rZyY = UNICODE.zhuyin.final
rZyD = UNICODE.zhuyin.tone + '|' + UNICODE.zhuyin.ruyun

const TYPESET = zhuyin: {
    form: new RegExp( '^\u02D9?(' + rZyS + ')?(' + rZyJ + ')?(' + rZyY + ')?(' + rZyD + ')?$' ),
    diao: new RegExp( '(' + rZyD + ')', 'g' )
}

ruby2hruby = (html) ->
  $ = require('cheerio').load("<ruby class='rightangle'>#html</ruby>")
  $rbs = $('rb')
  maxspan = $rbs.length
  $rus = []
  $('rtc.zhuyin').each (_, e) ->
    i, rt <- $(e).find('rt').each
    return unless $rbs[i]
    $rb = $($rbs[i]).clone!
    $rt = $(rt)
    $ru     = $( '<ru/>' )
    $zhuyin = $( '<zhuyin/>' )
    $yin    = $( '<yin/>' )
    $diao   = $( '<diao/>' )
    zhuyin = $rt.text!
    yin  = zhuyin.replace( TYPESET.zhuyin.diao, '' )
    len  = if yin then yin.length else 0
    diao = zhuyin.replace( yin, '' )
      .replace( /[\u02C5]/g, '\u02C7' )
      .replace( /[\u030D]/g, '\u0358' )
    form = zhuyin.replace TYPESET.zhuyin.form, ( s, j, y ) -> [
      if s then 'S' else null,
      if j then 'J' else null,
      if y then 'Y' else null
    ].join('')
    $diao.html diao
    $yin.html yin
    $zhuyin.append $yin
    $zhuyin.append $diao
    $ru.append $rb
    $ru.append $zhuyin
    $ru.attr \zhuyin ''
    $ru.attr \diao diao
    $ru.attr \length len
    $ru.attr \form form
    $($rbs[i]).replaceWith $ru
    $rus.push $ru
  $('rtc.zhuyin').remove()
  spans = []
  $('rtc').each (order, e) ->
    i, rt <- $(e).find('rt').each
    if order is 0
      aRb = []
      rbspan = Number( $(rt).attr( 'rbspan' ) || 1 ) <? maxspan
      span = 0
      while rbspan > span
        rb = $rus.shift!
        aRb.push rb
        break unless rb?
        span += Number( $(rb).attr('span') || 1)
      if rbspan < span
        return if aRb.length > 1
        aRb = $(aRb[0]).find('rb').get()
        $ru = aRb.slice( rbspan ).concat( $ru )
        aRb = aRb.slice( 0, rbspan )
        span = rbspan
      spans[i] = span
    else
      span = spans[i]
      aRb = [$('ru[order=0]').eq(i)]
    $ru = $('<ru/>')
    $rt = $(rt).clone()
    $ru.html aRb.map((rb) ->
      return '' unless rb?
      return $.html(rb)
    ).join('')
    $ru.append $rt
    $ru.attr \span span
    $ru.attr \order order
    $ru.attr \class $('ruby').attr \class
    $ru.attr \annotation do
      $rt.text()
        .replace(/\u0061[\u030d\u0358]/g '\uDB80\uDC61')
        .replace(/\u0065[\u030d\u0358]/g '\uDB80\uDC65')
        .replace(/\u0069[\u030d\u0358]/g '\uDB80\uDC69')
        .replace(/\u006F[\u030d\u0358]/g '\uDB80\uDC6F')
        .replace(/\u0075[\u030d\u0358]/g '\uDB80\uDC75')
    $(aRb.shift!).replaceWith($ru)
    for x in aRb => $(x).remove!
  $('rtc').remove()
  $('rt').attr \style 'text-indent: -9999px; color: transparent'
  return $('ruby').html().replace(
    /&#x([0-9a-fA-F]+);/g (_, _1) -> String.fromCharCode parseInt(_1, 16)
  )
