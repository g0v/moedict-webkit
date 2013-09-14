(function() {
  var StrokeData, WordStroker, fetchStrokeJSON, fetchStrokeJSONFromBinary, fetchStrokeJSONFromXml, fetchStrokeXml, forEach, getBinary, glMatrix, jsonFromXml, root, sax, sortSurrogates, transform, transformWithMatrix;

  root = this;

  sax = root.sax || require("sax");

  glMatrix = root.glMatrix || require("./gl-matrix-min");

  fetchStrokeXml = function(path, success, fail, progress) {
    var fs;
    if (root.window) {
      return jQuery.ajax({
        type: "GET",
        url: path,
        dataType: "text",
        progress: progress
      }).done(success).fail(fail);
    } else {
      fs = require("fs");
      return fs.readFile(path, {
        encoding: "utf8"
      }, function(err, data) {
        if (err) {
          return fail(err);
        } else {
          return success(data);
        }
      });
    }
  };

  fetchStrokeJSON = function(path, success, fail, progress) {
    var fs;
    if (root.window) {
      return jQuery.ajax({
        type: "GET",
        url: path,
        dataType: "json",
        progress: progress
      }).done(success).fail(fail);
    } else {
      fs = require("fs");
      return fs.readFile(path, {
        encoding: "utf8"
      }, function(err, data) {
        if (err) {
          return fail(err);
        } else {
          return success(JSON.parse(data));
        }
      });
    }
  };

  jsonFromXml = function(doc, success, fail) {
    var outline, outlines, parser, ret, strict, track, tracks;
    ret = [];
    outlines = [];
    tracks = [];
    outline = void 0;
    track = void 0;
    strict = true;
    parser = sax.parser(strict);
    parser.onopentag = function(node) {
      if (outline !== void 0) {
        switch (node.name) {
          case "MoveTo":
            return outline.push({
              type: "M",
              x: parseFloat(node.attributes.x),
              y: parseFloat(node.attributes.y)
            });
          case "LineTo":
            return outline.push({
              type: "L",
              x: parseFloat(node.attributes.x),
              y: parseFloat(node.attributes.y)
            });
          case "CubicTo":
            return outline.push({
              type: "C",
              begin: {
                x: parseFloat(node.attributes.x1),
                y: parseFloat(node.attributes.y1)
              },
              mid: {
                x: parseFloat(node.attributes.x2),
                y: parseFloat(node.attributes.y2)
              },
              end: {
                x: parseFloat(node.attributes.x3),
                y: parseFloat(node.attributes.y3)
              }
            });
          case "QuadTo":
            return outline.push({
              type: "Q",
              begin: {
                x: parseFloat(node.attributes.x1),
                y: parseFloat(node.attributes.y1)
              },
              end: {
                x: parseFloat(node.attributes.x2),
                y: parseFloat(node.attributes.y2)
              }
            });
        }
      } else if (track !== void 0) {
        switch (node.name) {
          case "MoveTo":
            return track.push({
              x: parseFloat(node.attributes.x),
              y: parseFloat(node.attributes.y),
              size: node.attributes.size ? parseFloat(node.attributes.size) : void 0
            });
        }
      } else {
        if (node.name === "Outline") {
          outline = [];
        }
        if (node.name === "Track") {
          return track = [];
        }
      }
    };
    parser.onclosetag = function(name) {
      if (name === "Outline") {
        outlines.push(outline);
        outline = void 0;
      }
      if (name === "Track") {
        tracks.push(track);
        return track = void 0;
      }
    };
    parser.onend = function() {
      var i, _i, _len;
      for (i = _i = 0, _len = outlines.length; _i < _len; i = ++_i) {
        outline = outlines[i];
        track = tracks[i];
        ret.push({
          outline: outline,
          track: track
        });
      }
      return success(ret);
    };
    parser.onerror = function(err) {
      return fail(err);
    };
    return parser.write(doc).close();
  };

  fetchStrokeJSONFromXml = function(path, success, fail) {
    return fetchStrokeXml(path, function(doc) {
      return jsonFromXml(doc, success, fail);
    }, fail);
  };

  getBinary = function(path, success, fail, progress) {
    var xhr;
    xhr = new XMLHttpRequest;
    xhr.open("GET", path, true);
    xhr.responseType = "arraybuffer";
    xhr.onprogress = progress;
    xhr.onreadystatechange = function(e) {
      if (this.readyState === 4) {
        if (this.status === 200) {
          return typeof success === "function" ? success(this.response) : void 0;
        } else {
          return typeof fail === "function" ? fail(this.status) : void 0;
        }
      }
    };
    return xhr.send();
  };

  fetchStrokeJSONFromBinary = function(path, success, fail, progress) {
    var file_id, packed_path;
    if (root.window) {
      packed_path = "" + (path.substr(0, 6)) + (path.substr(path.length - 6, 2)) + ".bin";
      file_id = parseInt(path.substr(6, path.length - 12), 16);
      return getBinary(packed_path, function(data) {
        var cmd, cmd_len, data_view, i, id, index, node, offset, outline, p, ret, scale, size_indices, size_len, stroke_count, strokes_len, track, track_len, _i, _j, _k, _l, _len, _len1, _len2, _len3, _m, _n, _o, _p, _q;
        scale = 2060.0 / 256;
        data_view = new DataView(data);
        stroke_count = data_view.getUint16(0, true);
        for (i = _i = 0; 0 <= stroke_count ? _i < stroke_count : _i > stroke_count; i = 0 <= stroke_count ? ++_i : --_i) {
          id = data_view.getUint16(2 + i * 6, true);
          if (id === file_id) {
            offset = data_view.getUint32(2 + i * 6 + 2, true);
            break;
          }
        }
        if (i === stroke_count) {
          return typeof fail === "function" ? fail(new Error("stroke not found")) : void 0;
        }
        p = 0;
        ret = [];
        strokes_len = data_view.getUint8(offset + p++);
        for (_j = 0; 0 <= strokes_len ? _j < strokes_len : _j > strokes_len; 0 <= strokes_len ? _j++ : _j--) {
          outline = [];
          cmd_len = data_view.getUint8(offset + p++);
          for (_k = 0; 0 <= cmd_len ? _k < cmd_len : _k > cmd_len; 0 <= cmd_len ? _k++ : _k--) {
            outline.push({
              type: String.fromCharCode(data_view.getUint8(offset + p++))
            });
          }
          for (_l = 0, _len = outline.length; _l < _len; _l++) {
            cmd = outline[_l];
            switch (cmd.type) {
              case "M":
                cmd.x = scale * data_view.getUint8(offset + p++);
                break;
              case "L":
                cmd.x = scale * data_view.getUint8(offset + p++);
                break;
              case "Q":
                cmd.begin = {
                  x: scale * data_view.getUint8(offset + p++)
                };
                cmd.end = {
                  x: scale * data_view.getUint8(offset + p++)
                };
                break;
              case "C":
                cmd.begin = {
                  x: scale * data_view.getUint8(offset + p++)
                };
                cmd.mid = {
                  x: scale * data_view.getUint8(offset + p++)
                };
                cmd.end = {
                  x: scale * data_view.getUint8(offset + p++)
                };
            }
          }
          for (_m = 0, _len1 = outline.length; _m < _len1; _m++) {
            cmd = outline[_m];
            switch (cmd.type) {
              case "M":
                cmd.y = scale * data_view.getUint8(offset + p++);
                break;
              case "L":
                cmd.y = scale * data_view.getUint8(offset + p++);
                break;
              case "Q":
                cmd.begin.y = scale * data_view.getUint8(offset + p++);
                cmd.end.y = scale * data_view.getUint8(offset + p++);
                break;
              case "C":
                cmd.begin.y = scale * data_view.getUint8(offset + p++);
                cmd.mid.y = scale * data_view.getUint8(offset + p++);
                cmd.end.y = scale * data_view.getUint8(offset + p++);
            }
          }
          track = [];
          track_len = data_view.getUint8(offset + p++);
          size_indices = [];
          size_len = data_view.getUint8(offset + p++);
          for (_n = 0; 0 <= size_len ? _n < size_len : _n > size_len; 0 <= size_len ? _n++ : _n--) {
            size_indices.push(data_view.getUint8(offset + p++));
          }
          for (_o = 0; 0 <= track_len ? _o < track_len : _o > track_len; 0 <= track_len ? _o++ : _o--) {
            track.push({
              x: scale * data_view.getUint8(offset + p++)
            });
          }
          for (_p = 0, _len2 = track.length; _p < _len2; _p++) {
            node = track[_p];
            node.y = scale * data_view.getUint8(offset + p++);
          }
          for (_q = 0, _len3 = size_indices.length; _q < _len3; _q++) {
            index = size_indices[_q];
            track[index].size = scale * data_view.getUint8(offset + p++);
          }
          ret.push({
            outline: outline,
            track: track
          });
        }
        return typeof success === "function" ? success(ret) : void 0;
      }, fail, progress);
    } else {
      return console.log("not implement");
    }
  };

  StrokeData = void 0;

  forEach = Array.prototype.forEach;

  sortSurrogates = function(str) {
    var code_point, cps, text;
    cps = [];
    while (str.length) {
      if (/[\uD800-\uDBFF]/.test(str.substr(0, 1))) {
        text = str.substr(0, 2);
        code_point = (text.charCodeAt(0) - 0xD800) * 0x400 + text.charCodeAt(1) - 0xDC00 + 0x10000;
        cps.push({
          cp: code_point.toString(16),
          text: text
        });
        str = str.substr(2);
      } else {
        cps.push({
          cp: str.charCodeAt(0).toString(16),
          text: str.substr(0, 1)
        });
        str = str.substr(1);
      }
    }
    return cps;
  };

  transform = function(mat2d, x, y) {
    var mat, out, vec;
    vec = glMatrix.vec2.clone([x, y]);
    mat = glMatrix.mat2d.clone(mat2d);
    out = glMatrix.vec2.create();
    glMatrix.vec2.transformMat2d(out, vec, mat);
    return {
      x: out[0],
      y: out[1]
    };
  };

  transformWithMatrix = function(strokes, mat2d) {
    var cmd, new_cmd, new_stroke, out, ret, stroke, v, _i, _j, _k, _len, _len1, _len2, _ref, _ref1;
    ret = [];
    for (_i = 0, _len = strokes.length; _i < _len; _i++) {
      stroke = strokes[_i];
      new_stroke = {
        outline: [],
        track: []
      };
      _ref = stroke.outline;
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        cmd = _ref[_j];
        switch (cmd.type) {
          case "M":
            out = transform(mat2d, cmd.x, cmd.y);
            new_stroke.outline.push({
              type: cmd.type,
              x: out.x,
              y: out.y
            });
            break;
          case "L":
            out = transform(mat2d, cmd.x, cmd.y);
            new_stroke.outline.push({
              type: cmd.type,
              x: out.x,
              y: out.y
            });
            break;
          case "C":
            new_cmd = {
              type: cmd.type
            };
            out = transform(mat2d, cmd.begin.x, cmd.begin.y);
            new_cmd.begin = {
              x: out.x,
              y: out.y
            };
            out = transform(mat2d, cmd.mid.x, cmd.mid.y);
            new_cmd.mid = {
              x: out.x,
              y: out.y
            };
            out = transform(mat2d, cmd.end.x, cmd.end.y);
            new_cmd.end = {
              x: out.x,
              y: out.y
            };
            new_stroke.outline.push(new_cmd);
            break;
          case "Q":
            new_cmd = {
              type: cmd.type
            };
            out = transform(mat2d, cmd.begin.x, cmd.begin.y);
            new_cmd.begin = {
              x: out.x,
              y: out.y
            };
            out = transform(mat2d, cmd.end.x, cmd.end.y);
            new_cmd.end = {
              x: out.x,
              y: out.y
            };
            new_stroke.outline.push(new_cmd);
        }
      }
      _ref1 = stroke.track;
      for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
        v = _ref1[_k];
        out = transform(mat2d, v.x, v.y);
        new_stroke.track.push({
          x: out.x,
          y: out.y
        });
      }
      ret.push(new_stroke);
    }
    return ret;
  };

  StrokeData = function(options) {
    var buffer, fetchers, ret;
    fetchers = {
      "xml": fetchStrokeJSONFromXml,
      "json": fetchStrokeJSON,
      "bin": fetchStrokeJSONFromBinary
    };
    options = $.extend({
      url: "./json/",
      dataType: "json"
    }, options);
    buffer = {};
    return ret = {
      transform: transformWithMatrix,
      get: function(cp, success, fail, progress) {
        if (!buffer[cp]) {
          return fetchers[options.dataType]("" + options.url + cp + "." + options.dataType, function(json) {
            return typeof success === "function" ? success(buffer[cp] = json) : void 0;
          }, function(err) {
            return typeof fail === "function" ? fail(err) : void 0;
          }, progress);
        } else {
          return typeof success === "function" ? success(buffer[cp]) : void 0;
        }
      }
    };
  };

  if (root.window) {
    window.WordStroker || (window.WordStroker = {});
    window.WordStroker.utils = {
      sortSurrogates: sortSurrogates,
      StrokeData: StrokeData,
      fetchStrokeXml: fetchStrokeXml,
      fetchStrokeJSON: fetchStrokeJSON,
      fetchStrokeJSONFromXml: fetchStrokeJSONFromXml
    };
  } else {
    WordStroker = {
      utils: {
        sortSurrogates: sortSurrogates,
        StrokeData: StrokeData,
        fetchStrokeXml: fetchStrokeXml,
        fetchStrokeJSON: fetchStrokeJSON,
        fetchStrokeJSONFromXml: fetchStrokeJSONFromXml
      }
    };
    module.exports = WordStroker;
  }

}).call(this);

