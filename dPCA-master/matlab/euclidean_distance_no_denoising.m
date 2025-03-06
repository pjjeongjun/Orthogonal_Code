function euclid_dist = euclidean_distance_no_denoising(firingRates_train, firingRates_test)

for direction_dist = 1:size(firingRates_train,2)
    for direction_test = 1:size(firingRates_test,2)
        train_trials = squeeze(firingRates_train(:,direction_dist,:));
        test_trial = firingRates_test(:,direction_test);
        
        X = train_trials';
        Y = test_trial';

        % Compute the Euclidean distance
        % ver1 (mean first, calculate distance)
        euclid_dist(direction_dist,direction_test) = sqrt(sum((mean(X,1) - Y).^2, 2));
        % % ver2 (calculate distances, mean later)
        % euclid_dist(direction_dist,direction_test) = mean(sqrt(sum((X - Y).^2, 2)));
    end
end