%% Example cells for task-induced baseline activity modulation (Figure 4A,B)

clear; clc; close all;

load('firingRates_pref_null.mat');

time = -500:50:1150; % -500~1200 ms from target onset with 50 ms time window

for unit = [24, 36, 39, 41, 45, 48, 50, 66, 118, 168, 173, 179, 192, 193, 217, 252, 262, 265, 271, 274, 297, 303, 310]
    look_null = squeeze(firingRates(unit,1,2,:,:));
    look_pref = squeeze(firingRates(unit,2,2,:,:));
    nolook_null = squeeze(firingRates(unit,1,1,:,:));
    nolook_pref = squeeze(firingRates(unit,2,1,:,:));
    
    fig=figure;

    % std-err
    fr1 = look_null(:,1:find(isnan(look_null(1,:)),1)-1);
    fr2 = look_pref(:,1:find(isnan(look_pref(1,:)),1)-1);
    fr3 = nolook_null(:,1:find(isnan(nolook_null(1,:)),1)-1);
    fr4 = nolook_pref(:,1:find(isnan(nolook_pref(1,:)),1)-1);

    % mean
    look_pref = nanmean(look_pref,2);
    look_null = nanmean(look_null,2);
    nolook_pref = nanmean(nolook_pref,2);
    nolook_null = nanmean(nolook_null,2);
    
    plot(time,look_pref,'g'); hold on;
    plot(time,look_null,'g:'); hold on;
    plot(time,nolook_pref,'r'); hold on;
    plot(time,nolook_null,'r:'); hold on;

    xlim([-500 1150]); 
    xlabel('Time from target onset (ms)'); ylabel('Firing rate (spikes/s)');
    legend('Look task, Preferred direction','Look task, Null direction','No-look task, Preferred direction','No-look task, Null direction');
end