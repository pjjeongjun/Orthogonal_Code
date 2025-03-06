function coef = tdrRegression(data,regpars,plotflag)
% tdrRegression linear regression on population responses
%
% Inputs:
%  data: population response (sequential or simultaneous)
%  regpars.regressor: cell array of regressors {nrg 1}
%     Each entry is a string, corresponding to the name of one of the fields
%     in data.task_variable.
%  regpars.regressor_normalization:
%     (1) normalize regressors by maximum ('max_abs')
%     (2) use raw regressors ('none')
%  plotflag: summary plot, yes (1) or no (0)
%
% Outputs:
%  coef.name: regressor names (same as regpars.regressor)
%  coef.response: regression coefficients over units and times [nun npt nrg]
%     nun: n of units
%     npt: n of time samples
%     nrg: n of regressors
%  coef.time: time axis
%  coef.dimension: dimension labels
%
% coef = tdrRegression(data,regpars,plotflag)

% Default inputs
if nargin<3
    plotflag = 0;
end

% Initialize
coef.name = regpars.regressor;

% Check if data is sequentially or simultaneously recorded
if isfield(data,'unit') && ~isempty(data.unit)

    
    %--- Sequential recordings ---    
    % Dimensions
    npt = length(data.time);
    nun = length(data.unit);
    nrg = length(regpars.regressor);
    
    % Initialize
    % bb = zeros(nun,npt,nrg); % regression coefficients
    bb = zeros(nun,npt,nrg+1); % regression coefficients
    
    % Loop over units
    for iun = 1:nun
        
        % Construct the regressor values from the task variables
        ntr = size(data.unit(iun).response,1);
        regmod = ones(ntr,nrg);
        
        % Get the regressors
        for irg = 1:nrg
            
            % Loop over task variables
            isep = [0 strfind(regpars.regressor{irg},'*') length(regpars.regressor{irg})+1];
            for jsep = 1:length(isep)-1
                
                % The task variable
                varname = regpars.regressor{irg}(isep(jsep)+1:isep(jsep+1)-1);
                
                % Check that not constant term
                if ~strcmp(varname,'b0');
                    % Update regressor
                    regmod(:,irg) = ...
                        regmod(:,irg).*data.unit(iun).task_variable.(varname);
                end
            end
        end
        
        % Normalize the regressors
        switch regpars.regressor_normalization
            case 'none'
                regnrm = regmod;
                
            case 'max_abs'
                regnrm = zeros(size(regmod));
                for irg = 1:nrg
                    regnrm(:,irg) = regmod(:,irg) / max(abs(regmod(:,irg)));
                end
        end
        
        % Loop over time points
        % bbt = zeros(npt,nrg);
        bbt = zeros(npt,nrg+1);
        for ipt = 1:npt
            % Responses to predict
            yy = squeeze(data.unit(iun).response(:,ipt));
            % Linear regression
            % regnrm(find(regnrm(:,2)==0),2) = 2;
            % regnrm(find(regnrm(:,3)==0),3) = 3;
            % regnrm(find(regnrm(:,2)==1),2) = 4;
            % regnrm(find(regnrm(:,3)==1),3) = 5;
            regnrm(:,4) = regnrm(:,2).*regnrm(:,3);

            [bbt(ipt,:),bint,~,~,stats] = regress(yy,regnrm);
            p(ipt) = stats(3);
        end
        
        % Keep coefficients & p-values
        bb(iun,:,:) = bbt;
        pval(iun,:) = p;
    end
    
    % The state space dimensions
    dimension = {data.unit(:).dimension}';
    

else
    
    
    %--- Simultaneous recordings ---
    % Dimensions
    [nun npt ntr] = size(data.response);
    nrg = length(regpars.regressor);
    
    % Initialize
    bb = zeros(nun,npt,nrg); % regression coefficients
    
    % Construct the regressor values from the task variables
    regmod = ones(ntr,nrg);
    
    % Get the regressors
    for irg = 1:nrg
        
        % Loop over task variables
        isep = [0 strfind(regpars.regressor{irg},'*') length(regpars.regressor{irg})+1];
        for jsep = 1:length(isep)-1
            
            % The task variable
            varname = regpars.regressor{irg}(isep(jsep)+1:isep(jsep+1)-1);
            
            % Check that not constant term
            if ~strcmp(varname,'b0');
                % Update regressor
                regmod(:,irg) = ...
                    regmod(:,irg).*data.task_variable.(varname);
            end
        end
    end
    
    % Normalize the regressors
    switch regpars.regressor_normalization
        case 'none'
            regnrm = regmod;
            
        case 'max_abs'
            regnrm = zeros(size(regmod));
            for irg = 1:nrg
                regnrm(:,irg) = regmod(:,irg) / max(abs(regmod(:,irg)));
            end
    end
        
    % Loop over units
    for iun = 1:nun
        
        % Loop over time points
        bbt = zeros(npt,nrg);
        for ipt = 1:npt
            % Responses to predict
            yy = squeeze(data.response(iun,ipt,:));
            
            % Linear regression
            bbt(ipt,:) = regress(yy,regnrm);
        end
        
        % Keep coefficients
        bb(iun,:,:) = bbt;
    end
    
    % The state space dimensions
    dimension = data.dimension;
    
end

% The norm of the raw regression vectors
% bnorm = zeros(npt,nrg);
% for irg = 1:nrg
%     for ipt = 1:npt
%         bnorm(ipt,irg) = norm(squeeze(bb(:,ipt,irg)));
%     end
% end
bnorm = zeros(npt,nrg+1);
for irg = 1:nrg+1
    for ipt = 1:npt
        bnorm(ipt,irg) = norm(squeeze(bb(:,ipt,irg)));
    end
end

% Plot the norms
if plotflag
    % Plot
    figure; hp=plot(data.time,bnorm);
    
    % Labels
    % for irg = 1:nrg
    for irg = 1:nrg+1
        if irg == 4
            ht=text(data.time(end),bnorm(end,irg),['  ' 'interaction'],...
                'interpreter','none');
            set(ht,'horizontalalignment','left','verticalalignment','middle',...
                'color',get(hp(irg),'color'));
        else
            ht=text(data.time(end),bnorm(end,irg),['  ' regpars.regressor{irg}],...
                'interpreter','none');
            set(ht,'horizontalalignment','left','verticalalignment','middle',...
                'color',get(hp(irg),'color'));
        end
    end
    set(gca,'xlim',[data.time(1) data.time(end)],'ylim',[0 inf]);
    xlabel('time (s)'); ylabel('regressor norm');
    
end


% Keep what you need
coef.response = bb;
coef.pval = pval;
coef.time = data.time;
coef.dimension = dimension;
% regpars.norm = bnorm;


