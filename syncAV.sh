#!/bin/bash

times=( 1.8453    1.9901    7.2472    2.6052    6.5754    1.0051    4.8872    4.4622    4.9490 )
names=( SphereOnWood SphereOnFoam SphereOnPlate CubeOnWood CubeOnFoam CubeOnPlate CylOnWood CylOnFoam CylOnPlate )

for i in {0..8};
do
  ffmpeg -i ${names[${i}]}Video.MOV -itsoffset ${times[${i}]} -i ${names[${i}]}.wav -shortest -map 0:v -map 1:a -vcodec copy -acodec copy ${names[${i}]}Synced2.MOV
  ffmpeg -i ${names[${i}]}Synced2.MOV -ss ${times[${i}]} -c copy ${names[${i}]}Synced.MOV  
done
