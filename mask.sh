#!/usr/local/bin/bash

names=( SphereOnWood SphereOnFoam SphereOnPlate CubeOnWood CubeOnFoam CubeOnPlate CylOnWood CylOnFoam CylOnPlate )

for i in {0..8};
do
	for filename in TrialVideos*/${names[$i]}*;
	do
		ffmpeg -i ${filename} -i ${names[$i]}Mask.png -filter_complex "[1:v]scale=1920:1080 [ovrl], [0:v][ovrl]overlay" Masked${filename}
	done
done