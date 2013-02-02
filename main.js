(function(){
  var DEBUGGING, MOEID, isCordova, isDeviceReady, MOE, join$ = [].join;
  DEBUGGING = false;
  MOEID = 18979;
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
    var init, grokHash, fillQuery, prevId, prevVal, titleToId, titleRegex, charRegex, lookup, fetch, fillHtml;
    if (!isDeviceReady) {
      return;
    }
    $(window).on('hashchange', function(){
      return grokHash();
    });
    init = function(){
      if (!grokHash()) {
        fetch(MOEID);
      }
      $('#query').keyup(lookup).change(lookup).keypress(lookup).keydown(lookup).on('input', lookup);
      $('#query').on('focus', function(){
        return this.select();
      });
      $('#query').show().focus();
      return $('a').live('click', function(){
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
    prevId = prevVal = titleToId = titleRegex = charRegex = null;
    lookup = function(){
      var val, id;
      val = $('#query').val();
      if (prevVal === val) {
        return true;
      }
      id = titleToId[val];
      if (prevId === id || !id) {
        return true;
      }
      prevId = id;
      prevVal = val;
      try {
        if (location.hash + "" !== "#" + val) {
          history.pushState(null, null, "#" + val);
        }
      } catch (e$) {}
      fetch(id);
      return true;
    };
    fetch = function(it){
      if (it === MOEID) {
        return fillHtml(MOE);
      }
      return $.get("data/" + it % 100 + "/" + it + ".html", fillHtml);
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
    if (isCordova) {
      fetch = function(id){
        if (id === MOEID) {
          return fillHtml(MOE);
        }
        return $.get("pack/" + id % 1000 + ".txt", function(txt){
          var keyStr, bz2, i, j, enc1, enc2, enc3, enc4, chr1, chr2, chr3, json;
          keyStr = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
          bz2 = new Uint8Array(new ArrayBuffer(Math.ceil(txt.length * 0.75)));
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
          if (json.match(RegExp('"' + id + '":("[^"]+")'))) {
            return fillHtml(JSON.parse(RegExp.$1));
          }
        });
      };
    }
    return setTimeout(function(){
      var walk, chars, k, ref$, v, titles, res$, opts, title;
      titleToId = {};
      walk = function(prefix, obj){
        var k, v, results$ = [];
        for (k in obj) {
          v = obj[k];
          if (k === '$') {
            results$.push(titleToId[prefix] = v);
          } else if (v instanceof Object) {
            results$.push(walk(prefix + k, v));
          } else {
            results$.push(titleToId[prefix + k] = v);
          }
        }
        return results$;
      };
      chars = '';
      for (k in ref$ = window.trie) {
        v = ref$[k];
        chars += "|" + k;
        walk(k, v);
      }
      res$ = [];
      for (k in titleToId) {
        res$.push(k.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&"));
      }
      titles = res$;
      titles.sort(function(a, b){
        return b.length - a.length;
      });
      titleRegex = new RegExp(join$.call(titles, '|'), 'g');
      charRegex = new RegExp(chars.substring(1), 'g');
      if (/Chrome/.exec(navigator.userAgent) && !/Android/.test(navigator.userAgent) && !(isCordova || DEBUGGING)) {
        opts = '';
        for (title in titleToId) {
          opts += "<option value='" + title + "' />";
        }
        $('#toc').html(opts);
      }
      return init();
    }, 1);
  };
  MOE = "<h1 class='title'>萌</h1><span class='bopomofo'>ㄇㄥˊ</span><div>\n    <div><span class='part-of-speech'>名</span>\n        <ol><li>\n              <p class='definition'>草木初生的芽。說文解字：「萌，艸芽也。」唐．韓愈､劉師服､侯喜､軒轅彌明．石鼎聯句：「秋瓜未落蒂，凍芋強抽萌。」</p>\n               \n            </li><li>\n              <p class='definition'>事物發生的開端或徵兆。韓非子．說林上：「聖人見微以知萌，見端以知末。」漢．蔡邕．對詔問灾異八事：「以杜漸防萌，則其救也。」</p>\n               \n            </li><li>\n              <p class='definition'>人民。通「氓」。如：「萌黎」､「萌隸」。</p>\n               \n            </li><li>\n              <p class='definition'>姓。如五代時蜀有萌慮。</p>\n               \n            </li></ol>\n        </div><div><span class='part-of-speech'>動</span>\n        <ol><li>\n              <p class='definition'>發芽。如：「萌芽」。楚辭．王逸．九思．傷時：「明風習習兮龢暖，百草萌兮華榮。」</p>\n               \n            </li><li>\n              <p class='definition'>發生。如：「故態復萌」。管子．牧民：「惟有道者，能備患於未形也，故禍不萌。」三國演義．第一回：「若萌異心，必獲惡報。」</p>\n               \n            </li></ol>\n        </div>";
}).call(this);
