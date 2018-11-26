%  This is the high level script that calls all required functions to run
%  the redundantCoding study. 
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
%  Additional Scripts Used: demographicsQuestions.m
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
clear all;
close all;
clearvars;

%% 1) Initialize, assign condition/block info

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
                 [10, 90];                % [todo] find a proportion value near 50 that works for different set sizes
                 [90, 10]];
             
nProportionLevels = size(proportionMat);  % how many proportion levels are there?
             
proportionIdx = 1:nProportionLevels(1);   % prep an indexing vector

% levels of the Redundancy factor
redundancyVect = [1;0];                   % are group differences redundantly encoded? 


% full crossing of redundancy x proportion
[propGrid,redundantGrid] = meshgrid(proportionIdx,redundancyVect); % note: can use combvec at scale with >2 vectors
              tempReshape=cat(2,propGrid',redundantGrid');
        conditionCrossing=reshape(tempReshape,[],2);               % use index in first column to pull proportion from proportionMat
        
% presentation order
presentationOrder = randperm(length(conditionCrossing));


%% 2) Participant-level information; prep PsychToolBox presentation info
experimentOpenTime = tic;

% Clear the workspace and the screen
sca;
close all;

debugMode = 0; % toggle to 1 for development

if debugMode
    subID = 1; %#ok<UNRCH> % the debug subject ID will overwrite input to avoid errors
end

% Basic experiment parameters
nMinutes = 50; % maximum duration
trialPerBlock = 50;

%% PsychToolbox
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% keyboard, mouse information
[keyboardIndices, productNames, allInfos] = GetKeyboardIndices;  %#ok<*ASGLU>
[mouseIndices, productNames, allInfo] = GetMouseIndices;

kbPointer = keyboardIndices(end);  %#ok<*NASGU>
mousePntr = mouseIndices(end);

KbName('UnifyKeyNames');

% Get the screen numbers
screens = Screen('Screens');
Screen('Preference', 'SkipSyncTests', 1)

% Draw to the external screen if avaliable
screenNumber = min(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
lightGrey = [.75 .75 .75];

experimentOpenTime = tic; testIfTimeUp = 0;

% Open an on screen window
[windowPtr, windowRect] = PsychImaging('OpenWindow', screenNumber, lightGrey, [1 1 1200 750]);
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

    % [todo] 3-7 this needs to be within an nTrials for loop or an nMinutes
    % while loop
    
    %% 3) Prepare and show display
    
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
    
    % [todo] create a function to draw n=setSize shapes in the specified
    % area
    
    % [todo] show display
    
    %% 4) mask
    
    % [todo] mask the display
    
    %% 5) response
    
    % [todo] create a function to have a participants make their response
    % on a bar 
    
    %% 6) collect response
    responseOnset = Screen('Flip', windowPtr)
    % [todo] log response value, response location, response time 
    [responseTime, responsePixels, responseRatio] = responsePhase(kbPointer, windowPtr, screenXpixels, screenYpixels);
    
    % clear screen, collect timing 
    Screen('FillRect', windowPtr, [.5 .5 .5]);
    responseOffset = Screen('Flip', windowPtr);
    
    %% 7) feedback? 
catch %#ok<*CTCH> In event of error
    % This "catch" section executes in case of an error in the "try"
    % section above.  
    sca;
    ShowCursor()
    fclose('all');
    psychrethrow(psychlasterror);
end