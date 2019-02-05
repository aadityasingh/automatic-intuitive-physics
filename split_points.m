shapes = ["Sphere", "Cube", "Cyl"];
surfaces = ["Wood", "Foam", "Plate"];
% Below are in SphereWood, SphereFoam, etc. order
index = 1;
figure(2);
pre_peak_time = 1;
num_peaks  = zeros(1, 9);
for i = 1:3
    for j = 1:3
        subplot(3, 3, index);
        data = audioread(char(shapes(i)+"On"+surfaces(j)+".wav"));
        max_peak = max(data(:, 3));
        findpeaks(data(:, 3), 44100, 'MinPeakDistance', 2, 'MinPeakHeight', max_peak/4)
        [pks, locs, widths] = findpeaks(data(:, 3), 44100, 'MinPeakDistance', 2, 'MinPeakHeight', max_peak/4);
%         length(locs)
%         transpose(locs)
        num_peaks(index) = length(locs);
        for k = 1:num_peaks(index)
            disp("peaks[" + (index-1) + "," + (k-1) + "]=" + (locs(k)-1))
        end
        hold on;
        title(char(shapes(i)+" On "+surfaces(j)));
        hold off;
        index = index +1;
    end
end
disp(num_peaks)