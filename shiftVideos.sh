#!/usr/local/bin/bash

files=`ls *-shift-1*`
substr= -shift-*

for filename in $files;
do
  ffmpeg -ss 0.75 -i $filename -c copy ${filename%-s*}.MOV
done
