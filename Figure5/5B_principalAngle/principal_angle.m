%% Principal angle between memory axis and task axis (Figure 5B)
% Step 1: Run 'memory_and_task_axes' to define axes
% Step 2: Run 'principal_angle' to compute the angle between axes
%
% memory axis is from either the early or late delay period
% task axis is from the fixation period

clear; clc;

type = 'early_delay'; % replace it to 'late_delay' to use late delay activity

angle = []; rho = []; pval = [];
for pc = [1 2 3 10 319]
    load(['axis_pref_null_task_pc' num2str(pc) '_' type '.mat']);
    direction = squeeze(vBeta.response(:,1,2));
    task = squeeze(vBeta.response(:,1,1));

    [r,p] = corr(task,direction,'type','Spearman');
    angle = [angle; rad2deg(subspace(task,direction))];
    rho = [rho; r];
    pval = [pval; p];
end

plot(1:5,angle,'LineWidth',2); hold on;
scatter(1:5,angle,'b');
ylim([0 90]);
xx = {'1'; '2'; '3'; '10'; 'All'};
xticks(1:6);
xticklabels(xx);
xlabel('Number of PCs used for defining the axes');
ylabel('Principal angle between the axes (deg)');
title('Geometrical relationship between the task and memory axes');
