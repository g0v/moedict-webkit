
/*! 
 * HanJS v3.0.0-alpha
 * css.hanzi.co/hanjs
 *
 * License under MIT License
 */

;(function($){

var rubies,

	_test_for_ruby = function() {
		if ( rubies != null )
			return rubies

		var ruby = document.createElement('ruby'),
			rt = document.createElement('rt'),
			rp = document.createElement('rp'),
			docElement = document.documentElement,
			displayStyleProperty = 'display'

		ruby.appendChild(rp)
		ruby.appendChild(rt)
		docElement.appendChild(ruby)

		// browsers that support <ruby> hide the <rp> via "display:none"
		rubies = ( _getStyle(rp, displayStyleProperty) == 'none' ||
			// but in IE browsers <rp> has "display:inline" so, the test needs other conditions:
			_getStyle(ruby, displayStyleProperty) == 'ruby'
			&& _getStyle(rt, displayStyleProperty) == 'ruby-text' ) ? true : false


		docElement.removeChild(ruby)
		// the removed child node still exists in memory, so ...
		ruby = null
		rt = null
		rp = null

		return rubies

		function _getStyle( element, styleProperty ) {
			var result

			if ( window.getComputedStyle )	 // for non-IE browsers
				result = document.defaultView.getComputedStyle(element,null).getPropertyValue(styleProperty)
			else if ( element.currentStyle )   // for IE
				result = element.currentStyle[styleProperty]

			return result
		}
	},


	/**
	 *
	 * Unicode區段說明（6.2.0）
	 * Unicode blocks 6.2.0
	 *
	 * 或參考：
	 * http://css.hanzi.co/manual/api/javascript_jiekou-han.unicode
	 * --------------------------------------------------------
	 *
	 ** 以下歸類為「拉丁字母」（`unicode('latin')`）**
	 *
	 * 基本拉丁字母：a-z
	 * 阿拉伯數字：0-9
	 * 拉丁字母補充-1：[\u00C0-\u00FF]
	 * 拉丁字母擴展-A區：[\u0100-\u017F]
	 * 拉丁字母擴展-B區：[\u0180-\u024F]
	 * 拉丁字母附加區：[\u1E00-\u1EFF]
	 *
	 ** 符號：[~!@#&=_\$\%\^\*\-\+\,\.\/(\\)\?\:\'\"\[\]\(\)'"<>‘“”’]
	 *
	 * --------------------------------------------------------
	 *
	 ** 以下歸類為「漢字」（`unicode（'hanzi')`）**
	 *
	 * CJK一般：[\u4E00-\u9FFF]
	 * CJK擴展-A區：[\u3400-\u4DB5]
	 * CJK擴展-B區：[\u20000-\u2A6D6]
	 * CJK Unicode 4.1：[\u9FA6-\u9FBB]、[\uFA70-\uFAD9]
	 * CJK Unicode 5.1：[\u9FBC-\u9FC3]
	 * CJK擴展-C區：[\u2A700-\u2B734]
	 * CJK擴展-D區：[\u2B740-\u2B81D]（急用漢字）
	 * CJK擴展-E區：[\u2B820-\u2F7FF]（**註**：暫未支援）
	 * CJK擴展-F區（**註**：暫未支援）
	 * CJK筆畫區：[\u31C0-\u31E3]
	 * 數字「〇」：[\u3007]
	 * 日文假名：[\u3040-\u309E][\u30A1-\u30FA][\u30FD\u30FE]（**註**：排除片假名中點、長音符）
	 *
	 * CJK相容表意文字：
	 * [\uF900-\uFAFF]（**註**：不使用）
	 * [\uFA0E-\uFA0F\uFA11\uFA13-\uFA14\uFA1F\uFA21\uFA23-\uFA24\uFA27-\uFA29]（**註**：12個例外）
	 * --------------------------------------------------------
	 *
	 ** 符號
	 * [·・︰、，。：；？！—⋯…．·「『（〔【《〈“‘」』）〕】》〉’”–ー—]
	 *
	 ** 其他
	 *
	 * 漢語注音符號、擴充：[\u3105-\u312D][\u31A0-\u31BA]
	 * 國語五聲調（三聲有二種符號）：[\u02D9\u02CA\u02C5\u02C7\u02CB]
	 * 台灣漢語方言音擴充聲調：[\u02EA\u02EB]
	 *
	 */
	unicode = {
		latin: {
			alphabet: 	'[A-Za-z0-9\u00C0-\u00FF\u0100-\u017F\u0180-\u024F\u1E00-\u1EFF]',
			word: 		'[A-Za-z0-9\u00C0-\u00FF\u0100-\u017F\u0180-\u024F\u1E00-\u1EFF\(\\[\'"‘“@&;=_\,\.\?\!\$\%\^\*\-\+\/\)\\]\'"”’]',
			group: 		'[A-Za-z0-9\u00C0-\u00FF\u0100-\u017F\u0180-\u024F\u1E00-\u1EFF\(\\[\'"‘“@&;=_\,\.\?\!\$\%\^\*\-\+\/\)\\]\'"”’\s]'
		},

		punct: {
			all: 	'[\(\\[\'"‘“@&;=_\,\.\?\!\$\%\^\*\-\+\/\)\\]\'"”’]',

			open: 	'[\(\\[\'"‘“]',
			close: 	'[@&;=_\,\.\?\!\$\%\^\*\-\+\/\)\\]\'"”’]',
			pause: 	'[@&;=_\,\.\?\!\$\%\^\*\-\+\/]',

			quote: {
				all: '[\(\\[\'"‘“\)\\]\'”’]',
				open: '[\(\\[\'"‘“]',
				close: '[\)\\]\'”’]'
			}
		},

		hanzi: {
			zi: '[\u4E00-\u9FFF\u3400-\u4DB5\u9FA6-\u9FBB\uFA70-\uFAD9\u9FBC-\u9FC3\u3007\u3040-\u309E\u30A1-\u30FA\u30FD\u30FE\u31C0-\u31E3]|[\uD840-\uD868][\uDC00-\uDFFF]|\uD869[\uDC00-\uDEDF]|\uD86D[\uDC00-\uDF3F]|[\uD86A-\uD86C][\uDC00-\uDFFF]|\uD869[\uDF00-\uDFFF]|\uD86D[\uDF40-\uDFFF]|\uD86E[\uDC00-\uDC1F]',
			group: '[\u4E00-\u9FFF\u3400-\u4DB5\u9FA6-\u9FBB\uFA70-\uFAD9\u9FBC-\u9FC3\u3007\u3040-\u309E\u30A1-\u30FA\u30FD\u30FE\u31C0-\u31E3]|[\uD840-\uD868][\uDC00-\uDFFF]|\uD869[\uDC00-\uDEDF]|\uD86D[\uDC00-\uDF3F]|[\uD86A-\uD86C][\uDC00-\uDFFF]|\uD869[\uDF00-\uDFFF]|\uD86D[\uDF40-\uDFFF]|\uD86E[\uDC00-\uDC1F]|[「『（〔【《〈“‘·・︰、，。：；？！—ー⋯…．·／」』）〕】》〉’”　\s]'
		},

		biaodian: {
			all: 	'[「『（〔【《〈“‘·・︰、，。：；？！—ー⋯…．·／」』）〕】》〉’”]',

			open: 	'[「『（〔【《〈“‘]',
			close: 	'[·・︰、，。：；？！—ー⋯…．·／」』）〕】》〉’”]',
			dian: 	'[·・︰、，。：；？！—ー⋯…．·／]',

			quote: {
				all: '[「『（〔【《〈“‘」』）〕】》〉’”]',
				open: '[「『（〔【《〈“‘]',
				close: '[」』）〕】》〉’”]'
			}
		},

		zhuyin: {
			all: '[\u3105-\u312D\u31A0-\u31BA]',

			shengmu: '[\u3105-\u3119\u312A-\u312C\u31A0-\u31A3]',
			jieyin: '[\u3127-\u3129]',
			yunmu: '[\u311A-\u3126\u312D\u31A4-\u31B3\u31B8-\u31BA]',
			yunjiao: '[\u31B4-\u31B7]',
			diao: '[\u02D9\u02CA\u02C5\u02C7\u02CB\u02EA\u02EB]'
		}
	},


	_elem = function( elem, className ) {
		var elem = document.createElement(elem)

		if ( className )
			elem.className = className

		return elem
	},


	_apply_ruby_annotation = function( node ) {
		$(node).find('rbc').find('rb')
		.each(function(i){
			$(this).attr('index', i)
		})

		$(node).find('rtc:not(.zhuyin)')
		.hide()
		.each(function(t){
			var c = 0,
				rtc = $(this),
				rbc = $(this).prevAll('rbc'),
				len = $(this).find('rt').length,
				data = []

			$(this).find('rt')
			.each(function(h){
				var anno 	= $(this).html(),
					rbspan 	= $(this).attr('rbspan') || 1,
					i		= c

				c += Number(rbspan)

				data[h] = {
					'annotation': anno,
					'order': (t==0) ? '1' : '2'
				}

				for ( var j=i; j<c; j++ ) {
					rbc.find('rb[index]')
					.eq(j).attr({ 'set': h })
				}
			})

			rbc.find('rb[annotation]')
			.each(function(){
				var rb = $(this).find('rb[index]'),
					first = rb.filter(':first-child').attr('set'),
					last = rb.filter(':last-child').attr('set')

				if ( first === last ) {
					rb.removeAttr('set')
					$(this).attr('set', first)
				}
			})

			for ( var k=0; k<len; k++ ) {
				rbc
				.find('rb[set='+ k +']')
				.wrapAll(
					$('<rb/>')
					.attr( data[k] )
				)
			}
		})

		$(node).find('rb')
		//.after(' ')
		.removeAttr('set index')
		.filter('rb[annotation]')
		.each(function(){
			var t = $(this).attr('annotation')
			$(this).after( $(_elem('copy')).html( t ) )
		})
	},


	_apply_ruby_zhuyin = function( node, rb ) {
		var sm 		= unicode.zhuyin.shengmu,
			jy 		= unicode.zhuyin.jieyin,
			ym 		= unicode.zhuyin.yunmu,
			yj 		= unicode.zhuyin.yunjiao,
			tone 	= unicode.zhuyin.diao,

			prev, text, zi,
			zy = $(node).html(),
			yin, diao, form, length, data

		form = 	( zy.match(eval('/(' + sm + ')/')) ) ? 'shengmu' : ''
		form += ( zy.match(eval('/(' + jy + ')/')) ) ? (( form !== '' ) ? '-' : '') + 'jieyin' : ''
		form += ( zy.match(eval('/(' + ym + ')/')) ) ? (( form !== '' ) ? '-' : '') + 'yunmu' : ''

		yin = zy
			.replace(eval('/(' + tone + ')/g'), '')
			.replace(eval('/(' + yj + '[\u0358\u030D]?)/g'), '')

		length = (yin) ? yin.length : 0

		diao = 	( zy.match(/(\u02D9)/) )					? '\u02D9' : 
				( zy.match(/(\u02CA)/) )					? '\u02CA' : 
				( zy.match(/([\u02C5\u02C7])/) )			? '\u02C7' :
				( zy.match(/(\u02CB)/) )					? '\u02CB' : 
				( zy.match(/(\u02EA)/) )					? '\u02EA' : 
				( zy.match(/(\u02EB)/) )					? '\u02EB' : 
				( zy.match(/(\u31B4[\u0358\u030D]?)/) )		? '\u31B4\u030D' : 
				( zy.match(/(\u31B5[\u0358\u030D]?)/) )		? '\u31B5\u030D' :
				( zy.match(/(\u31B6[\u0358\u030D]?)/) )		? '\u31B6\u030D' :
				( zy.match(/(\u31B7[\u0358\u030D]?)/) )		? '\u31B7\u030D' :
				( zy.match(/(\u31B4)/) )					? '\u31B4' : 
				( zy.match(/(\u31B5)/) )					? '\u31B5' :
				( zy.match(/(\u31B6)/) )					? '\u31B6' :
				( zy.match(/(\u31B7)/) )					? '\u31B7' : ''

		data = {
			'zhuyin': zy,
			'yin': yin,
			'diao': diao,
			'length': length,
			'form': form
		}

		if ( rb )
			rb
			.attr(data)
			.append( $(_elem('copy')).html( zy ) )
		else {
			prev = node.previousSibling
			text = prev.nodeValue.split('')
			zi = text.pop()
			prev.nodeValue = text.join('')

			$(node)
			.before( 
				$('<rb/>')
				.attr(data)
				.text( zi )
			)
			//.after( ' ' )
			.replaceWith( $(_elem('copy')).html( zy ) )
		}
	},


	/**
	 * 判斷並取得指定節點之通用字體族
	 * Get the generic font family of designated nodes
	 *
	 */
	_get_generic_family = function( node ) {
		var reg = /(sans-serif|monospace)$/,
			generic = $(node).css('font-family'),
        	font = generic.match(reg) ? 'sans-serif' : 'serif'

		return font
	}


	$.fn.extend({
		ruby: function() {
			return this.each(function(){
				// 語義類別簡化
				$(this).find('ruby, rtc').filter('.pinyin').addClass('romanization')
				$(this).find('ruby, rtc').filter('.mps').addClass('zhuyin')
				$(this).find('ruby, rtc').filter('.romanization').addClass('annotation')

				$(this).find('ruby').each(function() {
					var html = $(this).html(),
						hruby = document.createElement('hruby')

					// 羅馬拼音（在不支援`<ruby>`的瀏覽器下）
					if ( !_test_for_ruby() && 
						 !$(this).hasClass('complex') &&
						 !$(this).hasClass('zhuyin') &&
						 !$(this).hasClass('rightangle') ) {

						// 將拼音轉為元素屬性以便CSS產生偽類
						$(this)
						.find('rt')
						.each(function(){
							var anno = $(this).html(),
								prev = this.previousSibling,
								text = prev.nodeValue

							prev.nodeValue = ''

							$(prev).before(
								 $('<rb/>')
								.html( text )
								.attr('annotation', anno)
								.replaceWith(_elem('copy'))
							)

							$(this).replaceWith(
								$(_elem('copy')).html(anno)
							)
						})

						$(this)
						.replaceWith(
							$(hruby)
							.html( $(this).html() )
						)

					} else {
						var attr = {}

						// 國語注音、台灣方言音符號
						if ( $(this).hasClass('zhuyin') ) {
							// 將注音轉為元素屬性以便CSS產生偽類
							$(this).find('rt')
							.each(function(){
								_apply_ruby_zhuyin(this)
							})

						// 雙行文字註記
						} else if ( $(this).hasClass('complex') ) {
							attr.complex = 'complex'

							_apply_ruby_annotation(this)
							

						// 拼音、注音直角顯示
						} else if ( $(this).hasClass('rightangle') ) {
							attr.rightangle = 'rightangle'

							// 國語注音、台灣方言音符號
							$(this).find('rtc.zhuyin')
							.hide()
							.each(function(){
								var t = $(this).prevAll('rbc'),
									c, len, data

								$(this).find('rt')
								.each(function(i){
									var rb = t.find('rb:not([annotation])').eq(i)
									_apply_ruby_zhuyin(this, rb)
								})
							})

							// 羅馬拼音或文字註記
							_apply_ruby_annotation(this)
						}

						// 以`<hruby>`元素替代`<ruby>`，避免UA原生樣式的干擾
						$(this).filter(function(){
							return $(this).hasClass("zhuyin") ||
								   $(this).hasClass("complex") ||
								   $(this).hasClass("rightangle")
						}).replaceWith(
							$(hruby)
							.html( $(this).html() )
							//.attr('generic', _get_generic_family(this))
							.attr(attr)
						)
					}
				})
			})
		}
	})
})(jQuery)

