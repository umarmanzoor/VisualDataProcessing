% Determine if object one is inside object two.
% Calculate the percentage

% Created by Umar Manzoor

function [ percent ] = disjointObjects( object1, object2 )

    disjointPointsCounter = 0;
    biggerObject = object1;
    smallerObject = object2;

    if(size(object2, 1) > size(object1, 1))
        biggerObject = object2;  
        smallerObject = object1;
    end

    biggerObjectX = biggerObject(:,1);
    biggerObjectY = biggerObject(:,2);
    sizeSmallerObj = size(smallerObject, 1);

    for i = 1 : sizeSmallerObj
        pt = smallerObject(i,:);   
        [in , on] = inpolygon(pt(1), pt(2), biggerObjectX, biggerObjectY);   
        if~(in || on)           
            disjointPointsCounter = disjointPointsCounter + 1;
        end
    end

    percent = ((sizeSmallerObj - disjointPointsCounter) / sizeSmallerObj) * 100;    
%   display([num2str(percent), ' % of smaller object lies outside bigger object']);    
%   display([num2str(disjointPointsCounter), ' out of total ', num2str(sizeSmallerObj), ' points lie outside']);

end
