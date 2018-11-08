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
%  2) Prepare and show display
%  3) Mask
%  4) Show response display
%  5) Collect response
%  6) Feedback [todo: design decision about how we want to incentivize performance]
%

clear all;
close all;
clearvars;

%% 1) Initialize, assign condition/block info
currFolder = fileparts(which(mfilename)); % find current folder 
addpath(genpath(currFolder));             % add subdirectories
cd(currFolder)                            % move to current folder

proportionMat = [[30, 70];                % proportion of filled-in icons
                 [70, 30];
                 [52, 48];
                 [48, 52];                % [todo] make this an external script to streamline
                 [10, 90];                % [todo] find a proportion value near 50 that works for different set sizes
                 [90, 10]];
             
nProportionLevels = size(proportionMat);  % how many proportion levels are there?
             
proportionIdx = 1:nProportionLevels(1);   % prep an indexing vector
             
redundancyVect = [1;0];                   % are group differences redundantly encoded? 


% full crossing of redundancy x proportion
[propGrid,redundantGrid] = meshgrid(proportionIdx,redundancyVect); % note: can use combvec at scale with >2 vectors
              tempReshape=cat(2,propGrid',redundantGrid');
        conditionCrossing=reshape(tempReshape,[],2);               % use index in first column to pull proportion from proportionMat
        
% presentation order
presentationOrder = randperm(length(conditionCrossing));


%% 2) Participant-level information; prep PsychToolBox presentation info
experimentOpenTime = tic;
sca;  
Screen('Preference', 'SkipSyncTests', 1);
 
% collect demographics 
[demographics, cancelledInput] = demographicsQuestions;