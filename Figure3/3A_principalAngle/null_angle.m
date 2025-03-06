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

%% noise floor
clear; clc; close all;

type = 'early_delay';
pc = 1;

for iter = 1:100
    load(['axis_look_' type '_pc' num2str(pc) '_control.mat']);
    control1 = vBeta{iter,1}.response;
    control2 = vBeta{iter,2}.response;
    angle_look(1,iter) = rad2deg(subspace(control1,control2));

    load(['axis_nolook_' type '_pc' num2str(pc) '_control.mat']);
    control3 = vBeta{iter,1}.response;
    control4 = vBeta{iter,2}.response;
    angle_nolook(1,iter) = rad2deg(subspace(control3,control4));
end

load(['angle_' type '.mat']);

scatter(1,angle); hold on; 
errorbar(1,mean([angle_look angle_nolook],2), std([angle_look angle_nolook],[],2));

ylim([0 90]);
legend('Principal angle','Noise floor');
xlabel('Between same or different tasks'); ylabel('Principal angle (deg)');
title('Principal angle of direction axes');

null = [angle_look(1,:) angle_nolook(1,:)];
p_value = (length(find(null > angle))+1)/(length(null)+1);