/*
//@ sourceMappingURL=utils.stroke-words.js.map
*/(function() {
  $(function() {
    var drawOutline, fetchStrokeXml, filterNodes, strokeWord, strokeWords;
    filterNodes = function(childNodes) {
      var n, nodes, _i, _len;
      nodes = [];
      for (_i = 0, _len = childNodes.length; _i < _len; _i++) {
        n = childNodes[_i];
        if (n.nodeType === 1) {
          nodes.push(n);
        }
      }
      return nodes;
    };
    drawOutline = function(paper, outline, pathAttrs) {
      var a, node, path, _i, _len, _ref;
      path = [];
      _ref = outline.childNodes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        if (node.nodeType !== 1) {
          continue;
        }
        a = node.attributes;
        if (!a) {
          continue;
        }
        switch (node.nodeName) {
          case "MoveTo":
            path.push(["M", parseFloat(a.x.value), parseFloat(a.y.value)]);
            break;
          case "LineTo":
            path.push(["L", parseFloat(a.x.value), parseFloat(a.y.value)]);
            break;
          case "CubicTo":
            path.push(["C", parseFloat(a.x1.value), parseFloat(a.y1.value), parseFloat(a.x2.value), parseFloat(a.y2.value), parseFloat(a.x3.value), parseFloat(a.y3.value)]);
            break;
          case "QuadTo":
            path.push(["Q", parseFloat(a.x1.value), parseFloat(a.y1.value), parseFloat(a.x2.value), parseFloat(a.y2.value)]);
        }
      }
      return paper.path(path).attr(pathAttrs).transform("s0.2,0.2,0,0");
    };
    fetchStrokeXml = function(code, cb) {
      return $.get("utf8/" + code.toLowerCase() + ".xml", cb, "xml");
    };
    strokeWord = function(element, word) {
      var utf8code;
      utf8code = escape(word).replace(/%u/, "");
      return fetchStrokeXml(utf8code, function(doc) {
        var color, delay, dim, gridLines, line, outline, paper, pathAttrs, timeoutSeconds, _i, _j, _len, _len1, _ref, _results;
        dim = 430;
        paper = Raphael(element, dim, dim);
        gridLines = ["M0,0 L0," + dim, "M" + dim + ",0 L" + dim + "," + dim, "M0,0 L" + dim + ",0", "M0," + dim + ",0 L" + dim + "," + dim, "M" + (Math.round(dim / 3)) + ",0 L" + (Math.round(dim / 3)) + "," + dim, "M" + (Math.round(dim / 3 * 2)) + ",0 L" + (Math.round(dim / 3 * 2)) + "," + dim, "M0," + (Math.round(dim / 3)) + " L" + dim + "," + (Math.round(dim / 3)), "M0," + (Math.round(dim / 3 * 2)) + " L" + dim + "," + (Math.round(dim / 3 * 2))];
        for (_i = 0, _len = gridLines.length; _i < _len; _i++) {
          line = gridLines[_i];
          paper.path(line).attr({
            'stroke-width': 1,
            'stroke': '#a33'
          });
        }
        Raphael.getColor();
        Raphael.getColor();
        color = Raphael.getColor();
        pathAttrs = {
          stroke: color,
          "stroke-width": 5,
          "stroke-linecap": "round",
          "fill": color
        };
        timeoutSeconds = 0;
        delay = 500;
        _ref = doc.getElementsByTagName('Outline');
        _results = [];
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          outline = _ref[_j];
          _results.push((function(outline) {
            return setTimeout((function() {
              return drawOutline(paper, outline, pathAttrs);
            }), timeoutSeconds += delay);
          })(outline));
        }
        return _results;
      });
    };
    strokeWords = function(element, words) {
      var a, _i, _len, _ref, _results;
      _ref = words.split(/(?:)/);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        a = _ref[_i];
        _results.push(strokeWord(element, a));
      }
      return _results;
    };
    window.WordStroker || (window.WordStroker = {});
    return window.WordStroker.raphael = {
      strokeWords: strokeWords
    };
  });

}).call(this);

