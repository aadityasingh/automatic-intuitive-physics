#!/usr/local/bin/bash

# num_peaks=( 12    14    12    16    15    12    18    14    13 )
names=( SphereOnWood SphereOnFoam SphereOnPlate CubeOnWood CubeOnFoam CubeOnPlate CylOnWood CylOnFoam CylOnPlate )

for i in {0..8};
do
   for j in {0..11};
   do
      ffmpeg -i ${names[$i]}${j}.MOV -vn -acodec copy ${names[$i]}${j}Audio.wav
   done
done
