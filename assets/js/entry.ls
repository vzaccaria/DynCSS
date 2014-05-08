
css-parse = require('css-parse')
built-in = require('./lib')

dyn-css = (window-di, document-di) ->

    inner-module = ->
      # Use `inner-module` to inject dependencies into `dep`
      # e.g. sinon.stub mod.inner-module().dep, 'method'.
      #
      # You can access `dep` method with plain `dep.method`
      # in functions defined below.
      return root


    window-di.dynCss      = {}
    window-di.dynCss.lib  = built-in
    window-di.dynCss.data = {}


    #         __                    __               _       __      
    #        / /_  ________  ____ _/ /______  ____  (_)___  / /______
    #       / __ \/ ___/ _ \/ __ `/ //_/ __ \/ __ \/ / __ \/ __/ ___/
    #      / /_/ / /  /  __/ /_/ / ,< / /_/ / /_/ / / / / / /_(__  ) 
    #     /_.___/_/   \___/\__,_/_/|_/ .___/\____/_/_/ /_/\__/____/  
    #                               /_/                              

    class breakpoint

        (@name, @breakpoints, @expression) ->
            @expression = transcompile-function @expression
            @compiled = create-function @expression 

    set-named-breakpoints = (name, list, expression) ->
            window-di.dynCss.data[name] = new breakpoint(name, list, expression)

    set-breakpoints = (list, variable) ->
            set-named-breakpoints 'responsive', list, variable

    window-di.dynCss.api = {
        set-breakpoints:            set-breakpoints 
        set-named-breakpoints:      set-named-breakpoints 
    }

    debug = true

    #                           
    #       _________  ________ 
    #      / ___/ __ \/ ___/ _ \
    #     / /__/ /_/ / /  /  __/
    #     \___/\____/_/   \___/ 
    #                           

    camelize = (str) ->
          ex = /[-_\s]+(.)?/g
          return str.replace ex, (m, c) ->
                | c? => c.toUpperCase()
                | otherwise => ""


    scroll-handlers = {}

    get-scroll-expression = (d) ->
        if (results = d.property is /\-dyn\-(.*)/)?
            property = results[1]
            if (results = d.value is /'(.*)'/)?
                return { property: property, expression: results[1] }
        return undefined

    transcompile-function = (body) ->
        body   = body.replace(/@a-(\w+){(.+)}/g , 'jQuery(\'$2\').$1()')
        body   = body.replace(/@p-(\w+){(.+)}/g , 'jQuery(\'$2\').position().$1')
        body   = body.replace(/\#{(.+)}/g       , '"+($1)+"')
        body   = body.replace(/@i-(\w+)/g       , 'parseInt(this.el.css(\'$1\'))')
        body   = body.replace(/@j-(\w+)/g       , 'jQuery(this.el).$1()')
        body   = body.replace(/@w-(\w+)/g       , '(this.lib.wRef.$1())')
        body   = body.replace(/@/g              , 'this.lib.')
        return body        

    create-function = (body) ->

        script = document-di.createElement("script")
        script.text = "window.tmp = function() { return (#body); }.bind(window.dynCss);"

        document-di.head.appendChild( script ).parentNode.removeChild( script );
        return window-di.tmp


    build-handlers = (rules, refresh-handler) ->

      window-di.dynCss.lib.wRef = jQuery(window-di)


      for rule in rules 
        if rule.type is "rule"
            sel = rule.selectors

            actions = []

            for decl in rule.declarations 
                result = get-scroll-expression(decl)

                if result?

                    { property, expression, trigger} = result 
                    comp    = transcompile-function expression
                    handler = create-function comp

                    actions.push { property: camelize(property), original-property: property, funct: handler, sel: sel }

            wrapper = (next) ->
                let act = actions, scoped-sel=sel
                    (e) -> 
                        for sct in scoped-sel
                            jQuery(sct).each (i) ->
                                window-di.dynCss.el = jQuery(this)
                                css = {} 
                                for a in act 
                                    if (r = (a.original-property == /set-state-(.+)/))
                                        cc = r[1]
                                        if a.funct()
                                            window-di.dynCss.el.addClass(cc)
                                        else 
                                            window-di.dynCss.el.removeClass(cc)
                                    else 
                                        css[a.property] = a.funct()

                                window-di.dynCss.el.css(css)

                        next(e) if next?

            if actions.length != 0
                refresh-handler := wrapper(refresh-handler)                

      return refresh-handler

    return {
        inner-module: inner-module
        build-handlers: build-handlers
    }

{ build-handlers } = dyn-css(window, document)

#         __                    ____              
#        / /_  ____ _____  ____/ / /__  __________
#       / __ \/ __ `/ __ \/ __  / / _ \/ ___/ ___/
#      / / / / /_/ / / / / /_/ / /  __/ /  (__  ) 
#     /_/ /_/\__,_/_/ /_/\__,_/_/\___/_/  /____/  
#                                                 

refresh-handler = undefined
decimate        = 1
iOS             = /(iPad|iPhone|iPod)/g.test( navigator.userAgent );
counter         = 0
lt              = 0
fixed-ttc       = (1000/1)

install-custom-raf = ->
    window.customRAF = (cb) ->
        ct = new Date().getTime()
        ttc = Math.max(0, 16 - (ct - lt))
        if fixed-ttc? 
            set-timeout cb, fixed-ttc, true
        else 
            set-timeout cb, ttc, true

        lt := ct + ttc

install-custom-raf-handler = ->
    install-custom-raf()
    wrapped-handler = ->
        customRAF wrapped-handler 
        refresh-handler()

    customRAF(wrapped-handler)
    refresh-handler()

install-raf-handler = ->
            wrapped-handler = ->
                request-animation-frame wrapped-handler 
                refresh-handler()

            request-animation-frame(wrapped-handler)

install-scroll-handler = (options) ->
            scroll-handler = ->
                if (counter % decimate) == 0
                    refresh-handler()
                counter := counter + 1

            if not options?.only-on-resize?
                window.onscroll     = scroll-handler
                window.ontouchmove  = scroll-handler

            window.onresize     = scroll-handler
            scroll-handler()

#                         _                     __            
#        ____ ___  ____ _(_)___     ___  ____  / /________  __
#       / __ `__ \/ __ `/ / __ \   / _ \/ __ \/ __/ ___/ / / /
#      / / / / / / /_/ / / / / /  /  __/ / / / /_/ /  / /_/ / 
#     /_/ /_/ /_/\__,_/_/_/ /_/   \___/_/ /_/\__/_/   \__, /  
#                                                    /____/   

$('link[type="text/css"]').each (i,n) ->
    if n.href?
        $.get n.href, ->
            rules = css-parse(it).stylesheet.rules
            refresh-handler := build-handlers(rules, refresh-handler)
            if refresh-handler?
                if iOS
                    install-scroll-handler({+only-on-resize})
                else 
                    install-scroll-handler()
            

            # window.onscroll = refresh-handler
            # window.onresize = refresh-handler 
            # refresh-handler()



