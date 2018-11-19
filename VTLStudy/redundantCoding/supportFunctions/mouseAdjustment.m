%  Allows a user in an adjustment task to change the value of a stimulus.
%
function [hasBeenAdjusted, updatedRect] = mouseAdjustment(stimType, inAdjustmentRegion, weHaveSomethingToDraw, buttonDown, adjustableRect, x, y, windowPtr, lightGrey, referenceRect)
%
%  Author: Caitlyn McColeman
%  Date Created: March 23 2018
%  Last Edit: November 19 2018
%
%  Visual Thinking Lab, Northwestern University
%  Originally Created For: ratio3.m; big re-write for redundantCoding.m
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

% initialize output
hasBeenAdjusted = weHaveSomethingToDraw; 
updatedRect = adjustableRect;


if inAdjustmentRegion && buttonDown && ~strcmpi(stimType, 'stackedAcross')
    hasBeenAdjusted = 1;
    % update the adjusted rectangle
    updatedRect(2) = min(y, adjustableRect(4));
    
    ShowCursor('CrossHair')
    Screen('FillRect', windowPtr, lightGrey/2, updatedRect);
elseif inAdjustmentRegion && buttonDown && strcmpi(stimType, 'stackedAcross')
    hasBeenAdjusted = 1;
    
    xInsideAdjustable = x<adjustableRect(3) && x>adjustableRect(1);
    xInsideReference = x<referenceRect(3)  && x>referenceRect(1);
    
    if xInsideReference && ~xInsideAdjustable
        % update the adjusted rectangle ... rightward
        updatedRect(3) = max(x, adjustableRect(3));
        % update the adjusted rectangle ... leftward
        updatedRect(1) = min(x, adjustableRect(1));
    elseif xInsideAdjustable
        % update the adjusted rectangle ... rightward
        updatedRect(3) = min(x, adjustableRect(3));
        % update the adjusted rectangle ... leftward
        updatedRect(1) = max(x, adjustableRect(1));
    elseif ~xInsideReference
         updatedRect = referenceRect; 
         updatedRect(3)=updatedRect(1)+1;
    end
         
    ShowCursor('CrossHair')
    Screen('FillRect', windowPtr, lightGrey/2, updatedRect);
elseif weHaveSomethingToDraw && inAdjustmentRegion
    ShowCursor('CrossHair')
    % keep the most recent adjusted rectangle on screen
    Screen('FillRect', windowPtr, lightGrey/2, updatedRect);
    
elseif inAdjustmentRegion
    % no current action, but in the region to make one. show cross
    % hair
    ShowCursor('CrossHair')
    
elseif weHaveSomethingToDraw
    % no current action, outside of region to adjust
    Screen('FillRect', windowPtr, lightGrey/2, updatedRect);
    ShowCursor('Arrow')
else
    % no action (current or past), not in the region to
    % adjust
    ShowCursor('Arrow')
end

