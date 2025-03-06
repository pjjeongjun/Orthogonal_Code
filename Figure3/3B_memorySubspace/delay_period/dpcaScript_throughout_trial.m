%% Perform dPCA on population activity
% Step 1. Run '../delay_period/dpcaScript_delay_period.m'
% Step 2. Run 'dpcaScript_throughout_trial.m'
% AND THEN
% Step 3. Run 'Projection_plot.m'

%% Add path & Load data
clear; clc;

% dPCA path
dpcaDir = '/Users/jeongjun/Desktop/dPCA-master/matlab'; % replace it to your path
addpath(fullfile(dpcaDir));

for task = 1:3 % 1:nolook, 2:look, 3:combined
    load('firingRates_directions_normalized.mat');
    % firingRates:        unit, direction, task, time, trial
    % firingRatesAverage: unit, direction, task, time

    if task == 1 %no-look
        firingRates = squeeze(firingRates(:,:,1,:,:));
    elseif task == 2 %look
        firingRates = squeeze(firingRates(:,:,2,:,:));
    elseif task == 3 % both tasks combined
        nolook = squeeze(firingRates(:,:,1,:,:));
        look = squeeze(firingRates(:,:,2,:,:));

        for n = 1:size(firingRates,1)
            for d = 1:size(firingRates,2)
                if ~isempty(find(isnan(nolook(n,d,1,:)),1))
                    nolook_idx(n,d) = find(isnan(nolook(n,d,1,:)),1)-1;
                else
                    nolook_idx(n,d) = size(nolook,4);
                end
                if ~isempty(find(isnan(look(n,d,1,:)),1))
                    look_idx(n,d) = find(isnan(look(n,d,1,:)),1)-1;
                else
                    look_idx(n,d) = size(look,4);
                end
            end
        end
        maxtrial = max(max(nolook_idx+nolook_idx));
        firingRates_combined = nan(size(look,1),size(look,2),size(look,3),maxtrial);

        for n = 1:size(firingRates_combined,1)
            for d = 1:size(firingRates_combined,2)
                % use the same number of trials from each task
                trialidx = min(nolook_idx(n,d),look_idx(n,d));
                firingRates_combined(n,d,:,1:2*trialidx) = cat(4, nolook(n,d,:,1:trialidx),look(n,d,:,1:trialidx));
            end
        end
        firingRates = firingRates_combined;
    end

    firingRatesAverage = squeeze(nanmean(firingRates,4));

    % time and trialNum info
    time = -500:50:1150;

    % trialNum
    trialNum = nan(size(firingRates,1),size(firingRates,2));
    for i1 = 1:size(firingRates,1) %unit
        for i2 = 1:size(firingRates,2) %direction
            tmp = firingRates(i1,i2,1,:);
            trialNum(i1,i2) = length(tmp(~isnan(tmp)));
        end
    end

    % setting random number of repetitions for each neuron and condition
    ifSimultaneousRecording = false;  % change this to simulate simultaneous

    % number of directions
    S = 6;

    % Define parameter grouping
    combinedParams = {{1, [1 2]}, {2}};
    margNames = {'Direction', 'Condition-independent'};
    margColours = [23 100 171; 187 20 25; 150 150 150]/256;

    timeEvents = 0;

    % check consistency between trialNum and firingRates
    for n = 1:size(firingRates,1)
        for s = 1:size(firingRates,2)
            assert(isempty(find(isnan(firingRates(n,s,:,1:trialNum(n,s))), 1)), 'Something is wrong!')
        end
    end

    % dPCA with regularization
    optimalLambda = dpca_optimizeLambda(firingRatesAverage, firingRates, trialNum, ...
        'combinedParams', combinedParams, ...
        'simultaneous', ifSimultaneousRecording, ...
        'numRep', 2, ...  % increase this number to ~10 for better accuracy
        'filename', 'tmp_optimalLambdas.mat');

    Cnoise = dpca_getNoiseCovariance(firingRatesAverage, ...
        firingRates, trialNum, 'simultaneous', ifSimultaneousRecording);

    [W,V,whichMarg] = dpca(firingRatesAverage, 20, ...
        'combinedParams', combinedParams, ...
        'lambda', optimalLambda, ...
        'Cnoise', Cnoise);

    explVar = dpca_explainedVariance(firingRatesAverage, W, V, ...
        'combinedParams', combinedParams);

    [Xcen, Z, dataDim] = dpca_plot(firingRatesAverage, W, V, @dpca_plot_default, ...
        'explainedVar', explVar, ...
        'marginalizationNames', margNames, ...
        'marginalizationColours', margColours, ...
        'whichMarg', whichMarg,                 ...
        'time', time,                        ...
        'timeEvents', timeEvents,               ...
        'timeMarginalization', 3,           ...
        'legendSubplot', 16);

    save(['dpca_result_task' num2str(task) '.mat'],'W','V','whichMarg','explVar','Xcen','Z','dataDim');
end