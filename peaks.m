%investigate the peakfinding and tune parameters to identify proper peaks
%also compare to actual audio
% We use this code to tune parameters to use for various sphere surfaces
% The peakfinding parameters we use on channel3 for wood spheres are:
%           MinPeakDistance: 0.03
%           MinPeakHeight: 0.001
% This tends to identify >=3 peaks corresponding to the three main bounces
% The peakfinding parameters we use on channel3 for foam spheres are:
%           MinPeakDistance: 0.03
%           MinPeakHeight: 0.004
% This tends to identify 3 peaks corresponding to the three main bounces
% The peakfinding parameters we use on channel3 for ceramic spheres are:
%           MinPeakDistance: 0.08
%           MinPeakHeight: 0.01
% This tends to identify 2 peaks corresponding to the three main bounces

% NOTE: all these parameters can be fine tuned later... this is just
% tentative... I'm going to try syntheses w these and see how they turn out

type = "CubeOnWood";
suffix = "Audio.wav";
% the below is hardcoded to visualize 12 waveforms simultaneously
figure(1);
for number = 0:11
    subplot(3, 4, number+1);
    audio = audioread(char(type+number+suffix));
    findpeaks(audio(1:length(audio), 3), 44100, 'MinPeakDistance', 0.03, 'MinPeakHeight', 0.001)
    title(number)
    [pks, locs, widths] = findpeaks(audio(:, 3), 44100, 'MinPeakDistance', 0.08, 'MinPeakHeight', 0.01);
end