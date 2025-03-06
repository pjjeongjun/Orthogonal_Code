%% Decoding target directions using memory subspace from dPCA
% Step 1: Run 'run_dPCA.m'
% Step 2: Run 'decode_direction.m'
% Step 3: Run 'plot_accuracy.m'

%% Decoding accuracy
clear; clc;

% dPCA path
dpcaDir = '/Users/jeongjun/Desktop/dPCA-master/matlab'; % replace it to your path
addpath(fullfile(dpcaDir));

option = 1; % options for averaging 1: shifts 2: iter 3: all

ndirs = 6; % number of target direction bins
nboots = 100; % number of bootstrapping
nshifts = 60; % number of target direction bin "sets"

look_original = []; nolook_original = [];
look_each = []; nolook_each = [];
look_cross = []; nolook_cross = [];

for shifted = 1:nshifts
    % original
    load(['performance_shifted' num2str(shifted) '_cross0_max.mat']);
    look_original(shifted,:) = percent_correct_look;
    nolook_original(shifted,:) = percent_correct_nolook;

    % common (each)
    load(['performance_shifted' num2str(shifted) '_cross2_nolook_max.mat']);
    nolook_each(shifted,:) = percent_correct_nolook;

    load(['performance_shifted' num2str(shifted) '_cross2_look_max.mat']);
    look_each(shifted,:) = percent_correct_look;

    % cross
    load(['performance_shifted' num2str(shifted) '_cross1_max.mat']);
    look_cross(shifted,:) = percent_correct_look;
    nolook_cross(shifted,:) = percent_correct_nolook;
end

look_original = look_original(:,1:nboots);
nolook_original = nolook_original(:,1:nboots);
look_each = look_each(:,1:nboots);
nolook_each = nolook_each(:,1:nboots);
look_cross = look_cross(:,1:nboots);
nolook_cross = nolook_cross(:,1:nboots);

if option == 1 % average across shifts
    look_original = mean(look_original,1)';
    nolook_original = mean(nolook_original,1)';
    look_each = mean(look_each,1)';
    nolook_each = mean(nolook_each,1)';
    look_cross = mean(look_cross,1)';
    nolook_cross = mean(nolook_cross,1)';

elseif option == 2 % average across iterations
    look_original = mean(look_original,2);
    nolook_original = mean(nolook_original,2);
    look_each = mean(look_each,2);
    nolook_each = mean(nolook_each,2);
    look_cross = mean(look_cross,2);
    nolook_cross = mean(nolook_cross,2);

elseif option == 3 % use all
    look_original = look_original(:);
    nolook_original = nolook_original(:);
    look_each = look_each(:);
    nolook_each = nolook_each(:);
    look_cross = look_cross(:);
    nolook_cross = nolook_cross(:);
end

%% Plot decoding accuracy
figure;

% Look task data
y = [look_original, look_cross, look_each];

mean(y)

% Create the boxplot
h = boxplot(y, 'Symbol', '');

% Define custom colors for each box with RGB values
colors = [
    1 1 0;  % Dark Yellow
    0 1 0;  % Look
    1 0 0;  % Nolook
];

% Get handles to the boxes
boxes = findobj(gca, 'Tag', 'Box');

% Loop through each box and set the FaceColor
for i = 1:length(boxes)
    % Get the box's X and Y data
    xData = get(boxes(i), 'XData');
    yData = get(boxes(i), 'YData');
    
    % Create a patch object with the specified color
    patch(xData, yData, colors(i,:), 'FaceAlpha', 1, 'EdgeColor', 'none');
end

% Get handles to the median lines
medians = findobj(gca, 'Tag', 'Median');

% Ensure the median lines are visible on top of the colored boxes
for i = 1:length(medians)
    % Redraw the median line to be on top
    xMed = get(medians(i), 'XData');
    yMed = get(medians(i), 'YData');
    line(xMed, yMed, 'Color', 'k', 'LineWidth', 2);
end

% Get handles to the error bars (whiskers)
whiskers = findobj(gca, 'Tag', 'Upper Whisker');
whiskers = [whiskers; findobj(gca, 'Tag', 'Lower Whisker')];

