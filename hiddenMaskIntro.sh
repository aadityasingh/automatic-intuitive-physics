#!/usr/local/bin/bash

for name in CubeOnPlate6DubbedPlate0 CylOnWood8DubbedWood0 SphereOnFoam6DubbedFoam0;
do
	ffmpeg -i ${name}.mp4 -i ${name%[0-9]Dubbed*}Mask.png -filter_complex "[1:v]scale=1920:1080 [ovrl], [0:v][ovrl]overlay" Mask${name}.mp4
	ffmpeg -i Mask$name.mp4 -vf "select=eq(n\,0)" -q:v 3 Frame${name}.png
	ffmpeg -i Mask${name}.mp4 -i ${name%[0-9]Dubbed*}Black.png -filter_complex "[1:v]scale=1920:1080 [ovrl], [0:v][ovrl]overlay" Temp${name}.mp4
	ffmpeg -loop 1 -i Frame${name}.png -c:v h264 -t 2 -pix_fmt yuvj420p -vf scale=1920:1080 Looped${name}.mp4
	ffmpeg -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -i Looped${name}.mp4 -shortest -c:v copy -s:a aac LoopedSilent${name}.mp4
	ffmpeg -i LoopedSilent${name}.mp4 -i Temp${name}.mp4 -filter_complex "[0:v] [0:a:0] [1:v] [1:a:0] concat=n=2:v=1:a=1 [v] [a]" -map "[v]" -map "[a]" Hidden${name}.mp4
done

rm Frame*.png
rm Temp*.mp4
rm Looped*.mp4
