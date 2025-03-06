function mahal_dist = mahalanobis_distance2(W, firingRates_train, firingRates_test, nComponents, task_components)

% Decode the 1st target direction

Zfull = [];
for trial = 1:size(firingRates_train,5)
    % train set
    Xfull = squeeze(firingRates_train(:,:,:,:,trial)); %cell x direction1 x direction2 x time x trial
    if isempty(find(~isnan(Xfull)==0)) %if all cells have response to all directions and times
        X = Xfull(:,:)';
        Xcen = bsxfun(@minus, X, mean(X));
        dataDim = size(Xfull);
        Z = Xcen * W;

        % projection of each trial of population response into the subspace
        % Zfull = component x direction x time x trial
        Zfull = cat(5, Zfull, reshape(Z(:,task_components)', [nComponents dataDim(2:end)]));
    end
end

% test set
Xfull_test = firingRates_test;
if isempty(find(~isnan(Xfull_test)==0)) %if all cells have response to all directions and times
    X_test = Xfull_test(:,:)';
    Xcen_test = bsxfun(@minus, X_test, mean(X_test));
    dataDim_test = size(Xfull_test);
    Z_test = Xcen_test * W;
    Zfull_test = reshape(Z_test(:,task_components)', [nComponents dataDim(2:end)]);

    % projected trial population response for each direction at each time
    % and calculate the mahalnobis distance between train distribution and test sample
    for direction_dist = 1:size(Zfull,2)
        for direction_test = 1:size(Zfull_test,2)
            for time = 1:size(Zfull,4)
                train_trials = squeeze(Zfull(:,direction_dist,:,time,:));
                test_trials = squeeze(Zfull_test(:,direction_test,:,time));
                train_trials = reshape(train_trials,[size(train_trials,1) size(train_trials,2)*size(train_trials,3)]);
                for i = 1:size(test_trials,2)
                    test_trial = test_trials(:,i);
                    mahal_dist(direction_dist,size(test_trials,2)*(direction_test-1)+i,time) = mahal(test_trial',train_trials');
                end
            end
        end
    end
end
end