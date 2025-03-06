%% Tuning difference as a function of t-statistics (Figure 2C)
clear; clc;

% Load data
tstats_memory = readtable('tstats_memorycells');
load('memory_tuning_of_319_memory_cells.mat');

empty = []; tstats = [];
for i = 1:size(list,1)
    idx = find(ismember(tstats_memory(:,11:14),list(i,1:4)));
    if isempty(idx) || length(idx) < 2
        empty = [empty; i];
        tstats(i,1) = nan;
        tstats(i,2) = nan;
    else
        for j = 1:2
            if tstats_memory.stack(idx(j)) == 10 % nolook
                tstats(i,1) = tstats_memory.p_t(idx(j));
            elseif tstats_memory.stack(idx(j)) == 46 % look
                tstats(i,2) = tstats_memory.p_t(idx(j));
            end
        end
    end
end

load('memory_cell_idx.mat');

common_tstats = tstats(common_idx,:);
common_tstat = nan(1,size(common_tstats,1));
common_selected_task = nan(1,size(common_tstats,1));
for n = 1:size(common_tstats,1)
    [common_tstat(n), common_selected_task(n)] = min(common_tstats(n,:));
end

look_tstat = tstats(look_idx,2);

nolook_tstat = tstats(nolook_idx,1);

% Plot preferred direction difference as a function of t-statistics
figure;

x = [common_tstat'; look_tstat; nolook_tstat];
y = [abs_diff_common; abs_diff_look; abs_diff_nolook];

idx_delete1 = find(x<2.7);
idx_delete2 = find(isnan(x));
idx_delete = union(idx_delete1,idx_delete2);
x(idx_delete) = [];
y(idx_delete) = [];

idx_incon = find(y>=30);
scatter(x(idx_incon),y(idx_incon),'black'); hold on;

idx_con = find(y<30);
scatter(x(idx_con),y(idx_con),'blue'); hold on;

k = 0;
start_t = 2;
step_t = 1;
end_t = 14;
percent = 50;
for i = start_t:step_t:end_t
    k = k+1;
    bin{k} = intersect(find(x >= i), find(x < i+step_t));
    bin_mean(k) = mean(y(bin{k}));
    bin_median(k) = median(y(bin{k}));
    percentile(k) = prctile(y(bin{k}), percent);
    range(k) = (i+i+step_t)/2;
end
bins = percentile;
scatter(range,bins,'black','filled'); hold on;
plot(range(find(~isnan(bins))),bins(find(~isnan(bins))),'black'); hold on;

% Exponential fit
x = range([1:9 11]);
y = bins([1:9 11]);

% Define the exponential model: a * exp(b * x)
model = @(params, x) params(1) * exp(params(2) * x);

% Initial parameter guesses [a, b]
initial_params = [1, -0.5];

% Perform the fit
fitted_params = lsqcurvefit(model, initial_params, x, y);

% Generate fitted values
y_fit = model(fitted_params, x);
plot(x, y, 'o', x, y_fit, '-');

% Calculate goodness-of-fit metrics
SS_res = sum((y - y_fit).^2); % Residual sum of squares
SS_tot = sum((y - mean(y)).^2); % Total sum of squares
R_squared = 1 - (SS_res / SS_tot); % Coefficient of determination

yline(30,'k:');
xlim([0 14]);
yticks(0:30:180);

xlabel('Tuning reliability (t-stats)'); ylabel('Direction difference (deg)');

legend('','','',['' num2str(percent) 'th percentile']);