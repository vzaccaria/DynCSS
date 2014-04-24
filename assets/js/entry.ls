
css-parse = require('css-parse')

window.dynCss = {}
window.dynCss.lib = require('./lib')


scroll-handlers = {}
sheets          = []

allow-element-selectors = true 

# From http://davidwalsh.name/add-rules-stylesheets

create-sheet = ->
    style = document.createElement "style" 
    style.setAttribute "media", "screen" 
    style.appendChild document.createTextNode ""  
    document.head.appendChild style 
    return style.sheet

get-css-rules = (sheet) ->
    if sheet.rules?
        return sheet.rules 
    else    
        return sheet.cssRules

add-css-rule = (sheet, selector, rules, index) ->
    if sheet.insert-rule?
        sheet.insert-rule "#selector { #rules }", index
    else 
        sheet.add-rule selector, rules, index

    index = get-css-rules(sheet).length - 1
    return { ref: get-css-rules(sheet)[index].style, index: index }

get-scroll-expression = (d) ->
    if (results = d.property is /\-dyn\-(.*)/)?
        property = results[1]
        if (results = d.value is /'(.*)'/)?
            return { property: property, expression: results[1] }
    return undefined

create-function = (body) ->

    body   = body.replace(/\#{(.+)}/g, '"+($1)+"')
    body   = body.replace(/\#(\w+)/g, '"+($1)+"')
    body   = body.replace(/@i-(\w+)/g,'parseInt(this.el.css(\'$1\'))')
    body   = body.replace(/@w-(\w+)/g,'(this.lib.wRef.$1())')
    body   = body.replace(/@/g,'this.lib.')
    
    script = document.createElement("script")
    console.log body
    script.text = "window.tmp = function() { return (#body); }.bind(window.dynCss);"
    document.head.appendChild( script ).parentNode.removeChild( script );
    return window.tmp


wRef = $(window)

update-scope = ->
        window.dynCss.lib.wRef = wRef 

refresh-handler = undefined

build-handlers = (rules, sheet) ->
  for rule in rules 
    if rule.type is "rule"
        sel = rule.selectors

        for decl in rule.declarations 
            result = get-scroll-expression(decl)

            if result?
                { property, expression, trigger} = result 
                { ref, index } = add-css-rule sheet, sel, ""
                handler = create-function expression

                wrapper = (next) ->
                    wRef = $(window)
                    let i = index, fun = handler, pro = _.str.camelize(property), s = sel
                        (e) -> 
                            update-scope()

                            for sct in s 
                                $(sct).each (i) ->
                                    window.dynCss.el = $(this)
                                    val = fun()
                                    $(this).css(pro, val)

                            next(e) if next?

                refresh-handler := wrapper(refresh-handler)                

 


$('link[type="text/css"]').each (i,n) ->
    if n.href?
        $.get n.href, ->
            sheet = create-sheet()
            sheets.push(sheet)
            rules = css-parse(it).stylesheet.rules
            build-handlers(rules, sheet)
            window.onscroll = refresh-handler
            window.onresize = refresh-handler 
            refresh-handler()



