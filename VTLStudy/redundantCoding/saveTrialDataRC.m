
% This creates an organized .csv file for each participant with an eye
% toward human readability for easier analysis on the other side. 

saveTrialDataRC(...
                ... %======================== basic analysis variables [BA] 
                subID, ...                     participantID
                trial, ...                     trialID    
                trialAccuracy, ...             accuracy
                proportionTest, ...            the full proportion
                baseEncoding, ...              comparisonTask
                redundancyCond, ...            if the groups are redundantly encoded
                responseTime, ...              response time
                setSize, ...                   setSize
                percentProp1, ...              correctRatio
                responseRatio, ...             participant's response
                responsePixels, ...         %  participant's response (raw, in pixel form)
                ... %======================== stimulus properties variables [SP]
                prop1Col, ...                  color of first group
                prop2Col, ...                  color of second group
                prop1Shape,...                 shape of first group
                prop2Shape,...                 shape of second group
                shapeOrder,...                 string representing order of presentation
                iconWidth, ...                 how many pixels in diameter is a dot
                iconWidth_dva, ...             how many degrees of visual angle in diameter is a dot (allows us to calculate visual angle for other elements in pixels too) 
                presentationLocation, ...   %  on which part of the screen was the array presented?
                ... %======================== stimulus timing details [TD]
                stimOn, ...                    stimulus onset
                maskOn, ...                    mask onset
                maskOff, ...                   mask offset
                responseOnset, ...             response phase onset
                responseOffset, ...            response phase offset
                testIfTimeUp, ...              time elapsed in minutes
                ITI_secs, ...                  intertrial interval seconds
                arrayDur, ...                  stimulus presentation duration
                maskDur)                     % mask duration
            
            
%  Author: Caitlyn McColeman
%  Date Created: Nov 29 2018
%  Last Edit: Nov 29 2018
%
%  Visual Thinking Lab, Northwestern University
%  
%  Originally Created For: Perception, Priors & Cognition - Redundant
%  Coding. An adaptation of the saveTrialData* series from the ratio
%  experiments.
%
%  Reviewed: []
%  Verified: []
%
%  INPUT: [todo] I'll comment this one day, but see redundantCoding.m from
%  whence this is called to get details about variables
%
%  OUTPUT: saves a .txt file



% reference: common data types
%     1) strings: "%s\t" 
%     2) floats:  "2.6f\t" for xx.xxxxxx or "6.2f\t" for xxxxxx.xx format
%                 numbers
%     3) integers "d\t"
% note the trailing \t creates a tab delimited file for fprintf


% basic analyses
varNames_BA = {'participantID', 'trial', 'trialAccuracy',   'testedProportion', 'firstEncoding', 'redundantlyCoded', 'responseTime', 'setSize', 'correctRatio', 'participantResponseRatio', 'participantResponsePixel' };
varTypes_BA = ['     %s\t        %d\t        %2.6f\t               %s\t               %s\t            %d\t                %6.6f\t       %d\t         %2.2f\t               %2.6f\t                     6.2f\t  '];
  dataIn_BA = {     subID,      trial,    trialAccuracy,  mat2str(proportionTest), baseEncoding,    redundancyCond,   responseTime,   setSize,   percentProp1,           responseRatio,          responsePixels };


% stimulus properties
varNames_SP = {'group1Color', 'group2Color', 'group1Shape', 'group2Shape', 'shapeOrder', 'iconWidthPx', 'iconWidthDVA', 'arrayLocation'};
varTypes_SP = ['    %s\t          %s\t           %s\t           %s\t          %s\t          %4.4f\t         %4.4f\t             %d\t'];
  dataIn_SP = {prop1Col,        prop2Col,     prop1Shape,   prop2Shape,     shapeOrder,    iconWidth,   iconWidth_dva, presentationLocation};
  
% stimulus timing details
varNames_TD = {'stimulusOnset', 'maskOnset', 'maskOffset', 'responseOnset', 'responseOffset', 'minutesElapsed', 'interTrialInterval', 'arrayDuration', 'maskDuration'};
varTypes_TD = ['  %6.4f\t         %6.4f\t       %6.4f\t        %6.4f\t           %6.4f\t           %3.4f\t                %1.4\t          %1.4\t          %1.4\t'];
  dataIn_TD = {   stimOn,         maskOn,       maskOff,    responseOnset,   responseOffset,   testIfTimeUp,             ITI_secs,       arrayDur,        maskDur} ;                    % mask duration  
  



% Create header row if this the first trial
if ~(exist(['../' whoAmIFile '_data/' num2str(subID) whoAmIFile 'trialLvl.txt'])==2)
    fID = fopen(['../' whoAmIFile '_data/' num2str(subID) whoAmIFile 'trialLvl.txt'], 'a+'); % open file
    
    % all the variable names are strings; save as such
    varTypes_names = repmat('%s\t ', 1, length(varNames_BA)+length(varNames_SP)+length(varNames_TD));
    
    namesIn = {varNames_BA{:} varNames_SP{:} varNames_TD{:}};
    
    % push to file
    fprintf(fID, [varTypes_names '\n'], namesIn{:}); % save data
    
    % close connection to file
    fclose(fID)
end


% Open/create a file named after this subject; spec. permission to append
fID = fopen(['../' whoAmIFile '_data/' num2str(subID) whoAmIFile 'trialLvl.txt'], 'a+');

dataIn = {dataIn_BA{:} dataIn_SP{:} dataIn_TD{:}};
fprintf(fID, [varTypes_BA varTypes_SP varTypes_TD '\n'], dataIn{:}); % save data
fclose(fID); % close the file connection

