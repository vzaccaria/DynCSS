
{ client-html, client-less, client-ls, client-brfy-roots, directives, other-deps } = require('./config')
{ vendor-js, vendor-css, , data-to-be-copied }      = require('./config')
{ remote, destination, font-dir, img-dir }          = require('./config')
 
client-js = [ "#destination/js/build/#s" for s in client-brfy-roots ]

files-to-watch = client-ls ++ client-less ++ client-html ++ directives ++ other-deps

force-file-reload = [
    "#destination/**/*.html"
    "#destination/**/*.css"
    "#destination/**/*.js"
    "#destination/**/*.png"
    "#destination/**/*.jpg"
    ]

require! 'gulp'
jade       = require 'gulp-jade'
stylus     = require 'gulp-stylus'
ftp        = require 'gulp-ftp'
less       = require 'gulp-less'
browserify = require 'gulp-browserify'
live       = require 'gulp-livescript'
uglify     = require 'gulp-uglify'
concat     = require 'gulp-concat'
rename     = require 'gulp-rename'
exec       = require 'gulp-exec'
clean      = require 'gulp-clean'
filesize   = require('gulp-filesize');
spawn      = require 'gulp-spawn'
changed    = require 'gulp-changed'
plumber    = require('gulp-plumber');
cr         = require '/Users/zaccaria/.ssh/sftp_credentials'



EXPRESS_PORT    = 4000;
EXPRESS_ROOT    = destination;
LIVERELOAD_PORT = 35729;

start-express = ->
  express = require('express');
  app = express();
  app.use(require('connect-livereload')());
  app.use(express.static(EXPRESS_ROOT, {maxAge: 0}));
  app.listen(EXPRESS_PORT);

var lr

start-livereload = ->
  lr := require('tiny-lr')()
  lr.listen(LIVERELOAD_PORT)


notifyLivereload = (event) ->
  fileName = require('path').relative(EXPRESS_ROOT, event.path);
  lr.changed body: { files: [fileName] }
                

gulp.task 'build-html', ->
    gulp.src client-html
        .pipe plumber()
        .pipe jade()
        .pipe gulp.dest "#destination/html"

gulp.task 'build-index', ['build-html'] ->
    gulp.src "#destination/html/index.html"
        .pipe gulp.dest "#destination"

gulp.task 'build-client-js', ['build-client-ls'], ->
    gulp.src client-js, { read: false }
        .pipe plumber()
        .pipe browserify {
            insertGlobals : false
        }
        .pipe concat('client.js')
        .pipe gulp.dest "#destination/js"

gulp.task 'build-client-ls', ->
    gulp.src client-ls
        .pipe plumber()
        .pipe changed "#destination/js/build"
        .pipe live()
        .pipe gulp.dest "#destination/js/build"

gulp.task 'build-vendor-js-prod', ['build-client-js'],->
    gulp.src vendor-js
        .pipe(concat('vendor.js'))
        .pipe filesize()
        .pipe gulp.dest "#destination/js"
        .pipe uglify()
        .pipe rename('vendor.min.js')
        .pipe filesize()
        .pipe gulp.dest "#destination/js"

gulp.task 'build-vendor-js', ['build-client-js'], ->
    gulp.src vendor-js
        .pipe(concat('vendor.js'))
        .pipe gulp.dest "#destination/js"

gulp.task 'build-less', ->
    gulp.src client-less
        .pipe plumber()
        .pipe changed "#destination/css/build"
        .pipe less()
        .pipe gulp.dest "#destination/css/build"

gulp.task 'build-css', ['build-less'], ->
    gulp.src "#destination/css/build/*.css"
        .pipe plumber()
        .pipe concat('client.css')
        .pipe gulp.dest "#destination/css"

gulp.task 'build-vendor-css', ->
    gulp.src vendor-css
        .pipe concat('vendor.css')
        .pipe gulp.dest "#destination/css"

gulp.task 'build-img', ->
    gulp.src ["#img-dir/*.png", "#img-dir/*.jpg"]
        .pipe changed "#destination/img"
        .pipe gulp.dest "#destination/img"

gulp.task 'build-fonts', ->
    gulp.src [  "#font-dir/*.woff" 
                "#font-dir/*.otf"
                "#font-dir/*.eot"
                "#font-dir/*.svg"
                "#font-dir/*.ttf"
                ]
        .pipe changed "#destination/fonts"
        .pipe gulp.dest "#destination/fonts"

gulp.task 'ftp', ->
    gulp.src ["#destination/**"]
        .pipe ftp {
            host: '217.64.195.216'
            user: 'vittoriozaccaria.net'
            pass: cr['217.64.195.216']['vittoriozaccaria.net']
            remote-path: "htdocs/#remote" 
        }


gulp.task 'sjs', ->
    gulp.src directives
        .pipe changed "#destination/js"
        .pipe((spawn { cmd: 'sweet-angle', args: [ '-a', 'application', '/dev/stdin'] }).on 'error', console.log)
        .pipe gulp.dest "#destination/js"


gulp.task 'build-clean', ->
    gulp.src destination, {read: false}
        .pipe clean()

gulp.task 'js-build-clean', ->
    gulp.src "#destination/js/build", {read: false}
        .pipe clean()

gulp.task 'watch-build', ->
  startExpress();
  startLivereload();
  gulp.watch(force-file-reload, notifyLivereload);
  files-to-watch = client-ls ++ client-less ++ client-html ++ directives ++ other-deps
  gulp.watch(files-to-watch, ["default"])


fs = require('fs')

gulp.task 'build-package-json', ->
    fs.readdir "./node_modules", (err, dirs)  ->
         for dir in dirs 
            if dir.index-of(".") != 0 
                packageJsonFile = "./node_modules/#dir/package.json"
                if fs.existsSync packageJsonFile 
                    fs.readFile packageJsonFile, (err, data) ->
                        json = JSON.parse(data)
                        console.log "\"#{json.name}\": \"#{json.version}\", "

gulp.task 'copy-data', ->
    gulp.src data-to-be-copied
        .pipe changed("#destination/data")
        .pipe gulp.dest "#destination/data"
  
gulp.task 'default', [
    \build-index
    \build-client-js
    \build-vendor-js
    \build-vendor-css
    \build-css
    \build-fonts
    \build-img
    \copy-data
    \sjs
    ...
    ]

gulp.task 'production', [
    \build-index
    \build-client-js
    \build-vendor-js-prod
    \build-vendor-css
    \build-css
    \build-fonts
    \build-img
    \copy-data
    \sjs
    ...
    ]

runSequence = require('run-sequence');

gulp.task 'dev', (done) ->
    runSequence 'build-clean', 'default', 'watch-build', done

gulp.task 'deploy', (done) ->
    runSequence 'build-clean', 'default', 'ftp'
