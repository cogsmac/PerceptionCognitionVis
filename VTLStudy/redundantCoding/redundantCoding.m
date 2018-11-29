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
%  Because different machines PsychToolBox stored in different places, that directly will be need to manually coded in prep for data collection.
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
%clear all; % prefer only clearvars, so that PTB is a little faster
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
% sizeOfProportionLevels = size(proportionMat);  % how many proportion levels are there?
sizeProportionMat = size(proportionMat);    
proportionIdx = 1:sizeProportionMat(1);   % prep an indexing vector
nProportionLevels = length(proportionIdx);

% levels of the Redundancy factor
baseEncodingVect = {'shape','color'};     % whether shape or color is used as the redundandy=0 encoding
nBaseEncodingLevels = length(baseEncodingVect);

redundancyVect = [1;0];                   % are group differences redundantly encoded?
nRedundancyLevels = length(redundancyVect);% if base=shape, uses dots and triangles. redundancy adds color.


% full crossing of redundancy x proportion
% [propGrid,redundantGrid] = meshgrid(proportionIdx,redundancyVect,nRedundancyLevels); % note: can use combvec at scale with >2 vectors
% tempReshape=cat(2,propGrid',redundantGrid');
% conditionCrossing=reshape(tempReshape,[],2);               % use index in first column to pull proportion from proportionMat
nConds = nProportionLevels * nBaseEncodingLevels * nRedundancyLevels;                                        

randomizeOrder = 1;
if debugMode == 1
    randomizeOrder = 0;
end


% block/trial content
trialRepsPerBlock = 1; % how many reps per condition
nBlocks = 2;
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

if debugMode
    subID = 9999;  % the debug subject ID will overwrite input to avoid errors
end

% Basic experiment parameters
nMinutes = 50; % maximum duration
trialPerBlock = 50;

%% PsychToolbox
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% keyboard, mouse information
[keyboardIndices, productNames, allInfos] = GetKeyboardIndices;  
[mouseIndices, productNames, allInfo] = GetMouseIndices;
       
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
[windowPtr, screenRect] = Screen('OpenWindow', screenNumber, 0, [], 32, 2);
[width_Win, height_Win]=Screen('WindowSize', windowPtr); % display size in pix
width_Dis=Screen('DisplaySize', screenNumber); % display size in mm
Screen('Close');
%calcualte deg to pix conversion coefficient
deg2pixCoeff=1/(atan(width_Dis/(width_Win*(viewingDistance*10)))*180/pi);

[windowPtr, windowRect] = PsychImaging('OpenWindow', screenNumber, lightGrey); %CMC rect [1 1 1200 750]
Screen('Resolution', windowPtr);
% Get the size of the on screen window
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
ret = RestrictKeysForKbCheck([32 44 40 37 77 88]); % spacebar, return and enter for OSx and PC. only tested on mac


%% new stimulus sizing
iconWidth = iconWidth_dva*deg2pixCoeff;
dotRadius = dotRadius_dva*deg2pixCoeff;


%% directory prep
% make sure we're in the right place in the directory so that stuff saves
% to the proper location
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
                case 'tridot'
                    triIndices = 1:nProp1; dotIndices = nProp1+1:setSize;
                    nDots = length(dotIndices);
                    nTris = length(triIndices);
                case 'dotdot'
                    dotIndices = 1:setSize; triIndices = 0;
                    nDots = length(dotIndices);
                    nTris = 0;
                case 'tritri'
                    triIndices = 1:setSize; dotIndices = 0;
                    nDots = 0;
                    nTris = length(triIndices);
            end

            % locations are top left = 1, top center = 2, top right = 3 ... [todo coerce order in positionRef]
            presentationLocation = randi([1,6],1); % display is in one of six locations
            if presentationLocation <= 3          % eliminate common vertical baseline
                responseLocation = randi([4,6],1);
            else
                responseLocation = randi([1,3],1);
            end
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
            

            %% 5) response
            
            % [todo] create a function to have a participants make their response
            % on a bar
            
            %% 6) collect response
            responseOnset = Screen('Flip', windowPtr);
            % [todo] log response value, response location, response time
            if debugMode==0
                [responseTime, responsePixels, responseRatio] = responsePhase(kbPointer, windowPtr, screenXpixels, screenYpixels);
                % clear screen, collect timing
                Screen('FillRect', windowPtr, backgroundColor);
                responseOffset = Screen('Flip', windowPtr);
            end
            
            %% 7) feedback?
  
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
