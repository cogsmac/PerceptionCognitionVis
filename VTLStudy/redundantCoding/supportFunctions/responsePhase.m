%  This is a wrapper function to contain all of the code and functions 
%  relevant for making a response on the response bar. 
%
function [responseTime, responsePixels, responseRatio] = responsePhase(kbPtr, windowPtr, screenXMax, screenYMax, baseEncoding, label1Properties, label2Properties)
%
%  Author: Caitlyn McColeman
%  Date Created: November 19 2018
%  Last Edit:    November 29 2018
%
%  Visual Thinking Lab, Northwestern University
%  Originally Created For: redundantCoding.m
%
%  Reviewed: []
%  Verified: []
%
%  INPUT:    
%               kbPtr, Int: the index marker for the keyboard
%           windowPtr; Int: the index maker for the psychtoolbox window we're
%                           drawing to
%          screenXMax; Int: the size of the screen horizontally in pixels
%          screenYMax; Int: the size of the screen vertically in pixels
%   label1Properties; Cell: the information required to draw the first
%                           label
%   label2Properties; Cell: the information required to draw the second
%                           label
%         
%  OUTPUT: 
%
%  Additional Scripts Used:
%
%  Additional Comments:

% some hard-coded constants we can adjust on additional iterations
     scaleType = 'rectangleSlider'; %'rectangleAcross'; % starting with this for now; we can change to be a variable if we want to play with other response options.
responseBarCol = [0,0,0];           % what color is the participant using to draw?


%  Initialize constants
instructionTxt = 'Press space to advance';
responseOnsetTic = tic; % should the same as prompOnset; coding for safe redundancy/checking

commandwindow;          % coerce cursor to command window for easy exit and to keep code from getting typed over by participants

% set-up properties of the response scale outline 
switch lower(scaleType)
    case {'rectangleacross', 'rectangleslider'} %[todo make a choice whether to use color here too if it's meaningful during stimulus phase]
        minX = .25 * screenXMax;
        maxX = .75 * screenXMax;
        
        minY = .7 * screenYMax;
        maxY = .75 * screenYMax;
        
        labCenterY = minY - .02*screenXMax; % same for both labels; slightly above bar
        
        
        snapVec = [minY maxY]; % participants won't draw vertically, so we'll do it for them    

        previousRect = [minX minY minX+1 minY+1];  %initialize to something silly, this will store the participants' latest response so they can see it while they adjust the bar

        
end

weHaveSomethingToDraw = 0; %initially, but as the user adjusts the scale we'll have their last response to draw in
responseAdjustmentRec = [];%in case we'd like to see how people adjust the response bar over time, we can access it from a .mat file saved herein
keycode = 0;               %no button press to start, but listen until there is via while loop
mouseSampler = 0;



while sum(keycode)==0   % present response scale, and wait for the user to press enter to advance.
       
    % prepare label markers
    if strcmpi(label1Properties{1}, 'dot')
        % draw a dot around the label center position (lab1CenterY, labCenterY)
        Screen('FillOval', windowPtr, label1Properties{2}, [minX-.5*label1Properties{3}, labCenterY-.5*label1Properties{3}, minX+.5*label1Properties{3}, labCenterY+.5*label1Properties{3}]);
       % Screen('FillOval', windowPtr, label1Properties{2}, [100 500 200 600]);
        % draw a triangle around the label center position (lab1CenterY, labCenterY)
        DrawTriangle(windowPtr, maxX, labCenterY,0,label1Properties{3},label1Properties{3},label1Properties{2});
    elseif strcmpi(label2Properties{1}, 'dot')
        % dot, as above
        Screen('FillOval', windowPtr, label2Properties{2}, [maxX-.5*label2Properties{3}, labCenterY-.5*label2Properties{3}, maxX+.5*label2Properties{3}, labCenterY+.5*label2Properties{3}]);
        % triangle, as above
        DrawTriangle(windowPtr, maxX, labCenterY,0,label2Properties{3},label2Properties{3},label2Properties{2});
    elseif strcmpi(label1Properties{1}, 'square') % shape is not a meaningful variable. Use square to represent color. 
        Screen(windowPtr,'FillRect', label1Properties{2}, [minX-.5*label1Properties{3}, labCenterY-.5*label1Properties{3}, minX+.5*label1Properties{3}, labCenterY+.5*label1Properties{3}])
        Screen(windowPtr,'FillRect', label2Properties{2}, [maxX-.5*label2Properties{3}, labCenterY-.5*label2Properties{3}, maxX+.5*label2Properties{3}, labCenterY+.5*label2Properties{3}])
    end
    
    % listen to keyboard
    [touch, secs, keycode, timingChk] = KbCheck(kbPtr);
    keyIn = KbName(keycode);
    
    % listen to mouse
    [x,y,buttons,focus,valuators,valinfo] = GetMouse();
   
    % draw the outline of the response scale 
    Screen('FrameRect',windowPtr, [0 0 0],[minX, minY, maxX, maxY])
    
    % determine if participants are hovering/clicking over the response window
    inAdjustmentRegion = y>minY-30 && y<maxY+30; % an extra 30 pixels added as a usability buffer
            buttonDown = sum(buttons)>0;         % is the mouse clicked?
            
    [hasBeenAdjusted, updatedRect] = responseScale(scaleType, inAdjustmentRegion, weHaveSomethingToDraw, buttonDown, previousRect, x, y, windowPtr, responseBarCol, snapVec);
    
                     previousRect = updatedRect; % replace the previously stored rectangle with most recent reponse
    % note whether there's a response so we make sure to draw in the on the
    % next iteration
    weHaveSomethingToDraw = hasBeenAdjusted;
        
    % [todo: presently escapes on any keypress]
   
    if weHaveSomethingToDraw
        mouseSampler = mouseSampler + 1; % keep track of iterations
        
        %adjustOnset(mouseSampler) = Screen('Flip', windowPtr);
        % Horizontally and vertically centered:
        DrawFormattedText(windowPtr, instructionTxt, 'center', 'center', 0);
        
        % record the value of the drawn rectangle this millisecond
        responseAdjustmentRec = [responseAdjustmentRec updatedRect];
    end
    Screen('Flip', windowPtr)
    WaitSecs(0.001); % avoid overloading the system on checks, update keyboard and mouse status each millisecond
    
end

% variables for output
 responseTime = toc(responseOnsetTic);             % how long from the start to the end of the response phase
responsePixels= updatedRect(3)-minX;               % how many pixels did the user draw in?
responseRatio = responsePixels/(maxX-minX); % what percentage was the user estimate?
