
css-parse = require('css-parse')
built-in  = require('./lib')
dyn-css   = require('./core')

{ build-handlers } = dyn-css(window, document, jQuery)

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



