gulp = require 'gulp'
concat = require 'gulp-concat'
coffee = require 'gulp-coffee'
pug = require 'gulp-pug'
sass = require 'gulp-sass'
plumber = require 'gulp-plumber'

path = 
  coffee: ['src/coffee/datas/*.coffee', 'src/coffee/*.coffee']
  pug: 'src/pug/*.pug'
  css: 'src/sass/*.sass'
  img: 'src/img/*.png'

gulp.task 'build:js', ->
  gulp.src path.coffee 
    .pipe plumber()
    .pipe concat('index.coffee') 
    .pipe coffee() 
    .pipe gulp.dest('site/js/')

gulp.task 'build:html', ->
  gulp.src path.pug 
    .pipe plumber() 
    .pipe pug()
    .pipe gulp.dest('site/')

gulp.task 'build:css', ->
  gulp.src path.css
    .pipe plumber()
    .pipe sass outputStyle: 'compressed'
    .pipe gulp.dest('site/css/')

gulp.task 'build:img', ->
  gulp.src path.img
    .pipe gulp.dest('site/img/')

gulp.task 'watch:js',  ->
  gulp.watch path.coffee, ['build:js']

gulp.task 'watch:html', ->
  gulp.watch path.pug, ['build:html']

gulp.task 'watch:css', ->
  gulp.watch path.css, ['build:css']