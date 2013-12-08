#!/bin/sh

mkdir android || true
convert my-hires-icon.png -resize 36x36 android/icon-36-ldpi.png
convert my-hires-icon.png -resize 48x48 android/icon-48-mdpi.png
convert my-hires-icon.png -resize 72x72 android/icon-72-hdpi.png
convert my-hires-icon.png -resize 96x96 android/icon-96-xhdpi.png
 
mkdir ios || true
convert my-hires-icon.png -resize 29 ios/icon-29.png
convert my-hires-icon.png -resize 40 ios/icon-40.png
convert my-hires-icon.png -resize 50 ios/icon-50.png
convert my-hires-icon.png -resize 57 ios/icon-57.png
convert my-hires-icon.png -resize 58 ios/icon-29-2x.png
convert my-hires-icon.png -resize 60 ios/icon-60.png
convert my-hires-icon.png -resize 72 ios/icon-72.png
convert my-hires-icon.png -resize 76 ios/icon-76.png
convert my-hires-icon.png -resize 80 ios/icon-40-2x.png
convert my-hires-icon.png -resize 100 ios/icon-50-2x.png
convert my-hires-icon.png -resize 114 ios/icon-57-2x.png
convert my-hires-icon.png -resize 120 ios/icon-60-2x.png
convert my-hires-icon.png -resize 144 ios/icon-72-2x.png
convert my-hires-icon.png -resize 152 ios/icon-76-2x.png
