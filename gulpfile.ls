require! gulp
sass = require \gulp-sass
jade = require \gulp-jade

gulp.task \sass ->
  gulp.src('./sass/*.scss')
    .pipe(sass!)
    .pipe(gulp.dest('.'))

gulp.task \jade ->
  gulp.src('./*.jade')
    .pipe(jade { +pretty })
    .pipe(gulp.dest('.'))

gulp.task \default <[ sass jade ]>
