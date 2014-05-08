(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
(function(){
  var builtIn, dynCss;
  builtIn = require('./lib');
  dynCss = function(windowDi, documentDi, jqDi){
    var innerModule, breakpoint, setNamedBreakpoints, setBreakpoints, debug, camelize, getScrollExpression, transcompileFunction, buildHandlers;
    innerModule = function(){
      return this;
    };
    windowDi.dynCss = {};
    windowDi.dynCss.lib = builtIn;
    windowDi.dynCss.data = {};
    breakpoint = (function(){
      breakpoint.displayName = 'breakpoint';
      var prototype = breakpoint.prototype, constructor = breakpoint;
      function breakpoint(name, breakpoints, expression){
        this.name = name;
        this.breakpoints = breakpoints;
        this.expression = expression;
        this.expression = transcompileFunction(this.expression);
        this.compiled = windowDi.dynCss.api.createFunction(this.expression);
      }
      return breakpoint;
    }());
    setNamedBreakpoints = function(name, list, expression){
      return windowDi.dynCss.data[name] = new breakpoint(name, list, expression);
    };
    setBreakpoints = function(list, variable){
      return setNamedBreakpoints('responsive', list, variable);
    };
    windowDi.dynCss.api = {
      setBreakpoints: setBreakpoints,
      setNamedBreakpoints: setNamedBreakpoints
    };
    debug = false;
    camelize = function(str){
      var ex;
      ex = /[-_\s]+(.)?/g;
      return str.replace(ex, function(m, c){
        switch (false) {
        case c == null:
          return c.toUpperCase();
        default:
          return "";
        }
      });
    };
    getScrollExpression = function(d){
      var results, property;
      if ((results = /\-dyn\-(.*)/.exec(d.property)) != null) {
        property = results[1];
        if ((results = /'(.*)'/.exec(d.value)) != null) {
          return {
            property: property,
            expression: results[1]
          };
        }
      }
      return undefined;
    };
    transcompileFunction = function(body){
      body = body.replace(/@a-(\w+){(.+)}/g, 'this.lib.jqRef(\'$2\').$1()');
      body = body.replace(/@p-(\w+){(.+)}/g, 'this.lib.jqRef(\'$2\').position().$1');
      body = body.replace(/\#{(.+)}/g, '"+($1)+"');
      body = body.replace(/@i-(\w+)/g, 'parseInt(this.el.css(\'$1\'))');
      body = body.replace(/@j-(\w+)/g, 'this.lib.jqRef(this.el).$1()');
      body = body.replace(/@w-(\w+)/g, '(this.lib.wRef.$1())');
      body = body.replace(/@el-(\w+)/g, 'parseInt(this.el.css(\'$1\'))');
      body = body.replace(/@jq-(\w+)/g, 'this.lib.jqRef(this.el).$1()');
      body = body.replace(/@win-(\w+)/g, '(this.lib.wRef.$1())');
      body = body.replace(/@/g, 'this.lib.');
      return body;
    };
    windowDi.dynCss.api.createFunction = function(body){
      var script;
      script = documentDi.createElement("script");
      script.text = "window.tmp = function() { return (" + body + "); }.bind(window.dynCss);";
      documentDi.head.appendChild(script).parentNode.removeChild(script);
      return windowDi.tmp;
    };
    buildHandlers = function(rules, refreshHandler){
      var i$, len$, rule, sel, actions, j$, ref$, len1$, decl, result, property, expression, trigger, comp, handler, wrapper;
      windowDi.dynCss.lib.jqRef = jqDi;
      windowDi.dynCss.lib.wRef = jqDi(windowDi);
      for (i$ = 0, len$ = rules.length; i$ < len$; ++i$) {
        rule = rules[i$];
        if (rule.type === "rule") {
          sel = rule.selectors;
          actions = [];
          for (j$ = 0, len1$ = (ref$ = rule.declarations).length; j$ < len1$; ++j$) {
            decl = ref$[j$];
            result = getScrollExpression(decl);
            if (result != null) {
              property = result.property, expression = result.expression, trigger = result.trigger;
              comp = transcompileFunction(expression);
              handler = windowDi.dynCss.api.createFunction(comp);
              actions.push({
                property: camelize(property),
                originalProperty: property,
                funct: handler,
                sel: sel
              });
            }
          }
          wrapper = fn$;
          if (actions.length !== 0) {
            refreshHandler = wrapper(refreshHandler);
          }
        }
      }
      return refreshHandler;
      function fn$(next){
        return (function(act, scopedSel){
          return function(e){
            var i$, ref$, len$, sct;
            for (i$ = 0, len$ = (ref$ = scopedSel).length; i$ < len$; ++i$) {
              sct = ref$[i$];
              jqDi(sct).each(fn$);
            }
            if (next != null) {
              return next(e);
            }
            function fn$(i){
              var css, i$, ref$, len$, a, r, cc;
              windowDi.dynCss.el = jqDi(this);
              css = {};
              for (i$ = 0, len$ = (ref$ = act).length; i$ < len$; ++i$) {
                a = ref$[i$];
                if (r = /set-state-(.+)/.exec(a.originalProperty)) {
                  cc = r[1];
                  if (a.funct()) {
                    windowDi.dynCss.el.addClass(cc);
                  } else {
                    windowDi.dynCss.el.removeClass(cc);
                  }
                } else {
                  css[a.property] = a.funct();
                }
              }
              return windowDi.dynCss.el.css(css);
            }
          };
        }.call(this, actions, sel));
      }
    };
    return {
      innerModule: innerModule,
      buildHandlers: buildHandlers
    };
  };
  module.exports = dynCss;
}).call(this);

},{"./lib":3}],2:[function(require,module,exports){
(function(){
  var cssParse, builtIn, dynCss, buildHandlers, refreshHandler, decimate, iOS, counter, lt, fixedTtc, installCustomRaf, installCustomRafHandler, installRafHandler, installScrollHandler;
  cssParse = require('css-parse');
  builtIn = require('./lib');
  dynCss = require('./core');
  buildHandlers = dynCss(window, document, jQuery).buildHandlers;
  refreshHandler = undefined;
  decimate = 1;
  iOS = /(iPad|iPhone|iPod)/g.test(navigator.userAgent);
  counter = 0;
  lt = 0;
  fixedTtc = 1000 / 1;
  installCustomRaf = function(){
    return window.customRAF = function(cb){
      var ct, ttc;
      ct = new Date().getTime();
      ttc = Math.max(0, 16 - (ct - lt));
      if (fixedTtc != null) {
        setTimeout(cb, fixedTtc, true);
      } else {
        setTimeout(cb, ttc, true);
      }
      return lt = ct + ttc;
    };
  };
  installCustomRafHandler = function(){
    var wrappedHandler;
    installCustomRaf();
    wrappedHandler = function(){
      customRAF(wrappedHandler);
      return refreshHandler();
    };
    customRAF(wrappedHandler);
    return refreshHandler();
  };
  installRafHandler = function(){
    var wrappedHandler;
    wrappedHandler = function(){
      requestAnimationFrame(wrappedHandler);
      return refreshHandler();
    };
    return requestAnimationFrame(wrappedHandler);
  };
  installScrollHandler = function(options){
    var scrollHandler;
    scrollHandler = function(){
      if (counter % decimate === 0) {
        refreshHandler();
      }
      return counter = counter + 1;
    };
    if ((options != null ? options.onlyOnResize : void 8) == null) {
      window.onscroll = scrollHandler;
      window.ontouchmove = scrollHandler;
    }
    window.onresize = scrollHandler;
    return scrollHandler();
  };
  $('link[type="text/css"]').each(function(i, n){
    if (n.href != null) {
      return $.get(n.href, function(it){
        var rules;
        rules = cssParse(it).stylesheet.rules;
        refreshHandler = buildHandlers(rules, refreshHandler);
        if (refreshHandler != null) {
          if (iOS) {
            return installScrollHandler({
              onlyOnResize: true
            });
          } else {
            return installScrollHandler();
          }
        }
      });
    }
  });
}).call(this);

},{"./core":1,"./lib":3,"css-parse":4}],3:[function(require,module,exports){
(function(){
  var debug, perspective, sat, asPercentageOf, asRemainingPercentageOf, shouldDisappear, shouldAppear, selectFrom, ifThenElse, isVerticallyVisible, _module;
  debug = false;
  perspective = function(px){
    return "perspective(" + px + "px) ";
  };
  sat = function(x){
    switch (false) {
    case !(x > 1):
      return 1;
    case !(x < 0):
      return 0;
    default:
      return x;
    }
  };
  asPercentageOf = function(x, y){
    return x / y;
  };
  asRemainingPercentageOf = function(x, y){
    return 1 - asPercentageOf(x, y);
  };
  shouldDisappear = function(context){
    var isHigherThan, isLowerThan, wn, v;
    isHigherThan = context.isHigherThan, isLowerThan = context.isLowerThan;
    wn = context['when'];
    if (isHigherThan != null && wn != null) {
      return sat(asRemainingPercentageOf(wn, isHigherThan));
    }
    if (isLowerThan != null && wn != null) {
      v = sat(asPercentageOf(wn, isLowerThan));
      return v;
    }
  };
  shouldAppear = function(context){
    var isHigherThan, isLowerThan, wn, vv, int;
    isHigherThan = context.isHigherThan, isLowerThan = context.isLowerThan;
    wn = context['when'];
    if (isHigherThan != null && wn != null) {
      int = asPercentageOf(wn, isHigherThan);
    }
    if (isLowerThan != null && wn != null) {
      int = asRemainingPercentageOf(wn, isLowerThan);
    }
    vv = sat(int);
    if (debug) {
      console.log("final: " + vv + ", intermediate: " + int + ", is-higher: " + isHigherThan + ", is-lower: " + isLowerThan);
    }
    return vv;
  };
  selectFrom = function(values){
    var dt, vv, i$, ref$, len$, i, b, error;
    dt = window.dynCss.data['responsive'];
    try {
      if (dt.compiled != null && values.length > 0) {
        vv = dt.compiled();
        for (i$ = 0, len$ = (ref$ = dt.breakpoints).length; i$ < len$; ++i$) {
          i = i$;
          b = ref$[i$];
          if (vv < b || i === values.length - 1) {
            return values[i];
          }
        }
        return values[values.length - 1];
      } else {}
    } catch (e$) {
      error = e$;
    }
  };
  ifThenElse = function(cond, v1, v2){
    if (cond) {
      return v1;
    } else {
      return v2;
    }
  };
  isVerticallyVisible = function(el, threshold){
    var r, w, vp, value;
    r = jQuery(el)[0].getBoundingClientRect();
    w = jQuery(window);
    vp = {};
    vp.top = w.scrollTop();
    vp.bottom = w.scrollTop() + w.height();
    if (threshold == null) {
      threshold = w.height() / 3;
    }
    value = (function(){
      switch (false) {
      case !(r.top >= 0 && r.top < threshold):
        return true;
      case !(r.top < 0 && r.bottom > threshold):
        return true;
      default:
        return false;
      }
    }());
    return value;
  };
  _module = function(){
    var iface;
    iface = {
      shouldDisappear: shouldDisappear,
      shouldAppear: shouldAppear,
      perspective: perspective,
      selectFrom: selectFrom,
      isVerticallyVisible: isVerticallyVisible,
      'if': ifThenElse,
      shouldBeVisible: function(){
        var $wTop, $el, $elTop, $elH, $wHeight, $setOff, v;
        $wTop = $(window).scrollTop();
        $el = jQuery(window.dynCss.el);
        $elTop = $el.offset().top;
        $elH = $el.innerHeight();
        $wHeight = $(window).height();
        $setOff = $elTop;
        v = shouldAppear({
          when: $(window).scrollTop(),
          isHigherThan: $setOff
        });
        if (debug) {
          console.log("top = " + $wTop + ", completed-at = " + $setOff + ", visible = " + v + ", eltop = " + $elTop + ", el-h = " + $elH);
        }
        return v;
      }
    };
    return iface;
  };
  module.exports = _module();
}).call(this);

},{}],4:[function(require,module,exports){

module.exports = function(css, options){
  options = options || {};

  /**
   * Positional.
   */

  var lineno = 1;
  var column = 1;

  /**
   * Update lineno and column based on `str`.
   */

  function updatePosition(str) {
    var lines = str.match(/\n/g);
    if (lines) lineno += lines.length;
    var i = str.lastIndexOf('\n');
    column = ~i ? str.length - i : column + str.length;
  }

  /**
   * Mark position and patch `node.position`.
   */

  function position() {
    var start = { line: lineno, column: column };
    if (!options.position) return positionNoop;

    return function(node){
      node.position = {
        start: start,
        end: { line: lineno, column: column },
        source: options.source
      };

      whitespace();
      return node;
    }
  }

  /**
   * Return `node`.
   */

  function positionNoop(node) {
    whitespace();
    return node;
  }

  /**
   * Error `msg`.
   */

  function error(msg) {
    var err = new Error(msg + ' near line ' + lineno + ':' + column);
    err.filename = options.source;
    err.line = lineno;
    err.column = column;
    err.source = css;
    throw err;
  }

  /**
   * Parse stylesheet.
   */

  function stylesheet() {
    return {
      type: 'stylesheet',
      stylesheet: {
        rules: rules()
      }
    };
  }

  /**
   * Opening brace.
   */

  function open() {
    return match(/^{\s*/);
  }

  /**
   * Closing brace.
   */

  function close() {
    return match(/^}/);
  }

  /**
   * Parse ruleset.
   */

  function rules() {
    var node;
    var rules = [];
    whitespace();
    comments(rules);
    while (css.charAt(0) != '}' && (node = atrule() || rule())) {
      rules.push(node);
      comments(rules);
    }
    return rules;
  }

  /**
   * Match `re` and return captures.
   */

  function match(re) {
    var m = re.exec(css);
    if (!m) return;
    var str = m[0];
    updatePosition(str);
    css = css.slice(str.length);
    return m;
  }

  /**
   * Parse whitespace.
   */

  function whitespace() {
    match(/^\s*/);
  }

  /**
   * Parse comments;
   */

  function comments(rules) {
    var c;
    rules = rules || [];
    while (c = comment()) rules.push(c);
    return rules;
  }

  /**
   * Parse comment.
   */

  function comment() {
    var pos = position();
    if ('/' != css.charAt(0) || '*' != css.charAt(1)) return;

    var i = 2;
    while (null != css.charAt(i) && ('*' != css.charAt(i) || '/' != css.charAt(i + 1))) ++i;
    i += 2;

    var str = css.slice(2, i - 2);
    column += 2;
    updatePosition(str);
    css = css.slice(i);
    column += 2;

    return pos({
      type: 'comment',
      comment: str
    });
  }

  /**
   * Parse selector.
   */

  function selector() {
    var m = match(/^([^{]+)/);
    if (!m) return;
    return trim(m[0]).split(/\s*,\s*/);
  }

  /**
   * Parse declaration.
   */

  function declaration() {
    var pos = position();

    // prop
    var prop = match(/^(\*?[-#\/\*\w]+(\[[0-9a-z_-]+\])?)\s*/);
    if (!prop) return;
    prop = trim(prop[0]);

    // :
    if (!match(/^:\s*/)) return error("property missing ':'");

    // val
    var val = match(/^((?:'(?:\\'|.)*?'|"(?:\\"|.)*?"|\([^\)]*?\)|[^};])+)/);
    if (!val) return error('property missing value');

    var ret = pos({
      type: 'declaration',
      property: prop,
      value: trim(val[0])
    });

    // ;
    match(/^[;\s]*/);

    return ret;
  }

  /**
   * Parse declarations.
   */

  function declarations() {
    var decls = [];

    if (!open()) return error("missing '{'");
    comments(decls);

    // declarations
    var decl;
    while (decl = declaration()) {
      decls.push(decl);
      comments(decls);
    }

    if (!close()) return error("missing '}'");
    return decls;
  }

  /**
   * Parse keyframe.
   */

  function keyframe() {
    var m;
    var vals = [];
    var pos = position();

    while (m = match(/^((\d+\.\d+|\.\d+|\d+)%?|[a-z]+)\s*/)) {
      vals.push(m[1]);
      match(/^,\s*/);
    }

    if (!vals.length) return;

    return pos({
      type: 'keyframe',
      values: vals,
      declarations: declarations()
    });
  }

  /**
   * Parse keyframes.
   */

  function atkeyframes() {
    var pos = position();
    var m = match(/^@([-\w]+)?keyframes */);

    if (!m) return;
    var vendor = m[1];

    // identifier
    var m = match(/^([-\w]+)\s*/);
    if (!m) return error("@keyframes missing name");
    var name = m[1];

    if (!open()) return error("@keyframes missing '{'");

    var frame;
    var frames = comments();
    while (frame = keyframe()) {
      frames.push(frame);
      frames = frames.concat(comments());
    }

    if (!close()) return error("@keyframes missing '}'");

    return pos({
      type: 'keyframes',
      name: name,
      vendor: vendor,
      keyframes: frames
    });
  }

  /**
   * Parse supports.
   */

  function atsupports() {
    var pos = position();
    var m = match(/^@supports *([^{]+)/);

    if (!m) return;
    var supports = trim(m[1]);

    if (!open()) return error("@supports missing '{'");

    var style = comments().concat(rules());

    if (!close()) return error("@supports missing '}'");

    return pos({
      type: 'supports',
      supports: supports,
      rules: style
    });
  }

  /**
   * Parse host.
   */

  function athost() {
    var pos = position();
    var m = match(/^@host */);

    if (!m) return;

    if (!open()) return error("@host missing '{'");

    var style = comments().concat(rules());

    if (!close()) return error("@host missing '}'");

    return pos({
      type: 'host',
      rules: style
    });
  }

  /**
   * Parse media.
   */

  function atmedia() {
    var pos = position();
    var m = match(/^@media *([^{]+)/);

    if (!m) return;
    var media = trim(m[1]);

    if (!open()) return error("@media missing '{'");

    var style = comments().concat(rules());

    if (!close()) return error("@media missing '}'");

    return pos({
      type: 'media',
      media: media,
      rules: style
    });
  }

  /**
   * Parse paged media.
   */

  function atpage() {
    var pos = position();
    var m = match(/^@page */);
    if (!m) return;

    var sel = selector() || [];

    if (!open()) return error("@page missing '{'");
    var decls = comments();

    // declarations
    var decl;
    while (decl = declaration()) {
      decls.push(decl);
      decls = decls.concat(comments());
    }

    if (!close()) return error("@page missing '}'");

    return pos({
      type: 'page',
      selectors: sel,
      declarations: decls
    });
  }

  /**
   * Parse document.
   */

  function atdocument() {
    var pos = position();
    var m = match(/^@([-\w]+)?document *([^{]+)/);
    if (!m) return;

    var vendor = trim(m[1]);
    var doc = trim(m[2]);

    if (!open()) return error("@document missing '{'");

    var style = comments().concat(rules());

    if (!close()) return error("@document missing '}'");

    return pos({
      type: 'document',
      document: doc,
      vendor: vendor,
      rules: style
    });
  }

  /**
   * Parse import
   */

  function atimport() {
    return _atrule('import');
  }

  /**
   * Parse charset
   */

  function atcharset() {
    return _atrule('charset');
  }

  /**
   * Parse namespace
   */

  function atnamespace() {
    return _atrule('namespace')
  }

  /**
   * Parse non-block at-rules
   */

  function _atrule(name) {
    var pos = position();
    var m = match(new RegExp('^@' + name + ' *([^;\\n]+);'));
    if (!m) return;
    var ret = { type: name };
    ret[name] = trim(m[1]);
    return pos(ret);
  }

  /**
   * Parse at rule.
   */

  function atrule() {
    if (css[0] != '@') return;

    return atkeyframes()
      || atmedia()
      || atsupports()
      || atimport()
      || atcharset()
      || atnamespace()
      || atdocument()
      || atpage()
      || athost();
  }

  /**
   * Parse rule.
   */

  function rule() {
    var pos = position();
    var sel = selector();

    if (!sel) return;
    comments();

    return pos({
      type: 'rule',
      selectors: sel,
      declarations: declarations()
    });
  }

  return stylesheet();
};

/**
 * Trim `str`.
 */

function trim(str) {
  return str ? str.replace(/^\s+|\s+$/g, '') : '';
}

},{}]},{},[2])