/*
//@ sourceMappingURL=draw.js.map
*/(function() {
  $(function() {
    var Word, demoMatrix, drawBackground, drawElementWithWord, drawElementWithWords, internalOptions, pathOutline;
    internalOptions = {
      dim: 2150,
      trackWidth: 150
    };
    demoMatrix = [1, 0, 0, 1, 100, 100];
    Word = function(options) {
      var $canvas;
      this.options = $.extend({
        scales: {
          fill: 0.4,
          style: 0.25
        },
        updatesPerStep: 10,
        delays: {
          stroke: 0.25,
          word: 0.5
        },
        progress: null,
        url: "./",
        dataType: "json"
      }, options, internalOptions);
      this.matrix = [this.options.scales.fill, 0, 0, this.options.scales.fill, 0, 0];
      this.myCanvas = document.createElement("canvas");
      $canvas = $(this.myCanvas);
      $canvas.css("width", this.styleWidth() + "px");
      $canvas.css("height", this.styleHeight() + "px");
      this.myCanvas.width = this.fillWidth();
      this.myCanvas.height = this.fillHeight();
      this.canvas = this.myCanvas;
      return this;
    };
    Word.prototype.init = function() {
      this.currentStroke = 0;
      this.currentTrack = 0;
      return this.time = 0.0;
    };
    Word.prototype.width = function() {
      return this.options.dim;
    };
    Word.prototype.height = function() {
      return this.options.dim;
    };
    Word.prototype.fillWidth = function() {
      return this.width() * this.options.scales.fill;
    };
    Word.prototype.fillHeight = function() {
      return this.height() * this.options.scales.fill;
    };
    Word.prototype.styleWidth = function() {
      return this.fillWidth() * this.options.scales.style;
    };
    Word.prototype.styleHeight = function() {
      return this.fillHeight() * this.options.scales.style;
    };
    Word.prototype.drawBackground = function(canvas) {
      var ctx;
      this.canvas = canvas ? canvas : this.myCanvas;
      ctx = this.canvas.getContext("2d");
      ctx.fillStyle = "#FFF";
      ctx.fillRect(0, 0, this.fillWidth(), this.fillHeight());
      return drawBackground(ctx, this.fillWidth());
    };
    Word.prototype.draw = function(strokeJSON, canvas) {
      var ctx,
        _this = this;
      this.init();
      this.strokes = strokeJSON;
      this.canvas = canvas ? canvas : this.myCanvas;
      ctx = this.canvas.getContext("2d");
      ctx.strokeStyle = "#000";
      ctx.fillStyle = "#000";
      ctx.lineWidth = 5;
      requestAnimationFrame(function() {
        return _this.update();
      });
      return this.promise = $.Deferred();
    };
    Word.prototype.update = function() {
      var ctx, delay, i, stroke, _i, _ref,
        _this = this;
      if (this.currentStroke >= this.strokes.length) {
        return;
      }
      ctx = this.canvas.getContext("2d");
      ctx.setTransform.apply(ctx, this.matrix);
      stroke = this.strokes[this.currentStroke];
      if (this.time === 0.0) {
        this.vector = {
          x: stroke.track[this.currentTrack + 1].x - stroke.track[this.currentTrack].x,
          y: stroke.track[this.currentTrack + 1].y - stroke.track[this.currentTrack].y,
          size: stroke.track[this.currentTrack].size || this.options.trackWidth
        };
        ctx.save();
        ctx.beginPath();
        pathOutline(ctx, stroke.outline);
        ctx.clip();
      }
      for (i = _i = 1, _ref = this.options.updatesPerStep; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
        this.time += 0.02;
        if (this.time >= 1) {
          this.time = 1;
        }
        ctx.beginPath();
        ctx.arc(stroke.track[this.currentTrack].x + this.vector.x * this.time, stroke.track[this.currentTrack].y + this.vector.y * this.time, this.vector.size * 2, 0, 2 * Math.PI);
        ctx.fill();
        if (this.time >= 1) {
          break;
        }
      }
      delay = 0;
      if (this.time >= 1.0) {
        ctx.restore();
        this.time = 0.0;
        this.currentTrack += 1;
      }
      if (this.currentTrack >= stroke.track.length - 1) {
        this.currentTrack = 0;
        this.currentStroke += 1;
        delay = this.options.delays.stroke;
      }
      if (this.currentStroke >= this.strokes.length) {
        return setTimeout(function() {
          return _this.promise.resolve();
        }, this.options.delays.word * 1000);
      } else {
        if (delay) {
          return setTimeout(function() {
            return requestAnimationFrame(function() {
              return _this.update();
            });
          }, delay * 1000);
        } else {
          return requestAnimationFrame(function() {
            return _this.update();
          });
        }
      }
    };
    drawBackground = function(ctx, dim) {
      ctx.strokeStyle = "#A33";
      ctx.beginPath();
      ctx.lineWidth = 10;
      ctx.moveTo(0, 0);
      ctx.lineTo(0, dim);
      ctx.lineTo(dim, dim);
      ctx.lineTo(dim, 0);
      ctx.lineTo(0, 0);
      ctx.stroke();
      ctx.beginPath();
      ctx.lineWidth = 2;
      ctx.moveTo(0, dim / 3);
      ctx.lineTo(dim, dim / 3);
      ctx.moveTo(0, dim / 3 * 2);
      ctx.lineTo(dim, dim / 3 * 2);
      ctx.moveTo(dim / 3, 0);
      ctx.lineTo(dim / 3, dim);
      ctx.moveTo(dim / 3 * 2, 0);
      ctx.lineTo(dim / 3 * 2, dim);
      return ctx.stroke();
    };
    pathOutline = function(ctx, outline) {
      var path, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = outline.length; _i < _len; _i++) {
        path = outline[_i];
        switch (path.type) {
          case "M":
            _results.push(ctx.moveTo(path.x, path.y));
            break;
          case "L":
            _results.push(ctx.lineTo(path.x, path.y));
            break;
          case "C":
            _results.push(ctx.bezierCurveTo(path.begin.x, path.begin.y, path.mid.x, path.mid.y, path.end.x, path.end.y));
            break;
          case "Q":
            _results.push(ctx.quadraticCurveTo(path.begin.x, path.begin.y, path.end.x, path.end.y));
            break;
          default:
            _results.push(void 0);
        }
      }
      return _results;
    };
    drawElementWithWord = function(element, word, options) {
      var $loader, $word, data, promise, stroker;
      options || (options = {});
      promise = jQuery.Deferred();
      stroker = new Word(options);
      $word = $("<div class=\"word\"></div>");
      $loader = $("<div class=\"loader\"><div style=\"width: 0\"></div><i class=\"icon-spinner icon-spin icon-large icon-fixed-width\"></i></div>");
      $word.append(stroker.canvas).append($loader);
      $(element).append($word);
      data = WordStroker.utils.StrokeData({
        url: options.url,
        dataType: options.dataType
      });
      data.get(word.cp, function(json) {
        $loader.remove();
        return promise.resolve({
          drawBackground: function() {
            return stroker.drawBackground();
          },
          draw: function() {
            return stroker.draw(json);
          },
          remove: function() {
            return $(stroker.canvas).remove();
          }
        });
      }, function() {
        $loader.remove();
        return promise.resolve({
          drawBackground: function() {
            return stroker.drawBackground();
          },
          draw: function() {
            var p;
            p = jQuery.Deferred();
            $(stroker.canvas).fadeTo("fast", 0.5, function() {
              return p.resolve();
            });
            return p;
          },
          remove: function() {
            return $(stroker.canvas).remove();
          }
        });
      }, function(e) {
        if (e.lengthComputable) {
          $loader.find("> div").css("width", e.loaded / e.total * 100 + "%");
        }
        return promise.notifyWith(e, [e, word.text]);
      });
      return promise;
    };
    drawElementWithWords = function(element, words, options) {
      return WordStroker.utils.sortSurrogates(words).map(function(word) {
        return drawElementWithWord(element, word, options);
      });
    };
    window.WordStroker || (window.WordStroker = {});
    return window.WordStroker.canvas = {
      Word: Word,
      drawElementWithWords: drawElementWithWords
    };
  });

}).call(this);

