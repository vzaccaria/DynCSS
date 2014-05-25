built-in = require('./lib')

blue = '#3498db'
red = '#c0392b'
normal = 'black'

core-debug-message = (m) ->
    if window.dynCss.config.debug
        console.log "%cdyncss-core : %c#m", "color: #blue", "color: #normal"

core-heavy-debug-message = (m) ->
    if window.dynCss.config.debug
        console.log "%cdyncss-core : %c#m", "color: #red", "color: #normal"

dyn-css = (window-di, document-di, jq-di) ->

    inner-module = ->
      # Use `inner-module` to inject dependencies into `dep`
      # e.g. sinon.stub mod.inner-module().dep, 'method'.
      #
      # You can access `dep` method with plain `dep.method`
      # in functions defined below.
      return this 


    window-di.dynCss      = {}
    window-di.dynCss.lib  = built-in
    window-di.dynCss.data = {}
    window-di.dynCss.config = 
        debug: false
        dontComputeInvisible: false
        useRAF: false;


    #         __                    __               _       __      
    #        / /_  ________  ____ _/ /______  ____  (_)___  / /______
    #       / __ \/ ___/ _ \/ __ `/ //_/ __ \/ __ \/ / __ \/ __/ ___/
    #      / /_/ / /  /  __/ /_/ / ,< / /_/ / /_/ / / / / / /_(__  ) 
    #     /_.___/_/   \___/\__,_/_/|_/ .___/\____/_/_/ /_/\__/____/  
    #                               /_/                              

    class breakpoint

        (@name, @breakpoints, @expression) ->
            @expression = transcompile-function @expression
            @compiled = window-di.dynCss.api.create-function @expression 

    set-named-breakpoints = (name, list, expression) ->
            window-di.dynCss.data[name] = new breakpoint(name, list, expression)

    set-breakpoints = (list, variable) ->
            set-named-breakpoints 'responsive', list, variable

    window-di.dynCss.api = {
        set-breakpoints:            set-breakpoints 
        set-named-breakpoints:      set-named-breakpoints 

        force-redraw: ->
            ss = document.styleSheets[0];
            try 
                ss.addRule('.xxxxxx', 'position: relative'); 
            catch

        force-redraw-brute: ->
            $(window).hide().show()
    }

    

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


    get-scroll-expression = (d) ->
        if (results = d.property is /\-dyn\-(.*)/)?
            property = results[1]
            if (results = d.value is /'(.*)'/)?
                expression = results[1]

                if property == 'fixed-right-edge'

                    property   = 'left'
                    expression = "#expression - @el-width"

                if property == 'fixed-left-edge'

                    property   = 'left'
                    expression = "#expression"

                if property == 'fixed-bottom-edge'

                    property   = 'top'
                    expression = "#expression - @el-height"

                if property == 'fixed-top-edge'

                    property   = 'top'
                    expression = "#expression"

                if property == 'fixed-horizontal-center'

                    property   = 'left'
                    expression = "#expression - @el-width/2"

                if property == 'fixed-vertical-center'

                    property   = 'top'
                    expression = "#expression - @el-height/2"

                return { property: property, expression: expression }
        return undefined

    transcompile-function = (body) ->
        core-debug-message body if window-di.dynCss.config.debug
        body   = body.replace(/@a-(\w+){(.+)}/g , 'this.lib.jqRef(\'$2\').$1()')
        body   = body.replace(/\#{(.+)}/g       , '"+($1)+"')
        body   = body.replace(/@i-(\w+)/g       , 'parseInt(this.el.css(\'$1\'))')
        body   = body.replace(/@j-(\w+)/g       , 'this.lib.jqRef(this.el).$1()')
        body   = body.replace(/@w-(\w+)/g       , '(this.lib.wRef.$1())')
        body   = body.replace(/@el-(\w+)/g      , 'parseInt(this.el.css(\'$1\'))')
        body   = body.replace(/@jq-(\w+)/g      , 'this.lib.jqRef(this.el).$1()')
        body   = body.replace(/@win-(\w+)/g     , '(this.lib.wRef.$1())')
        body   = body.replace(/@/g              , 'this.lib.')
        return body        

    window-di.dynCss.api.create-function = (body) ->

        script = document-di.createElement("script")
        script.text = "window.tmp = function() { return (#body); }.bind(window.dynCss);"

        document-di.head.appendChild( script ).parentNode.removeChild( script );
        return window-di.tmp


    build-handlers = (rules, refresh-handler) ->

      window-di.dynCss.lib.jqRef = jq-di
      window-di.dynCss.lib.wRef  = jq-di(window-di)


      for rule in rules 
        if rule.type is "rule"
            sel = rule.selectors

            actions = []

            for decl in rule.declarations 
                result = get-scroll-expression(decl)
                if result?

                    { property, expression, trigger} = result 
                    comp    = transcompile-function expression
                    handler = window-di.dynCss.api.create-function comp
                    actions.push { property: camelize(property), original-property: property, funct: handler, sel: sel }

            wrapper = (next) ->
                let act = actions, scoped-sel=sel
                    (changed) -> 
                        for sct in scoped-sel
                            jq-di(sct).each (i) ->
                                window-di.dynCss.el = jq-di(this)
                                css = {} 
                                for a in act 
                                    if (r = (a.original-property == /set-state-(.+)/))
                                        cc = r[1]
                                        if a.funct()
                                            window-di.dynCss.el.addClass(cc)
                                        else 
                                            window-di.dynCss.el.removeClass(cc)
                                    else 
                                        core-debug-message "Assigning to #{sct}.#{a.property} value #{a.funct()}" if window-di.dynCss.config.debug
                                        css[a.property] = a.funct()


                                for k,v of css 
                                    is-initial-phase = (not this.old-value?) or (not this.old-value?[k]?)
                                    is-changed = (this.old-value? and this.old-value[k]? and css[k] != this.old-value[k])
                                    # is-not-hidden = (css['display']?) and not (css['display']='hidden') 
                                    is-not-hidden = 
                                        | not window-di.dynCss.config.dontComputeInvisible => true 
                                        | window-di.dynCss.el.css('display') != 'none' => true 
                                        | otherwise => false 
                                        
                                    is-visibility-toggled = (k == 'display')
                                    if (is-initial-phase and is-not-hidden) or (is-changed and is-not-hidden) or (is-changed and is-visibility-toggled)
                                        core-heavy-debug-message "#sct - #k transition (#{this.old-value?[k]} --> #{css[k]})" if window-di.dynCss.config.debug
                                        window-di.dynCss.el.css({"#k": v})
                                        this.old-value ?= {}
                                        this.old-value[k] = v
                                        changed := true

                                new-value = JSON.stringify(css)

                        next(changed) if next?

            if actions.length != 0
                refresh-handler := wrapper(refresh-handler)                

      return refresh-handler

    return {
        inner-module: inner-module
        build-handlers: build-handlers
    }

module.exports = dyn-css
