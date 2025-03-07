%% max accuracy
clear; clc; close all;

% dPCA path
dPCADir = '/Users/jeongjun/Desktop/dPCA-master/matlab';
addpath(fullfile(dPCADir));

ndirs = 6;
nboots = 100;
nshifts = 60;

for shifted = 1:nshifts
    load(['performance_shifted' num2str(shifted) '_cross2_task_max.mat']);
    task(shifted,:) = sum(correct_task,1)/(size(correct_task,1)*2)*100;
end

% figure - bar

task = mean(task,1);
% task = task(:);

mean_task = mean(task);
std_task = std(task);

% bar graph
figure;
y = mean_task;
b = bar(y);

set(gca, 'XTickLabel',{'Task'})
b.FaceColor = 'flat';
b.CData(1,:) = [0 0 1];

hold on; errorbar(1,y,std_task);

title('Task');
xlabel('Decoder')
ylabel('Decoding performance (%)');
ylim([0 100]);

save('mean_task.mat','mean_task');