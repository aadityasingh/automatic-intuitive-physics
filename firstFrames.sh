#!/bin/bash

names=( SphereOnWood SphereOnFoam SphereOnPlate CubeOnWood CubeOnFoam CubeOnPlate CylOnWood CylOnFoam CylOnPlate )

for i in {0..8};
do
  echo ffmpeg -i ${names[${i}]}0.MOV -vf "select=eq(n\,0)" -q:v 3 ${names[${i}]}0.jpg 
done