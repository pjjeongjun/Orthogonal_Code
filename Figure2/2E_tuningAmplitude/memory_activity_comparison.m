%% memory tuning amplitude comparison between tasks (Figure 2E)
clear; clc;

% Load memory activity in the look task
load('memory_amp_look_early_delay.mat'); % in early delay (0-500 ms from target offset)
look_early = memory_amp;
load('memory_amp_look_late_delay.mat'); % in late delay (500-1000 ms from target offset)
look_late = memory_amp;

% Load memory activity in the no-look task
load('memory_amp_nolook_early_delay.mat'); % in early delay (0-500 ms from target offset)
nolook_early = memory_amp;
load('memory_amp_nolook_late_delay.mat'); % in late delay (500-1000 ms from target offset)
nolook_late = memory_amp;

look = look_early; % replace it to "look_late" to see late delay period activity
nolook = nolook_early; % replace it to "nolook_late" to see late delay period activity

scatter(look,nolook,'b'); hold on;
[b,bintr,bintjm] = gmregress(look,nolook);
y = b(2)*look+b(1);
hold on; plot(look,y,'b','LineWidth',2);

xline(0,'k:'); hold on;
yline(0,'k:'); hold on;

[r1, p1] = corr(look', nolook', 'type', 'Spearman');

title(['Memory activity in the two tasks: rho = ' num2str(round(r1,2)) ', p = ' num2str(round(p1,2)) '']);
xlabel('Look, Tuning amplitude (spikes/s)');
ylabel('No-look, Tuning amplitude (spikes/s)');