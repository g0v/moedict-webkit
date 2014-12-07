require! gulp
sass = require \gulp-sass

gulp.task \sass ->
  gulp.src('./sass/*.scss')
    .pipe(sass!)
    .pipe(gulp.dest('.'))

gulp.task \default <[ sass ]>
