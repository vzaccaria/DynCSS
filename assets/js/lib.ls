translate = (vy, vx = 0) ->
    "translate(#{vx}px,#{vy}px) "

translate3d = (vx, vy, vz) ->
    "translate3d(#{vx}px,#{vy}px,#{vz}px) "

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

_module = ->

          
    iface = {
        easeOut     : easeOut
        easeIn      : easeIn
        translate   : translate
        translate3d : translate3d
        perspective : perspective

    }
  
    return iface
 
module.exports = _module()