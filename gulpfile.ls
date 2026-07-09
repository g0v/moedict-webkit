require! gulp
sass = require \gulp-dart-sass
jade = require \gulp-jade
src = -> gulp.src it
task = process.argv[*-1]

if task in <[ run dev ]>
  src = ->
    rv = gulp.src(it)
    gulp.watch(it, gulp.series({run: \build, dev: \webpack:dev}[task]))
    return rv

require! child_process
gitShort = child_process.execSync('git rev-parse --short HEAD').toString().trim()
cssBasename = "styles-#gitShort.css"

gulp.task \sass ->
  fs = require \fs
  src(\./sass/*.scss)
    .pipe sass!
    .pipe(require('gulp-postcss')([
      require('autoprefixer-core') browsers: ['last 1 version']
      require('css-mqpacker')
      require('csswring')
    ]))
    .pipe gulp.dest \.
    .on \end -> fs.copyFileSync \styles.css, cssBasename

gulp.task \jade ->
  src(\./*.jade)
    .pipe jade { +pretty, locals: { cssVersion: gitShort } }
    .pipe gulp.dest('.')

gulp.task \static-here ->
  process.argv[*-1] = \8888
  require \./static-here.js

gulp.task \show-url ->
  <- setTimeout _, 2000ms
  console.log "\n===> http://127.0.0.1:8888/"

gulp.task \webpack:build ->
  process.env.NODE_ENV = \production
  webpack = require \webpack
  webpack require(\./webpack.config.js), it

gulp.task \webpack:dev ->
  process.env.NODE_ENV = \development
  process.argv ++= <[ --hot --port 8888 ]>
  require \./node_modules/webpack-dev-server/bin/webpack-dev-server.js

gulp.task \default gulp.parallel \sass \jade
gulp.task \build gulp.series \default \webpack:build
gulp.task \run gulp.series \default \static-here \show-url
gulp.task \dev gulp.series \default \webpack:dev \show-url

