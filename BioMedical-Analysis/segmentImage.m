function [BW,maskedImage] = segmentImage(X)
%segmentImage Segment image using auto-generated code from imageSegmenter App
%  [BW,MASKEDIMAGE] = segmentImage(X) segments image X using auto-generated
%  code from the imageSegmenter App. The final segmentation is returned in
%  BW, and a masked image is returned in MASKEDIMAGE.

% Auto-generated by imageSegmenter app on 17-Nov-2017
%----------------------------------------------------


% Threshold image - adaptive threshold
BW = imbinarize(X, 'adaptive', 'Sensitivity', 0.750000, 'ForegroundPolarity', 'bright');

% Invert mask
BW = imcomplement(BW);

% Create masked image.
maskedImage = X;
maskedImage(~BW) = 0;