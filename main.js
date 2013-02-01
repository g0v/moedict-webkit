(function(){
  var join$ = [].join;
  this.doLoad = function(){
    var init, grokHash, fillQuery, prevId, prevVal, titleToId, titleRegex, lookup, fetch;
    $(window).on('hashchange', function(){
      return grokHash();
    });
    init = function(){
      if (!grokHash()) {
        fetch(18979);
      }
      $('#query').keyup(lookup).change(lookup).keypress(lookup).keydown(lookup).on('input', lookup);
      $('#query').show().focus();
      return $('a').live('click', function(){
        fillQuery($(this).text());
        return false;
      });
    };
    grokHash = function(){
      if (!/^#./.test(location.hash)) {
        return false;
      }
      if (fillQuery(decodeURIComponent(location.hash.substr(1)))) {
        return true;
      }
      return false;
    };
    fillQuery = function(it){
      try {
        $('#query').val(it);
        $('#query').show().focus();
        $('#query').get(0).select();
        lookup();
        return true;
      } catch (e$) {}
      return false;
    };
    prevId = prevVal = titleToId = titleRegex = null;
    lookup = function(){
      var val, id;
      val = $('#query').val();
      if (prevVal === val) {
        return true;
      }
      prevVal = val;
      id = titleToId[val];
      if (prevId === id || !id) {
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
    fetch = function(it){
      return $.get("data/" + it % 100 + "/" + it + ".html", function(html){
        return $('#result').html(html.replace(titleRegex, function(it){
          return "<a href=\"#\">" + it + "</a>";
        }));
      });
    };
    return setTimeout(function(){
      return $.get('options.html', function(data){
        var res$, k;
        titleToId = JSON.parse(data.replace(/<option value=/g, ',').replace(/ (?:data-)?id=/g, ':').replace(/ \/>/g, '').replace(/,/, '{') + "}");
        res$ = [];
        for (k in titleToId) {
          res$.push(k.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&"));
        }
        titleRegex = res$;
        titleRegex.sort(function(a, b){
          return b.length - a.length;
        });
        titleRegex = new RegExp(join$.call(titleRegex, '|'), 'g');
        if (/Chrome/.exec(navigator.userAgent) && !/Android/.test(navigator.userAgent)) {
          $('#toc').html(data);
        }
        return init();
      });
    }, 1);
  };
}).call(this);
