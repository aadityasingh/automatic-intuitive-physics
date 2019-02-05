% Compare different audio channels
type = "SphereOnPlate";
suffix = "Audio.wav";
number = 0;%randi(12)-1;
char(type+number+suffix)
audio = audioread(char(type+number+suffix));
figure(1);
subplot(3, 1, 1);
plot(data(:, 1));
subplot(3, 1, 2)
plot(data(:, 2));
subplot(3, 1, 3);
plot(data(:, 3));
% prefix = "SampleVideos/";
% suffix = ".wav";
% type = "Wood_Sphere_";
% number = randi(19);
% channels12 = audioread(char(prefix+type+number+suffix));
% channels3 = audioread(char(prefix+type+number+'_Channel_3'+suffix));
% fig1 = figure(1);
% plot(channels12)
% title(type+number)
% fig2 = figure(2);
% plot(channels3)
% title(type+number+'_Channel_3')

% Viewing used to find split points
% shapes = ["Sphere", "Cube", "Cyl"];
% surfaces = ["Wood", "Foam", "Plate"];
% % Below are in SphereWood, SphereFoam, etc. order
% index = 1;
% figure(2);
% for i = 1:3
%     for j = 1:3
%         subplot(3, 3, index);
%         data = audioread(char(shapes(i)+"On"+surfaces(j)+".wav"));
%         max_peak = max(data(:, 3))
%         findpeaks(data(:, 3), 44100, 'MinPeakDistance', 2, 'MinPeakHeight', max_peak/4)
%         [pks, locs, widths] = findpeaks(data(:, 3), 44100, 'MinPeakDistance', 2, 'MinPeakHeight', max_peak/4);
%         length(locs)
%         transpose(locs)
%         hold on;
%         title(char(shapes(i)+" On "+surfaces(j)));
%         hold off;
%         index = index +1;
%     end
% end

% Viewing to test if shift performed correctly
% data = audioread('SphereOnFoam.wav');
% figure(1);
% subplot(2, 1, 1);
% plot(linspace(0, 10, 441000), data(1:441000, 1))
% subplot(2, 1, 2);
% data = audioread('SphereOnFoam2.wav');
% plot(linspace(0, 10, 441000), data(1:441000, 1))