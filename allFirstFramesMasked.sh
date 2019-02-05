#!/usr/local/bin/bash

for name in MaskedTrial*/*.mp4;
do
	ffmpeg -i $name -vf "select=eq(n\,0)" -q:v 3 Hidden${name%.mp4}.png
done