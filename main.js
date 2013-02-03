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
    var init, grokHash, fillQuery, prevId, prevVal, titleRegex, charRegex, lookup, bucketOf, doLookup, htmlCache, fetch, fillHtml, fillJson, bucketCache, fillBucket;
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
      if (!grokHash()) {
        fetch(MOEID);
      }
      $('#query').keyup(lookup).change(lookup).keypress(lookup).keydown(lookup).on('input', lookup);
      $('#query').on('focus', function(){
        return this.select();
      });
      $('#query').show().focus();
      return $('a').on('click', function(){
        fillQuery($(this).text());
        return false;
      });
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
      try {
        $('#query').val(it);
        if (!/Android|iPhone|iPad|Mobile/.test(navigator.userAgent)) {
          $('#query').focus();
          $('#query').get(0).select();
        }
        lookup();
        return true;
      } catch (e$) {}
      return false;
    };
    prevId = prevVal = titleRegex = charRegex = null;
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
      matched = titleRegex.exec(val);
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
      var chunk;
      $('#result').html((function(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = html.replace(/(.)\u20DE/g, "<span class='part-of-speech'>$1</span>").split(/(<\/?div>)/)).length; i$ < len$; ++i$) {
          chunk = ref$[i$];
          results$.push(chunk.replace(/<h1/.exec(chunk) ? charRegex : titleRegex, fn$));
        }
        return results$;
        function fn$(it){
          return "<a href=\"#" + it + "\">" + it + "</a>";
        }
      }()).join(""));
      return window.scrollTo(0, 0);
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
        return $.get("pack/" + bucket + ".json.bz2.txt", function(txt){
          var keyStr, bz2, i, j, enc1, enc2, enc3, enc4, chr1, chr2, chr3, json;
          keyStr = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
          bz2 = [];
          window.Uint8Array || (window.Uint8Array = Array);
          window.Uint32Array || (window.Uint32Array = Array);
          try {
            bz2 = new Uint8Array(new ArrayBuffer(Math.ceil(txt.length * 0.75)));
          } catch (e$) {}
          i = j = 0;
          while (i < txt.length) {
            enc1 = keyStr.indexOf(txt.charAt(i++));
            enc2 = keyStr.indexOf(txt.charAt(i++));
            enc3 = keyStr.indexOf(txt.charAt(i++));
            enc4 = keyStr.indexOf(txt.charAt(i++));
            chr1 = enc1 << 2 | enc2 >> 4;
            chr2 = (enc2 & 15) << 4 | enc3 >> 2;
            chr3 = (enc3 & 3) << 6 | enc4;
            bz2[j++] = chr1;
            if (enc3 !== 64) {
              bz2[j++] = chr2;
            }
            if (enc4 !== 64) {
              bz2[j++] = chr3;
            }
            chr1 = chr2 = chr3 = enc1 = enc2 = enc3 = enc4 = '';
          }
          json = bzip2.simple(bzip2.array(bz2));
          bucketCache[bucket] = json;
          return fillBucket(id, bucket);
        });
      };
    }
    return $.getJSON('prefix.json', function(trie){
      var chars, titles, k, v, i$, ref$, len$, suffix, titleJoined, prefixEntries, prefixRegexes;
      chars = '';
      titles = [];
      for (k in trie) {
        v = trie[k];
        chars += "|" + k;
        for (i$ = 0, len$ = (ref$ = split$.call(v, '|')).length; i$ < len$; ++i$) {
          suffix = ref$[i$];
          titles.push(k + "" + suffix);
        }
      }
      titles.sort(function(a, b){
        return b.length - a.length;
      });
      titleJoined = (join$.call(titles, '|')).replace(/[-[\]{}()*+?.,\\#\s]/g, "\\$&");
      titleRegex = new RegExp(titleJoined, 'g');
      charRegex = new RegExp(chars.substring(1), 'g');
      titles = null;
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
        ref1$ = ref$[i$], bopomofo = ref1$.bopomofo, definitions = (ref2$ = ref1$.definitions) != null
          ? ref2$
          : [];
        results$.push("<h1 class='title'>" + h(title) + "</h1><span class='bopomofo'>" + h(bopomofo).replace(/ /g, '\u3000').replace(/([ˇˊˋ])\u3000/g, '$1 ') + "</span><div>\n" + ls((fn$())) + "</div>");
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
            results$.push("<li><p class='definition'>\n    " + h(expandDef(def)).replace(/([：。」])([\u278A-\u2793\u24eb-\u24f4])/g, '$1<br/>$2') + "\n    " + ls((fn$())) + "\n    " + ls((fn1$())) + "\n    " + ls((fn2$())) + "\n</p></li>");
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
