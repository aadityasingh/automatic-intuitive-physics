shapes = ["Sphere", "Cube", "Cyl"];
surfaces = ["Wood", "Foam", "Plate"];
% Below are in SphereWood, SphereFoam, etc. order
estimates = [8, 7, 13, 5, 9, 6, 6, 6, 8];
first_hit_times = zeros(1, 9);
index = 1;
figure(1);
for i = 1:3
    for j = 1:3
        subplot(3, 3, index);
        data = audioread(char(shapes(i)+"On"+surfaces(j)+"Audio.wav"));
        [pks, locs, widths] = findpeaks(data(1:661500, 1), 44100, 'MinPeakDistance', 0.3, 'MinPeakHeight', 0.25);
        first_hit_times(index) = locs(closest_index(estimates(index), locs));
        plot(data(:, 1));
        hold on;
        title(char(shapes(i)+" On "+surfaces(j)));
        est = first_hit_times(index)*44100;
        plot([est est], [-1 1]);
        hold off;
        index = index +1;
    end
end
first_hit_times

estimates2 = [6, 5, 5, 2, 3, 5, 2, 1, 3];
first_hit_times2 = zeros(1, 9);
index = 1;
figure(2);
for i = 1:3
    for j = 1:3
        subplot(3, 3, index);
        data = audioread(char(shapes(i)+"On"+surfaces(j)+".wav"));
        [pks, locs, widths] = findpeaks(data(1:441000, 1), 44100, 'MinPeakDistance', 1, 'MinPeakHeight', 0.01);
        first_hit_times2(index) = locs(closest_index(estimates2(index), locs));
        plot(data(1:441000, 1));
        hold on;
        title(char(shapes(i)+" On "+surfaces(j)));
        est = first_hit_times2(index)*44100;
        plot([est est], ylim);
        hold off;
        index = index +1;
    end
end
first_hit_times2
first_hit_times-first_hit_times2