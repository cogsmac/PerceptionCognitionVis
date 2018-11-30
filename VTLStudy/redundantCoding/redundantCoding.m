%  This is the high level script that calls all required functions to run
%  the redundantCoding study.
%%TO ADD: level, baseEncoding(color,shape) 
%%
%
%  Author: Caitlyn McColeman & Nicole Jardine
%  Date Created: Nov 8 2018
%  Last Edit:
%
%  Visual Thinking Lab, Northwestern University
%  Originally Created For: Perception, Priors & Cognition - Redundant Coding
%
%  Reviewed: []
%  Verified: []
%
%  INPUT:
%
%  OUTPUT:
%
%  Additional Scripts Used: 
%   demographicsQuestions.m
%   getStimCentroids.m
%   DrawTriangle.m
%   makeNoiseTexture.m
%   
%
%  Additional Comments:
%  The file will change the directory to its source folder to keep saving consistent and avoid file errors.
%  Because different machines PsychToolBox stored in different places, that directory will be need to manually coded in prep for data collection.
%
%  During development, comments marked [to do.. are action items
%
%  Design:
%   STUDY ONE: Redundancy (redundant vs not) x Proportion (30/70, 52/48, 10/90)
%   STUDY TWO: Study One x Organization (ordered vs scattered) x Set Size
%              (20 x 60 x 100)
%
%  =========================
%  Major Script Sections
%  PARTICIPANT LEVEL
%  1) Initialize, assign condition/block info
%  2) collect subject number, high level experiment log information (demographics, time)
%
%  TRIAL LEVEL
%  3) Prepare and show display
%  4) Mask
%  5) Show response display
%  6) Collect response
%  7) Feedback [todo: design decision about how we want to incentivize performance]
%
%
%  Conditions: greyscale icons (white vs black on top of grey background),
%               shape icons (circle vs triangle, all black/white on grey background)
%               color & shape redundant coding (grey bg)
%  -
%  -
%

close all;
clearvars;

debugMode = 1; % toggle to 1 for development

viewingDistance = 50; %cm, distance from eye to screen (approx)

%% 1) Initialize, assign condition/block info, stimulus info

% the Psychtoolbox path may be different on different computers. Careful.
addpath(genpath('/Applications/Psychtoolbox'))

currFolder = fileparts(which(mfilename)); % find current folder
addpath(genpath(currFolder));             % add subdirectories
cd(currFolder)                            % move to current folder

% levels of the Proportion factor
proportionMat = [[30, 70];                % proportion of filled-in icons
    [70, 30];
    [52, 48];
    [48, 52];                % [todo] make this an external script to streamline
    [10, 90]];                % [todo] find a proportion value near 50 that works for different set sizes

% prepare indexing and reference variables to proportionMat
sizeProportionMat = size(proportionMat);    
    proportionIdx = 1:sizeProportionMat(1);   % prep an indexing vector
nProportionLevels = length(proportionIdx);

% levels of the Redundancy factor
baseEncodingVect = {'shape','color'};      % whether shape or color is used as the redundandy=0 encoding
nBaseEncodingLevels = length(baseEncodingVect);

redundancyVect = [1;0];                    % are group differences redundantly encoded?
nRedundancyLevels = length(redundancyVect);% if base=shape, uses dots and triangles. redundancy adds color.


% full crossing of redundancy x proportion
nConds = nProportionLevels * nBaseEncodingLevels * nRedundancyLevels;                                        

randomizeOrder = 1;

% for development, set to one; for data collection set to 0
if debugMode == 1
    randomizeOrder = 0;
end


% block/trial content
trialRepsPerBlock = 1; % how many reps per condition
nBlocks = 2;
testIfTimeUp = 0;

% blockContent = repmat((1:nConds),1,trialRepsPerBlock);
nTrials = trialRepsPerBlock*nConds; %length(blockContent);

% stimulus properties 
iconWidth_dva = .8; % size (in deg vis angle; converted to pix later)
dotRadius_dva = iconWidth_dva/2;
setSize = 100; % nIcons

% Timing, in secs
ITI_secs = 1.00;
arrayDur = 0.300;
 maskDur = 1.00;


%% 2) Participant-level information; prep PsychToolBox presentation info
experimentOpenTime = tic;

% Basic experiment parameters
nMinutes = 50; % maximum duration
trialPerBlock = 50;

