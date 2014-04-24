_module = ->

          
    iface = { 

      # main properties 
      destination:'_site'
      remote:'simple-login'

      vendor-js:
          "./bower_components/underscore.string/lib/underscore.string.js"
          "./bower_components/jquery/dist/jquery.js"
          ...

      # client files 
      client-ls:
          "./assets/js/*.ls"
          ...

      client-brfy-roots: [ 'entry.js' ]

      client-html:
          "./assets/*.jade"
          "./assets/views/*.jade"
          ...

      client-less:
          './assets/less/*.less'
          ...

      directives:[
          './assets/directives/*.sjs'
          ]

      # vendor files 
      vendor-css:
          './vendor/css/*.css'
          ...

      # other assets
      font-dir:'./assets/fonts'

      img-dir:'./assets/img'

      data-to-be-copied:[
          "./data/*.json"
          "./assets/less/*.dss"
          ]


      other-deps: []

    }
  
    return iface
 
module.exports = _module()