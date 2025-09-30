function fitness = SVM_Fitness_Function(hyperparams, XTrain_pca, YTrain)
% SVM_Fitness_Function.m — Optimized for Speed (Hold-Out) + Q1 Validity

% Extract hyperparameters
C = hyperparams(1);
gamma = hyperparams(2);

% Create SVM template
template = templateSVM(...
    'BoxConstraint', C, ...
    'KernelFunction', 'rbf', ...
    'KernelScale', 1/sqrt(gamma), ... % Note: MATLAB uses 1/sqrt(gamma) for RBF
    'Standardize', true);

% Create ECOC model
ecocModel = fitcecoc(XTrain_pca, YTrain, 'Learners', template);

%% Option 1: Hold-Out Validation (Faster — Recommended for PWPA)
% 80% train, 20% validation
cvPartition = cvpartition(size(XTrain_pca,1), 'HoldOut', 0.2);
trainIdx = training(cvPartition);
valIdx = test(cvPartition);

% Retrain on train set
ecocModel = fitcecoc(XTrain_pca(trainIdx,:), YTrain(trainIdx), 'Learners', template);

% Predict on validation set
YPred = predict(ecocModel, XTrain_pca(valIdx,:));

% Calculate loss
fitness = sum(YPred ~= YTrain(valIdx)) / numel(YPred);


%% ⚠️ Option 2: 5-Fold Cross Validation (More Accurate — Slower)
% Uncomment below if you prefer CV (comment out Hold-Out section above)
%
% opts = statset('UseParallel', false); % Set true if you have Parallel Computing Toolbox
% cvModel = crossval(ecocModel, 'KFold', 5, 'Options', opts);
% fitness = kfoldLoss(cvModel);

end