%  Just so we have a record of it, this is the x, y coordinates around
%  which the initial rectangle in a stimulus may be drawn.
%
function posCenters = positionRef(screenSize)
%
%
%  Author: Caitlyn McColeman 
%  Date Created: February 26 2018
%  Last Edit:    November 8 2018
%  
%  Visual Thinking Lab, Northwestern University
%  Originally Created For: Ratio Judgement; Updated for Perception, Priors
%                           and Cognition redudant coding study.
%  
%  Reviewed: [] 
%  Verified: [] 
%  
%  INPUT: screenSize, vect; the X and Y limits of the open screen
%  
%  OUTPUT: An x, y coordinate for the reference bar
%  
%  Additional Scripts Used: 
%  
%  Additional Comments: 
%       note that this returns the coordinates of the reference bar. The second
%       bar will have to be draw in relation to it. Mind the leftOrRight
%       value when actually drawing the stimulus
%       This runs ahead of time for a rapid reference to right the
%       position
%       [TO DO update constant values in response to current stimuli ]

% find equal spacing
heightIn = screenSize(2)/2;
widthIn = screenSize(1)/3;

yBoundaries = 0:heightIn:screenSize(2); % y dimension
xBoundaries = 0:widthIn:screenSize(1); % x dimension 

% loop through boundaries to find centroids
iterX = 0;

centersX = []; centersY = [];
for x = xBoundaries(1:end-1)
    iterX = iterX + 1;
    
    iterY = 0; % restart count for inside loop
    for y = yBoundaries(1:end-1)
        iterY = iterY + 1;
        
         centersX = [centersX; mean([xBoundaries(iterX+1),x])];
         centersY = [centersY; mean([yBoundaries(iterY+1),y])]; 
         
    end
end

posCenters = [centersX centersY]; % concatenate full output