/*
//@ sourceMappingURL=draw.canvas.js.map
*/(function() {
  var $, isCanvasSupported;

  isCanvasSupported = function() {
    var _ref;
    return (_ref = document.createElement("canvas")) != null ? _ref.getContext("2d") : void 0;
  };

  $ = jQuery;

  $.fn.extend({
    strokeWords: function(words, options) {
      if (words === void 0 || words === "") {
        return null;
      }
      options = $.extend({
        single: false,
        svg: !isCanvasSupported(),
        progress: null
      }, options);
      return this.each(function() {
        var promises;
        if (options.svg) {
          return window.WordStroker.raphael.strokeWords(this, words);
        } else {
          promises = window.WordStroker.canvas.drawElementWithWords(this, words, options);
          if (!options.single) {
            promises.forEach(function(p) {
              return p.progress(options.progress).then(function(word) {
                return word.drawBackground();
              });
            });
            return promises.reduceRight(function(next, current) {
              return function() {
                return current.then(function(word) {
                  return word.draw().then(next);
                });
              };
            }, null)();
          } else {
            return promises.reduceRight(function(next, current) {
              return function() {
                return current.then(function(word) {
                  word.drawBackground();
                  return word.draw().then(function() {
                    if (next) {
                      word.remove();
                      return next();
                    }
                  });
                });
              };
            }, null)();
          }
        }
      }).data("strokeWords", {
        play: null
      });
    }
  });

}).call(this);

/*
//@ sourceMappingURL=jquery.stroke-words.js.map
*/