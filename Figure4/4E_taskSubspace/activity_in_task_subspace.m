%% Projection of population activity into the task-related neural subspace defined by dPCA (Figure 4E)

% Add path & Load data
clear; clc;

% dPCA path
dPCADir = '/Users/jeongjun/Desktop/dPCA-master/matlab';
addpath(fullfile(dPCADir));

load('firingRates_directions_normalized.mat');
% firingRates:        unit, direction, task, time, trial
% firingRatesAverage: unit, direction, task, time

firingRatesAverage = squeeze(nanmean(firingRates,5));

% time and trialNum info
time = -500:50:1150;
trialNum = nan(size(firingRates,1),size(firingRates,2),size(firingRates,3));
for i1 = 1:size(firingRates,1) %unit
    for i2 = 1:size(firingRates,2) %direction
        for i3 = 1:size(firingRates,3) %task
            tmp = firingRates(i1,i2,i3,1,:);
            trialNum(i1,i2,i3) = length(tmp(~isnan(tmp)));
        end
    end
end

% setting random number of repetitions for each neuron and condition
ifSimultaneousRecording = false;  % change this to simulate simultaneous 
                                 % recordings (they imply the same number 
                                 % of trials for each neuron)
% number of directions
S = 6;

combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};
margNames = {'Direction', 'Task', 'Condition-independent', 'D/T Interaction'};
margColours = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;

timeEvents = 0;

% check consistency between trialNum and firingRates
for n = 1:size(firingRates,1)
    for s = 1:size(firingRates,2)
        for d = 1:size(firingRates,3)
            assert(isempty(find(isnan(firingRates(n,s,d,:,1:trialNum(n,s,d))), 1)), 'Something is wrong!')
        end
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

[W,V,whichMarg] = dpca(firingRatesAverage, 319, ...
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

save('dpca_result.mat','Z','dataDim','W','V','whichMarg','explVar');

%% 2d or 3d projection plot
clear; clc;

load('dpca_result.mat');

% whichMarg: 1 = memory, 2 = task
% task: 1 = nolook, 2 = look

time = -500:50:1150;
dim = 1;
componentsToPlot = find(whichMarg == 2);

componentsToPlot = componentsToPlot(1:dim);
Zfull = reshape(Z(:,componentsToPlot)', [length(componentsToPlot) dataDim(2:end)]);

figure;

% Define a color map for each 'dir'
colors = lines(6); % This will generate 6 distinct colors

% Iterate over dirs
for dir = 1:6
    % Select color for the current 'dir'
    color = colors(dir, :);
    
    % Iterate over tasks
    for task = 1:2
        if dim == 1
            if task == 1
                plot(time, squeeze(Zfull(1,dir,task,:)), '--', 'Color', color); hold on;
            elseif task == 2
                plot(time, squeeze(Zfull(1,dir,task,:)), 'Color', color); hold on;
            end
        elseif dim == 2
            if task == 1
                plot(squeeze(Zfull(1,dir,task,:)), squeeze(Zfull(2,dir,task,:)), '--', 'Color', color); hold on;
            elseif task == 2
                plot(squeeze(Zfull(1,dir,task,:)), squeeze(Zfull(2,dir,task,:)), 'Color', color); hold on;
            end
        elseif dim == 3
            if task == 1
                plot3(squeeze(Zfull(1,dir,task,:)), squeeze(Zfull(2,dir,task,:)), squeeze(Zfull(3,dir,task,:)), '--', 'Color', color); hold on;
            elseif task == 2
                plot3(squeeze(Zfull(1,dir,task,:)), squeeze(Zfull(2,dir,task,:)), squeeze(Zfull(3,dir,task,:)), 'Color', color); hold on;
            end
        end
    end
end

title('Projection of population activity on task subspace');
xlabel('Task component 1');
ylabel('Task component 2');