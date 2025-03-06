%% Distribution of baseline activity effect across memory cells (Figure 4C)

%% Add paths
clear; clc;

% TDR path
tdrDir = '/Users/jeongjun/Desktop'; % replace it your path
addpath(fullfile(tdrDir,'TDR'));
addpath(fullfile(tdrDir,'TDR','nansuite'));
addpath(fullfile(tdrDir,'TDR','tools'));

%% Load data
% firing rate

load('spikes_binary_directions_pref_null.mat');
dataT = data;

period = 3:10;
dataT.time = dataT.time(period);

% make nolook = 1, look = 0
for i = 1:length(dataT.unit)
    idx_nolook = find(dataT.unit(i).task_variable.look==0);
    idx_look = find(dataT.unit(i).task_variable.look==1);
    dataT.unit(i).task_variable.look(idx_nolook) = 1;
    dataT.unit(i).task_variable.look(idx_look) = 0;

    dataT.unit(i).response = dataT.unit(i).response(:,period);
end

%% task information
%task type: nolook = 0, look = 1
%stimulus direction: % null = 0, preferred = 1

% include cells that have both task types and stimulus directions
delete_idx = [];
for i = 1:length(dataT.unit)
    if length(unique(dataT.unit(i).task_variable.look)) == 2 && ...
        length(unique(dataT.unit(i).task_variable.direction)) == 2
    else
        delete_idx = [delete_idx; i];
    end
end
dataT.unit(delete_idx) = [];

%% baseline activity difference
period = 3:8;
for unit = 1:size(dataT.unit,2)
    look_idx = find(dataT.unit(unit).task_variable.look == 1);
    nolook_idx = find(dataT.unit(unit).task_variable.look == 0);
    FR = mean(dataT.unit(unit).response(:,period),2);
    FR_look = FR(look_idx);
    FR_nolook = FR(nolook_idx);

    mean_FR_look(unit) = mean(FR_look);
    mean_FR_nolook(unit) = mean(FR_nolook);
    fixation_diff(unit) = mean_FR_look(unit)-mean_FR_nolook(unit);
end

save('fixation_amp.mat','fixation_diff','mean_FR_look','mean_FR_nolook');

%% square root transform
for n = 1:length(dataT.unit)
    dataT.unit(n).response = sqrt(dataT.unit(n).response);
end

%% Parameters

plotflag = 0;

%% Condition averaged responses

% The conditions to use
task_index = [];
task_index.look = [1 1 2 2]'; %nolook = 0, look = 1
task_index.direction = [1 2 1 2]'; %contra = 0, ipsi = 180 / preferred = 0, null = 1

% Condition average
dataC = tdrAverageCondition(dataT,task_index);

% save('dataC.mat','dataC'); % condition-averaged data

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
% nrmlpars.cnst = median(stdC)/2; % arbitrary

% Normalize
dataC_nrml = tdrNormalize(dataC,nrmlpars);

%% Linear regression

% Averaging parameters
avgpars = [];
avgpars.trial = [];
avgpars.time = [];

% Mean and STD across time and trials
[meanT,stdT] = tdrMeanAndStd(dataT,avgpars);

% Normalization parameters
nrmlpars = [];
nrmlpars.ravg = meanT;
nrmlpars.rstd = stdT;
% nrmlpars.cnst = median(stdT)/2; % arbitrary

% Normalize
dataT_nrml = tdrNormalize(dataT,nrmlpars);

% Regression parameters
regpars = [];
regpars.regressor = {...
    'b0';...
    'look';'direction'};
regpars.regressor_normalization = 'none';

% Linear regression
coef_fulUN = tdrRegression(dataT_nrml,regpars,plotflag);

% p-value for task coefficient during fixation
variable = 2; %task=2, direction=3
task_coef = []; task_pval = []; task_wilcoxon_pval = [];
for unit = 1:size(dataT_nrml.unit,2)
    mdl = fitlm([dataT_nrml.unit(unit).task_variable.look],mean(dataT_nrml.unit(unit).response,2));
    task_coef = [task_coef; mdl.Coefficients.Estimate(variable)];
    task_pval = [task_pval; mdl.Coefficients.pValue(variable)];
    
    nolookidx = find(dataT_nrml.unit(unit).task_variable.look == 0);
    lookidx = find(dataT_nrml.unit(unit).task_variable.look == 1);
    FR = mean(dataT_nrml.unit(unit).response,2);
    nolookFR = FR(nolookidx);
    lookFR = FR(lookidx);
    task_wilcoxon_pval = [task_wilcoxon_pval; ranksum(nolookFR,lookFR)];
end
save('task_coef_pval_fixation.mat','task_coef','task_pval','task_wilcoxon_pval');

%% baseline activity difference
clear; clc;
load('fixation_amp.mat');
load('task_coef_pval_fixation.mat');

task_pval = task_wilcoxon_pval;
sig = find(task_pval<0.05);
non = find(task_pval>=0.05);

histogram(fixation_diff,'BinWidth',2); hold on;
histogram(fixation_diff(sig),'BinWidth',2); hold on;

legend(['Non-significant (n=' num2str(length(non)) ')'],['Significant (n=' num2str(length(sig)) ')']);
xlabel('Look - No-look (spikes/s)'); ylabel('Number of cells');
title('Baseline activity difference across tasks');
