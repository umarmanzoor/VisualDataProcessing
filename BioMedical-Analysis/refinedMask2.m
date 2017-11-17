function mask = refinedMask2(BW)

mask = segmentImageFcn(tmpImg);
mask = imfill(bwareaopen(mask,30),'holes');
tmpImg = imhmin(rgb2gray(tmpImg),13);
tmpImg = watershed(tmpImg);
tmpImg = tmpImg == 0;
tmpImg = bwareaopen(tmpImg,200,8);
mask(tmpImg) = 0;
