
css-parse = require('css-parse')
built-in  = require('./lib')
dyn-css   = require('./core')
_q         = require('q')

{ build-handlers } = dyn-css(window, document, jQuery)

#         __                    ____              
#        / /_  ____ _____  ____/ / /__  __________
#       / __ \/ __ `/ __ \/ __  / / _ \/ ___/ ___/
#      / / / / /_/ / / / / /_/ / /  __/ /  (__  ) 
#     /_/ /_/\__,_/_/ /_/\__,_/_/\___/_/  /____/  
#                                                 

blue = '#3498db'
red = '#c0392b'
normal = 'black'

entry-debug-message = (m) ->
    if window.dynCss.config.debug
        console.log "%cdyncss-entry: %c#m", "color: #blue", "color: #normal"

var scroll-handler 

refresh-handler = (changed) ->
        if changed
            window.dynCss.api.force-redraw()
    
decimate        = 1
iOS             = /(iPad|iPhone|iPod)/g.test( navigator.userAgent );
counter         = 0
lt              = 0
fixed-ttc       = (1000/1)

install-custom-raf = ->
    window.custom-request-animation-frame = (cb) ->
        ct = new Date().getTime()
        ttc = Math.max(0, 16 - (ct - lt))
        if fixed-ttc? 
            set-timeout cb, fixed-ttc, true
        else 
            set-timeout cb, ttc, true

        lt := ct + ttc

install-scroll-handler = (options) ->
            scroll-handler := ->
                    if window.dynCss.config.useRAF
                        window.request-animation-frame ->
                            if (counter % decimate) == 0
                                refresh-handler(false)
                            counter := counter + 1
                    else 
                            if (counter % decimate) == 0
                                refresh-handler(false)
                            counter := counter + 1                        

            if options?.only-on-resize?
                window.onresize     = scroll-handler
            else 
                if not options?.only-on-start?
                   window.onscroll     = scroll-handler
                   window.ontouchmove  = scroll-handler
                   window.onresize     = scroll-handler

#                         _                     __            
#        ____ ___  ____ _(_)___     ___  ____  / /________  __
#       / __ `__ \/ __ `/ / __ \   / _ \/ __ \/ __/ ___/ / / /
#      / / / / / / /_/ / / / / /  /  __/ / / / /_/ /  / /_/ / 
#     /_/ /_/ /_/\__,_/_/_/ /_/   \___/_/ /_/\__/_/   \__, /  
#                                                    /____/   

entry-debug-message "Scanning for css" 

parse-css = (n) ->
    entry-debug-message "Loading #{n.href}"
    _d = _q.defer()
    if n.href?
        $.get n.href, ->
            entry-debug-message "Loaded #{n.href}"
            rules = css-parse(it).stylesheet.rules
            refresh-handler := build-handlers(rules, refresh-handler)
            if refresh-handler?
                if iOS
                    install-scroll-handler({+only-on-start})
                else 
                    install-scroll-handler()
            _d.resolve()
    return _d.promise

_loaded_d = _q.defer()
_loaded_p = _loaded_d.promise 

window.onload = ->
    entry-debug-message "Content loaded"
    _loaded_d.resolve()

$(document).ready = ->
    entry-debug-message "Document parsed."

results = $('link[type="text/css"]')
p-array = [ parse-css(r) for r in results ] ++ [ _loaded_p ]

_q.all(p-array).then ->
    entry-debug-message "Initializing handler"
    scroll-handler()            

window.dynCss.api.initVariable = (vr, value) ->
    window.dynCss.lib[vr] = value

window.dynCss.api.setVariable = (vr, value) ->
    window.dynCss.api.initVariable vr, value 
    scroll-handler()

window.dynCss.api.initToggle = (vr, value1, value2) ->
    window.dynCss.api.initVariable vr, value1 
    window.dynCss.api.initVariable vr+"Value0", value1 
    window.dynCss.api.initVariable vr+"Value1", value2 
    entry-debug-message "Initialising variable #vr to #value1"

window.dynCss.api.toggle = (vr) ->
    vv = window.dynCss.lib[vr]
    v1 = window.dynCss.lib[vr+"Value0"]
    v2 = window.dynCss.lib[vr+"Value1"]
    if vv == v1 
        window.dynCss.api.setVariable vr, v2
        entry-debug-message "Setting #vr to #v2"
    else 
        window.dynCss.api.setVariable vr, v1
        entry-debug-message "Setting #vr to #v1"
