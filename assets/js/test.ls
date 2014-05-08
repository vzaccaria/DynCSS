

require! 'should'
require! 'sinon'

moment = require 'moment'
__q    = require('q')

notifies-on-fail = (p, cb) ->
    p.then((-> cb(it)),(-> cb()))

notifies-on-success = (p, cb) ->
    p.then((-> cb()), (-> cb(it)))

create-resolved-promise = ->
    d = __q.defer()
    p = d.promise   
    d.resolve()
    return p

create-rejected-promise = ->
    d = __q.defer()
    p = d.promise   
    d.reject()
    return p

var dyncss

var window-di
var jq-di 
var el-di
var document-di
var temp-stub1
var rules
var iterator

quote = (i) -> "\'#i\'"

describe 'DynCSS tests - base', (empty) ->
    before-each ->

        dyncss      := require('./core')

        window-di   := { type: "window" }

        document-di := { type: "document" }

        el-di       := { 
            type: "element" 
            css: (css) -> 

            }

        iterator    := {
            each: (cb) ->
                cb.apply(el-di, [0])
            }

        # That's a short jquery hack..
        jq-di       := (sel) ->

            if not sel.type? and sel == '.test' 
                return iterator

            if sel.type == "window"
                return window-di

            if sel.type == "element"
                return el-di

        dyncss      := dyncss(window-di,  document-di ,  jq-di)

        window-di.width  = -> 100
        window-di.height = -> 100

        # sinon.stub window-di, 'height', -> 200

        rules := [

            * type: 'rule'
              selectors: ['.test']
              declarations: [
                * property: '-dyn-width'
                  value: quote(333)
              ]

        ]

        temp-stub1 := sinon.stub window-di.dynCss.api, 'createFunction', (body) ->
            (-> eval(body)).bind(window-di.dynCss)

    after-each ->
        temp-stub1.restore()



    it 'should instantiate correctly main module',  ->
        should.exist(dyncss)

    it 'should instantiate internal data structures', ->
        should.exist(window-di.dynCss.data)

    it 'should instantiate breakpoint api', ->
        should.exist(window-di.dynCss.api.set-breakpoints)

    it 'should access inner module functions', -> 
        should.exist(window-di.dynCss.api.create-function)

    it 'should stub correctly create a function', ->
        f = window-di.dynCss.api.create-function('3')
        f.should.be.a.Function
        f().should.be.exactly(3)

    it 'should create a simple rule', ->
        handler = dyncss.build-handlers(rules, undefined)
        should.exist(handler)
        handler.should.be.a.Function

    it 'should modify the css when created', ->
        handler = dyncss.build-handlers(rules, undefined)
        cssspy = sinon.spy(el-di, 'css')
        handler()
        cssspy.callCount.should.be.exactly(1)
        should.exist(cssspy.firstCall.args[0].width)
        cssspy.firstCall.args[0].width.should.be.exactly(333)
        cssspy.restore()

describe 'DynCSS tests - using built-in', (empty) ->
    before-each ->

        dyncss      := require('./core')

        window-di   := { type: "window" }

        document-di := { type: "document" }

        el-di       := { 
            type: "element" 

            css: (css) -> 
                if css == "size"
                    return '444'

            width: -> 
                222
            }

        iterator    := {
            each: (cb) ->
                cb.apply(el-di, [0])
            }

        # That's a short jquery hack..
        jq-di       := (sel) ->

            if not sel.type? and sel == '.test' 
                return iterator

            if sel.type == "window"
                return window-di

            if sel.type == "element"
                return el-di

        dyncss      := dyncss(window-di,  document-di ,  jq-di)

        window-di.width  = -> 101
        window-di.height = -> 100

        # sinon.stub window-di, 'height', -> 200

        rules := [

            * type: 'rule'
              selectors: ['.test']
              declarations: [
                * property: '-dyn-width'
                  value: quote('@win-width')
              ]

        ]

        temp-stub1 := sinon.stub window-di.dynCss.api, 'createFunction', (body) ->
            (-> eval(body)).bind(window-di.dynCss)

    after-each ->
        temp-stub1.restore()


    it 'should create a rule accessing the window width', ->
        handler = dyncss.build-handlers(rules, undefined)
        should.exist(handler)
        handler.should.be.a.Function

    it 'should modify the css when created', ->
        handler = dyncss.build-handlers(rules, undefined)
        cssspy = sinon.spy(el-di, 'css')
        handler()
        cssspy.callCount.should.be.exactly(1)
        should.exist(cssspy.firstCall.args[0].width)
        cssspy.firstCall.args[0].width.should.be.exactly(101)

    it 'should create a rule accessing an element jquery computed value', ->
        
        rules := [

            * type: 'rule'
              selectors: ['.test']
              declarations: [
                * property: '-dyn-width'
                  value: quote('@jq-width')
              ]

        ]

        handler = dyncss.build-handlers(rules, undefined)
        should.exist(handler)
        handler.should.be.a.Function
        cssspy = sinon.spy(el-di, 'css')
        handler()
        cssspy.callCount.should.be.exactly(1)
        should.exist(cssspy.firstCall.args[0].width)
        cssspy.firstCall.args[0].width.should.be.exactly(222)
        cssspy.restore()

    it 'should create a rule accessing an element css property width', ->
        
        rules := [

            * type: 'rule'
              selectors: ['.test']
              declarations: [
                * property: '-dyn-width'
                  value: quote('@el-size')
              ]

        ]

        handler = dyncss.build-handlers(rules, undefined)
        should.exist(handler)
        handler.should.be.a.Function
        cssspy = sinon.spy(el-di, 'css')
        handler()
        cssspy.callCount.should.be.exactly(2)
        should.exist(cssspy.secondCall.args[0].width)
        cssspy.secondCall.args[0].width.should.be.exactly(444)
        cssspy.restore()




    
