%% Reorganize Spike Data
% This script sorts target directions into 6 directional bins for further analysis.
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
%   - firingRates:  5D matrix [Unit × Direction × Task × Time × maxTrialNum]

%% trial-based data: unit, direction, task, time
clear; clc;

%load data
table = readtable('PATH/TO/YOUR/SPIKE_DATASET'); % e.g. 'memory_vp001_corrected_either_tp001_von_abt3_0_500_success_att3_500_1200'

for shifted = 1 % use different sets of 6 direction bins by chaning this
    unit_trial = {}; dir_trial = {}; task_trial = {}; time_trial = {};

    unitnum = [];
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

        % 6 directions in absolute space
        % This code is only for 6 equal-sized direction bins
        % If you want to change it, NOTE you need to modify the code
        % by carefully considering the +- sign of the directions
        dir = table.direction_3(trial); %stimulus dir
        dirs = -180:60:180;
        dirs = dirs+10*(shifted-1);
        dirs(find(dirs > 180)) = dirs(find(dirs > 180))-360;
        dirs(find(dirs <= -180)) = dirs(find(dirs <= -180))+360;

        dir_bin = multi_directions(dir,dirs(1),dirs(2));
        if dir_bin == 1
            dir_trial{trial} = 1;
        end

        dir_bin = multi_directions(dir,dirs(2),dirs(3));
        if dir_bin == 1
            dir_trial{trial} = 2;
        end

        dir_bin = multi_directions(dir,dirs(3),dirs(4));
        if dir_bin == 1
            dir_trial{trial} = 3;
        end

        dir_bin = multi_directions(dir,dirs(4),dirs(5));
        if dir_bin == 1
            dir_trial{trial} = 4;
        end

        dir_bin = multi_directions(dir,dirs(5),dirs(6));
        if dir_bin == 1
            dir_trial{trial} = 5;
        end

        dir_bin = multi_directions(dir,dirs(6),dirs(7));
        if dir_bin == 1
            dir_trial{trial} = 6;
        end

        % Task
        if table.stack(trial) == 46
            task_trial{trial} = 1; % look
        elseif table.stack(trial) == 10 || table.stack(trial) == 12
            task_trial{trial} = 2; % no-look (10: 1-item) or no-look (12: 2-item sequential)
        end

        % Time
        time_trial{trial} = table.start(trial); % start timing
    end

    % Change format from cell to Matrix
    unit_trial = cell2mat(unit_trial);
    dir_trial = cell2mat(dir_trial);
    task_trial = cell2mat(task_trial);
    time_trial = cell2mat(time_trial);

    %% 4-D cell
    time = unique(time_trial);
    firingRates_4dcell = cell(length(unique(unit_trial)),length(unique(dir_trial)),length(unique(task_trial)),length(time));
    for n = 1:length(unit_trial)
        if ~isnan(dir_trial(n))
            firingRates_4dcell{unit_trial(n),dir_trial(n),task_trial(n),find(time_trial(n)==time)} = ...
                [firingRates_4dcell{unit_trial(n),dir_trial(n),task_trial(n),find(time_trial(n)==time)} table.rate(n)];
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
                    else
                        delete_unit = [delete_unit; i1];
                        firingRates(i1,i2,i3,i4,:) = nan;
                    end
                end
            end
        end
    end

    % Remove the cells without trials in any of conditions
    delete_unit = unique(delete_unit);

    save(['firingRates_directions_' num2str(shifted) '.mat'],'firingRates','delete_unit');
end

%% functions

function dir_bin = multi_directions(dir,dir1,dir2)

dir_bin = 0;

if (dir1 * dir2 < 0) && (dir1 > dir2)
    if (dir > dir1) || (dir <= dir2)
        dir_bin = 1;
    end
else
    if (dir > dir1) && (dir <= dir2)
        dir_bin = 1;
    end
end

end