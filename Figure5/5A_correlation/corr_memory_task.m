%% Correlation between memory activity and baseline modulation (Figure 5A)
clear; clc; close all;

type = 'early_delay'; % replace it to 'late_delay' to use late delay activity

load(['memory_amp_look_' type '.mat']);
look = memory_amp;
load(['memory_amp_nolook_' type '.mat']);
nolook = memory_amp;

memory_look = look';
memory_nolook = nolook';
memory_mean = mean([look; nolook],1)';

load('fixation_amp.mat');
task = fixation_diff';

[rho,p] = corr(memory_mean,task,'type','Spearman');

figure;
scatter(memory_look,task,'green'); hold on;
scatter(memory_nolook,task,'red'); hold on;
scatter(memory_mean,task,'blue'); hold on;

title(['rho = ' num2str(rho) ', p = ' num2str(p) '']);
xlabel('Memory modulation (spikes/s): Look-no-look');
ylabel('Task modulation (spikes/s): Look-no-look')