%% Memory target decoding using task subspace
% Step0: Run 'Figure4/4F_decoding/late_delay/dPCAScript.m'
% Step1: Run 'decodeDirection.m'
% Step2: Run 'decoding_figure.m'

%% Decode target direction using Mahalanobis distance
clear; clc; close all;

% dPCA path
dPCADir = '/Users/jeongjun/Desktop/dPCA-master/matlab';
addpath(fullfile(dPCADir));

for shifted = 1:60
    load(['../../../../Figure4/4F_decoding/late_delay/regul_train_test_' num2str(shifted) '.mat']);

    % cross projection?
    for cross = 2

        % number of test trials
        if cross == 2
            ntests = 2;
        else
            ntests = 1;
        end

        for tests = 1:ntests
            %0: use original decoder
            %1: use the other task's decoder
            %2: use the decoder trained on both

            decoded_dir_look = []; decoded_dir_nolook = [];
            percent_correct_look_tmp = []; percent_correct_nolook_tmp = [];

            ncomps_max = 1;

            for ncomps = ncomps_max
                for boots = 1:size(W_tt,1)
                    % reshape neural activity
                    FR_train = firingRates_tt{boots,3};
                    FR_train = squeeze(cat(5,FR_train(:,:,1,:,:),FR_train(:,:,2,:,:)));
                    FR_test = testset_tt{boots,3};
                    FR_test = permute(FR_test, [1, 2, 4, 3]);

                    both_W = W_tt{boots,3};
                    both_V = V_tt{boots,3};
                    both_firingRates = squeeze(mean(FR_train,3));
                    both_components = componentsToUse_tt{boots,3}(1,1:ncomps);
                    both_testset = squeeze(mean(FR_test,3));
                    both_testset = both_testset(:,:,tests); %1: nolook trial 2: look trial
                    both_nComponents = length(both_components);

                    % mahal_dist = direction of trainset x direction of testset x time
                    if cross == 2
                        % look data on mixed axis
                        mahal_dist_look = mahalanobis_distance_memory(both_W, both_firingRates, both_testset, both_nComponents, both_components);
                        % nolook data on mixed axis
                        mahal_dist_nolook  = mahalanobis_distance_memory(both_W, both_firingRates, both_testset, both_nComponents, both_components);
                    end

                    % Decoding direction
                    decoded_dir_look_tmp = []; decoded_dir_nolook_tmp = [];
                    for test_dir = 1:size(mahal_dist_look,2) % direction of testset
                        [~,i] = min(mahal_dist_look(:,test_dir));
                        decoded_dir_look(test_dir) = i;
                        [~,i] = min(mahal_dist_nolook(:,test_dir));
                        decoded_dir_nolook(test_dir) = i;
                    end

                    % performace of decoding
                    correct_look(ncomps,boots) = 0;
                    correct_nolook(ncomps,boots) = 0;
                    for direction = 1:length(decoded_dir_look)
                        correct_look(ncomps,boots) = correct_look(ncomps,boots)+length(find(decoded_dir_look(direction) == direction));
                        correct_nolook(ncomps,boots) = correct_nolook(ncomps,boots)+length(find(decoded_dir_nolook(direction) == direction));
                    end
                    percent_correct_look_tmp(ncomps,boots) = correct_look(ncomps,boots)/length(decoded_dir_look)*100;
                    percent_correct_nolook_tmp(ncomps,boots) = correct_nolook(ncomps,boots)/length(decoded_dir_nolook)*100;
                end
            end

            n_look = ncomps_max;
            n_nolook = ncomps_max;

            percent_correct_look = squeeze(percent_correct_look_tmp(n_look,:,:));
            percent_correct_nolook = squeeze(percent_correct_nolook_tmp(n_nolook,:,:));

            if tests == 1
                save(['performance_shifted' num2str(shifted) '_cross' num2str(cross) '_nolook_max.mat'],'percent_correct_nolook','correct_nolook');
            elseif tests == 2
                save(['performance_shifted' num2str(shifted) '_cross' num2str(cross) '_look_max.mat'],'percent_correct_look','correct_look');
            end
        end
    end
end
