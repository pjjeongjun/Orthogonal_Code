%% Preferred directions of PFC memory cells in look/no-look tasks (Figure 2A,B)
clear; clc;

% Setting up
crit = 0.01; % p-value significance criterion
correctionFactor = 4; % correction factor for p-values
degCrit = 30; % criterion for congruent preferred direction

% Load data
visual_resp = readtable('visual_responsiveness_data');
tuning = readtable('memory_tuning_data');
list_tuning = tuning(:,11:14);

% Significance criterion
pCrit_visualResp = crit;
idx1 = find(table2array(visual_resp(:,6))<=pCrit_visualResp);

% Tuning amplitude criterion
ampCrit_visualResp = 0;
idx2 = find(abs(table2array(visual_resp(:,5)))>=ampCrit_visualResp);

idx = intersect(idx1,idx2);

list_response = visual_resp(idx,1:4);
list_response{:,5:10} = nan;
list_response.Properties.VariableNames([1 2 3 4 5 6 7 8 9 10]) = {'datadir' 'unitnum' 'channel' 'cluster' ...
    'nolook_pref' 'nolook_pval' 'look_pref' 'look_pval' 'nolook_k' 'look_k'};

for i = 1:size(list_response,1)
    idx = find(ismember(list_tuning,list_response(i,1:4)));
    for ii = 1:length(idx)
        if tuning.stack(idx(ii)) == 10 % find no-look task data
            list_response.nolook_pref(i) = tuning.loc(idx(ii));
            list_response.nolook_pval(i) = tuning.p(idx(ii));
            list_response.nolook_k(i) = tuning.K(idx(ii));
        elseif tuning.stack(idx(ii)) == 46 % find look task data
            list_response.look_pref(i) = tuning.loc(idx(ii));
            list_response.look_pval(i) = tuning.p(idx(ii));
            list_response.look_k(i) = tuning.K(idx(ii));
        end
    end
end

% Make directions within -180~180 deg
for i=1:size(list_response,1)
    if list_response.look_pref(i) > 180
        list_response.look_pref(i) = list_response.look_pref(i)-360;
    elseif list_response.look_pref(i) <= -180
        list_response.look_pref(i) = list_response.look_pref(i)+360;
    end

    if list_response.nolook_pref(i) > 180
        list_response.nolook_pref(i) = list_response.nolook_pref(i)-360;
    elseif list_response.nolook_pref(i) <= -180
        list_response.nolook_pref(i) = list_response.nolook_pref(i)+360;
    end
end

for i=1:size(list_response,1)
    if list_response.look_pref(i) > 180
        list_response.look_pref(i) = list_response.look_pref(i)-360;
    elseif list_response.look_pref(i) <= -180
        list_response.look_pref(i) = list_response.look_pref(i)+360;
    end

    if list_response.nolook_pref(i) > 180
        list_response.nolook_pref(i) = list_response.nolook_pref(i)-360;
    elseif list_response.nolook_pref(i) <= -180
        list_response.nolook_pref(i) = list_response.nolook_pref(i)+360;
    end
end

for i=1:size(list_response,1)
    if list_response.look_pref(i) > 180
        list_response.look_pref(i) = list_response.look_pref(i)-360;
    elseif list_response.look_pref(i) <= -180
        list_response.look_pref(i) = list_response.look_pref(i)+360;
    end

    if list_response.nolook_pref(i) > 180
        list_response.nolook_pref(i) = list_response.nolook_pref(i)-360;
    elseif list_response.nolook_pref(i) <= -180
        list_response.nolook_pref(i) = list_response.nolook_pref(i)+360;
    end
end

% p-values for memory tuning significance
both_idx = find(~isnan(list_response.nolook_pref) & ~isnan(list_response.look_pref));
list_both = list_response(both_idx,:);

% Select cells with "significant" (p < 0.05) memory tuning at least in one task
pCrit_tuning = crit/correctionFactor;
pidx = find(list_both.nolook_pval < pCrit_tuning | list_both.look_pval < pCrit_tuning);
list_both_p = list_both(pidx,:);

% Cells with significant memory tuning in both tasks (task-independent)
% and cells with significant memory tuning only in one task (task-specific)
[maxp,task_id] = max([list_both_p.look_pval list_both_p.nolook_pval],[],2);
maxp = maxp*correctionFactor;
plot_size = [];
for m = 1:length(maxp)
    if maxp(m) < crit
        plot_size(m) = 100;
    else
        plot_size(m) = 40;
    end
end

big = find(plot_size==100);
medium = find(plot_size==40);

common = big; look = []; nolook = [];
for i = 1:length(medium)
    if list_both_p.look_pval(medium(i)) < list_both_p.nolook_pval(medium(i))
        look = [look; medium(i)];
    elseif list_both_p.look_pval(medium(i)) > list_both_p.nolook_pval(medium(i))
        nolook = [nolook; medium(i)];
    end
end

%  Pie chart for task-specificity of PFC memory cells (Figure 2A)
data = [length(common), length(look), length(nolook)];
labels = {'Task independent', 'Look task specific', 'No-look task specific'};
figure;
pie(data, labels);

% Scatter plot of preferred directions across tasks (Figure 2B)
abs_diff = abs(list_both_p.look_pref-list_both_p.nolook_pref);
abs_diff(find(abs_diff > 180)) = abs(abs_diff(find(abs_diff > 180))-360);
con = find(abs_diff <= degCrit);
incon = find(abs_diff > degCrit);

figure;
scatter(list_both_p.look_pref(con),list_both_p.nolook_pref(con),"filled",'b'); hold on;
scatter(list_both_p.look_pref(incon),list_both_p.nolook_pref(incon),"filled",'k');
title(['visResp p = ' num2str(pCrit_visualResp) ', tuning p = ' num2str(pCrit_tuning*correctionFactor) ', n = ' num2str(length(pidx)) '']);
xlabel('look, preferred direction (deg)'); ylabel('nolook, preferred direction (deg)');
xlim([-180 180]); ylim([-180 180]);

hold on; plot(-180:180,-180:180,'k:');
hold on; plot(-180:180,-180+degCrit:180+degCrit,'k:');
hold on; plot(-180:180,-180-degCrit:180-degCrit,'k:');

hold on; plot(180-degCrit:180,-180+0:-180+degCrit,'k:');
hold on; plot(-180+0:-180+degCrit,180-degCrit:180,'k:');