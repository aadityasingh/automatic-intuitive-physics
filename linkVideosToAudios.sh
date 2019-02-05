#!/bin/bash

for object in Sphere Cube Cyl
do
  for surface in Foam Wood Plate
  do
    name=${object}On$surface
    ffmpeg -i ${name}.MOV -an -c copy ${name}Video.MOV
    ffmpeg -i ${name}.MOV -vn -acodec pcm_s16le -ar 44100 ${name}Audio.wav
  done
done
echo done
