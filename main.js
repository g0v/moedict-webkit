(function(){
  var DEBUGGING, MOEID, isCordova, isDeviceReady, MOE, split$ = ''.split, join$ = [].join, slice$ = [].slice;
  DEBUGGING = false;
  MOEID = "萌";
  isCordova = /^file:...android_asset/.exec(location.href);
  isDeviceReady = !isCordova;
  document.addEventListener('deviceready', function(){
    try {
      navigator.splashscreen.hide();
    } catch (e$) {}
    isDeviceReady = true;
    return window.doLoad();
  }, false);
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
  window.doLoad = function(){
    var init, grokHash, fillQuery, prevId, prevVal, LTMRegexes, lenToRegex, lookup, bucketOf, doLookup, htmlCache, fetch, fillHtml, fillJson, bucketCache, fillBucket;
    if (!isDeviceReady) {
      return;
    }
    $(window).on('hashchange', function(){
      return grokHash();
    });
    if (isCordova) {
      $('body').addClass('cordova');
    }
    init = function(){
      $('#query').keyup(lookup).change(lookup).keypress(lookup).keydown(lookup).on('input', lookup);
      $('#query').on('focus', function(){
        return this.select();
      });
      $('#query').show().focus();
      $('a').on('click', function(){
        fillQuery($(this).text());
        return false;
      });
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
    grokHash = function(){
      var val;
      if (!/^#./.test(location.hash)) {
        return false;
      }
      try {
        val = decodeURIComponent(location.hash.substr(1));
        if (val === prevVal) {
          return true;
        }
        $('#query').show().focus();
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
      if (!(DEBUGGING || isCordova || /Android|iPhone|iPad|Mobile/.exec(navigator.userAgent))) {
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
      var matched, id;
      if (prevVal === val) {
        return true;
      }
      prevVal = val;
      matched = val.match(lenToRegex[val.length]);
      if (!matched) {
        return true;
      }
      id = matched[0];
      if (prevId === id || id !== val) {
        return true;
      }
      prevId = id;
      try {
        if (location.hash + "" !== "#" + val) {
          history.pushState(null, null, "#" + val);
        }
      } catch (e$) {}
      fetch(id);
      return true;
    };
    htmlCache = {};
    fetch = function(it){
      if (it === MOEID) {
        return fillJson(MOE);
      }
      if (htmlCache[it]) {
        return fillHtml(htmlCache[it]);
      }
      $('#result div, #result span, #result h1').css('visibility', 'hidden');
      $('#result h1:first').text(it).css('visibility', 'visible');
      return $.getJSON("api/data/" + bucketOf(it) + "/" + it + ".json", fillJson);
    };
    fillHtml = function(html){
      var spans, doStep;
      html = html.replace(/(.)\u20DE/g, "</span><span class='part-of-speech'>$1</span><span>");
      $('#result').html(html);
      $('#result h1').html(function(_, chunk){
        return chunk.replace(LTMRegexes[LTMRegexes.length - 1], function(it){
          return "<a href=\"#" + it + "\">" + it + "</a>";
        });
      });
      window.scrollTo(0, 0);
      spans = $('#result span').get();
      doStep = function(){
        var $span;
        if (!spans.length) {
          return;
        }
        $span = $(spans.shift());
        $span.html(function(_, chunk){
          var i$, ref$, len$, re;
          for (i$ = 0, len$ = (ref$ = LTMRegexes).length; i$ < len$; ++i$) {
            re = ref$[i$];
            chunk = chunk.replace(re, fn$);
          }
          return unescape(chunk);
          function fn$(it){
            return escape("<a href=\"#" + it + "\">" + it + "</a>");
          }
        });
        return setTimeout(doStep, 1);
      };
      return setTimeout(doStep, 1);
    };
    fillJson = function(struct){
      var html;
      html = render(prevId || MOEID, struct);
      htmlCache[prevId || MOEID] = html;
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
      fetch = function(id){
        var bucket;
        if (htmlCache[id]) {
          return fillHtml(htmlCache[id]);
        }
        if (id === MOEID) {
          return fillJson(MOE);
        }
        bucket = bucketOf(id);
        if (bucketCache[bucket]) {
          return fillBucket(id, bucket);
        }
        $('#result div, #result span, #result h1').css('visibility', 'hidden');
        $('#result h1:first').text(id).css('visibility', 'visible');
        return $.get("pack/" + bucket + ".json.gz.txt", function(txt){
          var json;
          json = ungzip(txt);
          bucketCache[bucket] = json;
          return fillBucket(id, bucket);
        });
      };
    }
    return $.getJSON('prefix.json', function(trie){
      var lenToTitles, k, v, prefixLength, i$, ref$, len$, suffix, key$, ref1$, lens, len, titles, prefixEntries, prefixRegexes;
      lenToTitles = {};
      for (k in trie) {
        v = trie[k];
        prefixLength = k.length;
        for (i$ = 0, len$ = (ref$ = split$.call(v, '|')).length; i$ < len$; ++i$) {
          suffix = ref$[i$];
          ((ref1$ = lenToTitles[key$ = prefixLength + suffix.length]) != null
            ? ref1$
            : lenToTitles[key$] = []).push(k + "" + suffix);
        }
      }
      lens = [];
      for (len in lenToTitles) {
        titles = lenToTitles[len];
        lens.push(len);
        lenToRegex[len] = new RegExp((join$.call(titles, '|')).replace(/[-[\]{}()*+?.,\\#\s]/g, "\\$&"), 'g');
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
    });
  };
  MOE = [{
    "bopomofo": "ㄇㄥˊ",
    "bopomofo2": "méng",
    "definitions": [
      {
        "definition": "草木初生的芽。",
        "pos": "名",
        "quote": ["說文解字：「萌，艸芽也。」", "唐．韓愈､劉師服､侯喜､軒轅彌明．石鼎聯句：「秋瓜未落蒂，凍芋強抽萌。」"]
      }, {
        "definition": "事物發生的開端或徵兆。",
        "pos": "名",
        "quote": ["韓非子．說林上：「聖人見微以知萌，見端以知末。」", "漢．蔡邕．對詔問灾異八事：「以杜漸防萌，則其救也。」"]
      }, {
        "definition": "人民。通「氓」。如：「萌黎」､「萌隸」。",
        "pos": "名"
      }, {
        "definition": "姓。如五代時蜀有萌慮。",
        "pos": "名"
      }, {
        "definition": "發芽。",
        "example": ["如：「萌芽」。"],
        "pos": "動",
        "quote": ["楚辭．王逸．九思．傷時：「明風習習兮龢暖，百草萌兮華榮。」"]
      }, {
        "definition": "發生。",
        "example": ["如：「故態復萌」。"],
        "pos": "動",
        "quote": ["管子．牧民：「惟有道者，能備患於未形也，故禍不萌。」", "三國演義．第一回：「若萌異心，必獲惡報。」"]
      }
    ],
    "hanyu_pinyin": "méng"
  }];
  function render(title, struct){
    var bopomofo, definitions, defs, pos, def, quote, example, link, x;
    return ls((function(){
      var i$, ref$, len$, ref1$, ref2$, results$ = [];
      for (i$ = 0, len$ = (ref$ = struct).length; i$ < len$; ++i$) {
        ref1$ = ref$[i$], bopomofo = (ref2$ = ref1$.bopomofo) != null ? ref2$ : '', definitions = (ref2$ = ref1$.definitions) != null
          ? ref2$
          : [];
        results$.push("<h1 class='title'>" + h(title) + "</h1>" + (bopomofo ? "<div class='bopomofo'>" + h(bopomofo).replace(/ /g, '\u3000').replace(/([ˇˊˋ])\u3000/g, '$1 ') + "</div>" : '') + "<div>\n" + ls((fn$())) + "</div>");
      }
      return results$;
      function fn$(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = groupBy('pos', definitions.slice())).length; i$ < len$; ++i$) {
          defs = ref$[i$];
          results$.push("<div>\n" + (defs[0].pos ? "<span class='part-of-speech'>" + defs[0].pos + "</span>" : '') + "\n<ol>\n" + ls((fn$())) + "</ol></div>");
        }
        return results$;
        function fn$(){
          var i$, ref$, len$, ref1$, ref2$, results$ = [];
          for (i$ = 0, len$ = (ref$ = defs).length; i$ < len$; ++i$) {
            ref1$ = ref$[i$], pos = ref1$.pos, def = ref1$.definition, quote = (ref2$ = ref1$.quote) != null
              ? ref2$
              : [], example = (ref2$ = ref1$.example) != null
              ? ref2$
              : [], link = (ref2$ = ref1$.link) != null
              ? ref2$
              : [];
            results$.push("<li><p class='definition'>\n    <span class=\"def\">" + h(expandDef(def)).replace(/([：。」])([\u278A-\u2793\u24eb-\u24f4])/g, '$1</span><span class="def">$2') + "</span>\n    " + ls((fn$())) + "\n    " + ls((fn1$())) + "\n    " + ls((fn2$())) + "\n</p></li>");
          }
          return results$;
          function fn$(){
            var i$, ref$, len$, results$ = [];
            for (i$ = 0, len$ = (ref$ = example).length; i$ < len$; ++i$) {
              x = ref$[i$];
              results$.push("<span class='example'>" + h(x) + "</span>");
            }
            return results$;
          }
          function fn1$(){
            var i$, ref$, len$, results$ = [];
            for (i$ = 0, len$ = (ref$ = quote).length; i$ < len$; ++i$) {
              x = ref$[i$];
              results$.push("<span class='quote'>" + h(x) + "</span>");
            }
            return results$;
          }
          function fn2$(){
            var i$, ref$, len$, results$ = [];
            for (i$ = 0, len$ = (ref$ = link).length; i$ < len$; ++i$) {
              x = ref$[i$];
              results$.push("<span class='link'>" + h(x) + "</span>");
            }
            return results$;
          }
        }
      }
    }()));
    function expandDef(def){
      return def.replace(/^\s*<(\d)>\s*([介代副助動名嘆形連]?)/, function(_, num, char){
        return String.fromCharCode(0x327F + parseInt(num)) + "" + (char ? char + "\u20DE" : '');
      }).replace(/<(\d)>/g, function(_, num){
        return String.fromCharCode(0x327F + parseInt(num));
      }).replace(/[（(](\d)[)）]/g, function(_, num){
        return String.fromCharCode(0x2789 + parseInt(num));
      }).replace(/\(/g, '（').replace(/\)/g, '）');
    }
    function ls(lines){
      return lines.join("");
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
}).call(this);
