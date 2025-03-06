%% Train and test datasets
% For every bootstrapping data,
% 1 trial of each direction (6) for testsets
% 50 trials of each direction (6) for trainsets

clear; clc; close all;

% dPCA path
dPCADir = '/Users/jeongjun/Desktop/dPCA-master/matlab'; % replace it to your path
addpath(fullfile(dPCADir));

% time selection
period3 = 1:10;  %0~500 ms (delay)

% number of trials
ntrials = 50;
nboots = 100;

for shifted = 1:60
    W_tt = {};
    V_tt = {};
    firingRates_tt = {};
    firingRatesAverage_tt = {};
    time_tt = {};
    componentsToUse_tt = {};
    testset_tt = {};

    for task = 3 %1:nolook 2:look %3:mixed
        load(['../../../Figure3/3C_decoding/late_delay/firingRates_directions_' num2str(shifted) '_normalized.mat']); % cell x direction x task x time x trial
        if task == 3
            firingRates_nolook = squeeze(firingRates(:,:,1,period3,:));
            firingRates_look = squeeze(firingRates(:,:,2,period3,:));
            firingRates_task = cat(4,firingRates_nolook,firingRates_look);
        else
            firingRates_task = squeeze(firingRates(:,:,task,period3,:));
        end

        % cell x direction x time x trial
        trainset = []; testset = [];
        for boots = 1:nboots
            for n = 1:size(firingRates_task,1)
                if task == 3
                    mintrials_nolook = []; mintrials_look = [];
                    for d = 1:size(firingRates_task,2)
                        mintrials_nolook = [mintrials_nolook find(isnan(firingRates_nolook(n,d,3,:)),1)];
                        mintrials_look = [mintrials_look find(isnan(firingRates_look(n,d,3,:)),1)];
                    end
                    
                    %nolook data
                    min_trial_nolook = min(mintrials_nolook)-1;
                    test_nolook = randsample(min_trial_nolook,1);
                    trials_nolook = 1:min_trial_nolook; trials_nolook(test_nolook) = [];
                    train_nolook = randsample(trials_nolook,ntrials/2,true);
                    % train_nolook = randsample(trials_nolook,ntrials/2);
                    trainset_nolook(n,:,1,:,:) = firingRates_nolook(n,:,:,train_nolook);
                    testset_nolook(n,:,1,:) = squeeze(firingRates_nolook(n,:,:,test_nolook));

                    %look data
                    min_trial_look = min(mintrials_look)-1;
                    test_look = randsample(min_trial_look,1);
                    trials_look = 1:min_trial_look; trials_look(test_look) = [];
                    train_look = randsample(trials_look,ntrials/2,true);
                    % train_look = randsample(trials_look,ntrials/2);
                    trainset_look(n,:,1,:,:) = firingRates_look(n,:,:,train_look);
                    testset_look(n,:,1,:) = squeeze(firingRates_look(n,:,:,test_look));     

                    %combined data
                    % cell x direction x task x time x trial
                    trainset = cat(3,trainset_nolook,trainset_look);
                    testset = cat(3,testset_nolook,testset_look);
                else
                end
            end

            %% dPCA
            % average firing rate
            firingRates = trainset;
            firingRatesAverage = squeeze(mean(firingRates,5));

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

            % combinedParams = {{1, [1 2]}, {2}};
            % margNames = {'Direction', 'Condition-independent'};
            % margColours = [23 100 171; 187 20 25; 150 150 150]/256;

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

            % Step 4: dPCA with regularization

            optimalLambda = dpca_optimizeLambda(firingRatesAverage, firingRates, trialNum, ...
                'combinedParams', combinedParams, ...
                'simultaneous', ifSimultaneousRecording, ...
                'numRep', 2, ...  % increase this number to ~10 for better accuracy
                'filename', 'tmp_optimalLambdas.mat');

            Cnoise = dpca_getNoiseCovariance(firingRatesAverage, ...
                firingRates, trialNum, 'simultaneous', ifSimultaneousRecording);

            minN1 = min(size(firingRates_task,1));
            minN2 = size(firingRates_task,2)*size(firingRates_task,3);
            minN = min(minN1,minN2);
            [W,V,whichMarg] = dpca(firingRatesAverage, minN, ...
                'combinedParams', combinedParams, ...
                'lambda', optimalLambda, ...
                'Cnoise', Cnoise);

            explVar = dpca_explainedVariance(firingRatesAverage, W, V, ...
                'combinedParams', combinedParams);

            componentsToUse_memory = find(whichMarg == 1); %1 = direction 2= task
            componentsToUse_task = find(whichMarg == 2); %1 = direction 2= task

            % save the data
            W_tt{boots,task} = W;
            V_tt{boots,task} = V;
            firingRates_tt{boots,task} = firingRates;
            firingRatesAverage_tt{boots,task} = firingRatesAverage;
            componentsToUse_tt{boots,task} = componentsToUse_task;
            componentsToUse_tt_memory{boots,task} = componentsToUse_memory;
            testset_tt{boots,task} = testset;

            disp(['Task' num2str(task) ', iteration ' num2str(boots) '/' num2str(nboots) '']);
        end
    end
    save(['regul_train_test_' num2str(shifted) '.mat'],'W_tt','V_tt','firingRates_tt','firingRatesAverage_tt','componentsToUse_tt','componentsToUse_tt_memory','testset_tt','-v7.3');
end
