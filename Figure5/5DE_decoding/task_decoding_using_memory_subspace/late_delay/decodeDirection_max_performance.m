%% Decode target direction using Mahalanobis distance
clear; clc; close all;

% Add path
tdrDir = '/Users/jeongjun/Documents/Larry/analysis/von/subspace/dPCA-master/matlab';
addpath(fullfile(tdrDir));

for shifted = 1:60
    load(['../../../task_subspace/early_delay/regul_train_test_' num2str(shifted) '.mat']);
    W_tt_early = W_tt;
    componentsToUse_tt_early = componentsToUse_tt_memory;
    load(['../../../task_subspace/late_delay/regul_train_test_' num2str(shifted) '.mat']);
    W_tt = W_tt_early;
    componentsToUse_tt_memory = componentsToUse_tt_early;

    % cross projection?
    for cross = 2

        % number of test trials
        ntests = 6; % directions

        for tests = 1:ntests
            %0: use original decoder
            %1: use the other task's decoder
            %2: use the decoder trained on both

            decoded_task = []; decoded_dir_nolook = [];
            percent_correct_task_tmp = []; percent_correct_nolook_tmp = [];

            ncomps_max = 1;

            for ncomps = ncomps_max
                for boots = 1:size(W_tt,1)
                    % reshape neural activity (cell x direction x task x time x trial)
                    FR_train = firingRates_tt{boots,3};
                    FR_train = squeeze(cat(5,FR_train(:,1,:,:,:),FR_train(:,2,:,:,:),FR_train(:,3,:,:,:),FR_train(:,4,:,:,:),FR_train(:,5,:,:,:),FR_train(:,6,:,:,:)));
                    FR_test = testset_tt{boots,3};
                    FR_test = squeeze(cat(5,FR_test(:,1,:,:),FR_test(:,2,:,:),FR_test(:,3,:,:),FR_test(:,4,:,:),FR_test(:,5,:,:),FR_test(:,6,:,:)));

                    both_W = W_tt{boots,3};
                    both_V = V_tt{boots,3};
                    both_firingRates = squeeze(mean(FR_train,3));
                    both_components = componentsToUse_tt_memory{boots,3}(1,1:ncomps);
                    both_testset = squeeze(mean(FR_test,3));
                    both_testset = both_testset(:,:,tests);
                    both_nComponents = length(both_components);

                    % mahal_dist = direction of trainset x direction of testset x time
                    mahal_dist = mahalanobis_distance_memory(both_W, both_firingRates, both_testset, both_nComponents, both_components);

                    % Decoding direction
                    for test_task = 1:size(mahal_dist,2) % direction of testset
                        [~,i] = min(mahal_dist(:,test_task));
                        decoded_task(test_task) = i;
                    end

                    % performace of decoding
                    correct_task_tmp(ncomps,boots) = 0;
                    for direction = 1:length(decoded_task)
                        correct_task_tmp(ncomps,boots) = correct_task_tmp(ncomps,boots)+length(find(decoded_task(direction) == direction));
                    end
                    percent_correct_task_tmp(ncomps,boots) = correct_task_tmp(ncomps,boots)/length(decoded_task)*100;
                end
            end

            n_task = ncomps_max;
            percent_correct_task(tests,:) = squeeze(percent_correct_task_tmp(n_task,:));
            correct_task(tests,:) = squeeze(correct_task_tmp(n_task,:));
        end
        save(['performance_shifted' num2str(shifted) '_cross' num2str(cross) '_task_max.mat'],'percent_correct_task','correct_task');
    end
end