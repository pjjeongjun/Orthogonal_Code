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

%% Principal Angle
clear; clc;

pc = 1;
type = 'early_delay';

angle = []; rho = []; pval = [];
load(['coef_look_pc' num2str(pc) '_' type '.mat']);
look = mean(coef_midUN.response(:,:,2),2);
load(['coef_nolook_pc' num2str(pc) '_' type '.mat']);
nolook = mean(coef_midUN.response(:,:,2),2);

angle = rad2deg(subspace(nolook,look));

save(['angle_' type '.mat'],'angle');