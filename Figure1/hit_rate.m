%% Behavioral performance (Figure 1B)
clear; clc;

% List of all PFC cell indices
load('all_cellList.mat')
list = list(:,1:4);

% Numbers of success and failure trials
load('behavior.mat');
list.look_success = look_success;
list.look_failure = look_failure;
list.nolook_success = nolook_success;
list.nolook_failure = nolook_failure;

% List of all sessions
sessions = unique(list(:,1:2));
idx = [];
for i = 1:size(sessions)
    idx = [idx; find(ismember(list(:,1:2),sessions(i,:)),1)];
end
list = list(idx,:);

% Compute hit rate in each task (look/no-look)
look_hitrate = list.look_success./(list.look_success+list.look_failure)*100;
nolook_hitrate = list.nolook_success./(list.nolook_success+list.nolook_failure)*100;

disp(['mean hit rate in look task: ' num2str(mean(look_hitrate)) ''])
disp(['SD of hit rate in look task: ' num2str(std(look_hitrate)) ''])
disp(['mean hit rate in no-look task: ' num2str(mean(nolook_hitrate)) ''])
disp(['SD of hit rate in no-look task: ' num2str(std(nolook_hitrate)) ''])

