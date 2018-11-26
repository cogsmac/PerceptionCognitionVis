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
%  INPUT: 
%  OUTPUT: 
%
%  Additional Scripts Used:
%
%  Additional Comments:

% if nothing else changes, the status remains as is
hasBeenAdjusted = weHaveSomethingToDraw; % will update if there's a viable click

if contains(scaleType,'rectangle') % rectangle across; slider response
    if weHaveSomethingToDraw % display the last response to aid user
        
        % draw the last adjustment 
        Screen(windowPtr,'FillRect', responseBarCol, previousRect)
    end
    
    if inAdjustmentRegion && buttonDown % participant is in response range
        ShowCursor('CrossHair')
        
        if strcmpi(scaleType, 'rectangleAcross')
        % new "best guess" from participant
        updatedRect = [previousRect(1), snapVec(1), ...
                                       x, snapVec(2)];
                                   
        else strcmpi(scaleType, 'rectangleSlider')
            % new "best guess" from participant
            updatedRect = [x-2, snapVec(1), ...
                x+2, snapVec(2)];
            
        end
        
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
        
        updatedRect = previousRect; % no change
    else
        ShowCursor('Arrow')
        updatedRect = previousRect; % no change
    end
end

