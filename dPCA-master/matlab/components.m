function componentsToUse = components(varargin)
% This code is based on 'dpca_plot.m'
% JeongJun, 05/10/23

% dpca_plot(X, W, V, plotFunction, ...)
% produces a plot of the dPCA results. X is the data matrix, W and V
% are decoder and encoder matrices, plotFunction is a
% pointer to to the function that plots one component (see dpca_plot_default()
% for the template)

% dpca_plot(..., 'PARAM1',val1, 'PARAM2',val2, ...)
% specifies optional parameter name/value pairs:
%
%  'whichMarg'              - which marginalization each component comes
%                             from. Is provided as an output of the dpca()
%                             function.
%
%  'time'                   - time axis
%
%  'timeEvents'             - time-points that should be marked on each subplot
%
%  'ylims'                  - array of y-axis spans for each
%                             marginalization or a single value to be used
%                             for each marginalization
%
%  'componentsSignif'       - time-periods of significant classification for each
%                             component. See dpca_signifComponents()
%
%  'timeMarginalization'    - if provided, it will be shown on top, and
%                             irrespective of significance (because
%                             significant classification is not assessed for
%                             time components)
%
%  'legendSubplot'          - number of the legend subplot
%
%  'marginalizationNames'   - names of each marginalization
%
%  'marginalizationColours' - colours for each marginalization
%
%  'explainedVar'           - structure returned by the dpca_explainedVariance
%
%  'numCompToShow'          - number of components to show on the explained
%                             variance plots (default = 15)
%
%  'X_extra'                - data array used for plotting that can be larger
%                             (i.e. have more conditions) than the one used
%                             for dpca computations
%  'showNonsignificantComponents'
%                           - display non-signficant components when there
%                             are fewer significant components than
%                             subplots

% default input parameters
options = struct('time',           [], ...
    'whichMarg',      [], ...
    'timeEvents',     [], ...
    'ylims',          [], ...
    'componentsSignif', [], ...
    'timeMarginalization', [], ...
    'legendSubplot',  [], ...
    'marginalizationNames', [], ...
    'marginalizationColours', [], ...
    'explainedVar',   [], ...
    'numCompToShow',  15, ...
    'X_extra',        [], ...
    'showNonsignificantComponents', false);

% read input parameters
optionNames = fieldnames(options);
if mod(length(varargin),2) == 1
    error('Please provide propertyName/propertyValue pairs')
end
for pair = reshape(varargin,2,[])    % pair is {propName; propValue}
    if any(strcmp(pair{1}, optionNames))
        options.(pair{1}) = pair{2};
    else
        error('%s is not a recognized parameter name', pair{1})
    end
end

% time marginalization, if specified, goes on top
if ~isempty(options.timeMarginalization)
    margRowSeq = [options.timeMarginalization setdiff(1:max(options.whichMarg), options.timeMarginalization)];
else
    margRowSeq = 1:max(options.whichMarg);
end


    moreComponents_use = ;
    componentsToUse = find(options.whichMarg == 1);[componentsToUse; moreComponents_use];
end