%% Decoding target directions using memory subspace from dPCA
% Step 1: Run 'run_dPCA.m'
% Step 2: Run 'decode_direction.m'
% Step 3: Run 'plot_accuracy.m'

%% Decode target direction using Mahalanobis distance
clear; clc; close all;

ntrials = 50;
nboots = 100;

ncomps_selected = 3; % number of components to use

% dPCA path
dpcaDir = '/Users/jeongjun/Desktop/dPCA-master/matlab'; % replace it to your path
addpath(fullfile(dpcaDir));

for shifted = 1:60
    load(['../regul_train_test_' num2str(shifted) '.mat']);
    % cross projection?
    for cross = [0 1 2]

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
            correct_look = nan(ncomps_selected,nboots);
            correct_nolook = nan(ncomps_selected,nboots);
            percent_correct_look_tmp = nan(ncomps_selected,nboots);
            percent_correct_nolook_tmp = nan(ncomps_selected,nboots);
            for boots = 1:nboots
                for ncomps = ncomps_selected
                    if cross < 2
                        if size(componentsToUse_tt{boots,1},2) < ncomps || size(componentsToUse_tt{boots,2},2) < ncomps
                            continue;
                        end
                        nolook_W = W_tt{boots,1};
                        nolook_V = V_tt{boots,1};

                        nolook_firingRates = squeeze(mean(firingRates_tt{boots,1},3));
                        nolook_components = componentsToUse_tt{boots,1}(1,1:ncomps);
                        nolook_testset = squeeze(mean(testset_tt{boots,1},3));
                        nolook_nComponents = length(nolook_components);

                        look_W = W_tt{boots,2};
                        look_V = V_tt{boots,2};
                        look_firingRates = squeeze(mean(firingRates_tt{boots,2},3));
                        look_components = componentsToUse_tt{boots,2}(1,1:ncomps);
                        look_testset = squeeze(mean(testset_tt{boots,2},3));
                        look_nComponents = length(look_components);
                    else
                        if size(componentsToUse_tt{boots,3},2) < ncomps
                            continue;
                        end
                        both_W = W_tt{boots,3};
                        both_V = V_tt{boots,3};
                        both_firingRates = squeeze(mean(firingRates_tt{boots,3},3));
                        both_components = componentsToUse_tt{boots,3}(1,1:ncomps);
                        both_testset = squeeze(mean(testset_tt{boots,3},3));
                        both_testset = both_testset(:,:,tests); %1: nolook trial 2: look trial
                        both_nComponents = length(both_components);
                    end

                    % mahal_dist = direction of trainset x direction of testset x time
                    if cross == 0
                        % look data on look axis
                        mahal_dist_look = mahalanobis_distance_memory(look_W, look_firingRates, look_testset, look_nComponents, look_components);
                        % nolook data on nolook axis
                        mahal_dist_nolook = mahalanobis_distance_memory(nolook_W, nolook_firingRates, nolook_testset, nolook_nComponents, nolook_components);
                    elseif cross == 1
                        % look data on look axis
                        mahal_dist_look = mahalanobis_distance_memory(nolook_W, look_firingRates, look_testset, nolook_nComponents, nolook_components);
                        % nolook data on nolook axis
                        mahal_dist_nolook = mahalanobis_distance_memory(look_W, nolook_firingRates, nolook_testset, look_nComponents, look_components);
                    elseif cross == 2
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

            n_look = ncomps_selected;
            n_nolook = ncomps_selected;

            percent_correct_look = squeeze(percent_correct_look_tmp(n_look,:));
            percent_correct_nolook = squeeze(percent_correct_nolook_tmp(n_nolook,:));

            if cross == 2
                if tests == 1
                    save(['performance_shifted' num2str(shifted) '_cross' num2str(cross) '_nolook_max.mat'],'percent_correct_nolook','n_nolook');
                elseif tests == 2
                    save(['performance_shifted' num2str(shifted) '_cross' num2str(cross) '_look_max.mat'],'percent_correct_look','n_look');
                end
            else
                save(['performance_shifted' num2str(shifted) '_cross' num2str(cross) '_max.mat'],'percent_correct_look','percent_correct_nolook','n_look','n_nolook');
            end
        end
    end
end