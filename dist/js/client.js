(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
(function(){
  var cssParse, camelize, scrollHandlers, getScrollExpression, createFunction, wRef, updateScope, refreshHandler, buildHandlers, decimate, iOS, counter, lt, fixedTtc, installCustomRaf, installCustomRafHandler, installRafHandler, installScrollHandler;
  cssParse = require('css-parse');
  window.dynCss = {};
  window.dynCss.lib = require('./lib');
  window.dynCss.data = {};
  window.dynCss.data.breakpoints = [];
  window.dynCss.data.variable = void 8;
  window.dynCss.api = {
    setBreakpoints: function(list, variable){
      window.dynCss.data.breakpoints = list;
      return window.dynCss.data.variable = variable;
    }
  };
  require('./sta');
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
  scrollHandlers = {};
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
  createFunction = function(body){
    var script;
    body = body.replace(/\#{(.+)}/g, '"+($1)+"');
    body = body.replace(/\#(\w+)/g, '"+($1)+"');
    body = body.replace(/@i-(\w+)/g, 'parseInt(this.el.css(\'$1\'))');
    body = body.replace(/@j-(\w+)/g, 'jQuery(this.el).$1()');
    body = body.replace(/@w-(\w+)/g, '(this.lib.wRef.$1())');
    body = body.replace(/@/g, 'this.lib.');
    script = document.createElement("script");
    console.log(body);
    script.text = "window.tmp = function() { return (" + body + "); }.bind(window.dynCss);";
    document.head.appendChild(script).parentNode.removeChild(script);
    return window.tmp;
  };
  wRef = $(window);
  updateScope = function(){
    return window.dynCss.lib.wRef = wRef;
  };
  refreshHandler = undefined;
  buildHandlers = function(rules){
    var i$, len$, rule, sel, actions, j$, ref$, len1$, decl, result, property, expression, trigger, handler, wrapper, results$ = [];
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
            handler = createFunction(expression);
            actions.push({
              property: camelize(property),
              funct: handler,
              sel: sel
            });
          }
        }
        wrapper = fn$;
        if (actions.length !== 0) {
          results$.push(refreshHandler = wrapper(refreshHandler));
        }
      }
    }
    return results$;
    function fn$(next){
      return (function(act){
        return function(e){
          var css, i$, ref$, len$, a, sct;
          updateScope();
          css = {};
          for (i$ = 0, len$ = (ref$ = act).length; i$ < len$; ++i$) {
            a = ref$[i$];
            css[a.property] = a.funct();
          }
          for (i$ = 0, len$ = (ref$ = a.sel).length; i$ < len$; ++i$) {
            sct = ref$[i$];
            $(sct).each(fn$);
          }
          if (next != null) {
            return next(e);
          }
          function fn$(i){
            window.dynCss.el = $(this);
            return $(this).css(css);
          }
        };
      }.call(this, actions));
    }
  };
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
  installScrollHandler = function(){
    var scrollHandler;
    scrollHandler = function(){
      if (counter % decimate === 0) {
        refreshHandler();
      }
      return counter = counter + 1;
    };
    window.onscroll = scrollHandler;
    window.onresize = scrollHandler;
    window.ontouchmove = scrollHandler;
    return scrollHandler();
  };
  $('link[type="text/css"]').each(function(i, n){
    if (n.href != null) {
      return $.get(n.href, function(it){
        var rules;
        rules = cssParse(it).stylesheet.rules;
        buildHandlers(rules);
        if (iOS) {
          return installCustomRafHandler();
        } else {
          return installScrollHandler();
        }
      });
    }
  });
}).call(this);

},{"./lib":2,"./sta":3,"css-parse":4}],2:[function(require,module,exports){
(function(){
  var translate, translate3d, perspective, sat, easeOut, easeIn, selectFrom, _module;
  translate = function(vy, vx){
    vx == null && (vx = 0);
    return "translate(" + vx + "px," + vy + "px) ";
  };
  translate3d = function(vx, vy, vz){
    return "translate3d(" + vx + "px," + vy + "px," + vz + "px) ";
  };
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
  easeOut = function(context){
    var isHigherThan, isLowerThan, wn, v;
    isHigherThan = context.isHigherThan, isLowerThan = context.isLowerThan;
    wn = context['when'];
    if (isHigherThan != null && wn != null) {
      return sat((isHigherThan - wn) / isHigherThan);
    }
    if (isLowerThan != null && wn != null) {
      v = sat((wn - isLowerThan) / isLowerThan);
      return v;
    }
  };
  easeIn = function(context){
    var isHigherThan, isLowerThan, wn, v;
    isHigherThan = context.isHigherThan, isLowerThan = context.isLowerThan;
    wn = context['when'];
    if (isHigherThan != null && wn != null) {
      return sat((wn - isHigherThan) / isHigherThan);
    }
    if (isLowerThan != null && wn != null) {
      v = sat((isLowerThan - wn) / isLowerThan);
      return v;
    }
  };
  selectFrom = function(values){
    var dt, nm, vv, i$, ref$, len$, i, b;
    dt = window.dynCss.data;
    if (dt.variable != null) {
      nm = dt.variable.replace(/@w-(\w+)/g, '$1');
      vv = window.dynCss.lib.wRef[nm]();
      for (i$ = 0, len$ = (ref$ = dt.breakpoints).length; i$ < len$; ++i$) {
        i = i$;
        b = ref$[i$];
        if (vv < b) {
          return values[i];
        }
      }
      return values[values.length - 1];
    } else {}
  };
  _module = function(){
    var iface;
    iface = {
      easeOut: easeOut,
      easeIn: easeIn,
      perspective: perspective,
      selectFrom: selectFrom
    };
    return iface;
  };
  module.exports = _module();
}).call(this);

},{}],3:[function(require,module,exports){
(function(){
  (function(window){
    var createTimer, resetTimer, timeouts, intervals, orgSetTimeout, orgSetInterval, orgClearTimeout, orgClearInterval;
    createTimer = function(set, map, args){
      var callback, id, cb, repeat;
      callback = function(){
        var cb;
        if (cb) {
          cb.apply(window, arguments);
          if (!repeat) {
            delete map[id];
            return cb = null;
          }
        }
      };
      id = void 8;
      cb = args[0];
      repeat = set === orgSetInterval;
      args[0] = callback;
      id = set.apply(window, args);
      map[id] = {
        args: args,
        created: Date.now(),
        cb: cb,
        id: id
      };
      return id;
    };
    resetTimer = function(set, clear, map, virtualId, correctInterval){
      var callback, timer, repeat, interval, reduction;
      callback = function(){
        if (timer.cb) {
          timer.cb.apply(window, arguments);
          if (!repeat) {
            delete map[virtualId];
            return timer.cb = null;
          }
        }
      };
      timer = map[virtualId];
      if (!timer) {
        return;
      }
      repeat = set === orgSetInterval;
      clear(timer.id);
      if (!repeat) {
        interval = timer.args[1];
        reduction = Date.now() - timer.created;
        if (reduction < 0) {
          reduction = 0;
        }
        interval -= reduction;
        if (interval < 0) {
          interval = 0;
        }
        timer.args[1] = interval;
      }
      timer.args[0] = callback;
      timer.created = Date.now();
      return timer.id = set.apply(window, timer.args);
    };
    timeouts = {};
    intervals = {};
    orgSetTimeout = window.setTimeout;
    orgSetInterval = window.setInterval;
    orgClearTimeout = window.clearTimeout;
    orgClearInterval = window.clearInterval;
    window.setTimeout = function(){
      return createTimer(orgSetTimeout, timeouts, arguments);
    };
    window.setInterval = function(){
      return createTimer(orgSetInterval, intervals, arguments);
    };
    window.clearTimeout = function(id){
      var timer;
      timer = timeouts[id];
      if (timer) {
        delete timeouts[id];
        return orgClearTimeout(timer.id);
      }
    };
    window.clearInterval = function(id){
      var timer;
      timer = intervals[id];
      if (timer) {
        delete intervals[id];
        return orgClearInterval(timer.id);
      }
    };
    return window.addEventListener('scroll', function(){
      var virtualId, results$ = [];
      virtualId = void 8;
      for (virtualId in timeouts) {
        resetTimer(orgSetTimeout, orgClearTimeout, timeouts, virtualId);
      }
      for (virtualId in intervals) {
        results$.push(resetTimer(orgSetInterval, orgClearInterval, intervals, virtualId));
      }
      return results$;
    });
  })(window);
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

},{}]},{},[1])