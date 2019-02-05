#!/usr/local/bin/bash

names=( SphereOnWood SphereOnFoam SphereOnPlate CubeOnWood CubeOnFoam CubeOnPlate CylOnWood CylOnFoam CylOnPlate )

for name in MaskedTrial*/*.mp4;
do
	ffmpeg -i $name -vf "select=eq(n\,0)" -q:v 3 Hidden${name%.mp4}.png
done

for i in {0..8};
do
	for filename in TrialVideos*/${names[$i]}*;
	do
		ffmpeg -i ${filename} -i ${names[$i]}Black.png -filter_complex "[1:v]scale=1920:1080 [ovrl], [0:v][ovrl]overlay" HiddenMasked${filename%.mp4}Temp.mp4
	done
done

for name in HiddenMaskedTrial*/*.png;
do
	ffmpeg -loop 1 -i ${name} -c:v h264 -t 2 -pix_fmt yuvj420p -vf scale=1920:1080 ${name%.png}Looped.mp4
	ffmpeg -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -i ${name%.png}Looped.mp4 -shortest -c:v copy -s:a aac ${name%.png}LoopedSilent.mp4
	ffmpeg -i ${name%.png}LoopedSilent.mp4 -i ${name%.png}Temp.mp4 -filter_complex "[0:v] [0:a:0] [1:v] [1:a:0] concat=n=2:v=1:a=1 [v] [a]" -map "[v]" -map "[a]" ${name%.png}.mp4
done

rm HiddenMaskedTrial*/*Temp.mp4
rm HiddenMaskedTrial*/*Looped*.mp4
rm HiddenMaskedTrial*/*.png
