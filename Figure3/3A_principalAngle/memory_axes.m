%% Principal angle between memory axes from TDR (Figure 3A)
% Step 1. Run "memory_axes.m"
% Perform targeted dimensionality reduction (TDR) method to get spatial memory axes of population activity
%
% Step 2. Run "principal_angle.m"
% Compute principal angle between spatial memory axes from each task (look & no-look task)
%
% Step 3. Run "shuffled_memory_axes.m"
% Generate memory axes using shuffled data to compute noise floor
%
% Step 4. Run "null_angle.m"
% Compute noise floor and compare it with the actual principal angle

%% Add paths
clear; clc;

% TDR path
tdrDir = '/Users/jeongjun/Desktop'; % replace it your path
addpath(fullfile(tdrDir,'TDR'));
addpath(fullfile(tdrDir,'TDR','nansuite'));
addpath(fullfile(tdrDir,'TDR','tools'));

%% Load data
% firing rate
type = 'early_delay'; % replace it to 'late_delay' for the memory axes during late delay period
load(['firingRates_' type '.mat']);

% early delay: 0:50:450 from target offset
% i.e., 0~50 ms, 50~100 ms, ..., 400~450 ms, 450~500 ms from target offset

% early delay: 500:50:950 from target offset
% i.e., 500~550 ms, 550~600 ms, ..., 900~950 ms, 950~1000 ms from target offset

%% task information
%task type: nolook = 0, look = 1
%stimulus direction: null = 0, preferred = 1

% include cells that have both task types and stimulus directions
delete_idx = [];
for i = 1:length(data.unit)
    if length(unique(data.unit(i).task_variable.look)) == 2 && ...
            length(unique(data.unit(i).task_variable.direction)) == 2
    else
        delete_idx = [delete_idx; i];
    end
end
data.unit(delete_idx) = [];

%% select data
for task = [0 1] % (0=nolook, 1=look)
    dataS = [];
    for nUnit = 1:length(data.unit)
        trialidx = find(data.unit(nUnit).task_variable.look == task);
        dataS.unit(nUnit).response = data.unit(nUnit).response(trialidx,:);
        dataS.unit(nUnit).task_variable.look = data.unit(nUnit).task_variable.look(trialidx);
        dataS.unit(nUnit).task_variable.direction = data.unit(nUnit).task_variable.direction(trialidx);
        dataS.unit(nUnit).dimension = data.unit(nUnit).dimension;
        dataS.time = data.time;
    end

    %% square root transform
    for n = 1:length(dataS.unit)
        dataS.unit(n).response = sqrt(dataS.unit(n).response);
    end

    %% Condition averaged responses

    % The conditions to use
    task_index = [];
    task_index.direction = [1 2]';

    % Condition average
    dataC = tdrAverageCondition(dataS,task_index);

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
    [meanT,stdT] = tdrMeanAndStd(dataS,avgpars);

    % Normalization parameters
    nrmlpars = [];
    nrmlpars.ravg = meanT;
    nrmlpars.rstd = stdT;
    % nrmlpars.cnst = median(stdT)/2; % arbitrary

    % Normalize
    dataT_nrml = tdrNormalize(dataS,nrmlpars);

    % Regression parameters
    regpars = [];
    regpars.regressor = {...
        'b0';...
        'direction'};
    regpars.regressor_normalization = 'none';

    % Linear regression
    coef_fulUN = tdrRegression(dataT_nrml,regpars,0);
    coef_fulUN_rawFR = tdrRegression(dataS,regpars,0);

    %% Principal component analysis
    pc = 1;

    % PCA parameters
    pcapars = [];
    pcapars.trial_prj = [];
    pcapars.time_pca = [];
    pcapars.plot_dimensions = 1:pc;

    % Compute PCA
    [data_fulPC,fulUN_fulPC,varPC] = tdrPca(dataC_nrml,pcapars,0);


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
    var_mid = tdrSubspaceVariance(data_fulPC,dataC_nrml,varpars,0);


    % Denoise and smooth regression coefficients
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

    if task == 0
        save(['coef_nolook_pc' num2str(pc) '_' type '.mat'],'coef_midUN');
    elseif task == 1
        save(['coef_look_pc' num2str(pc) '_' type '.mat'],'coef_midUN');
    end
end