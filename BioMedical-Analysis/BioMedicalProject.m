% Main Function 
% Read Images and Their Masks
% Created by Umar Manzoor

%Generating Segments
generateDatasetAutoSegment(char('Images/autoSegments/train'));

% Generating training dataset
%[trainAxons, trainMyelin, trainSchwann] = generateDatasetManualSegment(char('Images/train'), 1);

% Generating testing dataset
%[testAxons, testMyelin, testSchwann] = generateDataset(char('Images/test'), 0);

%axonLabels = trainAxons{:, 2};
%axonFeatures = bagOfFeatures(trainAxons{:, 3});

% TRAIN category classifier on the training set
%axonsClassifier = trainImageCategoryClassifier(trainingAxons{:, 3},bag);

%evaluate(classifier,testAxons);