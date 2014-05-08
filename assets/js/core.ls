built-in = require('./lib')

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


    get-scroll-expression = (d) ->
        if (results = d.property is /\-dyn\-(.*)/)?
            property = results[1]
            if (results = d.value is /'(.*)'/)?
                return { property: property, expression: results[1] }
        return undefined

    transcompile-function = (body) ->
        body   = body.replace(/@a-(\w+){(.+)}/g , 'this.lib.jqRef(\'$2\').$1()')
        body   = body.replace(/@p-(\w+){(.+)}/g , 'this.lib.jqRef(\'$2\').position().$1')
        body   = body.replace(/\#{(.+)}/g       , '"+($1)+"')
        body   = body.replace(/@i-(\w+)/g       , 'parseInt(this.el.css(\'$1\'))')
        body   = body.replace(/@j-(\w+)/g       , 'this.lib.jqRef(this.el).$1()')
        body   = body.replace(/@w-(\w+)/g       , '(this.lib.wRef.$1())')
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
                    (e) -> 
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

module.exports = dyn-css
