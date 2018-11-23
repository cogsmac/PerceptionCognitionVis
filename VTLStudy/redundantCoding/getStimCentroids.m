function [stimCentroids,numGridColumns,numGridRows,rectContainer] = getStimCentroids(setSize, centroid, iconWidth)
%
%  Author: Jardine & McColeman
%  Date Created: February 26 2018
%  Last Edit:    November 8 2018
%  
%  Visual Thinking Lab, Northwestern University
%  Originally Created For: Perception, Priors and Cognition redundant coding study.
%  
%  Reviewed: [] 
%  Verified: [] 
%  
%  INPUT: 
%       setSize, integer; the number of icons in the array
%         centroid, vect; the x, y coordinates for the center of the array.
%         iconWidth, int; the x dimension for the circle/other shapes
%  OUTPUT: 
%       stimCentroids: 4 rows (x1,y1,x2,y2) x N setSize columns
%       stimCentroids will be used to draw shapes (dots or triangles) of
%       whatever sizes and colors at these centroids.
%
%       numGridColumns, numGridRows: how many x,y vals
%       rectContainer: rect of the entire stimulus, for easier masking and
%       analysis later
%
%  This can be used easily to 
%
%  EXAMPLE:
%       
%  
%  Additional Scripts Used: 
%  
%  Additional Comments: 
%
spacingRule = .5; % icons will be separated by half their width
% therefore centroids are separated by 1.5 item widths
xDist = (1+spacingRule)*iconWidth; yDist = (1+spacingRule)*iconWidth;

% 1. Use the number of icons to determine the dimensionality of the array.
% This is done by finding even divisors and choosing the squarest one ..
K = 1:setSize;
factorsPossible = K(rem(setSize,K)==0);
reshapeFactor = factorsPossible((round(length(factorsPossible)/2))); %median(factorsPossible); median breaks w/ non-squares
% .. and then initializing a matrix of the same dimensions that will later
% be filled in with X, Y coordinates
% following is reundant, but b/c may want non-squares later
xStimCoords = transpose(reshape(K, reshapeFactor, []));
    sizeX = size(xStimCoords); numGridColumns = sizeX(2); %1, 2, 3 goes L-->R
yStimCoords = reshape(K, reshapeFactor, []); % 1, 2, 3 goes top-->down
    sizeY = size(yStimCoords); numGridRows = sizeY(1);
    
temp_rectContainer = [0,0,numGridRows*xDist,numGridColumns*yDist];
rectContainer = CenterRectOnPoint(temp_rectContainer,centroid(1),centroid(2));

% 2. using centroid, build out array
% Screen('FillOval') can be sped up with rect as 4 rows by n columns
% so will output centroids as (x,y) x setSize
stimCentroids = zeros(2,setSize);
xVals = linspace(rectContainer(1),rectContainer(3),numGridColumns);
yVals = linspace(rectContainer(2),rectContainer(4),numGridRows);

% fill in
for xi=1:numGridColumns
    for yi=1:numGridRows
        xyi = sub2ind([numGridRows,numGridColumns],xi,yi);
        stimCentroids(1,xyi) = xVals(xi);
        stimCentroids(2,xyi) = yVals(yi);
    end
end

