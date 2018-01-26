% Main Function 
% Read Images and Their Masks
% Created by Umar Manzoor

%Generating Segments
%generateDatasetAutoSegment(char('Images/autoSegment/train'));

%Generating training dataset
generateDatasetManualSegment(char('Images/test'), 1);

% Generating test dataset
%[testAxons, testMyelin, testSchwann] = generateDatasetManualSegment(char('Images/test'), 1);
% axonstitle = 'Axons';
% axonExamples = trainAxons(:, 3);
% 
% bag = bagOfFeatures(axonExamples);
% X = 1.0;
% disp('Finished Processing');

% Generating testing dataset
%[testAxons, testMyelin, testSchwann] = generateDataset(char('Images/test'), 0);

%axonLabels = trainAxons{:, 2};
%axonFeatures = bagOfFeatures(trainAxons{:, 3});

% TRAIN category classifier on the training set
%axonsClassifier = trainImageCategoryClassifier(trainingAxons{:, 3},bag);

%evaluate(classifier,testAxons);