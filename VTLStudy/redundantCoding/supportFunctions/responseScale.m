%  Allows a user in an adjustment task to change the value of a stimulus. A
%  generalizable version of mouseAdjustment.m
%
function [hasBeenAdjusted, updatedRect]= responseScale(scaleType, inAdjustmentRegion, weHaveSomethingToDraw, buttonDown, previousRect, x, y, windowPtr, responseBarCol, snapVec)
%
%  Author: Caitlyn McColeman
%  Date Created: Nov 26 2018
%  Last Edit:
%
%  Visual Thinking Lab, Northwestern University
%  Originally Created For: Perception, Cognition, Vis; based loosely on
%                          drawBack.m from the ratio study
%
%  Reviewed: []
%  Verified: []
%
%  INPUT: inAdjustmentRegion, binary; is this an appropriate place to
%                                     update values?
%         weHaveSomethingToDraw, bin; is there already an adjusted value
%                                     from the last iteration?
%                    buttonDown, bin; is the mouse button being pressed?
%                adjustableRect,vect; the x1, y1, x2, y2 values of the new
%                                     rectangle to draw
%                             y, int; the updated y value for the rectangle
%                     windowPtr, int; the index to the stimulus
%                                     presentation window to draw the
%                                     rectangle to
%
%  OUTPUT: drawRect, vector; coordinates for the new rectangle
%
%  Additional Scripts Used:
%
%  Additional Comments:

% if nothing else changes, the status remains as is
hasBeenAdjusted = weHaveSomethingToDraw; % will update if there's a viable click

if strcmpi(scaleType, 'rectangleAcross')
    if weHaveSomethingToDraw % display the last response to aid user
        
        % draw the last adjustment 
        Screen(windowPtr,'FillRect', responseBarCol, previousRect)
    end
    
    if inAdjustmentRegion && buttonDown % participant is in response range
        ShowCursor('CrossHair')
        
        % new "best guess" from participant
        updatedRect = [adjustableRect(1), snapVec(1), ...
                                       x, snapVec(2)];
        
        %{
        updatedRect = [xSnap-.5*pointWidth y-.5*pointHeight...
            xSnap+.5*pointWidth y+.5*pointHeight];
        %}
                                       
        % we now have a response recorded
        hasBeenAdjusted = 1; 
        
        % draw
        Screen(windowPtr,'FillRect', responseBarCol, updatedRect)
        
    elseif inAdjustmentRegion
        ShowCursor('CrossHair')
        
        updatedRect = adjustableRect; % no change
    else
        
        updatedRect = adjustableRect; % no change
    end
end

