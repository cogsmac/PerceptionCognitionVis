function drawStims(setSize, proportion, redundancy, centroid, iconWidth)
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
%        proportion, int; how many make up the larger set.
%    redundancy, logical; are the groups redundantly encoded? 
%         centroid, vect; the x, y coordinates for the center of the array.
%         iconWidth, int; the x dimension for the circle/other shapes
%  OUTPUT: 
%
%  EXAMPLE:
%       
%  
%  Additional Scripts Used: 
%  
%  Additional Comments: 
%
spacingRule = .5; % icons will be separated by half their width

% 1. Use the number of icons to determine the dimensionality of the array.
% This is done by finding even divisors and choosing the squarest one ..
              K = 1:setSize;
factorsPossible = K(rem(setSize,K)==0);
  reshapeFactor = median(factorsPossible);
% .. and then initializing a matrix of the same dimensions that will later
% be filled in with X, Y coordinates
    xStimCoords = reshape(K, reshapeFactor, []);
    yStimCoords = xStimCoords;

% 2. using centroid, build out array


% 3. draw circles, icons (shape) 


% 4. Jardine IT 