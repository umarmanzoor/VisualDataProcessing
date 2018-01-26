cellSize = 50;
originalImage = imread('Images/autoSegments/train/MGF1-Cross-0009.tif');
[width, height, dim] = size(originalImage);
imshow(originalImage);
hold on;

Xboxes = fix(width / cellSize);
Yboxes = fix(height / cellSize);
row = 1;
for i = 1 : Xboxes
  line([1, height], [row, row]);
  row = row + cellSize;
end
column = 1;
for i = 1 : Yboxes
  line([column , column ], [1, width]);
  column = column + cellSize;
end

