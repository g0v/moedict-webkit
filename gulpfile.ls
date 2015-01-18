require! gulp
sass = require \gulp-sass
jade = require \gulp-jade
src = -> gulp.src it

gulp.task \default <[ sass jade ]>
gulp.task \build <[ default webpack:build ]>
gulp.task \run <[ default static-here show-url ]>
gulp.task \dev <[ default webpack:dev show-url ]>

if process.argv[*-1] in <[ run dev ]>
  watch = require \gulp-watch
  src = -> gulp.src(it).pipe(watch(it))

gulp.task \sass ->
  src(\./sass/*.scss)
    .pipe sass!
    .pipe gulp.dest \.

gulp.task \jade ->
  src(\./*.jade)
    .pipe jade { +pretty }
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
