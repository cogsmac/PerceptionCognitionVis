%  This is a wrapper function to contain all of the code and functions 
%  relevant for making a response on the response bar. 
%
function [responseOnset, responseTime, responsePixels, responseRatio] = responsePhase(kbPtr, windowPtr)
%
%  Author: Caitlyn McColeman
%  Date Created: November 19 2018
%  Last Edit:    November 26 2018
%
%  Visual Thinking Lab, Northwestern University
%  Originally Created For: redundantCoding.m
%
%  Reviewed: []
%  Verified: []
%
%  INPUT:    
%         
%  OUTPUT: 
%
%  Additional Scripts Used:
%
%  Additional Comments:

global screenXpixels 
global screenYpixels

% some hard-coded constants we can adjust on additional iterations
     scaleType = 'rectangleAcross'; % starting with this for now; we can change to be a variable if we want to play with other response options.
responseBarCol = [0,0,0];           % what color is the participant using to draw?


%  Initialize constants
instructionTxt = 'Press space to advance';
responseOnsetTic = tic; % should the same as prompOnset; coding for safe redundancy/checking

commandwindow;          % coerce cursor to command window for easy exit and to keep code from getting typed over by participants

% set-up properties of the response scale outline 
switch lower(scaleType)
    case 'rectangleacross' %[todo make a choice whether to use color here too if it's meaningful during stimulus phase]
        minX = .25 * screenXpixels;
        maxX = .75 * screenXpixels;
        
        minY = .66 * screenYpixels;
        maxY = .75 * screenYpixels;
        
        snapVec = [minY maxY]; % participants won't draw vertically, so we'll do it for them    
end

weHaveSomethingToDraw = 0; %initially, but as the user adjusts the scale we'll have their last response to draw in
previousRect = [0 0 1 1];  %initialize to something silly, this will store the participants' latest response so they can see it while they adjust the bar
responseAdjustmentRec = [];%in case we'd like to see how people adjust the response bar over time, we can access it from a .mat file saved herein


while sum(keycode)==0   % present response scale, and wait for the user to press enter to advance.
    
    % listen to keyboard
    [touch, secs, keycode, timingChk] = KbCheck(kbPtr);
    keyIn = KbName(keycode);
    
    % listen to mouse
    [x,y,buttons,focus,valuators,valinfo] = GetMouse();
   
    % draw the outline of the response scale 
    Screen(windowPtr,'FrameRect',[0,0,0],[minX, minY, maxX, maxY],2,2)
    
    % determine if participants are hovering/clicking over the response window
    inAdjustmentRegion = x>minX-30 && x<minX+30; % an extra 30 pixels added as a usability buffer
            buttonDown = sum(buttons)>0;         % is the mouse clicked?
    
    [hasBeenAdjusted, updatedRect] = responseScale(scaleType, inAdjustmentRegion, weHaveSomethingToDraw, buttonDown, previousRect, x, y, windowPtr, responseBarCol, snapVec);
    
    % note whether there's a response so we make sure to draw in the on the
    % next iteration
    weHaveSomethingToDraw = hasBeenAdjusted;
        
    % [todo: presently escapes on any keypress]
   
    if weHaveSomethingToDraw
        mouseSampler = mouseSampler + 1; % keep track of iterations
        
        adjustOnset(mouseSampler) = Screen('Flip', windowPtr, stimulus1Offset + (waitframes - 0.5) * ifi);
        % Horizontally and vertically centered:
        [nx, ny, bbox] = DrawFormattedText(windowPtr, instructionTxt, 'center', 'center', 0);
        
        % record the value of the drawn rectangle this millisecond
        responseAdjustmentRec = [responseAdjustmentRec updatedRect];
    end
    
    % push everything to screen 
    responseOnset = Screen('Flip', windowPtr);
    
    WaitSecs(0.001); % avoid overloading the system on checks, update keyboard and mouse status each millisecond
    
end

% variables for output
 responseTime = toc(responseOnsetTic);             % how long from the start to the end of the response phase
responsePixels= updatedRect(3)-minX;               % how many pixels did the user draw in?
responseRatio = responsePixels/(diff(maxX, minX)); % what percentage was the user estimate?
