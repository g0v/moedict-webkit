(function() {
  var Bomb, Explosion, Particle, targetTime, vendor, w, _i, _len, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  w = window;

  _ref = ['ms', 'moz', 'webkit', 'o'];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    vendor = _ref[_i];
    if (w.requestAnimationFrame) break;
    w.requestAnimationFrame = w["#vendorRequestAnimationFrame"];
    w.cancelAnimationFrame = w["#vendorCancelAnimationFrame"] || w["#vendorCancelRequestAnimationFrame"];
  }

  targetTime = 0;

  w.requestAnimationFrame || (w.requestAnimationFrame = function(callback) {
    var currentTime;
    targetTime = Math.max(targetTime + 16, currentTime = +(new Date));
    return w.setTimeout((function() {
      return callback(+(new Date));
    }), targetTime - currentTime);
  });

  w.cancelAnimationFrame || (w.cancelAnimationFrame = function(id) {
    return clearTimeout(id);
  });

  w.findClickPos = function(e) {
    var posx, posy;
    posx = 0;
    posy = 0;
    if (!e) e = window.event;
    if (e.pageX || e.pageY) {
      posx = e.pageX;
      posy = e.pageY;
    } else if (e.clientX || e.clientY) {
      posx = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
      posy = e.clientY + document.body.scrollTop + document.documentElement.scrollTop;
    }
    return {
      x: posx,
      y: posy
    };
  };

  w.getOffset = function(el) {
    var body, _x, _y;
    body = document.getElementsByTagName("body")[0];
    _x = 0;
    _y = 0;
    while (el && !isNaN(el.offsetLeft) && !isNaN(el.offsetTop)) {
      _x += el.offsetLeft - el.scrollLeft;
      _y += el.offsetTop - el.scrollTop;
      el = el.offsetParent;
    }
    return {
      top: _y + body.scrollTop,
      left: _x + body.scrollLeft
    };
  };

  Particle = (function() {

    function Particle(elem) {
      this.elem = elem;
      this.style = elem.style;
      this.elem.style['zIndex'] = 9999;
      this.transformX = 0;
      this.transformY = 0;
      this.transformRotation = 0;
      this.offsetTop = window.getOffset(this.elem).top;
      this.offsetLeft = window.getOffset(this.elem).left;
      this.velocityX = 0;
      this.velocityY = 0;
    }

    Particle.prototype.tick = function(blast) {
      var distX, distXS, distY, distYS, distanceWithBlast, force, forceX, forceY, previousRotation, previousStateX, previousStateY, rad, transform;
      previousStateX = this.transformX;
      previousStateY = this.transformY;
      previousRotation = this.transformRotation;
      if (this.velocityX > 1.5) {
        this.velocityX -= 1.5;
      } else if (this.velocityX < -1.5) {
        this.velocityX += 1.5;
      } else {
        this.velocityX = 0;
      }
      if (this.velocityY > 1.5) {
        this.velocityY -= 1.5;
      } else if (this.velocityY < -1.5) {
        this.velocityY += 1.5;
      } else {
        this.velocityY = 0;
      }
      if (blast != null) {
        distX = this.offsetLeft + this.transformX - blast.x;
        distY = this.offsetTop + this.transformY - blast.y;
        distXS = distX * distX;
        distYS = distY * distY;
        distanceWithBlast = distXS + distYS;
        force = 100000 / distanceWithBlast;
        if (force > 50) force = 50;
        rad = Math.asin(distYS / distanceWithBlast);
        forceY = Math.sin(rad) * force * (distY < 0 ? -1 : 1);
        forceX = Math.cos(rad) * force * (distX < 0 ? -1 : 1);
        this.velocityX = +forceX;
        this.velocityY = +forceY;
      }
      this.transformX = this.transformX + this.velocityX;
      this.transformY = this.transformY + this.velocityY;
      this.transformRotation = this.transformX * -1;
      if ((Math.abs(previousStateX - this.transformX) > 1 || Math.abs(previousStateY - this.transformY) > 1 || Math.abs(previousRotation - this.transformRotation) > 1) && ((this.transformX > 1 || this.transformX < -1) || (this.transformY > 1 || this.transformY < -1))) {
        transform = "translate(" + this.transformX + "px, " + this.transformY + "px) rotate(" + this.transformRotation + "deg)";
        this.style['MozTransform'] = transform;
        this.style['OTransform'] = transform;
        this.style['WebkitTransform'] = transform;
        this.style['msTransform'] = transform;
        return this.style['transform'] = transform;
      }
    };

    return Particle;

  })();

  this.Particle = Particle;

  Bomb = (function() {

    Bomb.SIZE = 50;

    function Bomb(x, y) {
      this.countDown = __bind(this.countDown, this);
      this.drop = __bind(this.drop, this);      this.pos = {
        x: x,
        y: y
      };
      this.body = document.getElementsByTagName("body")[0];
      this.state = 'planted';
      this.count = 3;
      this.drop();
    }

    Bomb.prototype.drop = function() {
      this.bomb = document.createElement("div");
      this.bomb.innerHTML = this.count;
      this.body.appendChild(this.bomb);
      this.bomb.style['zIndex'] = "9999";
      this.bomb.style['fontFamily'] = "verdana";
      this.bomb.style['width'] = "" + Bomb.SIZE + "px";
      this.bomb.style['height'] = "" + Bomb.SIZE + "px";
      this.bomb.style['display'] = 'block';
      this.bomb.style['borderRadius'] = "" + Bomb.SIZE + "px";
      this.bomb.style['WebkitBorderRadius'] = "" + Bomb.SIZE + "px";
      this.bomb.style['MozBorderRadius'] = "" + Bomb.SIZE + "px";
      this.bomb.style['fontSize'] = '18px';
      this.bomb.style['color'] = '#fff';
      this.bomb.style['lineHeight'] = "" + Bomb.SIZE + "px";
      this.bomb.style['background'] = '#000';
      this.bomb.style['position'] = 'absolute';
      this.bomb.style['top'] = "" + (this.pos.y - Bomb.SIZE / 2) + "px";
      this.bomb.style['left'] = "" + (this.pos.x - Bomb.SIZE / 2) + "px";
      this.bomb.style['textAlign'] = "center";
      this.bomb.style['WebkitUserSelect'] = 'none';
      this.bomb.style['font-weight'] = 700;
      return setTimeout(this.countDown, 1000);
    };

    Bomb.prototype.countDown = function() {
      this.state = 'ticking';
      this.count--;
      this.bomb.innerHTML = this.count;
      if (this.count > 0) {
        return setTimeout(this.countDown, 1000);
      } else {
        return this.explose();
      }
    };

    Bomb.prototype.explose = function() {
      this.bomb.innerHTML = '';
      return this.state = 'explose';
    };

    Bomb.prototype.exploded = function() {
      this.state = 'exploded';
      this.bomb.innerHTML = '';
      this.bomb.style['fontSize'] = '12px';
      return this.bomb.style['opacity'] = 0.05;
    };

    return Bomb;

  })();

  this.Bomb = Bomb;

  Explosion = (function() {

    function Explosion() {
      this.tick = __bind(this.tick, this);
      this.dropBomb = __bind(this.dropBomb, this);
      var char, confirmation, style, _ref2,
        _this = this;
      if (window.FONTBOMB_LOADED) return;
      window.FONTBOMB_LOADED = true;
      if (!window.FONTBOMB_HIDE_CONFIRMATION) confirmation = true;
      this.bombs = [];
      this.body = document.getElementsByTagName("body")[0];
      if ((_ref2 = this.body) != null) {
        _ref2.onclick = function(event) {
          return _this.dropBomb(event);
        };
      }
      this.body.addEventListener("touchstart", function(event) {
        return _this.touchEvent = event;
      });
      this.body.addEventListener("touchmove", function(event) {
        _this.touchMoveCount || (_this.touchMoveCount = 0);
        return _this.touchMoveCount++;
      });
      this.body.addEventListener("touchend", function(event) {
        if (_this.touchMoveCount < 2) _this.dropBomb(_this.touchEvent);
        return _this.touchMoveCount = 0;
      });
      this.explosifyNodes(this.body.childNodes);
      this.chars = (function() {
        var _j, _len2, _ref3, _results;
        _ref3 = document.getElementsByTagName('particle');
        _results = [];
        for (_j = 0, _len2 = _ref3.length; _j < _len2; _j++) {
          char = _ref3[_j];
          _results.push(new Particle(char, this.body));
        }
        return _results;
      }).call(this);
      this.tick();
      if (confirmation != null) {
        style = document.createElement('style');
        style.innerHTML = "div#fontBombConfirmation {\n  position: absolute;\n  top: -200px;\n  left: 0px;\n  right: 0px;\n  bottom: none;\n  width: 100%;\n  padding: 18px;\n  margin: 0px;\n  background: #e8e8e8;\n  text-align: center;\n  font-size: 14px;\n  line-height: 14px;\n  font-family: verdana, sans-serif;\n  color: #000;\n  -webkit-transition: all 1s ease-in-out;\n  -moz-transition: all 1s ease-in-out;\n  -o-transition: all 1s ease-in-out;\n  -ms-transition: all 1s ease-in-out;\n  transition: all 1s ease-in-out;\n  -webkit-box-shadow: 0px 3px 3px rgba(0,0,0,0.20);\n  -moz-box-shadow: 0px 3px 3px rgba(0,0,0,0.20);\n  box-shadow: 0px 3px 3px rgba(0,0,0,0.20);\n  z-index: 100000002;\n}\ndiv#fontBombConfirmation span,div#fontBombConfirmation a {\n  color: #fe3a1a;\n}\ndiv#fontBombConfirmation.show {\n  top:0px;\n  display:block;\n}";
        document.head.appendChild(style);
        this.confirmation = document.createElement("div");
        this.confirmation.id = 'fontBombConfirmation';
        this.confirmation.innerHTML = "<span style='font-weight:bold;'>fontBomb loaded!</span> Click anywhere to destroy " + (document.title.substring(0, 50));
        this.body.appendChild(this.confirmation);
        setTimeout(function() {
          return _this.confirmation.className = 'show';
        }, 10);
        setTimeout(function() {
          _this.confirmation.className = '';
          return setTimeout(function() {
            _this.confirmation.innerHTML = "If you think fontBomb is a blast, follow me on twitter <a href='http://www.twitter.com/plehoux'>@plehoux</a> for my next experiment!";
            _this.confirmation.className = 'show';
            return setTimeout(function() {
              return _this.confirmation.className = '';
            }, 20000);
          }, 5000);
        }, 5000);
      }
    }

    Explosion.prototype.explosifyNodes = function(nodes) {
      var node, _j, _len2, _results;
      _results = [];
      for (_j = 0, _len2 = nodes.length; _j < _len2; _j++) {
        node = nodes[_j];
        _results.push(this.explosifyNode(node));
      }
      return _results;
    };

    Explosion.prototype.explosifyNode = function(node) {
      var name, newNode, _j, _len2, _ref2;
      _ref2 = ['script', 'style', 'iframe', 'canvas', 'video', 'audio', 'textarea', 'embed', 'object', 'select', 'area', 'map', 'input'];
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        name = _ref2[_j];
        if (node.nodeName.toLowerCase() === name) return;
      }
      switch (node.nodeType) {
        case 1:
          return this.explosifyNodes(node.childNodes);
        case 3:
          if (!/^\s*$/.test(node.nodeValue)) {
            if (node.parentNode.childNodes.length === 1) {
              return node.parentNode.innerHTML = this.explosifyText(node.nodeValue);
            } else {
              newNode = document.createElement("particles");
              newNode.innerHTML = this.explosifyText(node.nodeValue);
              return node.parentNode.replaceChild(newNode, node);
            }
          }
      }
    };

    Explosion.prototype.explosifyText = function(string) {
      var char, chars, index;
      chars = (function() {
        var _len2, _ref2, _results;
        _ref2 = string.split('');
        _results = [];
        for (index = 0, _len2 = _ref2.length; index < _len2; index++) {
          char = _ref2[index];
          if (!/^\s*$/.test(char)) {
            _results.push("<particle style='display:inline-block;'>" + char + "</particle>");
          } else {
            _results.push('&nbsp;');
          }
        }
        return _results;
      })();
      chars = chars.join('');
      chars = (function() {
        var _len2, _ref2, _results;
        _ref2 = chars.split('&nbsp;');
        _results = [];
        for (index = 0, _len2 = _ref2.length; index < _len2; index++) {
          char = _ref2[index];
          if (!/^\s*$/.test(char)) {
            _results.push("<word style='white-space:nowrap'>" + char + "</word>");
          } else {
            _results.push(char);
          }
        }
        return _results;
      })();
      return chars.join(' ');
    };

    Explosion.prototype.dropBomb = function(event) {
      var pos;
      pos = window.findClickPos(event);
      this.bombs.push(new Bomb(pos.x, pos.y));
      if (window.FONTBOMB_PREVENT_DEFAULT) return event.preventDefault();
    };

    Explosion.prototype.tick = function() {
      var bomb, char, _j, _k, _l, _len2, _len3, _len4, _ref2, _ref3, _ref4;
      _ref2 = this.bombs;
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        bomb = _ref2[_j];
        if (bomb.state === 'explose') {
          bomb.exploded();
          this.blast = bomb.pos;
        }
      }
      if (this.blast != null) {
        _ref3 = this.chars;
        for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
          char = _ref3[_k];
          char.tick(this.blast);
        }
        this.blast = null;
      } else {
        _ref4 = this.chars;
        for (_l = 0, _len4 = _ref4.length; _l < _len4; _l++) {
          char = _ref4[_l];
          char.tick();
        }
      }
      return requestAnimationFrame(this.tick);
    };

    return Explosion;

  })();

  new Explosion();

}).call(this);
