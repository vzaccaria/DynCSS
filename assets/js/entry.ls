
css-parse = require('css-parse')
window.dynCss = {}
window.dynCss.lib = require('./lib')

window.dynCss.data = {}


#         __                    __               _       __      
#        / /_  ________  ____ _/ /______  ____  (_)___  / /______
#       / __ \/ ___/ _ \/ __ `/ //_/ __ \/ __ \/ / __ \/ __/ ___/
#      / /_/ / /  /  __/ /_/ / ,< / /_/ / /_/ / / / / / /_(__  ) 
#     /_.___/_/   \___/\__,_/_/|_/ .___/\____/_/_/ /_/\__/____/  
#                               /_/                              

class breakpoint

    (@name, @breakpoints, @expression) ->
        @compiled = create-function @expression 

set-named-breakpoints = (name, list, expression) ->
        window.dynCss.data[name] = new breakpoint(name, list, expression)

set-breakpoints = (list, variable) ->
        set-named-breakpoints 'responsive', list, variable

window.dynCss.api = {
    set-breakpoints:            set-breakpoints 
    set-named-breakpoints:      set-named-breakpoints 
}

debug = false

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

create-function = (body) ->

    body   = body.replace(/@a-(\w+){(.+)}/g, 'jQuery(\'$2\').$1()')
    body   = body.replace(/@p-(\w+){(.+)}/g, 'jQuery(\'$2\').position().$1')
    body   = body.replace(/\#{(.+)}/g, '"+($1)+"')
    body   = body.replace(/\#(\w+)/g, '"+($1)+"')
    body   = body.replace(/@i-(\w+)/g,'parseInt(this.el.css(\'$1\'))')
    body   = body.replace(/@j-(\w+)/g,'jQuery(this.el).$1()')
    body   = body.replace(/@w-(\w+)/g,'(this.lib.wRef.$1())')
    body   = body.replace(/@/g,'this.lib.')
   
    console.log body if debug
    script = document.createElement("script")
    script.text = "window.tmp = function() { return (#body); }.bind(window.dynCss);"
    document.head.appendChild( script ).parentNode.removeChild( script );
    return window.tmp


wRef = $(window)

update-scope = ->
        window.dynCss.lib.wRef = wRef 

refresh-handler = undefined

build-handlers = (rules) ->
  for rule in rules 
    if rule.type is "rule"
        sel = rule.selectors

        actions = []

        for decl in rule.declarations 
            result = get-scroll-expression(decl)

            if result?

                { property, expression, trigger} = result 
                handler = create-function expression

                # let fun = handler, pro = camelize(property), s = sel
                actions.push { property: camelize(property), funct: handler, sel: sel }

        wrapper = (next) ->
            let act = actions, scoped-sel=sel
                (e) -> 
                    update-scope()

                    for sct in scoped-sel
                        $(sct).each (i) ->
                            window.dynCss.el = $(this)
                            css = {} 
                            for a in act 
                                css[a.property] = a.funct()
                            $(this).css(css)

                    next(e) if next?

        if actions.length != 0
            refresh-handler := wrapper(refresh-handler)                


#         __                    ____              
#        / /_  ____ _____  ____/ / /__  __________
#       / __ \/ __ `/ __ \/ __  / / _ \/ ___/ ___/
#      / / / / /_/ / / / / /_/ / /  __/ /  (__  ) 
#     /_/ /_/\__,_/_/ /_/\__,_/_/\___/_/  /____/  
#                                                 

decimate = 1
iOS = /(iPad|iPhone|iPod)/g.test( navigator.userAgent );
counter = 0
lt = 0

fixed-ttc = (1000/1)

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

            if not options?.only-resize?
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
            build-handlers(rules)
            if iOS
                install-scroll-handler({+only-resize})
            else 
                install-scroll-handler()
            

            # window.onscroll = refresh-handler
            # window.onresize = refresh-handler 
            # refresh-handler()



