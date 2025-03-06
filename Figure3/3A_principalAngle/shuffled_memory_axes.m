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

%% square root transform
for n = 1:length(data.unit)
    data.unit(n).response = sqrt(data.unit(n).response);
end

%% select data
for task = [0 1]% (0=nolook, 1=look)
    dataS = [];
    for nUnit = 1:length(data.unit)
        trialidx = find(data.unit(nUnit).task_variable.look == task);
        dataS.unit(nUnit).response = data.unit(nUnit).response(trialidx,:);
        dataS.unit(nUnit).task_variable.look = data.unit(nUnit).task_variable.look(trialidx,:);
        dataS.unit(nUnit).task_variable.direction = data.unit(nUnit).task_variable.direction(trialidx,:);
        dataS.unit(nUnit).dimension = data.unit(nUnit).dimension;
        dataS.time = data.time;
    end

    %% Parameters
    plotflag = 0;

    for iter = 1:100
        %% select trials
        for n = 1:length(dataS.unit)
            pref = find(dataS.unit(n).task_variable.direction == 1);
            pref_1 = randsample(pref,round(length(pref)/2));
            pref_2 = setdiff(pref,pref_1);

            null = find(dataS.unit(n).task_variable.direction == 0);
            null_1 = randsample(null,round(length(null)/2));
            null_2 = setdiff(null,null_1);

            group_tr{n,1} = [pref_1; null_1];
            group_tr{n,2} = [pref_2; null_2];
        end

        for group = 1:2
            %% select group
            dataSG = [];
            for n = 1:length(dataS.unit)
                dataSG.unit(n).response = dataS.unit(n).response(group_tr{n,group},:);
                dataSG.unit(n).task_variable.look = dataS.unit(n).task_variable.look(group_tr{n,group});
                dataSG.unit(n).task_variable.direction = dataS.unit(n).task_variable.direction(group_tr{n,group});
                dataSG.unit(n).dimension = dataS.unit(n).dimension;
                dataSG.time = dataS.time;
            end

            %% Condition averaged responses

            % The conditions to use
            task_index = [];
            task_index.direction = [1 2]';

            % Condition average
            dataC = tdrAverageCondition(dataSG,task_index);

            %% Process condition averaged responses

            dataC_smth = dataC;

            % Averaging parameters
            avgpars = [];
            avgpars.trial = [];
            avgpars.time = [];

            % Mean and STD across time and conditions
            [meanC,stdC] = tdrMeanAndStd(dataC_smth,avgpars);

            % Normalization parameters
            nrmlpars = [];
            nrmlpars.ravg = meanC;
            nrmlpars.rstd = stdC;

            % Normalize
            dataC_nrml = tdrNormalize(dataC_smth,nrmlpars);

            %% Linear regression

            % Averaging parameters
            avgpars = [];
            avgpars.trial = [];
            avgpars.time = [];

            % Mean and STD across time and trials
            [meanT,stdT] = tdrMeanAndStd(dataSG,avgpars);

            % Normalization parameters
            nrmlpars = [];
            nrmlpars.ravg = meanT;
            nrmlpars.rstd = stdT;

            % Normalize
            dataT_nrml = tdrNormalize(dataSG,nrmlpars);

            % Regression parameters
            regpars = [];
            regpars.regressor = {...
                'b0';...
                'direction'};
            regpars.regressor_normalization = 'none';

            % Linear regression
            coef_fulUN = tdrRegression(dataT_nrml,regpars,plotflag);

            %% Principal component analysis
            pc = 1;

            % PCA parameters
            pcapars = [];
            % pcapars.trial_pca = dataC_nrml.task_index.diff==1;
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

            %% Temporal dynamics of regression coefficients

            % Correlogram parameters
            plotpars = [];
            plotpars.name = {'direction'};
            plotpars.plotpairs = 1;

            % Coefficient correlogram
            [autoCorr,~,h] = tdrVectorDynamics(coef_midUN,plotpars,plotflag);

            %% Define regression vectors

            % Regression vector parameters
            vecpars = [];
            vecpars.direction.time_win = 0:500;

            % Compute regression vectors
            vBeta{iter,group} = tdrVectorTimeAverage(coef_midUN,vecpars,plotflag);
        end
    end
    if task == 0
        save(['axis_nolook_' type '_pc' num2str(pc) '_control.mat'],'vBeta');
    elseif task == 1
        save(['axis_look_' type '_pc' num2str(pc) '_control.mat'],'vBeta');
    end
end