require! gulp
uglify = require \gulp-uglifyjs

gulp.task \uglify ->
  gulp.src(<[
    deps.js
    js/jquery-2.1.1.min.js
    js/jquery-ui-1.10.4.custom.min.js
    js/jquery.hoverIntent.js
    js/jquery.ruby.js
    js/bootstrap/dropdown.js
    js/simp-trad.js
    js/prelude-browser-min.js
    js/react.js
  ]>).pipe(uglify!).pipe(gulp.dest \js)

gulp.task \default <[ uglify ]>
