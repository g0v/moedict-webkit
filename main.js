(function(){
  this.doLoad = function(){
    var init, grokHash, prevId, prevVal, titleToId, lookup, fetch;
    $(window).on('hashchange', function(){
      return grokHash();
    });
    init = function(){
      if (!grokHash()) {
        fetch(18979);
      }
      $('#query').keyup(lookup).change(lookup).keypress(lookup).keydown(lookup).on('input', lookup);
      return $('#query').show().focus();
    };
    grokHash = function(){
      if (!/^#./.test(location.hash)) {
        return false;
      }
      try {
        $('#query').val(decodeURIComponent(location.hash.substr(1)));
        $('#query').show().focus();
        $('#query').get(0).select();
        lookup();
        return true;
      } catch (e$) {}
      return false;
    };
    prevId = prevVal = titleToId = null;
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
        history.pushState(null, null, "#" + val);
      } catch (e$) {}
      fetch(id);
      return true;
    };
    fetch = function(it){
      return $('#result').load("data/" + it % 100 + "/" + it + ".html");
    };
    return setTimeout(function(){
      return $.get('options.html', function(data){
        titleToId = JSON.parse(data.replace(/<option value=/g, ',').replace(/ (?:data-)?id=/g, ':').replace(/ \/>/g, '').replace(/,/, '{') + "}");
        if (/Chrome/.exec(navigator.userAgent) && !/Android/.test(navigator.userAgent)) {
          $('#toc').html(data);
        }
        return init();
      });
    }, 1);
  };
}).call(this);
