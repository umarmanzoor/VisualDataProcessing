% Calculate Minimum distance between two objects
% Calculate objects maximum x1, y1 and x2, y2 points for relations

% Created by Umar Manzoor

function [x1,y1,x2,y2,minDistance,maxx1, maxx2, maxy1, maxy2] = calculateMinDistance(boundary1, boundary2)
boundary1x = boundary1(:, 2);
boundary1y = boundary1(:, 1);
x1=1;
y1=1;
x2=1;
y2=1;
overallMinDistance = inf; % Initialize.
% For every point in boundary 2, find the distance to every point in boundary 1.
for k = 1 : size(boundary2, 1)
	% Pick the next point on boundary 2.
	boundary2x = boundary2(k, 2);
	boundary2y = boundary2(k, 1);
	% For this point, compute distances from it to all points in boundary 1.
	allDistances = sqrt((boundary1x - boundary2x).^2 + (boundary1y - boundary2y).^2);
	% Find closest point, min distance.
	[minDistance(k), indexOfMin] = min(allDistances);
	if minDistance(k) < overallMinDistance
		x1 = boundary1x(indexOfMin);
		y1 = boundary1y(indexOfMin);
		x2 = boundary2x;
		y2 = boundary2y;
		overallMinDistance = minDistance(k);
	end
end
% Find the overall min distance
minDistance = min(minDistance);

maxx1 = max(boundary1x);
maxy1 = max(boundary1y);

maxx2 = max(boundary2x);
maxy2 = max(boundary2y);

end