%%

%% Paths

clear all; 
close all;

% TDR path
tdrDir = '/Users/jeongjunpark/Desktop/Joonyeol/Mante';
addpath(fullfile(tdrDir,'TDR'));
addpath(fullfile(tdrDir,'TDR','nansuite'));
addpath(fullfile(tdrDir,'TDR','tools'));


%% Load data

% Data directory
datadir = fullfile(tdrDir,'/TDR/PFC data 1a');
% datadir = fullfile(tdrDir,'PFC data 1');

% Animal
animal = 'ar';
% animal = 'fe';

% Event to align
event = 'Vstim_100_850_ms';

% Downsample
Fd = 20; % Hz

% Load data
[dataT,metadata] = tdrLoadPfcData(datadir,animal,event,[],Fd);


%% Parameters

% plotflag = 1;
plotflag = 0;


%% THE BEHAVIOR

% Compute psychometric curves
nun = length(dataT.unit);
[ntr,npt] = size(dataT.unit(end).response);
udir = unique(dataT.unit(end).task_variable.stim_dir);
ucol = unique(dataT.unit(end).task_variable.stim_col);
ndir = length(udir);
ncol = length(ucol);
tt = dataT.time;

% Initialize
wmm = zeros(nun,ndir); xmm = zeros(nun,ndir);
wmc = zeros(nun,ndir); xmc = zeros(nun,ndir);
wcm = zeros(nun,ncol); xcm = zeros(nun,ncol);
wcc = zeros(nun,ncol); xcc = zeros(nun,ncol);

for iun = 1:nun
    % Motion context
    [xmm(iun,:),wmm(iun,:)] = psychfunctionmod(dataT.unit(iun).task_variable.stim_dir,dataT.unit(iun).task_variable.targ_dir==+1,dataT.unit(iun).task_variable.context==+1);
    [xmc(iun,:),wmc(iun,:)] = psychfunctionmod(dataT.unit(iun).task_variable.stim_dir,dataT.unit(iun).task_variable.targ_dir==+1,dataT.unit(iun).task_variable.context==-1);
    
    % Color context
    [xcm(iun,:),wcm(iun,:)] = psychfunctionmod(dataT.unit(iun).task_variable.stim_col,dataT.unit(iun).task_variable.targ_col==+1,dataT.unit(iun).task_variable.context==+1);
    [xcc(iun,:),wcc(iun,:)] = psychfunctionmod(dataT.unit(iun).task_variable.stim_col,dataT.unit(iun).task_variable.targ_col==+1,dataT.unit(iun).task_variable.context==-1);
end

