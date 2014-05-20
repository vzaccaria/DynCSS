
const debug = false

perspective = (px) ->
    return "perspective(#{px}px) "

sat = (x) ->
    | x>1 => 1
    | x<0 => 0
    | otherwise => x 

as-percentage-of = (/)

as-remaining-percentage-of = (x, y) -> 
    1 - x `as-percentage-of` y

shouldDisappear = (context) ->
    { is-higher-than, is-lower-than, when: wn } = context
    if is-higher-than? and wn?
        return sat(wn `as-remaining-percentage-of` is-higher-than)

    if is-lower-than? and wn?
        v = sat(wn `as-percentage-of` is-lower-than)
        return v

transitionToOne = (context, power = 1) ->
    var int, vv, direction

    { start, stop, when: val } = context
    orig = val

    pp = 
        | start<stop and val<start => 0
        | start<stop and val>stop  => 1
        | start<stop => (val - start) / (stop - start)
        | start>stop and val>start => 1
        | start>stop and val<stop  => 0
        | start>stop => 1 - (val - stop) / (start - stop)

    vv = sat(pp)
    return vv ** power


shouldAppear = (context) ->
    { is-higher-than, is-lower-than, when: wn } = context
    wn = context['when']
    var vv, int

    if is-higher-than? and wn?
        int := wn `as-percentage-of` is-higher-than

    if is-lower-than? and wn?
        int := wn `as-remaining-percentage-of` is-lower-than

    vv  := sat(int)
    console.log "final: #vv, intermediate: #int, is-higher: #is-higher-than, is-lower: #is-lower-than" if debug

    return vv

selectFrom = (values) ->
    dt = window.dynCss.data['responsive']
    try
        if dt.compiled? and values.length > 0
            vv = dt.compiled()
            for b,i in dt.breakpoints 

                if vv < b or (i == (values.length - 1))
                    return values[i]

            return values[* - 1]
    catch error

ifThenElse = (cond, v1, v2) ->
    if cond
        v1 
    else 
        v2

isVerticallyVisible = (el, threshold) ->

    r         = jQuery(el)[0].getBoundingClientRect!
    w         = jQuery(window)
    vp        =
        top:    w.scrollTop!
        bottom: w.scrollTop! + w.height!

    threshold ?= w.height! / 3


    value = 
        | r.top >= 0 and r.top < threshold   => true
        | r.top < 0 and r.bottom > threshold => true
        | otherwise                          => false

    return value


# These work only on fixed position elements

top-of = (el) ->
    if el != window
        jQuery(el).offset!top - $(window).scrollTop!
    else 
        0

bottom-of = (el) ->
    if el != window
        jQuery(el).offset!top - $(window).scrollTop! + parseInt(jQuery(el).css('margin-bottom')) + jQuery(el).innerHeight!
    else 
        $(window).height!

left-of = (el) ->
    if el != window
        jQuery(el).offset!.left + parseInt(jQuery(el).css('margin-right'))
    else 
        0    

right-of = (el) ->
    if el != window
        jQuery(el).offset!.left + parseInt(jQuery(el).css('margin-right')) + jQuery(el).innerWidth()
    else 
        $(window).width!
    # jQuery(el).offset().left + parseInt(jQuery(el).css('margin-left')) + jQuery(el).innerWidth()


    
_module = ->

          
    iface = 
        shouldDisappear     : shouldDisappear
        convergeToZero      : shouldDisappear
        shouldAppear        : shouldAppear
        convergeToOne       : shouldAppear

        transitionToOne     : transitionToOne

        perspective         : perspective
        selectFrom          : selectFrom
        isVerticallyVisible : isVerticallyVisible
        if                  : ifThenElse

        fixed-top-edge      : top-of
        fixed-bottom-edge   : bottom-of
        fixed-right-edge    : right-of
        fixed-left-edge     : left-of

        pos: (el) -> # could be (.offset) . ($)
            $(el).offset!


        fixed-horizontal-center: ->
            (right-of(it) + left-of(it)) / 2

        fixed-vertical-center: ->
            (top-of(it) + bottom-of(it)) / 2

        morph: (c, v1, v2) ->
            vv = v1*(1-c) + v2*c
            return vv


        should-be-visible: ->
            $w-top    = $(window).scrollTop!
            $el       = jQuery(window.dynCss.el)
            $el-top   = $el.offset!top
            $el-h     = $el.innerHeight!
            $w-height = $(window).height!
            $set-off  = $el-top
            v         = shouldAppear(when: $(window).scrollTop!, is-higher-than: $set-off)

            console.log "top = #{$w-top}, completed-at = #{$set-off}, visible = #v, eltop = #{$el-top}, el-h = #{$el-h}" if debug
            return v
    
  
    return iface
 
module.exports = _module()
