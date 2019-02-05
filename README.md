# automatic-intuitive-physics
A behavioral paradigm and computational models to explore whether humans automatically engage intuitive physical reasoning. It makes use of loudness judgments under natural audiovisual stimulation.

## Video/Audio preprocessing (pre-audio synth and dubbing):
Videos should be of the form SphereOnWood.MOV and come with corresponding “high-quality” 3-channel audio SphereOnWood.wav. Note that videos/audios are not committed in the repo (as seen in the gitignore).

1. run the shell script linkVideosToAudios.sh <br/>
	This will split the video and audio and create audio-less files of the form SphereOnWoodVideo.MOV and audio files SphereOnWoodAudio.wav
2. run the MATLAB script matcher.m <br/>
	This will generate an array of 9 values indicating how much the audio should be delayed when reattaching to the video (note we’re referring to SphereOnWood.wav and SphereOnWoodVideo.MOV). If some of these numbers are negative or small or smth, adjust by pre-cropping the audio file of the form SphereOnWood.wav
3. Edit syncAV.sh then run it <br/>
	syncAV should be edited so that “times” is updated to equal the array outputted by MATLAB after step 2. This step will create files of the form SphereOnWoodSynced.MOV which are the original videos with the high quality audio. Note that it also creates temporary files SphereOnWoodSynced2.MOV that can be deleted easily with “rm *2.MOV”
4. Run MATLAB script split_points.m <br/>
	This script will require some tuning (specifically the find peaks). The aim is to find the peaks (which correspond to different drops) and output these times. This running this script yields a huge output. The “peaks[*” lines correspond to lines that should be directly copied and pasted into the shell script split.sh.
5. Edit shell script split.sh then run it <br/>
	Paste in peak times as described above. Also use the last output of split_points.m and set the num_peaks variable to this. Running this script will then segment the synced video into ~1.5 second intervals that contain ~1 second of video before the peak. New files of the form SphereOnWood0.MOV will be created.
6. Look through the split videos <br/>
	Some of these videos will inevitably be bad (not indicative of real peaks). Delete those, but make sure the numbering is still 0 to n (the fastest way to do this is, if #i is deleted, change the name of the #n file to #i). Also, if some videos have bad frames at the start (i.e. hand still in the camera view), clip these videos. This can be done by renaming them as -shift-{amount} where u should replace {amount} with smth like 0_5 if you want to shift 0.5 seconds forward. In this step, files of the form SphereOnWood0-shift-0_5.MOV will be manually created (by renaming the files of the form SphereOnWood0.MOV as necessary).
7. Run shell script shiftVideos.sh on every batch of shifts <br/>
	For all the shift values, you will need to run shiftVideos. Before each run, edit the line that filters for files (`ls *-shift-0_5*`) and also alter the ffmpeg line which dictates how much to shift by (-ss 0.5). Run the file (note one run is necessary per shift). Check the created videos and adjust shift times/re-run if necessary. This step will create shifted files of the form SphereOnWood0.MOV as desired.
8. Run splitAudios.sh  <br/>
	Now that the video is split into pieces, we just need to extract the audio from each short video (we will use these audios for the dubbing). Running this script will generate files of the form SphereOnWood0Audio.wav. As a check, open one of these in MATLAB to make sure that all 3 channels are still present (as channel 3 is very important in the dubbing process). Note that this file contains a hard coded number, namely j in {0..11}, implying we use 12 audios for each recording. This number can be increased so long as at least that many recordings of each pair of object shape and material exist.

## Audio synthesis:
1. Find best peak finding parameters <br/>
	Experiment with peak finding parameters in the file peaks.m and visualize the results. Pick parameters which seem to identify the most distinct peaks. Enter these in peak_params variable in the synthesizeShape function. Note that currently the peak_params has 3 dimensions. These 3 dimensions correspond to the different shapes. Currently, the values are the same across the different shapes (sphere, cube, cyl), but they could be further fine tuned. For the current videos, using the same set of values works.
2. Modify and run synthAudios.m to produce appropriate videos <br/>
	Use the wrapper synthAudios for synthesizeShape to automate the production of all the standard and trick stimuli by changing the loop structure and exact arguments passed in. For trick videos, copy and paste the MATLAB print spam into the syncDubbedTrick.sh file as the names variable.
3. Create TrialVideos/ and TrialVideosTrick/ and run syncDubbedNormal.sh and syncDubbedTrick.sh without offset<br/>
	Pretty self explanatory
4. Look through videos and realign audio. <br/>
	For many (typically 2/3) of the videos ffmpeg decides to be mean to us and the audio is actually shifted. Look through the videos and label these (I just append "BAD") to the file name. Then rerun the scripts from step 3, to echo ffmpeg commands that will deal with the offset. This step is extremely manual and sad, but necessary.
 
## Going from synth videos to trials:
1. Extract first frames, used for making masks <br/>
	Run firstFrames.sh
2. Design masks and save as (i.e.) SphereOnWoodMask.png <br/>
	I do this in a powerpoint. Initially, I made the masks black, but I am switching to white because this works better with psiturk.
3. Create folders MaskedTrialVideosStandard/ and MaskedTrialVideosTrick/ and run mask.sh <br/>
	This will create the masked videos. These can be used in the experiment if you want to show the bounce.
4. Create folders HiddenMaskedTrialVideosStandard/ and HiddenMaskedTrialVideosTrick/ and run hiddenMask.sh
	This will create the masked videos with freeze frames at the start and hidden bouncing.


## Useful ffmpeg commands:

* Get video without audio:
ffmpeg -i SphereOnWood.MOV -an -c copy SphereOnWoodVideo.MOV

* Get audio without video:
ffmpeg -i SphereOnWood.MOV -vn -acodec copy SphereOnWoodAudio.wav

* Get audio downsampled to 44100 Hz (from 48000 Hz for our video files) from video:
ffmpeg -i SphereOnWood.MOV -vn -acodec pcm_s16le -ar 44100 SphereOnWoodAudio.wav

* Shift audio:
ffmpeg -i CubeOnPlate2.wav -ss 00:00:02.000 -c copy CubeOnPlate.wav
* Shift video:
ffmpeg -i CylOnWoodSynced2.MOV -ss 5 -c copy CylOnWoodSynced.MOV

* Combine shifted video+audio:
ffmpeg -i SphereOnWoodVideo.MOV -itsoffset 1.8453 -i SphereOnWood.wav -shortest -map 0:v -map 1:a -vcodec copy -acodec copy SphereOnWoodSynced.MOV

* Combine video with new audio:
ffmpeg -i SphereOnFoam0.MOV -i SphereOnFoam0DubbedPlate1Audio.wav -c copy -map 0`:v:`0 -map 1`:a:`0 SphereOnFoam0DubbedPlate1.MOV
