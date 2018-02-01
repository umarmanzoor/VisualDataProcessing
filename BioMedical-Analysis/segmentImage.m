function [BW,BW1] = segmentImage(X)

% Threshold image - adaptive threshold
BW = imbinarize(X, 'adaptive', 'Sensitivity', 0.680000, 'ForegroundPolarity', 'bright');

% Threshold image - adaptive threshold
BW1 = imbinarize(X, 'adaptive', 'Sensitivity', 0.680000, 'ForegroundPolarity', 'dark');

%BW1 = imcomplement(BW1);

% Dilate mask with disk
% radius = 1;
% decomposition = 0;
% se = strel('disk', radius, decomposition);
% BW = imdilate(BW, se);

% Invert mask
