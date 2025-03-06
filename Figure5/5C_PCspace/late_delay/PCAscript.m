%% Add paths

clear; clc;

% TDR path
tdrDir = '/Users/jeongjun/Desktop/';
addpath(fullfile(tdrDir,'TDR'));
addpath(fullfile(tdrDir,'TDR','nansuite'));
addpath(fullfile(tdrDir,'TDR','tools'));

%% Load data
% firing rate

load('spikes_binary_6directions_delay.mat');
% delay period activity: 0~1000 ms from target offset

dataT = data;

% make nolook = 1, look = 0
for i = 1:length(dataT.unit)
    idx_nolook = find(dataT.unit(i).task_variable.look==0);
    idx_look = find(dataT.unit(i).task_variable.look==1);
    dataT.unit(i).task_variable.look(idx_nolook) = 1;
    dataT.unit(i).task_variable.look(idx_look) = 0;
end

%% square root transform
for n = 1:length(dataT.unit)
    dataT.unit(n).response = sqrt(dataT.unit(n).response);
end

%% Parameters

plotflag = 0;

%% Condition averaged responses

% The conditions to use
task_index = [];
task_index.look = [1 1 1 1 1 1 2 2 2 2 2 2]'; %look = 1, nolook = 2
task_index.direction = [1 2 3 4 5 6 1 2 3 4 5 6]'; %-180~-120, -120 ~ -60, -60 ~ 0, 0 ~ 60, 60 ~ 120, 120 ~ -180

% Condition average
dataC = tdrAverageCondition(dataT,task_index);

%% Process condition averaged responses

% Averaging parameters
avgpars = [];
avgpars.trial = [];
avgpars.time = [];

% Mean and STD across time and conditions
[meanC,stdC] = tdrMeanAndStd(dataC,avgpars);

% Normalization parameters
nrmlpars = [];
nrmlpars.ravg = meanC;
nrmlpars.rstd = stdC;

% Normalize
dataC_nrml = tdrNormalize(dataC,nrmlpars);

%% Principal component analysis
pc = 1:3;

% PCA parameters
pcapars = [];
% pcapars.trial_pca = dataC_nrml.task_index.diff==1;
pcapars.trial_prj = [];
pcapars.time_pca = [];
% pcapars.plot_dimensions = 1:pc;
pcapars.plot_dimensions = pc;

% Compute PCA
[data_fulPC,fulUN_fulPC,varPC] = tdrPca(dataC_nrml,pcapars,plotflag);

%% Plot 3d projection
time = 11:20; % late delay; 500-1000 ms from target offset

look_1 = []; look_2 = []; look_3 = []; nolook_1 = []; nolook_2 = []; nolook_3 = []; 
for dir = 1:6+1
    if dir == 7
        dir = 1;
    end
    look_1 = [look_1; mean(data_fulPC.response(1,time,dir),2)];
    look_2 = [look_2; mean(data_fulPC.response(2,time,dir),2)];
    look_3 = [look_3; mean(data_fulPC.response(3,time,dir),2)];

    nolook_1 = [nolook_1; mean(data_fulPC.response(1,time,dir+6),2)];
    nolook_2 = [nolook_2; mean(data_fulPC.response(2,time,dir+6),2)];
    nolook_3 = [nolook_3; mean(data_fulPC.response(3,time,dir+6),2)];
end

figure;
plot3(look_1,look_2,look_3,'-o','Color',[0 1 0.5],'LineWidth',2); hold on;
plot3(nolook_1,nolook_2,nolook_3,'-o','Color',[1 0 0],'LineWidth',2); hold on;
plot3([look_1(1) nolook_1(1)],[look_2(1) nolook_2(1)],[look_3(1) nolook_3(1)],'k:','LineWidth',1); hold on;
plot3([look_1(2) nolook_1(2)],[look_2(2) nolook_2(2)],[look_3(2) nolook_3(2)],'k:','LineWidth',1); hold on;
plot3([look_1(3) nolook_1(3)],[look_2(3) nolook_2(3)],[look_3(3) nolook_3(3)],'k:','LineWidth',1); hold on;
plot3([look_1(4) nolook_1(4)],[look_2(4) nolook_2(4)],[look_3(4) nolook_3(4)],'k:','LineWidth',1); hold on;
plot3([look_1(5) nolook_1(5)],[look_2(5) nolook_2(5)],[look_3(5) nolook_3(5)],'k:','LineWidth',1); hold on;
plot3([look_1(6) nolook_1(6)],[look_2(6) nolook_2(6)],[look_3(6) nolook_3(6)],'k:','LineWidth',1); hold on;

xlim([-20 20]); xticks(-12:4:12);
ylim([-20 20]); yticks(-12:4:12);
zlim([-20 20]); zticks(-12:4:12);

grid on;
xlabel('PC1'); ylabel('PC2'); zlabel('PC3');
title('Memory activity on PC space');
legend('look task','no-look task');