% Set the thickness of the error bars
for i = 1:length(whiskers)
    set(whiskers(i), 'LineWidth', 1.2); % Adjust the value for desired thickness
end

% Also make the caps (end markers of whiskers) thicker
caps = findobj(gca, 'Tag', 'Upper Adjacent Value');
caps = [caps; findobj(gca, 'Tag', 'Lower Adjacent Value')];

for i = 1:length(caps)
    set(caps(i), 'LineWidth', 1.2); % Adjust the value for desired thickness
end

set(gca, 'XTickLabel',{'Look','No-look','Shared'});
title('Look task','FontWeight','normal');
xlabel('Memory subspace')
ylabel('Decoding performance (%)');
ylim([0 100]); yticks(0:25:100);
axis square;

yline(16.7, '--', 'LineWidth', 4);  % Add a dashed line at y=16.7

set(gca, 'LineWidth', 2);  % Adjust the value for thicker axis lines
set(gcf, 'Position', [100, 100, 700, 700]);  % [left, bottom, width, height]
set(gca, 'TickDir', 'out', 'FontSize', 35);

box off;  % Remove the top and right borders

figure;
% No-look task data
y = [nolook_original, nolook_cross, nolook_each];

mean(y)

% Create the boxplot
h = boxplot(y, 'Symbol', '');

% Define custom colors for each box with RGB values
colors = [
    1 1 0;  % Dark Yellow
    0 1 0;  % Look
    1 0 0;  % Nolook
];

% Get handles to the boxes
boxes = findobj(gca, 'Tag', 'Box');

% Loop through each box and set the FaceColor
for i = 1:length(boxes)
    % Get the box's X and Y data
    xData = get(boxes(i), 'XData');
    yData = get(boxes(i), 'YData');
    
    % Create a patch object with the specified color
    patch(xData, yData, colors(i,:), 'FaceAlpha', 1, 'EdgeColor', 'none');
end

% Get handles to the median lines
medians = findobj(gca, 'Tag', 'Median');

% Ensure the median lines are visible on top of the colored boxes
for i = 1:length(medians)
    % Redraw the median line to be on top
    xMed = get(medians(i), 'XData');
    yMed = get(medians(i), 'YData');
    line(xMed, yMed, 'Color', 'k', 'LineWidth', 2);
end

% Get handles to the error bars (whiskers)
whiskers = findobj(gca, 'Tag', 'Upper Whisker');
whiskers = [whiskers; findobj(gca, 'Tag', 'Lower Whisker')];

% Set the thickness of the error bars
for i = 1:length(whiskers)
    set(whiskers(i), 'LineWidth', 1.2); % Adjust the value for desired thickness
end

% Also make the caps (end markers of whiskers) thicker
caps = findobj(gca, 'Tag', 'Upper Adjacent Value');
caps = [caps; findobj(gca, 'Tag', 'Lower Adjacent Value')];

for i = 1:length(caps)
    set(caps(i), 'LineWidth', 1.2); % Adjust the value for desired thickness
end

% Customize outliers: make them black and thicker
outliers = findobj(gca, 'Tag', 'Outliers');
for i = 1:length(outliers)
    set(outliers(i), 'MarkerEdgeColor', 'k', 'LineWidth', 2); % Black and thicker
end

set(gca, 'XTickLabel',{'No-look','Look','Shared'});
title('No-look task','FontWeight','normal');
xlabel('Memory subspace')
ylabel('Decoding performance (%)');
ylim([0 100]); yticks(0:25:100);
axis square;

yline(16.7, '--', 'LineWidth', 4);  % Add a dashed line at y=16.7

set(gca, 'LineWidth', 2);  % Adjust the value for thicker axis lines
set(gcf, 'Position', [100, 100, 700, 700]);  % [left, bottom, width, height]
set(gca, 'TickDir', 'out', 'FontSize', 35);

box off;  % Remove the top and right borders

save('performance_data.mat',...
    'look_original','look_cross','look_each',...
    'nolook_original','nolook_cross','nolook_each');