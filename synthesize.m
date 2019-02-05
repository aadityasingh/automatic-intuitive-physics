% After running some synths, we see that the noise in channel 1 makes
% the synth procedure very unstable. As a result, we re-write both channels
% as channel 2. Also, for consistency, we run self-synths (wood onto wood)
% and will present these as the "unperturbed" videos.

% Overall the synth approach consists of starting with a 0 vector then
% "adding in" scaled peaks at the correct time from the replacement track.
% Important to note that overall amplitude is not normalized (this would
% interfere with loudness judgements), but the relative magnitude of the
% peaks is maintained to give a realistic impression of bouncing.
function synthesize(original, replace, original_num, replace_num, disp)

fs = 44100;
prefix = "SphereOn";
suffix = "Audio.wav";

surfaces = ["Wood", "Foam", "Plate"];
peak_params = [0.03 0.001; 0.03 0.004; 0.08 0.01];

original_audio = audioread(char(prefix+surfaces(original)+original_num+suffix));
replace_audio = audioread(char(prefix+surfaces(replace)+replace_num+suffix));

[pks3, locs3, widths3] = findpeaks(original_audio(:, 3), 44100, 'MinPeakDistance', peak_params(original, 1), 'MinPeakHeight', peak_params(original, 2));
[pks3_rep, locs3_rep, widths3_rep] = findpeaks(replace_audio(:, 3), 44100, 'MinPeakDistance', peak_params(replace, 1), 'MinPeakHeight', peak_params(replace, 2));

% We need to extract the first "clearest" peak from the replace audio:
% We take advantage of the fact that channel 3 peaks always come before
% channel 1,2 peaks, so we can find the max magnitude of the peak by doing
% a max, instead of trying to tune parameters to peakfind on the other
% channels. Note when we cut out our peak, we retain some time before the
% maximum since we're matching times based on channel 3 and we approximate
% that the latency is approximately the same always.
replace_peak_mag = max(replace_audio(int32(fs*locs3_rep(1)):int32(fs*locs3_rep(2)), :)); % one for each channel
replace_peak_len = int32(fs*(locs3_rep(2) - locs3_rep(1)));
replace_peak_start = int32(fs*locs3_rep(1));

% We also need the magnitude of the first original peak to do
% rescaling/normalize
original_peak_mag_norm = max(original_audio(int32(fs*locs3(1)):int32(fs*locs3(2)), :));

new_audio = zeros(length(original_audio), 2);

for i = 1:length(locs3)
    stop = int32(length(original_audio));
    if i < length(locs3)
        stop = int32(fs*locs3(i+1));
    end
    start = int32(fs*locs3(i));
    % We extract the peak in the original audio and get the magnitude
    original_peak_mag = max(original_audio(start:stop, :));
    for j = 1:replace_peak_len
        if start+j-1 > int32(length(original_audio))
            break
        end
        % Note below is where we write the channel 2 audio to both channel
        % 1 and channel 2. I still leave the code in a general form where
        % it can deal with channels independently; I simply do not take
        % advantage of this feature in the code.
        % new_audio(start+j-1, 1) = new_audio(start+j-1, 1) + replace_audio(replace_peak_start+j-1, 1)*original_peak_mag(1)/original_peak_mag_norm(1);
        new_audio(start+j-1, 1) = new_audio(start+j-1, 2) + replace_audio(replace_peak_start+j-1, 2)*original_peak_mag(2)/original_peak_mag_norm(2);
        new_audio(start+j-1, 2) = new_audio(start+j-1, 2) + replace_audio(replace_peak_start+j-1, 2)*original_peak_mag(2)/original_peak_mag_norm(2);
    end
end

% For visualization purposes
if disp == 1
    figure(1);
    subplot(2, 1, 1);
    plot(original_audio(:, 2))
    subplot(2, 1, 2);
    plot(new_audio(:, 2))
end

audiowrite(char(prefix+surfaces(original)+original_num+"Dubbed"+surfaces(replace)+replace_num+suffix), new_audio, fs);

% Output files in format [Surface]_Sphere_number_[Sound]_v[n].wav
% audiowrite(char(surface_type+infix+num+"_"+replace_type+"_v1"+suffix), new_audio_v1, fs);
% audiowrite(char(surface_type+infix+num+"_"+replace_type+"_v2"+suffix), new_audio_v2, fs);

% original12 = original_audio(:, 1);
% replace12 = replace_audio(:, 1);
% 
% new_audio_v1 = zeros(size(original12));
% new_audio_v2 = original12;
% % We need to extract the first "clearest" peak from the replace audio
% % We then find it's max magnitude which will be used for scaling and
% % overlaying
% replace_peak_mag = max(replace12(int32(fs*locs3_rep(1)):int32(fs*locs3_rep(2)), 1)); % the peak that will be used to overwrite
% replace_peak_len = fs*(locs3_rep(2) - locs3_rep(1));
% num_peaks = length(locs3);
% for i = 1:(num_peaks-1)
%     time = locs3(i+1) - locs3(i);
%     len = fs*time;
%     if replace_peak_len < len
%         len = rep_len;
%     end
%     peak = max(original12(int32(fs*locs3(i)):int32(fs*locs3(i+1)), 1));
%     for j = 1:len
% %         near = closest_index(locs(i), locs3);
%         new_audio_v1(int32(locs3(i)*fs+j-1), 1) = replace12(int32(locs3_rep(1)*fs+j-1), 1)*peak/replace_peak;
%         new_audio_v1(int32(locs3(i)*fs+j-1), 2) = replace12(int32(locs3_rep(1)*fs+j-1), 1)*peak/replace_peak;
%         new_audio_v2(int32(locs3(i)*fs+j-1), 1) = replace12(int32(locs3_rep(1)*fs+j-1), 1)*peak/replace_peak;
%         new_audio_v2(int32(locs3(i)*fs+j-1), 2) = replace12(int32(locs3_rep(1)*fs+j-1), 1)*peak/replace_peak;
% %         start(int32(locs(i)*fs+j-1), 2) = replace(locs2(1)*fs+j, 2)*pks3(near)/pks2(1);
%     end
% end
% len = length(original12) - fs*locs(num_peaks);
% peak = max(original12(int32(fs*locs3(num_peaks)):length(original12), 1));
% if rep_len < len
%     len = rep_len;
% end
% for j = 1:len
%     new_audio_v1(int32(locs3(num_peaks)*fs+j-1), 1) = replace12(int32(locs3_rep(1)*fs+j-1), 1)*peak/replace_peak;
%     new_audio_v1(int32(locs3(num_peaks)*fs+j-1), 2) = replace12(int32(locs3_rep(1)*fs+j-1), 1)*peak/replace_peak;
%     new_audio_v2(int32(locs3(num_peaks)*fs+j-1), 1) = replace12(int32(locs3_rep(1)*fs+j-1), 1)*peak/replace_peak;
%     new_audio_v2(int32(locs3(num_peaks)*fs+j-1), 2) = replace12(int32(locs3_rep(1)*fs+j-1), 1)*peak/replace_peak;
% end
% 
% % For visualization purposes
% fig1 = figure(1);
% plot(original12)
% hold on;
% plot(new_audio_v1)
% hold off;
% fig2 = figure(2);
% plot(replace12)
% 
% % Output files in format [Surface]_Sphere_number_[Sound]_v[n].wav
% audiowrite(char(surface_type+infix+num+"_"+replace_type+"_v1"+suffix), new_audio_v1, fs);
% audiowrite(char(surface_type+infix+num+"_"+replace_type+"_v2"+suffix), new_audio_v2, fs);

