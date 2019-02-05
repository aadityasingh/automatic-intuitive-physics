#!/usr/local/bin/bash

for object in Sphere Cube Cyl
do
	for surface in Foam Wood Plate
	do
		for i in 0 1 2 3
		do
			if [ -e TrialVideos/${object}On${surface}${i}Dubbed${surface}0.mp4 ]
			then
				echo skipping...
			else
				echo ffmpeg -i ${object}On${surface}${i}.MOV -itsoffset -0.7 -i ${object}On${surface}${i}Dubbed${surface}0Audio.wav -map 0:v:0 -map 1:a:0 TrialVideos/${object}On${surface}${i}Dubbed${surface}0.mp4
			fi
		done
	done
done
