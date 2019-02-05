%investigate the peakfinding and tune parameters to identify proper peaks
%also compare to actual audio
% We use this code to tune parameters to use for various sphere surfaces
% The peakfinding parameters we use on channel3 for wood spheres are:
%           MinPeakDistance: 0.03
%           MinPeakHeigh: 0.007
% This tends to identify >=3 peaks corresponding to the three main bounces
% The peakfinding parameters we use on channel3 for foam spheres are:
%           MinPeakDistance: 0.03
%           MinPeakHeigh: 0.001
% This tends to identify 3 peaks corresponding to the three main bounces
% The peakfinding parameters we use on channel3 for ceramic spheres are:
%           MinPeakDistance: 0.06
%           MinPeakHeigh: 0.01
% This tends to identify 2 peaks corresponding to the three main bounces

% NOTE: all these parameters can be fine tuned later... this is just
% tentative... I'm going to try syntheses w these and see how they turn out

prefix = "SampleVideos/";
suffix = ".wav";
type = "Ceramic_Sphere_";
% number = randi(21);
number=1;
channels12 = audioread(char(prefix+type+number+suffix));
channels3 = audioread(char(prefix+type+number+'_Channel_3'+suffix));
findpeaks(channels3(44100:49300, 1), 44100, 'MinPeakDistance', 0.03, 'MinPeakHeight', 0.001)
title(number)
[pks, locs, widths] = findpeaks(channels3(:, 1), 44100, 'MinPeakDistance', 0.03, 'MinPeakHeight', 0.001);
locs*44100