(function(){
  var DEBUGGING, MOEID, isCordova, isDeviceReady, isMobile, entryHistory, Index, e, callLater, MOE, replace$ = ''.replace, slice$ = [].slice;
  DEBUGGING = false;
  MOEID = "萌";
  isCordova = !/^https?:/.test(document.URL);
  isDeviceReady = !isCordova;
  if (DEBUGGING) {
    isCordova = true;
  }
  isMobile = isCordova || /Android|iPhone|iPad|Mobile/.exec(navigator.userAgent);
  entryHistory = [];
  Index = null;
  try {
    if (!(isCordova && !DEBUGGING)) {
      throw null;
    }
    document.addEventListener('deviceready', function(){
      try {
        navigator.splashscreen.hide();
      } catch (e$) {}
      isDeviceReady = true;
      return window.doLoad();
    }, false);
  } catch (e$) {
    e = e$;
    $(function(){
      var url;
      $('#F9868').html('&#xF9868;');
      $('#loading').text('載入中，請稍候…');
      if (/http:\/\/(?:www.)?moedict.tw/i.exec(document.URL)) {
        url = "https://www.moedict.tw/";
        if (/^#./.exec(location.hash)) {
          url += location.hash;
        }
        return location.replace(url);
      } else {
        window.doLoad();
        if (/MSIE\s+[678]/.exec(navigator.userAgent)) {
          return $.getScript('https://ajax.googleapis.com/ajax/libs/chrome-frame/1/CFInstall.min.js', function(){
            window.gcfnConfig = {
              imgpath: 'https://raw.github.com/atomantic/jquery.ChromeFrameNotify/master/img/',
              msgPre: '',
              msgLink: '敬請安裝 Google 內嵌瀏覽框，以取得更完整的萌典功能。',
              msgAfter: ''
            };
            return $.getScript('https://raw.github.com/atomantic/jquery.ChromeFrameNotify/master/jquery.gcnotify.min.js', function(){});
          });
        }
      }
    });
  }
  window.showInfo = function(){
    var ref, onStop, onExit;
    ref = window.open('Android.html', '_blank', 'location=no');
    onStop = function(arg$){
      var url;
      url = arg$.url;
      if (/quit\.html/.exec(url)) {
        return ref.close();
      }
    };
    onExit = function(){
      ref.removeEventListener('loadstop', onStop);
      return ref.removeEventListener('exit', onExit);
    };
    ref.addEventListener('loadstop', onStop);
    return ref.addEventListener('exit', onExit);
  };
  callLater = function(it){
    return setTimeout(it, isMobile ? 10 : 1);
  };
  window.doLoad = function(){
    var cacheLoading, pressBack, init, grokHash, fillQuery, prevId, prevVal, lenToRegex, bucketOf, lookup, doLookup, htmlCache, fetch, loadJson, setHtml, loadCacheHtml, fillJson, bucketCache, keyMap, fillBucket;
    if (!isDeviceReady) {
      return;
    }
    if (isCordova) {
      $('body').addClass('cordova');
    }
    if (!isCordova) {
      $('body').addClass('web');
    }
    if (isCordova && !/android_asset/.test(location.href)) {
      $('body').addClass('ios');
    }
    cacheLoading = false;
    window.pressBack = pressBack = function(){
      var token;
      if (cacheLoading) {
        return;
      }
      entryHistory.pop();
      token = Math.random();
      cacheLoading = token;
      setTimeout(function(){
        if (cacheLoading === token) {
          return cacheLoading = false;
        }
      }, 10000);
      callLater(function(){
        var id;
        id = entryHistory.length ? entryHistory[entryHistory.length - 1] : MOEID;
        $('#query').val(id);
        $('#cond').val("^" + id + "$");
        return fetch(id);
      });
      return false;
    };
    try {
      document.addEventListener('backbutton', pressBack, false);
    } catch (e$) {}
    init = function(){
      $('#query').keyup(lookup).change(lookup).keypress(lookup).keydown(lookup).on('input', lookup);
      $('#query').on('focus', function(){
        return this.select();
      });
      $('#query').show().focus();
      if (!in$('onhashchange', window)) {
        $('body').on('click', 'a', function(){
          var val;
          val = $(this).attr('href');
          if (val) {
            val = replace$.call(val, /.*\#/, '');
          }
          val || (val = $(this).text());
          if (val === $('#query').val()) {
            return;
          }
          $('#query').val(val);
          $('#cond').val("^" + val + "$");
          fillQuery(val);
          return false;
        });
      }
      if (window.grokHash()) {
        return;
      }
      if (isCordova) {
        fillQuery(MOEID);
        return $('#query').val('');
      } else {
        return fetch(MOEID);
      }
    };
    window.grokHash = grokHash = function(){
      var val;
      if (!/^#./.test(location.hash)) {
        return false;
      }
      try {
        val = decodeURIComponent(location.hash.substr(1));
        if (val === prevVal) {
          return true;
        }
        $('#query').show();
        fillQuery(val);
        if (val === prevVal) {
          return true;
        }
      } catch (e$) {}
      return false;
    };
    window.fillQuery = fillQuery = function(it){
      var title, input;
      title = replace$.call(decodeURIComponent(it), /[（(].*/, '');
      $('#query').val(title);
      $('#cond').val("^" + title + "$");
      input = $('#query').get(0);
      if (isMobile) {
        try {
          $('#query').autocomplete('close');
        } catch (e$) {}
      } else {
        input.focus();
        try {
          input.select();
        } catch (e$) {}
      }
      lookup(title);
      return true;
    };
    prevId = prevVal = null;
    lenToRegex = {};
    bucketOf = function(it){
      var code;
      code = it.charCodeAt(0);
      if (0xD800 <= code && code <= 0xDBFF) {
        code = it.charCodeAt(1) - 0xDC00;
      }
      return code % 1024;
    };
    lookup = function(){
      return doLookup($('#query').val());
    };
    window.doLookup = doLookup = function(val){
      var title, id;
      title = replace$.call(val, /[（(].*/, '');
      if (isCordova || !Index) {
        if (/object/.exec(title)) {
          return;
        }
        if (Index && Index.indexOf("\"" + title + "\"") === -1) {
          return true;
        }
        id = title;
      } else {
        if (prevVal === val) {
          return true;
        }
        prevVal = val;
        if (!(Index.indexOf("\"" + title + "\"") >= 0)) {
          return true;
        }
        id = title;
      }
      if (prevId === id || replace$.call(id, /\(.*/, '') !== replace$.call(val, /\(.*/, '')) {
        return true;
      }
      $('#cond').val("^" + title + "$");
      entryHistory.push(title);
      if (isCordova) {
        $('.back').show();
      }
      fetch(title);
      return true;
    };
    htmlCache = {};
    fetch = function(it){
      if (!it) {
        return;
      }
      prevId = it;
      prevVal = it;
      try {
        if (location.hash + "" !== "#" + it) {
          history.pushState(null, null, "#" + it);
        }
      } catch (e$) {}
      if (isMobile) {
        $('#result div, #result span, #result h1:not(:first)').hide();
        $('#result h1:first').text(it).show();
      } else {
        $('#result div, #result span, #result h1:not(:first)').css('visibility', 'hidden');
        $('#result h1:first').text(it).css('visibility', 'visible');
        window.scrollTo(0, 0);
      }
      if (loadCacheHtml(it)) {
        return;
      }
      if (it === MOEID) {
        return fillJson(MOE);
      }
      return loadJson(it);
    };
    loadJson = function(id, cb){
      var bucket;
      if (!isCordova) {
        return $.get("a/" + encodeURIComponent(replace$.call(id, /\(.*/, '')) + ".json", null, function(it){
          return fillJson(it, id, cb);
        }, 'text');
      }
      bucket = bucketOf(id);
      if (bucketCache[bucket]) {
        return fillBucket(id, bucket);
      }
      return $.get("pack/" + bucket + ".txt", function(json){
        bucketCache[bucket] = json;
        return fillBucket(id, bucket);
      });
    };
    setHtml = function(html){
      return callLater(function(){
        $('#result').html(html);
        $('#result .part-of-speech a').attr('href', null);
        cacheLoading = false;
        if (isCordova) {
          return;
        }
        $('#result a[href]').tooltip({
          disabled: true,
          show: 100,
          hide: 100,
          items: 'a',
          content: function(cb){
            var id;
            id = $(this).text();
            callLater(function(){
              if (htmlCache[id]) {
                cb(htmlCache[id]);
                return;
              }
              return loadJson(id, function(it){
                return cb(it);
              });
            });
          }
        });
        return $('#result a[href]').hoverIntent({
          timeout: 250,
          over: function(){
            return $(this).tooltip('open');
          },
          out: function(){
            return $(this).tooltip('close');
          }
        });
      });
    };
    loadCacheHtml = function(it){
      var html;
      html = htmlCache[it];
      if (!html) {
        return false;
      }
      setHtml(html);
      return true;
    };
    fillJson = function(part, id, cb){
      var html;
      cb == null && (cb = setHtml);
      while (/"`辨~\u20DE&nbsp`似~\u20DE"[^}]*},{"f":"([^（]+)[^"]*"/.exec(part)) {
        part = part.replace(/"`辨~\u20DE&nbsp`似~\u20DE"[^}]*},{"f":"([^（]+)[^"]*"/, '"辨\u20DE 似\u20DE $1"');
      }
      part = part.replace(/"`(.)~\u20DE"[^}]*},{"f":"([^（]+)[^"]*"/g, '"$1\u20DE $2"');
      part = part.replace(/"([hbpdcnftrelsaq])"/g, function(arg$, k){
        return keyMap[k];
      });
      part = part.replace(/`([^~]+)~/g, function(arg$, word){
        return "<a href='#" + word + "'>" + word + "</a>";
      });
      if ((typeof JSON != 'undefined' && JSON !== null ? JSON.parse : void 8) != null) {
        html = render(JSON.parse(part));
      } else {
        html = eval("render(" + part + ")");
      }
      html = html.replace(/(.)\u20DE/g, "</span><span class='part-of-speech'>$1</span><span>");
      html = html.replace(RegExp('<a[^<]+>' + id + '<\\/a>', 'g'), id + "");
      html = html.replace(/<a>([^<]+)<\/a>/g, "<a href='#$1'>$1</a>");
      html = html.replace(RegExp('(>[^<]*)' + id, 'g'), "$1<b>" + id + "</b>");
      cb(htmlCache[id] = html);
    };
    bucketCache = {};
    keyMap = {
      h: '"heteronyms"',
      b: '"bopomofo"',
      p: '"pinyin"',
      d: '"definitions"',
      c: '"stroke_count"',
      n: '"non_radical_stroke_count"',
      f: '"def"',
      t: '"title"',
      r: '"radical"',
      e: '"example"',
      l: '"link"',
      s: '"synonyms"',
      a: '"antonyms"',
      q: '"quote"'
    };
    fillBucket = function(id, bucket){
      var raw, key, idx, part;
      raw = bucketCache[bucket];
      key = escape(id);
      idx = raw.indexOf('"' + key + '"');
      if (idx === -1) {
        return;
      }
      part = raw.slice(idx + key.length + 3);
      idx = part.indexOf('\n');
      part = part.slice(0, idx);
      return fillJson(part);
    };
    $.get("a/index.json", null, initAutocomplete, 'text');
    return init();
  };
  MOE = '{"h":[{"b":"ㄇㄥˊ","d":[{"f":"`草木~`初~`生~`的~`芽~。","q":["`說文解字~：「`萌~，`艸~`芽~`也~。」","`唐~．`韓愈~、`劉~`師~`服~、`侯~`喜~、`軒轅~`彌~`明~．`石~`鼎~`聯句~：「`秋~`瓜~`未~`落~`蒂~，`凍~`芋~`強~`抽~`萌~。」"],"type":"`名~"},{"f":"`事物~`發生~`的~`開端~`或~`徵兆~。","q":["`韓非子~．`說~`林~`上~：「`聖人~`見~`微~`以~`知~`萌~，`見~`端~`以~`知~`末~。」","`漢~．`蔡邕~．`對~`詔~`問~`灾~`異~`八~`事~：「`以~`杜漸防萌~，`則~`其~`救~`也~。」"],"type":"`名~"},{"f":"`人民~。","e":["`如~：「`萌黎~」、「`萌隸~」。"],"l":["`通~「`氓~」。"],"type":"`名~"},{"f":"`姓~。`如~`五代~`時~`蜀~`有~`萌~`慮~。","type":"`名~"},{"f":"`發芽~。","e":["`如~：「`萌芽~」。"],"q":["`楚辭~．`王~`逸~．`九思~．`傷~`時~：「`明~`風~`習習~`兮~`龢~`暖~，`百草~`萌~`兮~`華~`榮~。」"],"type":"`動~"},{"f":"`發生~。","e":["`如~：「`故態復萌~」。"],"q":["`管子~．`牧民~：「`惟~`有道~`者~，`能~`備~`患~`於~`未~`形~`也~，`故~`禍~`不~`萌~。」","`三國演義~．`第一~`回~：「`若~`萌~`異心~，`必~`獲~`惡報~。」"],"type":"`動~"}],"p":"méng"}],"n":8,"r":"`艸~","c":12,"t":"萌"}';
  function initAutocomplete(text){
    Index = text;
    $.widget("ui.autocomplete", $.ui.autocomplete, {
      _close: function(){
        return this.menu.element.addClass('invisible');
      },
      _resizeMenu: function(){
        var ul;
        ul = this.menu.element;
        ul.outerWidth(Math.max(ul.width("").outerWidth() + 1, this.element.outerWidth()));
        return ul.removeClass('invisible');
      },
      _value: function(it){
        if (it) {
          fillQuery(it);
        }
        return this.valueMethod.apply(this.element, arguments);
      }
    });
    return $('#query').autocomplete({
      position: {
        my: "left bottom",
        at: "left top"
      },
      select: function(e, arg$){
        var item;
        item = arg$.item;
        if (/^\(/.exec(item != null ? item.value : void 8)) {
          return false;
        }
        if (item != null && item.value) {
          fillQuery(item.value);
        }
        return true;
      },
      change: function(e, arg$){
        var item;
        item = arg$.item;
        if (/^\(/.exec(item != null ? item.value : void 8)) {
          return false;
        }
        if (item != null && item.value) {
          fillQuery(item.value);
        }
        return true;
      },
      source: function(arg$, cb){
        var term, regex, results, MaxResults, more;
        term = arg$.term;
        if (!term.length) {
          return cb([]);
        }
        if (!/[^\u0000-\u00FF]/.test(term)) {
          return cb([]);
        }
        term = term.replace(/\*/g, '%');
        regex = term;
        if (/\s$/.exec(term) || /\^/.exec(term)) {
          regex = replace$.call(regex, /\^/g, '');
          regex = replace$.call(regex, /\s*$/g, '');
          regex = '"' + regex;
        } else {
          if (!/[?._%]/.test(term)) {
            regex = '[^"]*' + regex;
          }
        }
        if (/^\s/.exec(term) || /\$/.exec(term)) {
          regex = replace$.call(regex, /\$/g, '');
          regex = replace$.call(regex, /\s*/g, '');
          regex += '"';
        } else {
          if (!/[?._%]/.test(term)) {
            regex = regex + '[^"]*';
          }
        }
        regex = replace$.call(regex, /\s/g, '');
        if (/[%?._]/.exec(term)) {
          regex = regex.replace(/[?._]/g, '[^"]');
          regex = regex.replace(/%/g, '[^"]*');
          regex = "\"" + regex + "\"";
        }
        regex = regex.replace(/\(\)/g, '');
        results = (function(){
          try {
            return Index.match(RegExp(regex + '', 'g'));
          } catch (e$) {}
        }());
        if (!results) {
          return cb(['']);
        }
        if (results.length === 1) {
          doLookup(replace$.call(results[0], /"/g, ''));
        }
        MaxResults = 255;
        if (results.length > MaxResults) {
          more = "(僅顯示前 " + MaxResults + " 筆)";
          results = results.slice(0, MaxResults);
          results.push(more);
        }
        return cb((replace$.call(results.join(','), /"/g, '')).split(','));
      }
    });
  }
  function render(arg$){
    var title, heteronyms, radical, nrsCount, sCount, charHtml;
    title = arg$.title, heteronyms = arg$.heteronyms, radical = arg$.radical, nrsCount = arg$.non_radical_stroke_count, sCount = arg$.stroke_count;
    charHtml = radical ? "<div class='radical'><span class='glyph'>" + (replace$.call(radical, /<\/?a[^>]*>/g, '')) + "</span><span class='count'><span class='sym'>+</span>" + nrsCount + "</span><span class='count'> = " + sCount + "</span> 畫</div>" : '';
    return ls(heteronyms, function(arg$){
      var bopomofo, pinyin, definitions, ref$;
      bopomofo = arg$.bopomofo, pinyin = arg$.pinyin, definitions = (ref$ = arg$.definitions) != null
        ? ref$
        : [];
      return charHtml + "\n<h1 class='title'>" + h(title) + "</h1>" + (bopomofo ? "<div class='bopomofo'>" + (pinyin ? "<span class='pinyin'>" + h(pinyin).replace(/（.*）/, '') + "</span>" : '') + h(bopomofo).replace(/ /g, '\u3000').replace(/([ˇˊˋ])\u3000/g, '$1 ') + "</div>" : '') + "<div class=\"entry\">\n" + ls(groupBy('type', definitions.slice()), function(defs){
        return "<div>\n" + (defs[0].type ? "<span class='part-of-speech'>" + defs[0].type + "</span>" : '') + "\n<ol>\n" + ls(defs, function(arg$){
          var type, def, quote, ref$, example, link, antonyms, synonyms;
          type = arg$.type, def = arg$.def, quote = (ref$ = arg$.quote) != null
            ? ref$
            : [], example = (ref$ = arg$.example) != null
            ? ref$
            : [], link = (ref$ = arg$.link) != null
            ? ref$
            : [], antonyms = arg$.antonyms, synonyms = arg$.synonyms;
          return "<li><p class='definition'>\n    <span class=\"def\">" + h(expandDef(def)).replace(/([：。」])([\u278A-\u2793\u24eb-\u24f4])/g, '$1</span><span class="def">$2') + "</span>\n    " + ls(example, function(it){
            return "<span class='example'>" + h(it) + "</span>";
          }) + "\n    " + ls(quote, function(it){
            return "<span class='quote'>" + h(it) + "</span>";
          }) + "\n    " + ls(link, function(it){
            return "<span class='link'>" + h(it) + "</span>";
          }) + "\n    " + (synonyms ? "<span class='synonyms'><span class='part-of-speech'>似</span> " + h(synonyms.replace(/,/g, '、')) + "</span>" : '') + "\n    " + (antonyms ? "<span class='antonyms'><span class='part-of-speech'>反</span> " + h(antonyms.replace(/,/g, '、')) + "</span>" : '') + "\n</p></li>";
        }) + "</ol></div>";
      }) + "</div>";
    });
    function expandDef(def){
      return def.replace(/^\s*<(\d)>\s*([介代副助動名嘆形連]?)/, function(_, num, char){
        return String.fromCharCode(0x327F + parseInt(num)) + "" + (char ? char + "\u20DE" : '');
      }).replace(/<(\d)>/g, function(_, num){
        return String.fromCharCode(0x327F + parseInt(num));
      }).replace(/[（(](\d)[)）]/g, function(_, num){
        return String.fromCharCode(0x2789 + parseInt(num));
      }).replace(/\(/g, '（').replace(/\)/g, '）');
    }
    function ls(entries, cb){
      var x;
      entries == null && (entries = []);
      return (function(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = entries).length; i$ < len$; ++i$) {
          x = ref$[i$];
          results$.push(cb(x));
        }
        return results$;
      }()).join("");
    }
    function h(text){
      text == null && (text = '');
      return text;
    }
    function groupBy(prop, xs){
      var x, pre, y;
      if (xs.length <= 1) {
        return [xs];
      }
      x = xs.shift();
      x[prop] == null && (x[prop] = '');
      pre = [x];
      while (xs.length) {
        y = xs[0];
        y[prop] == null && (y[prop] = '');
        if (x[prop] !== y[prop]) {
          break;
        }
        pre.push(xs.shift());
      }
      if (!xs.length) {
        return [pre];
      }
      return [pre].concat(slice$.call(groupBy(prop, xs)));
    }
    return groupBy;
  }
  function in$(x, arr){
    var i = -1, l = arr.length >>> 0;
    while (++i < l) if (x === arr[i] && i in arr) return true;
    return false;
  }
}).call(this);
