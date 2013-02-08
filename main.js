(function(){
  var DEBUGGING, MOEID, isCordova, isMobile, isDeviceReady, entryHistory, callLater, MOE, replace$ = ''.replace, split$ = ''.split, join$ = [].join, slice$ = [].slice;
  DEBUGGING = false;
  MOEID = "萌";
  isCordova = /^file:...android_asset/.exec(location.href);
  isMobile = isCordova || DEBUGGING || /Android|iPhone|iPad|Mobile/.exec(navigator.userAgent);
  isDeviceReady = !isCordova;
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
    var cacheLoading, init, grokHash, fillQuery, prevId, prevVal, LTMRegexes, lenToRegex, abbrevToTitle, lookup, bucketOf, doLookup, htmlCache, fetch, loadJson, loadCacheHtml, fillHtml, fillJson, bucketCache, fillBucket;
    if (!isDeviceReady) {
      return;
    }
    if (isCordova) {
      $('body').addClass('cordova');
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
          fillQuery($(this).text());
          return false;
        });
      }
      if (grokHash()) {
        return;
      }
      if (isCordova || DEBUGGING) {
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
    fillQuery = function(it){
      var input;
      $('#query').val(it);
      input = $('#query').get(0);
      if (!isMobile) {
        input.focus();
        try {
          input.select();
        } catch (e$) {}
      }
      doLookup(it);
      return true;
    };
    prevId = prevVal = null;
    LTMRegexes = [];
    lenToRegex = {};
    abbrevToTitle = {};
    lookup = function(){
      return doLookup($('#query').val());
    };
    bucketOf = function(it){
      var code;
      code = it.charCodeAt(0);
      if (0xD800 <= code && code <= 0xDBFF) {
        code = it.charCodeAt(1) - 0xDC00;
      }
      return code % 1024;
    };
    doLookup = function(val){
      var title, regex, matched, id;
      if (prevVal === val) {
        return true;
      }
      prevVal = val;
      title = replace$.call(val, /\(.*/, '');
      regex = lenToRegex[title.length];
      if (regex instanceof Function) {
        matched = regex(title);
      } else {
        matched = title.match(regex);
      }
      if (!matched) {
        return true;
      }
      id = matched[0];
      id = abbrevToTitle[id] || id;
      if (prevId === id || id !== val) {
        return true;
      }
      entryHistory.push(val);
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
      var entries, id, doStep;
      html = html.replace(/(.)\u20DE/g, "</span><span class='part-of-speech'>$1</span><span>");
      $('#result').html(html);
      $('#result h1').html(function(_, chunk){
        return chunk.replace(LTMRegexes[LTMRegexes.length - 1], function(it){
          return "<a href=\"#" + (abbrevToTitle[it] || it) + "\">" + it + "</a>";
        });
      });
      entries = $('#result .entry').get();
      id = prevId || MOEID;
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
            return escape("<a href=\"#" + (abbrevToTitle[it] || it) + "\">" + it + "</a>");
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
      html = render(struct);
      return fillHtml(html);
    };
    bucketCache = {};
    fillBucket = function(id, bucket){
      var raw, key, idx, part;
      raw = bucketCache[bucket];
      key = escape(id);
      idx = raw.indexOf("\"" + key + "\"");
      part = raw.slice(idx + key.length + 4);
      part = part.slice(0, part.indexOf('"'));
      return fillJson(JSON.parse(unescape(part)));
    };
    if (isCordova || DEBUGGING) {
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
    }
    return $.getJSON('prefix.json', function(trie){
      var lenToTitles, k, v, prefixLength, i$, ref$, len$, suffix, abbrevIndex, orig, key$, ref1$, lens, len, titles, e, prefixEntries, prefixRegexes;
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
      prefixEntries = {};
      prefixRegexes = {};
      $('#query').autocomplete({
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
          return !(isCordova || DEBUGGING);
        },
        change: function(e, arg$){
          var item;
          item = arg$.item;
          if (item != null && item.value) {
            fillQuery(item.value);
          }
          return !(isCordova || DEBUGGING);
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
          "def": "草木初生的芽。",
          "quote": ["說文解字：「萌，艸芽也。」", "唐．韓愈、劉師服、侯喜、軒轅彌明．石鼎聯句：「秋瓜未落蒂，凍芋強抽萌。」"],
          "type": "名"
        }, {
          "def": "事物發生的開端或徵兆。",
          "quote": ["韓非子．說林上：「聖人見微以知萌，見端以知末。」", "漢．蔡邕．對詔問灾異八事：「以杜漸防萌，則其救也。」"],
          "type": "名"
        }, {
          "def": "人民。",
          "example": ["如：「萌黎」、「萌隸」。"],
          "link": ["通「氓」。"],
          "type": "名"
        }, {
          "def": "姓。如五代時蜀有萌慮。",
          "type": "名"
        }, {
          "def": "發芽。",
          "example": ["如：「萌芽」。"],
          "quote": ["楚辭．王逸．九思．傷時：「明風習習兮龢暖，百草萌兮華榮。」"],
          "type": "動"
        }, {
          "def": "發生。",
          "example": ["如：「故態復萌」。"],
          "quote": ["管子．牧民：「惟有道者，能備患於未形也，故禍不萌。」", "三國演義．第一回：「若萌異心，必獲惡報。」"],
          "type": "動"
        }
      ],
      "pinyin": "méng"
    }],
    "non_radical_stroke_count": "8",
    "radical": "艸",
    "stroke_count": "12",
    "title": "萌"
  };
  function render(arg$){
    var title, heteronyms, radical, nrsCount, sCount, charHtml;
    title = arg$.title, heteronyms = arg$.heteronyms, radical = arg$.radical, nrsCount = arg$.non_radical_stroke_count, sCount = arg$.stroke_count;
    charHtml = radical ? "<div class='radical'><span class='glyph'>" + radical + "</span><span class='count'><span class='sym'>+</span>" + nrsCount + "</span><span class='count'> = " + sCount + "</span> 畫</div>" : '';
    return ls(heteronyms, function(arg$){
      var bopomofo, pinyin, definitions, ref$;
      bopomofo = arg$.bopomofo, pinyin = arg$.pinyin, definitions = (ref$ = arg$.definitions) != null
        ? ref$
        : [];
      return charHtml + "\n<h1 class='title'>" + h(title) + "</h1>" + (bopomofo ? "<div class='bopomofo'>" + (pinyin ? "<span class='pinyin'>" + h(pinyin).replace(/（.*）/, '') + "</span>" : '') + h(bopomofo).replace(/ /g, '\u3000').replace(/([ˇˊˋ])\u3000/g, '$1 ') + "</div>" : '') + "<div class=\"entry\">\n" + ls(groupBy('pos', definitions.slice()), function(defs){
        return "<div>\n" + (defs[0].pos ? "<span class='part-of-speech'>" + defs[0].pos + "</span>" : '') + "\n<ol>\n" + ls(defs, function(arg$){
          var pos, def, quote, ref$, example, link;
          pos = arg$.pos, def = arg$.def, quote = (ref$ = arg$.quote) != null
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
      return text.replace(/</g, '&lt;').replace(/>/g, '&gt;');
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
