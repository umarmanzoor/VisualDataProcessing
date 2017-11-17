% Main Function
% Created by Umar Manzoor

file = 'Images/matlabdata.txt';
outputfile = 'Images/segmentBoxes.txt';
fid = fopen(file);   
outputfid = fopen(outputfile,'w');
tline = fgetl(fid);
while ischar(tline)
   objects = strsplit(tline, ' ');
   fileName = char(objects{1});
   segmentCount = str2double(char(objects{2}));
   imageFile = 'Images/images/';
   imageFile = strcat(imageFile,fileName);
   imageFile = strcat(imageFile,'.jpg');
   I = imread(imageFile);
   [imageWidth, imageHeight, dim] = size(I);
   imshow(I); hold on;
   colors=['b' 'g' 'r' 'c' 'm' 'y' 'w'];
    for k=1:segmentCount
      blackImage = 0 * I;
      BW = im2bw(blackImage);
      Mask = 'Images/segmentation_masks/';
      Mask = strcat(Mask, fileName);
      Mask = strcat(Mask, '_');
      Mask = strcat(Mask, num2str(k)); 
      Mask = strcat(Mask, '.mat'); 
      M = objMaskLoader(Mask);
      BW(~M)=255;
      [B,L,N,A] = bwboundaries(BW);
      boundary = B{1};
      
      X = boundary(:,2);
      Y = boundary(:,1);
      minX = min(X);
      maxX = max(X);
      minY = min(Y);
      maxY = max(Y);      
      
      width = maxX - minX;
      height = maxY - minY;
      
      fprintf(outputfid,'%s %d %d-%d-%d-%d %d-%d \r\n',fileName, k, minX, minY, width, height, imageWidth, imageHeight);
      
      cidx = mod(k,length(colors))+1;
      
      line([minX,maxX],[maxY,maxY],'Color', colors(cidx),'LineWidth',2)
      line([minX,maxX],[minY,minY],'Color', colors(cidx),'LineWidth',2)
      line([minX,minX],[minY,maxY],'Color', colors(cidx),'LineWidth',2)
      line([maxX,maxX],[minY,maxY],'Color', colors(cidx),'LineWidth',2)      
      
      plot(boundary(:,2), boundary(:,1),'Color', colors(cidx),'LineWidth',2);
    
      rndRow = ceil(length(boundary)/(mod(rand*20,7)+1));  
      col = boundary(rndRow,2); row = boundary(rndRow,1);
      h = text(col+1, row-1, num2str(k));
      set(h,'Color',colors(cidx),'FontSize',14,'FontWeight','bold');

      rndRow = ceil(length(boundary)/(mod(rand*50,11)+1));  
      col = boundary(rndRow,2); row = boundary(rndRow,1);
      h = text(col+1, row-1, num2str(k));
      set(h,'Color',colors(cidx),'FontSize',14,'FontWeight','bold');
    end
    frame = getframe(1);
    im = frame2im(frame);
    savingPath = 'Images/highlighted_segmented_images/';
    savingPath = strcat(savingPath, fileName);
    savingPath = strcat(savingPath, '.jpg');
    imwrite(im, savingPath)
    hold off
    % Reading Next Image    
    tline = fgetl(fid);
end
fclose(fid);
fclose(outputfid);