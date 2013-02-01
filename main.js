(function(){
  var join$ = [].join;
  this.doLoad = function(){
    var init, grokHash, fillQuery, prevId, prevVal, titleToId, titleRegex, charRegex, lookup, fetch;
    $(window).on('hashchange', function(){
      return grokHash();
    });
    init = function(){
      if (!grokHash()) {
        fetch(18979);
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
      return $.get("data/" + it % 100 + "/" + it + ".html", function(html){
        var chunk;
        $('#result').html((function(){
          var i$, ref$, len$, results$ = [];
          for (i$ = 0, len$ = (ref$ = html.split(/(<\/?div>)/)).length; i$ < len$; ++i$) {
            chunk = ref$[i$];
            results$.push(chunk.replace(/<h1/.exec(chunk) ? charRegex : titleRegex, fn$));
          }
          return results$;
          function fn$(it){
            return "<a href=\"#" + it + "\">" + it + "</a>";
          }
        }()).join(""));
        return window.scrollTo(0, 0);
      });
    };
    return setTimeout(function(){
      return $.get('options.html', function(data){
        var titles, res$, k, chars, i$, len$, re;
        titleToId = JSON.parse(data.replace(/<option value=/g, ',').replace(/ (?:data-)?id=/g, ':').replace(/ \/>/g, '').replace(/,/, '{') + "}");
        res$ = [];
        for (k in titleToId) {
          res$.push(k.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&"));
        }
        titles = res$;
        titles.sort(function(a, b){
          return b.length - a.length;
        });
        titleRegex = new RegExp(join$.call(titles, '|'), 'g');
        res$ = [];
        for (i$ = 0, len$ = titles.length; i$ < len$; ++i$) {
          re = titles[i$];
          if (re.length === 1) {
            res$.push(re);
          }
        }
        chars = res$;
        charRegex = new RegExp(join$.call(chars, '|'), 'g');
        if (/Chrome/.exec(navigator.userAgent) && !/Android/.test(navigator.userAgent)) {
          $('#toc').html(data);
        }
        return init();
      });
    }, 1);
  };
}).call(this);
