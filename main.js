(function(){
  var DEBUGGING, MOEID, isCordova, ref$, isDeviceReady, isMobile, entryHistory, callLater, MOE, replace$ = ''.replace, split$ = ''.split, join$ = [].join, slice$ = [].slice;
  DEBUGGING = false;
  MOEID = "萌";
  isCordova = (typeof navigator != 'undefined' && navigator !== null ? (ref$ = navigator.notification) != null ? ref$.alert : void 8 : void 8) != null;
  isDeviceReady = !isCordova;
  if (DEBUGGING) {
    isCordova = true;
  }
  isMobile = isCordova || /Android|iPhone|iPad|Mobile/.exec(navigator.userAgent);
  entryHistory = [];
  try {
    document.addEventListener('deviceready', function(){
      try {
        navigator.splashscreen.hide();
      } catch (e$) {}
      isDeviceReady = true;
      return window.doLoad();
    }, false);
  } catch (e$) {}
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
    var ref$, cacheLoading, init, grokHash, fillQuery, prevId, prevVal, LTMRegexes, lenToRegex, abbrevToTitle, bucketOf, lookup, doLookup, htmlCache, fetch, loadJson, loadCacheHtml, fillHtml, fillJson, bucketCache, fillBucket;
    if (!isDeviceReady) {
      return;
    }
    if (isCordova) {
      $('body').addClass('cordova');
    }
    if (isCordova && /iOS|iPhone/.exec(((ref$ = window.device) != null ? ref$.platform : void 8) != null)) {
      $('body').addClass('ios');
    }
    cacheLoading = false;
    try {
      document.addEventListener('backbutton', function(){
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
      }, false);
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
      if (grokHash()) {
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
        if (!isMobile) {
          $('#query').focus();
        }
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
    LTMRegexes = [];
    lenToRegex = {};
    abbrevToTitle = {};
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
      var title, id, regex, matched;
      title = replace$.call(val, /[（(].*/, '');
      if (isCordova) {
        if (/object/.exec(title)) {
          return;
        }
        id = title;
      } else {
        if (prevVal === val) {
          return true;
        }
        prevVal = val;
        regex = lenToRegex[title.length];
        switch (typeof regex) {
        case 'function':
          matched = regex(title);
          break;
        case 'string':
          lenToRegex[title.length] = new RegExp(regex, 'g');
          matched = lenToRegex[title.length].match(regex);
          break;
        default:
          matched = title.match(regex);
        }
        if (!matched) {
          return true;
        }
        id = matched != null ? matched[0] : void 8;
        id = abbrevToTitle[id] || id;
      }
      if (prevId === id || replace$.call(id, /\(.*/, '') !== replace$.call(val, /\(.*/, '')) {
        return true;
      }
      entryHistory.push(val);
      if (isCordova) {
        $('.back').show();
      }
      fetch(id);
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
    loadJson = function(it){
      return $.getJSON("pua/" + encodeURIComponent(it) + ".json", fillJson);
    };
    loadCacheHtml = function(it){
      var html;
      html = htmlCache[it];
      if (!html) {
        return false;
      }
      callLater(function(){
        $('#result').html(html);
        return cacheLoading = false;
      });
      return true;
    };
    fillHtml = function(html){
      var id, entries, doStep;
      html = html.replace(/(.)\u20DE/g, "</span><span class='part-of-speech'>$1</span><span>");
      html = html.replace(/<a>([^<]+)<\/a>/g, "<a href='#$1'>$1</a>");
      id = prevId || MOEID;
      if (/<\/a>/.exec(html)) {
        htmlCache[id] = html;
        callLater(function(){
          $('#result').html(html);
          return cacheLoading = false;
        });
        return;
      }
      $('#result').html(html);
      $('#result h1').html(function(_, chunk){
        if (chunk.length > 1) {
          return chunk.replace(LTMRegexes[LTMRegexes.length - 1], function(it){
            return "<a href=\"#" + encodeURIComponent(abbrevToTitle[it] || it) + "\">" + it + "</a>";
          });
        } else {
          return chunk;
        }
      });
      entries = $('#result .entry').get();
      doStep = function(){
        var $entry;
        if (!entries.length) {
          if (prevId === id) {
            htmlCache[id] = $('#result').html();
          }
          cacheLoading = false;
          return;
        }
        $entry = $(entries.shift());
        $entry.html(function(_, chunk){
          var i$, ref$, len$, re;
          for (i$ = 0, len$ = (ref$ = LTMRegexes).length; i$ < len$; ++i$) {
            re = ref$[i$];
            chunk = chunk.replace(re, fn$);
          }
          return unescape(chunk);
          function fn$(it){
            return escape("<a href=\"#" + encodeURIComponent(abbrevToTitle[it] || it) + "\">" + it + "</a>");
          }
        });
        return callLater(doStep);
      };
      return callLater(doStep);
    };
    fillJson = function(struct){
      var html;
      if (struct.dict) {
        struct = struct.dict;
      }
      if (struct[0]) {
        struct = struct[0];
      }
      html = render(struct);
      return fillHtml(html);
    };
    bucketCache = {};
    fillBucket = function(id, bucket){
      var raw, key, idx, part;
      raw = bucketCache[bucket];
      key = escape(abbrevToTitle[id] || id);
      idx = raw.indexOf("%22" + key + "%22");
      if (idx === -1) {
        return;
      }
      part = raw.slice(idx + key.length + 9);
      idx = part.indexOf('%2C%0A');
      if (idx === -1) {
        idx = part.indexOf('%0A');
      }
      part = part.slice(0, idx);
      return fillJson(JSON.parse(unescape(part)));
    };
    if (isCordova) {
      loadJson = function(id){
        var bucket;
        bucket = bucketOf(id);
        if (bucketCache[bucket]) {
          return fillBucket(id, bucket);
        }
        return $.get("pack/" + bucket + ".json.gz.txt", function(txt){
          var json;
          json = ungzip(txt);
          bucketCache[bucket] = json;
          return fillBucket(id, bucket);
        });
      };
      $.getJSON('precomputed.json', function(blob){
        abbrevToTitle = blob.abbrevToTitle;
        return $.getJSON('prefix.json', function(trie){
          setupAutocomplete(trie);
          return init();
        });
      });
      return;
    }
    return $.getJSON('prefix.json', function(trie){
      var lenToTitles, k, v, prefixLength, i$, ref$, len$, suffix, abbrevIndex, orig, key$, ref1$, lens, len, titles, e;
      lenToTitles = {};
      for (k in trie) {
        v = trie[k];
        prefixLength = k.length;
        for (i$ = 0, len$ = (ref$ = split$.call(v, '|')).length; i$ < len$; ++i$) {
          suffix = ref$[i$];
          abbrevIndex = suffix.indexOf('(');
          if (abbrevIndex >= 0) {
            orig = suffix;
            suffix = suffix.slice(0, abbrevIndex);
            abbrevToTitle[k + "" + suffix] = k + "" + orig;
          }
          ((ref1$ = lenToTitles[key$ = prefixLength + suffix.length]) != null
            ? ref1$
            : lenToTitles[key$] = []).push(k + "" + suffix);
        }
      }
      lens = [];
      for (len in lenToTitles) {
        titles = lenToTitles[len];
        lens.push(len);
        titles.sort();
        try {
          lenToRegex[len] = new RegExp((join$.call(titles, '|')).replace(/[-[\]{}()*+?.,\\#\s]/g, "\\$&"), 'g');
        } catch (e$) {
          e = e$;
          $.ajax({
            type: 'GET',
            url: "lenToRegex." + len + ".json",
            async: false,
            dataType: 'json',
            success: fn$
          });
        }
      }
      lens.sort(function(a, b){
        return b - a;
      });
      for (i$ = 0, len$ = lens.length; i$ < len$; ++i$) {
        len = lens[i$];
        LTMRegexes.push(lenToRegex[len]);
      }
      setupAutocomplete(trie);
      return init();
      function fn$(data){
        return lenToRegex[len] = new RegExp(data[len], 'g');
      }
    });
  };
  MOE = {
    "heteronyms": [{
      "bopomofo": "ㄇㄥˊ",
      "bopomofo2": "méng",
      "definitions": [
        {
          "def": "<a>草木</a><a>初</a><a>生</a><a>的</a><a>芽</a>。",
          "quote": ["<a>說文解字</a>：「<a>萌</a>，<a>艸</a><a>芽</a><a>也</a>。」", "<a>唐</a>．<a>韓愈</a>、<a>劉</a><a>師</a><a>服</a>、<a>侯</a><a>喜</a>、<a>軒轅</a><a>彌</a><a>明</a>．<a>石</a><a>鼎</a><a>聯句</a>：「<a>秋</a><a>瓜</a><a>未</a><a>落</a><a>蒂</a>，<a>凍</a><a>芋</a><a>強</a><a>抽</a><a>萌</a>。」"],
          "type": "<a>名</a>"
        }, {
          "def": "<a>事物</a><a>發生</a><a>的</a><a>開端</a><a>或</a><a>徵兆</a>。",
          "quote": ["<a>韓非子</a>．<a>說</a><a>林</a><a>上</a>：「<a>聖人</a><a>見</a><a>微</a><a>以</a><a>知</a><a>萌</a>，<a>見</a><a>端</a><a>以</a><a>知</a><a>末</a>。」", "<a>漢</a>．<a>蔡邕</a>．<a>對</a><a>詔</a><a>問</a><a>灾</a><a>異</a><a>八</a><a>事</a>：「<a>以</a><a>杜漸防萌</a>，<a>則</a><a>其</a><a>救</a><a>也</a>。」"],
          "type": "<a>名</a>"
        }, {
          "def": "<a>人民</a>。",
          "example": ["<a>如</a>：「<a>萌黎</a>」、「<a>萌隸</a>」。"],
          "link": ["<a>通</a>「<a>氓</a>」。"],
          "type": "<a>名</a>"
        }, {
          "def": "<a>姓</a>。<a>如</a><a>五代</a><a>時</a><a>蜀</a><a>有</a><a>萌</a><a>慮</a>。",
          "type": "<a>名</a>"
        }, {
          "def": "<a>發芽</a>。",
          "example": ["<a>如</a>：「<a>萌芽</a>」。"],
          "quote": ["<a>楚辭</a>．<a>王</a><a>逸</a>．<a>九思</a>．<a>傷</a><a>時</a>：「<a>明</a><a>風</a><a>習習</a><a>兮</a><a>龢</a><a>暖</a>，<a>百草</a><a>萌</a><a>兮</a><a>華</a><a>榮</a>。」"],
          "type": "<a>動</a>"
        }, {
          "def": "<a>發生</a>。",
          "example": ["<a>如</a>：「<a>故態復萌</a>」。"],
          "quote": ["<a>管子</a>．<a>牧民</a>：「<a>惟</a><a>有道</a><a>者</a>，<a>能</a><a>備</a><a>患</a><a>於</a><a>未</a><a>形</a><a>也</a>，<a>故</a><a>禍</a><a>不</a><a>萌</a>。」", "<a>三國演義</a>．<a>第一</a><a>回</a>：「<a>若</a><a>萌</a><a>異心</a>，<a>必</a><a>獲</a><a>惡報</a>。」"],
          "type": "<a>動</a>"
        }
      ],
      "pinyin": "méng"
    }],
    "non_radical_stroke_count": "8",
    "radical": "<a>艸</a>",
    "stroke_count": "12",
    "title": "萌"
  };
  function setupAutocomplete(trie){
    var prefixEntries, prefixRegexes;
    prefixEntries = {};
    prefixRegexes = {};
    return $('#query').autocomplete({
      position: {
        my: "left bottom",
        at: "left top"
      },
      select: function(e, arg$){
        var item;
        item = arg$.item;
        if (item != null && item.value) {
          fillQuery(item.value);
        }
        return true;
      },
      change: function(e, arg$){
        var item;
        item = arg$.item;
        if (item != null && item.value) {
          fillQuery(item.value);
        }
        return true;
      },
      source: function(arg$, cb){
        var term, pre, ref$, entries, post, regex, results, res$, i$, len$, e;
        term = arg$.term;
        if (!term.length) {
          return cb([]);
        }
        pre = term.slice(0, 1);
        if (0xD800 <= (ref$ = pre.charCodeAt(0)) && ref$ <= 0xDBFF) {
          pre = term.slice(0, 2);
        }
        if (!trie[pre]) {
          return cb([]);
        }
        entries = prefixEntries[pre] || (prefixEntries[pre] = (function(){
          var i$, ref$, len$, results$ = [];
          for (i$ = 0, len$ = (ref$ = split$.call(trie[pre], '|')).length; i$ < len$; ++i$) {
            post = ref$[i$];
            results$.push(pre + "" + post);
          }
          return results$;
        }()));
        if (term === pre) {
          return cb(entries);
        }
        regex = prefixRegexes[pre] || (prefixRegexes[pre] = new RegExp("^" + trie[pre].replace(/[-[\]{}()*+?.,\\^$#\s]/g, "\\$&")));
        while (term.length) {
          if (term === pre) {
            return cb(entries);
          }
          if (!regex.test(term)) {
            continue;
          }
          res$ = [];
          for (i$ = 0, len$ = entries.length; i$ < len$; ++i$) {
            e = entries[i$];
            if (e.indexOf(term) === 0) {
              res$.push(e);
            }
          }
          results = res$;
          if (results.length === 1) {
            doLookup(results[0]);
            return cb([]);
          }
          if (results.length) {
            return cb(results);
          }
          term = term.slice(0, -1);
        }
        return cb([]);
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
          var type, def, quote, ref$, example, link;
          type = arg$.type, def = arg$.def, quote = (ref$ = arg$.quote) != null
            ? ref$
            : [], example = (ref$ = arg$.example) != null
            ? ref$
            : [], link = (ref$ = arg$.link) != null
            ? ref$
            : [];
          return "<li><p class='definition'>\n    <span class=\"def\">" + h(expandDef(def)).replace(/([：。」])([\u278A-\u2793\u24eb-\u24f4])/g, '$1</span><span class="def">$2') + "</span>\n    " + ls(example, function(it){
            return "<span class='example'>" + h(it) + "</span>";
          }) + "\n    " + ls(quote, function(it){
            return "<span class='quote'>" + h(it) + "</span>";
          }) + "\n    " + ls(link, function(it){
            return "<span class='link'>" + h(it) + "</span>";
          }) + "\n</p></li>";
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
        y = xs.shift();
        y[prop] == null && (y[prop] = '');
        if (x[prop] !== y[prop]) {
          break;
        }
        pre.push(y);
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
