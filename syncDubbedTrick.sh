#!/usr/local/bin/bash

names=(
	SphereOnWood4
	DubbedFoam0
	SphereOnWood5
	DubbedPlate0
	SphereOnFoam4
	DubbedWood0
	SphereOnFoam5
	DubbedPlate0
	SphereOnPlate4
	DubbedWood0
	SphereOnPlate5
	DubbedFoam0
	CubeOnWood4
	DubbedFoam0
	CubeOnWood5
	DubbedPlate0
	CubeOnFoam4
	DubbedWood0
	CubeOnFoam5
	DubbedPlate0
	CubeOnPlate4
	DubbedWood0
	CubeOnPlate5
	DubbedFoam0
	CylOnWood4
	DubbedFoam0
	CylOnWood5
	DubbedPlate0
	CylOnFoam4
	DubbedWood0
	CylOnFoam5
	DubbedPlate0
	CylOnPlate4
	DubbedWood0
	CylOnPlate5
	DubbedFoam0 )

for i in {0..17};
do
	if [ -e TrialVideosTrick/${names[$i*2]}${names[$i*2+1]}.mp4 ]
	then
		echo skipping...
	else
		echo ffmpeg -i ${names[$i*2]}.MOV -itsoffset -0.5 -i ${names[$i*2]}${names[$i*2+1]}Audio.wav -map 0:v:0 -map 1:a:0 TrialVideosTrick/${names[$i*2]}${names[$i*2+1]}.mp4
	fi
done