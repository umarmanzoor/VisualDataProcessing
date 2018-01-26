function [schwann] = generateDatasetAutoSegment(folderPath) 

    MyFolderInfo = dir(folderPath);
    MyFolderInfo=MyFolderInfo(~ismember({MyFolderInfo.name},{'.','..'})); 

    colors=['b' 'g' 'r' 'c' 'm' 'y'];
    
    for k = 1 : size(MyFolderInfo)        
       if(~MyFolderInfo(k).isdir)
            filepath = strcat(MyFolderInfo(k).folder, "/");
            filepath = strcat(filepath, MyFolderInfo(k).name);
            originalImage = imread(char(filepath));
            imshow(originalImage);            
%             hold on;    
%             % Convert to grayscale
%             if size(originalImage,3) == 3
%                 originalImage = rgb2gray(originalImage);
%             end
%             [row, col, dim] = size(originalImage);
%             imageArea = row * col;
%             [BW, cellMask] = segmentImage(originalImage);
%             imshow(BW);
%             binaryImage = imfill(BW, 'holes');
% 
%             imshowpair(BW,binaryImage,'montage')
%             %hold on;
%             
%             % remove small pixels
% %            BW = bwareaopen(BW, 200);
%             
%             [B,L] = bwboundaries(BW);
%             %allObjCount = 1;
%             for j = 1:length(B)               
%                objectBoundary = B{j};
% %               objLength = length(objectBoundary);
% %               if(objLength > 10)
%                    % creating boundary if gaps in existing boundary
% %                    x = objectBoundary(:,2);
% %                    y = objectBoundary(:,1);
% %                    b = boundary(x,y);
% %                    objectMask = poly2mask(x(b),y(b), row, col);
%                     
%                    %objectMask = poly2mask(objectBoundary(:, 2),objectBoundary(:, 1), row, col);
%                    %objectArea = bwarea(objectMask);               
% %                   normalizeArea = objectArea / imageArea * 100;
%                    
% %                    allObjectAreas(allObjCount, 1) = objectArea;
% %                    allObjectAreas(allObjCount, 2) = normalizeArea;
% %                    allObjCount = allObjCount + 1;
% %                   if(normalizeArea > 0.05)
%                         %plot(x(b),y(b), 'g', 'LineWidth', 2);           
%                         plot(objectBoundary(:, 2),objectBoundary(:, 1), 'g', 'LineWidth', 2);
% %                   end
%     %                cidx = mod(k,length(colors))+1;
%     %                plot(objectBoundary(:,2), objectBoundary(:,1),colors(cidx),'LineWidth',2);
% %               end
% %            end
%             hold off;
%             closeFigures();
% 
% %             imshowpair(BW,BW2,'montage')      
% 
        end
     end    
%     schwann = 1;
end

function closeFigures()
    delete(findall(0,'Type','figure'))
    bdclose('all')
    allPlots = findall(0, 'Type', 'figure', 'FileName', []);
    delete(allPlots);
end