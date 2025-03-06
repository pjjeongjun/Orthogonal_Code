clear; clc;

load('fixation/mean_task.mat');
fixation_fixation = mean_task;
load('fixation/using_late_delay/mean_task.mat');
late_fixation = mean_task;
load('fixation/using_stimulus/mean_task.mat');
stimulation_fixation = mean_task;
load('fixation/using_early_delay/mean_task.mat');
early_fixation = mean_task;

load('stimulus/mean_task.mat');
stimulation_stimulation = mean_task;
load('stimulus/using_late_delay/mean_task.mat');
late_stimulation = mean_task;
load('stimulus/using_fixation/mean_task.mat');
fixation_stimulation = mean_task;
load('stimulus/using_early_delay/mean_task.mat');
early_stimulation = mean_task;

load('early_delay/mean_task.mat');
early_early = mean_task;
load('early_delay/using_fixation/mean_task.mat');
fixation_early = mean_task;
load('early_delay/using_stimulus/mean_task.mat');
stimulation_early = mean_task;
load('early_delay/using_late_delay/mean_task.mat');
late_early = mean_task;

load('late_delay/mean_task.mat');
late_late = mean_task;
load('late_delay/using_fixation/mean_task.mat');
fixation_late = mean_task;
load('late_delay/using_stimulus/mean_task.mat');
stimulation_late = mean_task;
load('late_delay/using_early_delay/mean_task.mat');
early_late = mean_task;

performance(:,4) = [fixation_late stimulation_late early_late late_late];
performance(:,3) = [fixation_early stimulation_early early_early late_early];
performance(:,2) = [fixation_stimulation stimulation_stimulation early_stimulation late_stimulation];
performance(:,1) = [fixation_fixation stimulation_fixation early_fixation late_fixation];

% figure
figure;
imagesc(performance);
colormap(jet);
colorbar;
clim([99.5, 100]);