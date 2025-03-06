%% PSTH (Figure 2D)
clear; clc; close all;

% Load firing rate data
load('firingRates_pref_null.mat'); % firing rates in preferred and null directions
% Data structure: unit x direction(null,pref) x task(nolook,look) x time(-500:50:1150) x trial

% Temporal resolution of firing rate data
time = -500:50:1150; % -500~1200 ms from target onset, with 50 ms time windows; 
% i.e., -500~450 ms, -450~400 ms, ... , 1100~1150 ms, 1150~1200 ms

% Look task, Preferred direction
fr = squeeze(firingRates(:,2,2,:,:));
fr = nanmean(fr,3);
hold on; plot(time,mean(fr,1),'g','LineWidth',3);
hold on; shadedErrorBar(time,mean(fr,1),std(fr,[],1)./sqrt(size(fr,1)),'lineprops','g');

% Look task, Null direction
fr = squeeze(firingRates(:,1,2,:,:));
fr = nanmean(fr,3);
hold on; plot(time,mean(fr,1),'g--','LineWidth',3);
hold on; shadedErrorBar(time,mean(fr,1),std(fr,[],1)./sqrt(size(fr,1)),'lineprops','g');

% No-look task, Preferred direction
fr = squeeze(firingRates(:,2,1,:,:));
fr = nanmean(fr,3);
hold on; plot(time,mean(fr,1),'r','LineWidth',3);
hold on; shadedErrorBar(time,mean(fr,1),std(fr,[],1)./sqrt(size(fr,1)),'lineprops','r');

% No-look task, Null direction
fr = squeeze(firingRates(:,1,1,:,:));
fr = nanmean(fr,3);
hold on; plot(time,mean(fr,1),'r--','LineWidth',3);
hold on; shadedErrorBar(time,mean(fr,1),std(fr,[],1)./sqrt(size(fr,1)),'lineprops','r');

legend('look,null','','','','','look,pref','','','','','nolook,null','','','','','nolook,pref');
xlim([-400 1150]); ylim([0 40]); xlabel('Time from target onset (ms)'); ylabel('Firing rate (spikes/s)');
title('PeriStimulus Time Histogram');