%% PsychToolbox
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% keyboard, mouse information
[keyboardIndices, productNamesKB, allInfos] = GetKeyboardIndices;  
[mouseIndices, productNamesMouse, allInfo] = GetMouseIndices;
       
kbPointer = keyboardIndices(end);  
mousePntr = mouseIndices(end);

KbName('UnifyKeyNames');

% Get the screen numbers
screens = Screen('Screens');
Screen('Preference', 'SkipSyncTests', 1)

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
lightGrey = [.75 .75 .75];
medGrey = [0.5 0.5 0.5];

backgroundColor = medGrey;

testIfTimeUp = 0;

% Open an on screen window
%[windowPtr, screenRect] = Screen('OpenWindow', screenNumber, 0, [], 32, 2);

[windowPtr, windowRect] = PsychImaging('OpenWindow', screenNumber, lightGrey); %CMC rect [1 1 1200 750]
Screen('Resolution', windowPtr);

[width_Win, height_Win]=Screen('WindowSize', windowPtr); % display size in pix
width_Dis=Screen('DisplaySize', screenNumber); % display size in mm
Screen('Close');

%calcualte deg to pix conversion coefficient
deg2pixCoeff=1/(atan(width_Dis/(width_Win*(viewingDistance*10)))*180/pi);


% Get the size of the on screen window [todo clean this up; it's the same as jardine's above]
[screenXpixels, screenYpixels] = Screen('WindowSize', windowPtr);

% get some details about the presentation size
positionOptions = positionRef([screenXpixels, screenYpixels]);

% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', windowPtr);

% Retreive the maximum priority number and set max priority
topPriorityLevel = MaxPriority(windowPtr);
Priority(topPriorityLevel);

% Using Scarfe's waitframe method to improve timing accuracy
flipSecs = .75;
waitframes = round(flipSecs / ifi);

% preparing logging variables
sameOrDiffTrial = 'adjust';

% allow only task-relevant responses [TODO] probably just want "enter" when
% they're done
% lol we need spacebar. revisit which keys should be excluded
% ret = RestrictKeysForKbCheck([32 44 40 37 77 88]); % spacebar, return and enter for OSx and PC. only tested on mac


%% new stimulus sizing
iconWidth = iconWidth_dva*deg2pixCoeff;
dotRadius = dotRadius_dva*deg2pixCoeff;


%% directory prep
% make sure we're in the right place in the directory so that stuff saves
% to the proper location
whoAmIFile = mfilename;
whereAmI  = mfilename('fullpath') ;
toLastDir = regexp(whereAmI, '.*\/', 'match') ;% get directory only (exclude file name)
toLastDir = toLastDir{1}; % extract string from cell
cd(toLastDir) % move to directory containing the file. Think of it as home base.

% collect demographics
%[demographics, cancelledInput] = demographicsQuestions;

% prepare this participants' unique directory to store every variable as a
% .mat backup. The subject number is the unique time from the OS via GetSecs
timeIDDir = num2str(GetSecs);
timeIDDir(strfind(timeIDDir, '.'))='_';
mkdir(timeIDDir)                  % create folder
addpath(timeIDDir)                % add that new folder to the path


if debugMode
    subID = 'debug';  % the debug subject ID will overwrite input to avoid errors
else
    subID = timeIDDir; % each participant gets their own folder with all of their data
end