% Plot
if plotflag
    figure; ha = [];
    ha(1) = subplot(2,2,1); plot(mean(xmm),wmm','k-');
    xlabel('motion coherence'); ylabel('choices to pref'); title('motion context');
    ha(2) = subplot(2,2,2); plot(mean(xcm),wcm','k-');
    xlabel('color coherence'); ylabel('choices to green'); title('motion context');
    ha(3) = subplot(2,2,3); plot(mean(xmc),wmc','b-');
    xlabel('motion coherence'); ylabel('choices to pref'); title('color context');
    ha(4) = subplot(2,2,4); plot(mean(xcc),wcc','b-');
    xlabel('color coherence'); ylabel('choices to green'); title('color context');
    set(ha,'plotbox',[1 1 1],'xlim',[-inf inf],'ylim',[0 1]);
end


%% The task configuration

% Random displacement
rd = (rand([nun 2])-0.5)*2;

% Colors
lc = linecolors(nun);

% The figure
if plotflag
    figure; ha=[];
    
    % The T1 target
    ha(1)=subplot(2,2,1); hold on;
    plot(0,0,'b+');
    for iun = 1:nun
        % Info for this unit
        stimInfo = metadata.unit(iun).stimInfo;
        
        % T1 target location
        t1x = stimInfo.t1Xpos - stimInfo.fpXpos;
        t1y = stimInfo.t1Ypos - stimInfo.fpYpos;
        
        % Plot
        hp=circle([t1x+rd(iun,1) t1y+rd(iun,2)],0.75);
        set(hp,'color',lc(iun,:));
    end
    grid on; title('T1 target'); xlabel('X position (deg'); ylabel('Y position (deg');
    
    % The T2 target
    ha(2)=subplot(2,2,2); hold on;
    plot(0,0,'b+');
    for iun = 1:nun
        % Info for this unit
        stimInfo = metadata.unit(iun).stimInfo;
        
        % T1 target location
        t2x = stimInfo.t2Xpos - stimInfo.fpXpos;
        t2y = stimInfo.t2Ypos - stimInfo.fpYpos;
        
        % Plot
        hp=circle([t2x+rd(iun,1) t2y+rd(iun,2)],0.75);
        set(hp,'color',lc(iun,:));
    end
    grid on; title('T2 target'); xlabel('X position (deg'); ylabel('Y position (deg');
    
    % The dots
    ha(3)=subplot(2,2,3); hold on;
    plot(0,0,'b+');
    for iun = 1:nun
        % Info for this unit
        stimInfo = metadata.unit(iun).stimInfo;
        
        % T1 target location
        dotx = stimInfo.dotXpos - stimInfo.fpXpos;
        doty = stimInfo.dotYpos - stimInfo.fpYpos;
        
        % Plot
        hp=circle([dotx+rd(iun,1) doty+rd(iun,2)],min(stimInfo.dotEccentricity/2,7.5));
        set(hp,'color',lc(iun,:));
    end
    grid on; title('Random dots'); xlabel('X position (deg'); ylabel('Y position (deg');
    
    % Both targets
    ha(4)=subplot(2,2,4); hold on;
    plot(0,0,'b+');
    for iun = 1:nun
        % Info for this unit
        stimInfo = metadata.unit(iun).stimInfo;
        
        % T1 target location
        t1x = stimInfo.t1Xpos - stimInfo.fpXpos;
        t1y = stimInfo.t1Ypos - stimInfo.fpYpos;
        
        % T2 target location
        t2x = stimInfo.t2Xpos - stimInfo.fpXpos;
        t2y = stimInfo.t2Ypos - stimInfo.fpYpos;
        
        % Plot
        hp=plot([t1x t2x]+rd(iun,1),[t1y t2y]+rd(iun,2),'-');
        set(hp,'color',lc(iun,:));
    end
    grid on; title('Targets'); xlabel('X position (deg'); ylabel('Y position (deg');
    
    set(ha,'xlim',[-30 30],'ylim',[-30 30],'xtick',-30:10:30,'ytick',-30:10:30',...
        'dataaspectratio',[1 1 1]);
end


%% Condition averaged responses

% The conditions to use
task_index = [];
task_index.correct      = [1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2]';
task_index.targ_dir     = [2 2 2 1 1 1 1 1 1 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2]';
task_index.stim_dir     = [1 2 3 4 5 6 1 2 3 4 5 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 2 3 4 5 6 1 2 3 4 5 6 1 2 3 4 5 6 1 2 3 4 5 6]';
task_index.stim_col2dir = [0 0 0 0 0 0 0 0 0 0 0 0 1 2 3 4 5 6 1 2 3 4 5 6 1 2 3 4 5 6 1 2 3 4 5 6 1 2 3 4 5 6 1 2 3 4 5 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]';
task_index.context      = [2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]';

% Condition average
dataC = tdrAverageCondition(dataT,task_index);


%% Process condition averaged responses

% Smoothing parameters
smthpars = [];
smthpars.filter = 'gauss'; % {'gauss';'box'}
smthpars.width = 0.04;

% Smooth responses
dataC_smth = tdrTemporalSmoothing(dataC,smthpars);

% Averaging parameters
avgpars = [];
avgpars.trial = [];
avgpars.time = [];

% Mean and STD across time and conditions
[meanC,stdC] = tdrMeanAndStd(dataC_smth,avgpars);

% Normalization parameters
nrmlpars = [];
nrmlpars.ravg = meanC;
nrmlpars.rstd = stdC;
% nrmlpars.cnst = median(stdC)/2; % arbitrary

% Normalize
dataC_nrml = tdrNormalize(dataC_smth,nrmlpars);


%% Linear regression

% Averaging parameters
avgpars = [];
avgpars.trial = [];
avgpars.time = [];

% Mean and STD across time and trials
[meanT,stdT] = tdrMeanAndStd(dataT,avgpars);

% Normalization parameters
nrmlpars = [];
nrmlpars.ravg = meanT;
nrmlpars.rstd = stdT;
% nrmlpars.cnst = median(stdT)/2; % arbitrary

% Normalize
dataT_nrml = tdrNormalize(dataT,nrmlpars);

% Regression parameters
regpars = [];
regpars.regressor = {...
    'b0';...
    'targ_dir';'stim_dir';'stim_col2dir';'context';...
    'targ_dir*context';'stim_dir*context';'stim_col2dir*context'};
regpars.regressor_normalization = 'max_abs';

% Linear regression
coef_fulUN = tdrRegression(dataT_nrml,regpars,plotflag);


%% Principal component analysis

% PCA parameters
pcapars = [];
pcapars.trial_pca = dataC_nrml.task_index.correct==2;
pcapars.trial_prj = [];
pcapars.time_pca = [];
pcapars.plot_dimensions = 1:20;

% Compute PCA
[data_fulPC,fulUN_fulPC,varPC] = tdrPca(dataC_nrml,pcapars,plotflag);


%% Define mid-dimensional subspace

% Principle components to keep
pc2keep = 1:12;

% Projection matrix full space (unit basis) into PC subspace (PC basis)
midPC_fulUN = fulUN_fulPC(:,pc2keep)';


%% Variance explained by PCs

% Variance parameters
varpars = [];
varpars.time_var = [];
varpars.dim_sub = pc2keep;

% Compute variance
var_mid = tdrSubspaceVariance(data_fulPC,dataC_nrml,varpars,plotflag);


%% Denoise and smooth regression coefficients

% Subspace parameters
subpars = [];
subpars.subSUB_fulORG = midPC_fulUN;
subpars.dimension = data_fulPC.dimension(pc2keep);

% Project coefficients into subspace
[coef_midPC,coef_midUN] = tdrSubspaceProjection(coef_fulUN,subpars);

% Smoothing parameters
smthpars = [];
smthpars.filter = 'gauss'; % {'gauss';'box'}
smthpars.width = 0.04;

% Smooth coefficients
coef_midPC = tdrTemporalSmoothing(coef_midPC,smthpars);
coef_midUN = tdrTemporalSmoothing(coef_midUN,smthpars);


%% Temporal dynamics of regression coefficients

% Correlogram parameters
plotpars = [];
plotpars.name = {'targ_dir';'stim_dir';'stim_col2dir';'context'};
plotpars.plotpairs = 1;

% Coefficient correlogram
[~,~,h] = tdrVectorDynamics(coef_midUN,plotpars,plotflag);


%% Define regression vectors

% Regression vector parameters
vecpars = [];
vecpars.targ_dir.time_win     = [0.60 0.90];
vecpars.stim_dir.time_win     = [0.25 0.45];
vecpars.stim_col2dir.time_win = [0.35 0.55];
vecpars.context.time_win      = [0.10 0.90];

% Compute regression vectors
vBeta = tdrVectorTimeAverage(coef_midUN,vecpars,plotflag);


%% Define task-related axes (orthogonalize regression vectors)

% Regression axes parameters
ortpars = [];
ortpars.name = {'targ_dir';'stim_dir';'stim_col2dir';'context'};

% Compute regression axes
[vAxes,lowUN_lowTA] = tdrVectorOrthogonalize(vBeta,ortpars);

% Projection matrix full space (unit basis) into task subspace (task basis)
lowTA_lowUN = lowUN_lowTA';


%% Responses in task-related subspace

% Subspace parameters
subpars = [];
subpars.subSUB_fulORG = lowTA_lowUN;
subpars.dimension = vAxes.name;

% Project responses into subspace
[dataC_lowTA,dataC_lowUN,varTA] = tdrSubspaceProjection(dataC_nrml,subpars,0);

% Variance parameters
varpars = [];
varpars.time_var = pcapars.time_pca;
var_low = tdrSubspaceVariance(dataC_lowTA,dataC_nrml,varpars,plotflag);


%% Plot 2D trajectories - condition averaged responses

% PICK AXES
plotpars = [];
% Choice vs motion
plotpars.dimension = {'targ_dir';'stim_dir'};
% Choice vs color
% plotpars.dimension = {'targ_dir';'stim_col2dir'};


%--- Data to plot ---
data = dataC_lowTA;

if plotflag
    
    % Common plot parameters
    % Markersize and linewidth. Use default if empty.
    plotpars.markersize = [];
    plotpars.linewidth = [];
    plotpars.handle.figure = [];
    plotpars.handle.axes = [];
    plotpars.handle.plot = [];
    plotpars.average_trials = 0; % 1 or 0
    plotpars.type = '-o';
    plotpars.dataaspectratio = [1 1 1];
    plotpars.plotboxaspectratio = [1 1 1];
    
    
    %--- Effect of motion (choice 1) - motion context ---
    plotpars.handle = [];
    plotpars.colormap = 'darkgray';
    plotpars.task_index.context  = 2;
    plotpars.task_index.correct  = 2;
    plotpars.task_index.stim_col2dir = [];
    
    % Choice 1
    plotpars.task_index.targ_dir = 2;
    plotpars.task_index.stim_dir = [6 5 4];
    plotpars.markerface = 'full';
    plotpars.handle = tdrPlotResponse2D(data,plotpars);
    
    % Choice 2
    plotpars.task_index.targ_dir = 1;
    plotpars.task_index.stim_dir = [1 2 3];
    plotpars.markerface = 'empty';
    plotpars.handle = tdrPlotResponse2D(data,plotpars);
    
    
    %--- Effect of motion (choice 1) - color context ---
    plotpars.handle = [];
    plotpars.colormap = 'darkgray';
    plotpars.task_index.context  = 1;
    plotpars.task_index.correct  = 2;
    plotpars.task_index.stim_col2dir = [];
    
    % Choice 1
    plotpars.task_index.targ_dir = 2;
    plotpars.task_index.stim_dir = [6 5 4];
    plotpars.markerface = 'full';
    plotpars.handle = tdrPlotResponse2D(data,plotpars);
    
    % Choice 1
    plotpars.task_index.targ_dir = 2;
    plotpars.task_index.stim_dir = [1 2 3];
    plotpars.markerface = 'empty';
    plotpars.handle = tdrPlotResponse2D(data,plotpars);
    
    % Choice 2
    plotpars.task_index.targ_dir = 1;
    plotpars.task_index.stim_dir = [6 5 4];
    plotpars.markerface = 'full';
    plotpars.handle = tdrPlotResponse2D(data,plotpars);
    
    % Choice 2
    plotpars.task_index.targ_dir = 1;
    plotpars.task_index.stim_dir = [1 2 3];
    plotpars.markerface = 'empty';
    plotpars.handle = tdrPlotResponse2D(data,plotpars);
    
    
    %--- Effect of color (choice 1) - color context ---
    plotpars.handle = [];
    plotpars.colormap = 'blue';
    plotpars.task_index.context  = 1;
    plotpars.task_index.correct  = 2;
    plotpars.task_index.stim_dir = [];
    
    % Choice 1
    plotpars.task_index.targ_dir = 2;
    plotpars.task_index.stim_col2dir = [6 5 4];
    plotpars.markerface = 'full';
    plotpars.handle = tdrPlotResponse2D(data,plotpars);
    
    % Choice 2
    plotpars.task_index.targ_dir = 1;
    plotpars.task_index.stim_col2dir = [1 2 3];
    plotpars.markerface = 'empty';
    plotpars.handle = tdrPlotResponse2D(data,plotpars);
    
    
    %--- Effect of motion (choice 1) - color context ---
    plotpars.handle = [];
    plotpars.colormap = 'blue';
    plotpars.task_index.context  = 2;
    plotpars.task_index.correct  = 2;
    plotpars.task_index.stim_dir = [];
    
    % Choice 1
    plotpars.task_index.targ_dir = 2;
    plotpars.task_index.stim_col2dir = [6 5 4];
    plotpars.markerface = 'full';
    plotpars.handle = tdrPlotResponse2D(data,plotpars);
    
    % Choice 1
    plotpars.task_index.targ_dir = 2;
    plotpars.task_index.stim_col2dir = [1 2 3];
    plotpars.markerface = 'empty';
    plotpars.handle = tdrPlotResponse2D(data,plotpars);
    
    % Choice 2
    plotpars.task_index.targ_dir = 1;
    plotpars.task_index.stim_col2dir = [6 5 4];
    plotpars.markerface = 'full';
    plotpars.handle = tdrPlotResponse2D(data,plotpars);
    
    % Choice 2
    plotpars.task_index.targ_dir = 1;
    plotpars.task_index.stim_col2dir = [1 2 3];
    plotpars.markerface = 'empty';
    plotpars.handle = tdrPlotResponse2D(data,plotpars);

end


%%

