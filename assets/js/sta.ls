((window) ->

  createTimer = (set, map, args) ->
    callback = ->
      if cb
        cb.apply window, arguments
        if not repeat
          delete! map[id]
          cb = null
  
    id     = void
    cb     = args.0
    repeat = set is orgSetInterval
    args.0 = callback
    id     = set.apply window, args
    
    map[id] = {
      args: args
      created: Date.now!
      cb: cb
      id: id
    }
    id
  
  resetTimer = (set, clear, map, virtualId, correctInterval) ->

    callback = ->
      if timer.cb
        timer.cb.apply window, arguments
        if not repeat
          delete! map[virtualId]
          timer.cb = null
    timer = map[virtualId]
    return  if not timer
    repeat = set is orgSetInterval
    clear timer.id

    if not repeat

      interval = timer.args.1
      reduction = Date.now! - timer.created
      reduction = 0 if reduction < 0
      interval -= reduction
      
      if interval < 0 then interval = 0
      
      timer.args.1 = interval

    timer.args.0 = callback
    timer.created = Date.now!
    timer.id = set.apply window, timer.args
  
  timeouts         = {}
  intervals        = {}
  orgSetTimeout    = window.setTimeout
  orgSetInterval   = window.setInterval
  orgClearTimeout  = window.clearTimeout
  orgClearInterval = window.clearInterval
  
  window.setTimeout = -> createTimer orgSetTimeout, timeouts, arguments
  window.setInterval = -> createTimer orgSetInterval, intervals, arguments
  
  window.clearTimeout = (id) ->
    timer = timeouts[id]
    if timer
      delete! timeouts[id]
      orgClearTimeout timer.id
  
  window.clearInterval = (id) ->
    timer = intervals[id]
    if timer
      delete! intervals[id]
      orgClearInterval timer.id
  
  window.addEventListener 'scroll', ->
    virtualId = void
    for virtualId of timeouts
      resetTimer orgSetTimeout, orgClearTimeout, timeouts, virtualId
    [resetTimer orgSetInterval, orgClearInterval, intervals, virtualId for virtualId of intervals]) window