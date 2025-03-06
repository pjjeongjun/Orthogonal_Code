%% max accuracy
clear; clc; close all;

% dPCA path
dPCADir = '/Users/jeongjun/Desktop/dPCA-master/matlab';
addpath(fullfile(dPCADir));

ndirs = 6;
nshifts = 60;
nboots = 100;

look_original = []; nolook_original = [];
look_each = []; nolook_each = [];
look_cross = []; nolook_cross = [];

for shifted = 1:nshifts
    % common (each)
    load(['performance_shifted' num2str(shifted) '_cross2_nolook_max.mat']);
    nolook_each(shifted,:) = percent_correct_nolook;

    load(['performance_shifted' num2str(shifted) '_cross2_look_max.mat']);
    look_each(shifted,:) = percent_correct_look;
end

look_each = look_each(:,1:nboots);
nolook_each = nolook_each(:,1:nboots);

look_each = mean(look_each,1)';
nolook_each = mean(nolook_each,1)';

% figure - bar
mean_look_each = mean(look_each);
std_look_each = std(look_each);

figure;

subplot(1,2,1)
y = mean_look_each;
b = bar(y);

set(gca, 'XTickLabel',{'Task'})
b.FaceColor = 'flat';
b.CData(1,:) = [0 0 1];

hold on; errorbar(1,y,std_look_each);

title('Memory decoding - look');
xlabel('Decoder')
ylabel('Decoding performance (%)');
ylim([0 100]);

mean_nolook_each = mean(nolook_each);
std_nolook_each = std(nolook_each);

subplot(1,2,2)
y = mean_nolook_each;
b = bar(y);

set(gca, 'XTickLabel',{'Task'})
b.FaceColor = 'flat';
b.CData(1,:) = [0 0 1];

hold on; errorbar(1,y,std_nolook_each);

title('Memory decoding - nolook');
xlabel('Decoder')
ylabel('Decoding performance (%)');
ylim([0 100]);