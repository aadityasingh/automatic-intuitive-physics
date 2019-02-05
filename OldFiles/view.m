% Just want to plot how various channel 3s compare to actual audio
% There are 19 wood audios
% There are 17 foam audios
% There are 21 ceramic audios
prefix = "SampleVideos/";
suffix = ".wav";
type = "Wood_Sphere_";
number = randi(19);
channels12 = audioread(char(prefix+type+number+suffix));
channels3 = audioread(char(prefix+type+number+'_Channel_3'+suffix));
fig1 = figure(1);
plot(channels12)
title(type+number)
fig2 = figure(2);
plot(channels3)
title(type+number+'_Channel_3')