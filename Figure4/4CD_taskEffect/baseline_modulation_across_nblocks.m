%% Baseline acitivity modulation of memory cells as a function of # blocks (Figure 4D)
clear; clc;

pCrit = 0.05; % p-value criterion

load('task_coef_pval_fixation.mat');
task_pval = task_wilcoxon_pval;
load('nblocks.mat');

block2 = find(nblocks == 2);
block3 = find(nblocks == 3);
block4 = find(nblocks == 4);
block5 = find(nblocks == 5);
block6 = find(nblocks == 6);
block7 = find(nblocks == 7);
block8 = find(nblocks == 8);
block9 = find(nblocks == 9);
block10 = find(nblocks == 10);
block26 = find(nblocks == 26);
block31 = find(nblocks == 31);
block32 = find(nblocks == 32);

block_above_9 = find(nblocks >= 9);
block_above_26 = find(nblocks >= 26);
block_above_30 = find(nblocks >= 30);

block1_each = find(nblocks == 2 | nblocks == 3);
block2_each = find(nblocks == 4 | nblocks == 5);
block3_each = find(nblocks == 6 | nblocks == 7);
block4_each = find(nblocks == 8 | nblocks == 9);
block_morethan_4_each = find(nblocks > 8);
block_morethan_10_each = find(nblocks > 20);

percent2 = length(find(task_pval(block2)<pCrit))/length(block2)*100;
percent3 = length(find(task_pval(block3)<pCrit))/length(block3)*100;
percent4 = length(find(task_pval(block4)<pCrit))/length(block4)*100;
percent5 = length(find(task_pval(block5)<pCrit))/length(block5)*100;
percent6 = length(find(task_pval(block6)<pCrit))/length(block6)*100;
percent7 = length(find(task_pval(block7)<pCrit))/length(block7)*100;
percent8 = length(find(task_pval(block8)<pCrit))/length(block8)*100;
percent9 = length(find(task_pval(block9)<pCrit))/length(block9)*100;
percent10 = length(find(task_pval(block10)<pCrit))/length(block10)*100;
percent26 = length(find(task_pval(block26)<pCrit))/length(block26)*100;
percent31 = length(find(task_pval(block31)<pCrit))/length(block31)*100;
percent32 = length(find(task_pval(block32)<pCrit))/length(block32)*100;

percent_above_9 = length(find(task_pval(block_above_9)<pCrit))/length(block_above_9)*100;
percent_above_26 = length(find(task_pval(block_above_26)<pCrit))/length(block_above_26)*100;
percent_above_30 = length(find(task_pval(block_above_30)<pCrit))/length(block_above_30)*100;

percent1_each = length(find(task_pval(block1_each)<pCrit))/length(block1_each)*100;
percent2_each = length(find(task_pval(block2_each)<pCrit))/length(block2_each)*100;
percent3_each = length(find(task_pval(block3_each)<pCrit))/length(block3_each)*100;
percent4_each = length(find(task_pval(block4_each)<pCrit))/length(block4_each)*100;
percent_morethan_4_each = length(find(task_pval(block_morethan_4_each)<pCrit))/length(block_morethan_4_each)*100;
percent_morethan_10_each = length(find(task_pval(block_morethan_10_each)<pCrit))/length(block_morethan_10_each)*100;

% figure
percent = [percent1_each percent2_each percent3_each percent4_each percent10 percent_morethan_10_each];

x = 1:6;
[rho,p] = corr(x',percent','type','Spearman');

figure;
scatter(1:6,percent); hold on;
plot(1:6,percent); hold on;
xlim([1 6]); ylim([0 100]);
x_labels = {'1', '2', '3', '4','5', '>10'};
xticks(1:length(x_labels)); % Set the x-tick positions
xticklabels(x_labels); % Set the x-tick labels
xlabel('Number of blocks for each task'); % Label for x-axis
ylabel('Cells with task effect (%)'); % Label for y-axis
title('Ratio of memory cells with significant baseline modulation');