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
  
% collect demographics 
[demographics, cancelledInput] = demographicsQuestions;

% prepare this participants' unique directory to store every variable as a
% .mat backup. The subject number is the unique time from the OS via GetSecs
                        timeIDDir = num2str(GetSecs);
timeIDDir(strfind(timeIDDir, '.'))='_';
mkdir(timeIDDir)                  % create folder
addpath(timeIDDir)                % add that new folder to the path

%% PsychToolbox
Screen('Preference', 'SkipSyncTests', 1); 

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% coerce input option to the external keyboad if there are multiple
% options (if you're on the macbook)
[keyboardIndices, productNames, allInfos] = GetKeyboardIndices;
kbPointer = keyboardIndices(end);

global psych_default_colormode;
psych_default_colormode = 1;

% open first window
[windowPtr, windowPtrRect] = Screen('OpenWindow', screenNumber, bkgnCol(1)*255); % open a screen

% Unify keycode to keyname mapping across operating systems:
KbName('UnifyKeyNames');
Screen('TextFont', windowPtr, 'Arial')

Screen('TextSize', windowPtr, textSize);

     textSize = 14;
    screenDim = get(screenNumber,'screensize');             % note: 0,0 is the top left corner of the screen
screenXpixels = screenDim(3); screenYpixels = screenDim(4); % max screen size (should be resolution of your computer)
       bgArea = screenDim;                                  % This sets the coordinate space of the screen window, WHICH MAY HAVE A DIFFERENT SIZE

       
% in the non-redundant condition; luminance is the only difference between
% categories. [todo: think about luminiance norming?]
    foreGrndD = (bkgnCol./4)*255; % 4x as bright as background [todo: this is backward? confirm color representation on active OS]
    foreGrndL = (bkgnCol*2)*255; % twice as dark as background


try % the whole experiment is in a try/catch

    % [todo] 3-7 this needs to be within an nTrials for loop or an nMinutes
    % while loop
    
    %% 3) Prepare and show display
    
    % locations are top left = 1, top center = 2, top right = 3 ... [todo coerce order in positionRef]
    presentationLocation = rand([1,6],1); % display is in one of six locations
    
    if presentationLocation <= 3          % eliminate common vertical baseline
        responseLocation = rand([4,6],1);
    else
        responseLocation = rand([1,3],1);
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
    
    % [todo] log response value, response location, response time 
    
    %% 7) feedback? 
catch %#ok<*CTCH> In event of error
    % This "catch" section executes in case of an error in the "try"
    % section above.  
    sca;
    ShowCursor()
    fclose('all');
    psychrethrow(psychlasterror);
end