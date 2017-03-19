% Load image mask
% Created by Umar Manzoor

function objMask = objMaskLoader(maskMatFile)
objMask = load(maskMatFile);
objMask = struct2cell(objMask);
objMask = cell2mat(objMask);
end