try % the whole experiment is in a try/catch
    for block = 1:nBlocks

        % generate block's list of factor levels for each trial
        [propConds, encodingConds, redundancyConds] = BalanceFactors(trialRepsPerBlock, randomizeOrder, 1:nProportionLevels, 1:nBaseEncodingLevels, 1:nRedundancyLevels);
                
        for trial = 1:nTrials
            
            % what proportions and redundancies are we showing
            propCond = propConds(trial); 
                percentProp1 = proportionMat(propCond,1);
                percentProp2 = proportionMat(propCond,2);
                nProp1 = ceil(percentProp1*setSize/100);
                nProp2 = floor(percentProp2*setSize/100);
            redundancyCond = redundancyVect(redundancyConds(trial));
            
            % base encoding is in shape or color?
            baseEncoding = baseEncodingVect{encodingConds(trial)};
            
            % coinflip to determine base col and "fill" col
            if rand < 0.5
                prop1Shape = 'dot'; prop2Shape = 'tri';
            else
                prop1Shape = 'tri'; prop2Shape = 'dot';
            end
            
            shapeOrder = [prop1Shape,prop2Shape];
            
            % coinflip to determine base col and "fill" col
            if rand < 0.5
                prop1Col = [white white white]; prop2Col = [black black black];
            else
                prop1Col = [black black black]; prop2Col = [white white white];
            end
            
            colorOrder = [prop1Col; prop2Col];
            
            % replace stuff
            switch baseEncoding
                case 'shape'
                    if redundancyCond == 0
                        prop2Col = prop1Col; % if just seeing shapes, all same color.
                    end
                case 'color'
                    if redundancyCond == 0
                        shapeOrder = [prop1Shape,prop1Shape]; % if just seeing colors, all the same shape.
                    end
            end
            
            %set up color matrices
            nCol1 = repmat(prop1Col',1,nProp1); 
            nCol2 = repmat(prop2Col',1,nProp2);
            objColors = [nCol1 nCol2]; % combine them
            
            
            %% 3) Prepare and show display
            
            % we will draw dots and draw triangles according to item
            % indices. 
            switch shapeOrder
                case 'dottri'
                    dotIndices = 1:nProp1; triIndices = nProp1+1:setSize;
                    nDots = length(dotIndices);
                    nTris = length(triIndices);
                    
                    % for response
                    label1Properties = {'dot', prop1Col, dotRadius, 'left'};
                    label2Properties = {'tri', prop2Col, dotRadius, 'right'};
                case 'tridot'
                    triIndices = 1:nProp1; dotIndices = nProp1+1:setSize;
                    nDots = length(dotIndices);
                    nTris = length(triIndices);
                    
                    % for response
                    label1Properties = {'tri', prop1Col, dotRadius, 'left'};
                    label2Properties = {'dot', prop2Col, dotRadius, 'right'};
                case 'dotdot'
                    dotIndices = 1:setSize; triIndices = 0;
                    nDots = length(dotIndices);
                    nTris = 0;
                    
                    label1Properties = {'dot', prop1Col, dotRadius, 'left'};
                    label2Properties = {'dot', prop2Col, dotRadius, 'right'};
                case 'tritri'
                    triIndices = 1:setSize; dotIndices = 0;
                    nDots = 0;
                    nTris = length(triIndices);
                    
                    label1Properties = {'tri', prop1Col, dotRadius, 'left'};
                    label2Properties = {'tri', prop2Col, dotRadius, 'right'};
            end

            % locations are top left = 1, top center = 2, top right = 3 ... [todo coerce order in positionRef]
            presentationLocation = randi([1,6],1); % display is in one of six locations
            
            positionOptions = positionRef([screenXpixels, screenYpixels]); % index into the posiiton options
            
            % get pixel information for the centre of the stimulus array.
            centroidPx = positionOptions(presentationLocation,:);
            % generate stimulus centroids
            [objCentroids,numGridColumns,numGridRows,rectContainer] = getStimCentroids(setSize, centroidPx, iconWidth);
            allstimWidth = rectContainer(3)-rectContainer(1);
            allstimHeight = rectContainer(4)-rectContainer(2);
            
            % calculate rects if hypothetically using all the dots
            allDotRects =  [objCentroids(1,:)-repmat(dotRadius,1,setSize); ...
                            objCentroids(2,:)-repmat(dotRadius,1,setSize);...
                            objCentroids(1,:)+repmat(dotRadius,1,setSize);...
                            objCentroids(2,:)+repmat(dotRadius,1,setSize)];
            

             %% ITI
             WaitSecs(ITI_secs);
            
            %% STIMULUS DRAWING
            % draw display
            Screen('FillRect', windowPtr, backgroundColor);
            for d=1:nDots
                dot=dotIndices(d);
                Screen('FillOval', windowPtr, objColors(:,dot), allDotRects(:,dot));
            end
            for t=1:nTris
                tri=triIndices(t);
                DrawTriangle(windowPtr, objCentroids(1,tri), objCentroids(2,tri),0,iconWidth,iconWidth,objColors(:,tri));
            end
            %debug
            if debugMode==1
                disp([trial nDots nTris]);
                textToShow = strcat('base:',baseEncoding,' redundancy:',num2str(redundancyCond),', ',shapeOrder,' prop',num2str(nProp1), '-', num2str(nProp2));
                DrawFormattedText(windowPtr, textToShow);
            end
            % flip                
            stimOn = Screen('Flip', windowPtr);
            

            
            %% 4 mask    
            Screen('FillRect', windowPtr, backgroundColor);
            noiseTex = makeNoiseTexture(windowPtr, setSize, rectContainer, round(iconWidth*1.2));
            maskOn = Screen('Flip',windowPtr, stimOn+arrayDur);
             
            Screen('FillRect', windowPtr, backgroundColor);
            maskOff = Screen('Flip', windowPtr,maskOn+maskDur);  
            

            %% 5) collect response
            
            % prepare data information so that the extremes of the
            % response bar can be labelled with symbols
            if strcmpi(baseEncoding, 'shape') || redundancyCond == 1
                %label1Properties = {prop1Shape, prop1Col, dotRadius};
                %label2Properties = {prop2Shape, prop2Col, dotRadius};
            else % don't use a shape lest that's in the array lest it conflates things in this within-subjects design
                %label1Properties = {'square', prop1Col, dotRadius};
                %label2Properties = {'square', prop2Col, dotRadius};
            end
            
            responseOnset = Screen('Flip', windowPtr);
            
            % gather response variables
            [responseTime, responsePixels, responseRatio] = responsePhase(kbPointer, windowPtr, screenXpixels, screenYpixels, baseEncoding, label1Properties, label2Properties);
           
            display(responseTime)
            
            % calculate response logging values
            trialAccuracy = responseRatio-percentProp1/100;
            
            % clear screen, collect timing
            Screen('FillRect', windowPtr, backgroundColor);
            responseOffset = Screen('Flip', windowPtr);
           
            % temporal threshold
            testIfTimeUp=toc(experimentOpenTime);
            testIfTimeUp < nMinutes; % [todo] make sure Jardine's cool with it, but if they get to 50 mins skip to the last trial so we don't go over time.
            
            remainingTime = round(nMinutes - testIfTimeUp/60);
            
            %% 6) write data to file
            % save the .mat file naively: all variables redundantly saved
            % within this subjects' folder
            save(['../' whoAmIFile '_data/' whoAmIFile 'sub' num2str(subID) 'trial' num2str(trial) '.mat'])
                        
            % save a curated .csv file: all variables organized so each
            % participant one file we can use for our primary analyses
            saveTrialDataRC(subID, ...  %======================== basic analysis variables [BA]                    participantID
                trial, ...                     trialID    
                trialAccuracy, ...             accuracy
                proportionMat(propCond,:), ... the full proportion
                baseEncoding, ...              comparisonTask
                redundancyCond, ...            if the groups are redundantly encoded
                responseTime, ...              response time
                setSize, ...                   setSize
                percentProp1, ...              correctRatio
                responseRatio, ...             participant's response
                responsePixels, ...         %  participant's response (raw, in pixel form)                
                prop1Col, ... %======================== stimulus properties variables [SP]                 color of first group
                prop2Col, ...                  color of second group
                prop1Shape,...                 shape of first group
                prop2Shape,...                 shape of second group
                shapeOrder,...                 string representing order of presentation
                iconWidth, ...                 how many pixels in diameter is a dot
                iconWidth_dva, ...             how many degrees of visual angle in diameter is a dot (allows us to calculate visual angle for other elements in pixels too) 
                presentationLocation, ...   %  on which part of the screen was the array presented?
                stimOn, ...   %======================== stimulus timing details [TD]   stimulus onset
                maskOn, ...                    mask onset
                maskOff, ...                   mask offset
                responseOnset, ...             response phase onset
                responseOffset, ...            response phase offset
                testIfTimeUp, ...              time elapsed in minutes
                ITI_secs, ...                  intertrial interval seconds
                arrayDur, ...                  stimulus presentation duration
                maskDur, ...                %  mask duration
                whoAmIFile)                 %  folder name    
            
  
        end %trial
        
        
        
    end %block
    
    
    sca;
    ShowCursor()
    fclose('all');
    
catch % In event of error
    % This "catch" section executes in case of an error in the "try"
    % section above.
    sca;
    ShowCursor()
    fclose('all');
    psychrethrow(psychlasterror);
end
