%% Reorganize Spike Data
% This script sorts target directions into preferred, intermediate, and null directions for further analysis.
%
% Author: JeongJun Park
% Date:   August 7, 2025
% Email:  jeongjun@wustl.edu
%
% -------------------------------
% Data Format and Description
% -------------------------------
% From the text file:
%   - loc:        Preferred direction of the unit
%   - direction3: Stimulus direction
%
% Cell-format variables:
%   - unit_trial:   Cell array indexed by unit and trial
%   - dir_trial:    Discretized direction (6 bins)
%                   e.g., [-180° to -120°], [-120° to -60°], [-60° to 0°],
%                         [0° to 60°], [60° to 120°], [120° to -180°]
%   - task_trial:   Task condition (1 = look, 2 = no-look)
%   - time_trial:   Start time of the analysis window (window size = +50 ms)
%
% Matrix-format variable:
%   - firingRates:  5D matrix [Unit × Direction (preferred or null) × Task × Time × maxTrialNum]
%   - dCrit1: preferred direction range (±), dCrit2 is null direction range (±)

%% trial-based data: unit, direction, task, time
clear; clc;

% load data
table = readtable('PATH/TO/YOUR/SPIKE_DATASET'); % e.g.,'memory_vp001_corrected_either_tp001_von_abt3_0_500_success_att3_500_1200'
load('PATH/TO/YOUR/TUNING_DATASET'); % e.g.,'memory_tuning_vp001_corrected_either_tp001_von_abt3_0_500.mat'

for n = 1:size(list,1)
    idx = find(ismember(table(:,8:11),list(n,1:4)));
    table.look_pref(idx) = list.look_pref(n);
    table.nolook_pref(idx) = list.nolook_pref(n);
    table.look_pval(idx) = list.look_pval(n);
    table.nolook_pval(idx) = list.nolook_pval(n);
end

look_pref = table.look_pref;
nolook_pref = table.nolook_pref;

unitnum = [];
unit_trial = []; dir_trial = []; task_trial = []; time_trial = []; pref_trial = [];
for trial = 1:size(table,1)
    % Neuron
    unit_tmp = [table.unitnum(trial); table.channel(trial); table.cluster(trial)];
    unit_trial{trial} = [];
    if trial ~= 1
        for c = 1:size(unitnum,2)
            if (unitnum(1,c) == unit_tmp(1)) && (unitnum(2,c) == unit_tmp(2)) && (unitnum(3,c) == unit_tmp(3))
                unit_trial{trial} = c;
            end
        end
    end
    if isempty(unit_trial{trial})
        unitnum = [unitnum unit_tmp];
        unit_trial{trial} = size(unitnum,2);
    end

    % Direction - preferred vs. null
    dCrit1 = 30; dCrit2 = 60;

    if abs(look_pref(trial)-nolook_pref(trial)) > 180
        pref = mean([look_pref(trial) nolook_pref(trial)],2)+180;
        if pref > 180
            pref = pref-360;
        elseif pref < -180
            pref = pref+360;
        end
    else
        pref = mean([look_pref(trial) nolook_pref(trial)],2);
    end

    diff_dirs = abs(table.direction_3(trial)-pref); %stimulus dir - preferred dir
    if diff_dirs > 180
        diff_dirs = abs(diff_dirs-360); %%
    end

    if diff_dirs < dCrit1
        dir_trial{trial} = 1; % preferred
    elseif diff_dirs > 180-dCrit2
        dir_trial{trial} = 0; % null
    else
        dir_trial{trial} = nan; %intermediate
    end

    % Task
    if table.stack(trial) == 46
        task_trial{trial} = 1; %look
    elseif table.stack(trial) == 10 || table.stack(trial) == 12
        task_trial{trial} = 2; %no-look
    end

    % Time
    time_trial{trial} = table.start(trial); % start timing

    % Preferred direction
    pref_trial{trial} = pref;
end

%% cell2mat
unit_trial = cell2mat(unit_trial);
dir_trial = cell2mat(dir_trial);
task_trial = cell2mat(task_trial);
time_trial = cell2mat(time_trial);
pref_trial = cell2mat(pref_trial);

%% 4-D cell
time = unique(time_trial);
firingRates_4dcell = cell(length(unique(unit_trial)),2,2,length(time));
for n = 1:length(unit_trial)
    if ~isnan(dir_trial(n))
        firingRates_4dcell{unit_trial(n),dir_trial(n)+1,task_trial(n),find(time_trial(n)==time)} = ...
            [firingRates_4dcell{unit_trial(n),dir_trial(n)+1,task_trial(n),find(time_trial(n)==time)} table.rate(n)];
        preferred_direction(unit_trial(n)) = pref_trial(n);
    end
end

%% sanity check
num = 0; trialnum = [];
for i1 = 1:size(firingRates_4dcell,1) %unit
    for i2 = 1:size(firingRates_4dcell,2) %direction
        for i3 = 1:size(firingRates_4dcell,3) %task
            for i4 = 1:size(firingRates_4dcell,4) %time
                trialnum = [trialnum; length(firingRates_4dcell{i1,i2,i3,i4})];
                num = num+length(firingRates_4dcell{i1,i2,i3,i4});
            end
        end
    end
end

if length(dir_trial(~isnan(dir_trial))) ~= num
    disp('Total number of trials does not match with the original!');
    keyboard;
end

%% 5-D matrix
maxtrialnum = max(trialnum);
firingRates = nan(size(firingRates_4dcell,1),size(firingRates_4dcell,2), ...
    size(firingRates_4dcell,3),size(firingRates_4dcell,4),maxtrialnum);

delete_unit =[];
for i1 = 1:size(firingRates_4dcell,1) %unit
    for i2 = 1:size(firingRates_4dcell,2) %direction
        for i3 = 1:size(firingRates_4dcell,3) %task
            for i4 = 1:size(firingRates_4dcell,4) %time
                if ~isempty(firingRates_4dcell{i1,i2,i3,i4})
                    for i5 = 1:maxtrialnum %trial
                        if length(firingRates_4dcell{i1,i2,i3,i4}) >= i5
                            firingRates(i1,i2,i3,i4,i5) = firingRates_4dcell{i1,i2,i3,i4}(i5);
                        else
                            firingRates(i1,i2,i3,i4,i5) = nan;
                        end
                    end
                else %if all direction are not preferred or null
                    delete_unit = [delete_unit; i1];
                    firingRates(i1,i2,i3,i4,:) = nan;
                end
            end
        end
    end
end

% Remove the cells without trials in any of conditions
delete_unit = unique(delete_unit);

save(['firingRates_' num2str(dCrit1) '_' num2str(dCrit2) '_pref_null.mat'],'firingRates','preferred_direction','delete_unit');