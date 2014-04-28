perspective = (px) ->
    return "perspective(#{px}px) "

sat = (x) ->
    | x>1 => 1
    | x<0 => 0
    | otherwise => x 


easeOut = (context) ->
    { is-higher-than, is-lower-than } = context
    wn = context['when']
    if is-higher-than? and wn?
        return sat((is-higher-than - wn)/is-higher-than)

    if is-lower-than? and wn?
        v = sat((wn - is-lower-than)/is-lower-than)
        return v

easeIn = (context) ->
    { is-higher-than, is-lower-than } = context
    wn = context['when']
    if is-higher-than? and wn?
        return sat((wn - is-higher-than)/is-higher-than)

    if is-lower-than? and wn?
        v = sat((is-lower-than - wn)/is-lower-than)
        return v

selectFrom = (values) ->
    dt = window.dynCss.data
    if dt.variable?
        nm = dt.variable.replace /@w-(\w+)/g, '$1'
        vv = window.dynCss.lib.wRef[nm]()
        for b,i in dt.breakpoints 
            if vv < b 
                return values[i]
        return values[values.length - 1]
    else 
        return void


_module = ->

          
    iface = {
        easeOut     : easeOut
        easeIn      : easeIn
        perspective : perspective
        selectFrom: selectFrom

        onVerticalTarget: ->
            v = easeIn({when: $(window).scrollTop(), isHigherThan: jQuery(window.dynCss.el).position().top})
            console.log v
            return v
    }
  
    return iface
 
module.exports = _module()