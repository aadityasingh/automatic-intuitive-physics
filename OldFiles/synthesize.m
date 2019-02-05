fs = 44100;

surface_type = "Foam";
surface_vals = [0.03 0.001]; %determined by manual test in peaks.m
replace_type = "Ceramic";
replace_vals = [0.06 0.01]; %determined by manual test in peaks.m
prefix = "SampleVideos/";
suffix = ".wav";
infix = "_Sphere_";
num = 1;
replace_num = 1; % we can randomize this later

original12 = audioread(char(prefix+surface_type+infix+num+suffix));
replace12 = audioread(char(prefix+replace_type+infix+replace_num+suffix));

original3 = audioread(char(prefix+surface_type+infix+num+'_Channel_3'+suffix));
replace3 = audioread(char(prefix+replace_type+infix+replace_num+'_Channel_3'+suffix));

[pks3, locs3, widths3] = findpeaks(original3(:, 1), 44100, 'MinPeakDistance', surface_vals(1), 'MinPeakHeight', surface_vals(2));
[pks3_rep, locs3_rep, widths3_rep] = findpeaks(replace3(:, 1), 44100, 'MinPeakDistance', replace_vals(1), 'MinPeakHeight', replace_vals(2));

new_audio_v1 = zeros(size(original12));
new_audio_v2 = original12;
replace_peak = max(replace12(int32(fs*locs3_rep(1)):int32(fs*locs3_rep(2)), 1));
rep_len = fs*(locs3_rep(2) - locs3_rep(1));
num_peaks = length(locs3);
for i = 1:(num_peaks-1)
    time = locs3(i+1) - locs3(i);
    len = fs*time;
    if rep_len < len
        len = rep_len;
    end
    peak = max(original12(int32(fs*locs3(i)):int32(fs*locs3(i+1)), 1));
    for j = 1:len
%         near = closest_index(locs(i), locs3);
        new_audio_v1(int32(locs3(i)*fs+j-1), 1) = replace12(int32(locs3_rep(1)*fs+j-1), 1)*peak/replace_peak;
        new_audio_v1(int32(locs3(i)*fs+j-1), 2) = replace12(int32(locs3_rep(1)*fs+j-1), 1)*peak/replace_peak;
        new_audio_v2(int32(locs3(i)*fs+j-1), 1) = replace12(int32(locs3_rep(1)*fs+j-1), 1)*peak/replace_peak;
        new_audio_v2(int32(locs3(i)*fs+j-1), 2) = replace12(int32(locs3_rep(1)*fs+j-1), 1)*peak/replace_peak;
%         start(int32(locs(i)*fs+j-1), 2) = replace(locs2(1)*fs+j, 2)*pks3(near)/pks2(1);
    end
end
len = length(original12) - fs*locs(num_peaks);
peak = max(original12(int32(fs*locs3(num_peaks)):length(original12), 1));
if rep_len < len
    len = rep_len;
end
for j = 1:len
    new_audio_v1(int32(locs3(num_peaks)*fs+j-1), 1) = replace12(int32(locs3_rep(1)*fs+j-1), 1)*peak/replace_peak;
    new_audio_v1(int32(locs3(num_peaks)*fs+j-1), 2) = replace12(int32(locs3_rep(1)*fs+j-1), 1)*peak/replace_peak;
    new_audio_v2(int32(locs3(num_peaks)*fs+j-1), 1) = replace12(int32(locs3_rep(1)*fs+j-1), 1)*peak/replace_peak;
    new_audio_v2(int32(locs3(num_peaks)*fs+j-1), 2) = replace12(int32(locs3_rep(1)*fs+j-1), 1)*peak/replace_peak;
end

% For visualization purposes
fig1 = figure(1);
plot(original12)
hold on;
plot(new_audio_v1)
hold off;
fig2 = figure(2);
plot(replace12)

% Output files in format [Surface]_Sphere_number_[Sound]_v[n].wav
audiowrite(char(surface_type+infix+num+"_"+replace_type+"_v1"+suffix), new_audio_v1, fs);
audiowrite(char(surface_type+infix+num+"_"+replace_type+"_v2"+suffix), new_audio_v2, fs);

