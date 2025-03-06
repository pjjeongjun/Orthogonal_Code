%% Define memory axis and task axis
% Step 1: Run 'memory_and_task_axes' to define axes
% Step 2: Run 'principal_angle' to compute the angle between axes

clear; clc; close all;

pc = 1; % number of PCs to use for denoising regression coefficients
type = 'lat'; % 'ear' for early delay; 'lat' for late delay

%% Add paths

% TDR path
tdrDir = '/Users/jeongjun/Desktop'; % replace it your path
addpath(fullfile(tdrDir,'TDR'));
addpath(fullfile(tdrDir,'TDR','nansuite'));
addpath(fullfile(tdrDir,'TDR','tools'));

%% Load data
% firing rate

load('spikes_binary_directions_pref_null.mat');
dataT = data;

% make nolook = 1, look = 0
for i = 1:length(dataT.unit)
    idx_nolook = find(dataT.unit(i).task_variable.look==0);
    idx_look = find(dataT.unit(i).task_variable.look==1);
    dataT.unit(i).task_variable.look(idx_nolook) = 1;
    dataT.unit(i).task_variable.look(idx_look) = 0;
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

    %% Memory amplitude
    period = 16:25;
    for unit = 1:size(dataT.unit,2)
        pref_idx = find(dataT.unit(unit).task_variable.direction == 1);
        null_idx = find(dataT.unit(unit).task_variable.direction == 0);

        look_idx = find(dataT.unit(unit).task_variable.look == 0);
        nolook_idx = find(dataT.unit(unit).task_variable.look == 1);

        idx1 = intersect(pref_idx,nolook_idx);
        idx2 = intersect(null_idx,nolook_idx);

        FR = mean(dataT.unit(unit).response(:,period),2);
        FR_pref = FR(idx1);
        FR_null = FR(idx2);

        memory_amp(unit) = mean(FR_pref)-mean(FR_null);
    end

%% Principal component analysis

% PCA parameters
pcapars = [];
pcapars.trial_prj = [];
pcapars.time_pca = [];
pcapars.plot_dimensions = 1:pc;

% Compute PCA
[data_fulPC,fulUN_fulPC,varPC] = tdrPca(dataC_nrml,pcapars,plotflag);


%% Define mid-dimensional subspace

% Principle components to keep
pc2keep = 1:pc;

% Projection matrix full space (unit basis) into PC subspace (PC basis)
midPC_fulUN = fulUN_fulPC(:,pc2keep)';

%% Variance explained by PCs

% Variance parameters
varpars = [];
varpars.time_var = [];
varpars.dim_sub = pc2keep;

% Compute variance
var_mid = tdrSubspaceVariance(data_fulPC,dataC_nrml,varpars,plotflag);


%% Denoise and smooth regression coefficients

% Subspace parameters
subpars = [];
subpars.subSUB_fulORG = midPC_fulUN;
subpars.dimension = data_fulPC.dimension(pc2keep);

% Project coefficients into subspace
[coef_midPC,coef_midUN] = tdrSubspaceProjection(coef_fulUN,subpars);

% Smoothing parameters
smthpars = [];
smthpars.filter = 'gauss'; % {'gauss';'box'}
smthpars.width = 0.04;

% Smooth coefficients
coef_midPC = tdrTemporalSmoothing(coef_midPC,smthpars);
coef_midUN = tdrTemporalSmoothing(coef_midUN,smthpars);

% save('coef.mat','coef_fulUN','coef_midUN');

%% Temporal dynamics of regression coefficients

% Correlogram parameters
plotpars = [];
plotpars.name = {'look','direction'};
plotpars.plotpairs = 1;

% Coefficient correlogram
[autoCorr,~,h] = tdrVectorDynamics(coef_midUN,plotpars,plotflag);

%% Define regression vectors

% Regression vector parameters
vecpars = [];
vecpars.look.time_win = -400:-50;
if strcmp(type,'ear')
    vecpars.direction.time_win = 0+200:450+200;
elseif strcmp(type,'lat')
        vecpars.direction.time_win = 500+200:950+200;
end
% Compute regression vectors
vBeta = tdrVectorTimeAverage(coef_midUN,vecpars,plotflag);

%% Define task-related axes (orthogonalize regression vectors)

% Regression axes parameters
ortpars = [];
ortpars.name = {'look';'direction'};

% Compute regression axes
[vAxes,lowUN_lowTA] = tdrVectorOrthogonalize(vBeta,ortpars);

% Projection matrix full space (unit basis) into task subspace (task basis)
lowTA_lowUN = lowUN_lowTA';

if strcmp(type,'ear')
    save(['axis_pref_null_task_pc' num2str(pc2keep(end)) '_early_delay.mat'],'vBeta','vAxes');
elseif strcmp(type,'lat')
    save(['axis_pref_null_task_pc' num2str(pc2keep(end)) '_late_delay.mat'],'vBeta','vAxes');
end