function [demoResp, cancelledInput]= demographicsQuestions

%  This is a way to get some information at the start of the experiment
%  from the participant.
%
%  Author: C. M. McColeman
%  Date Created: September 9 2016
%  Last Edit:    November 8 2018 
%
%  Cognitive Science Lab, Simon Fraser University
%  Originally Created For: 6ix. Big overhaul for the Perception, Priors and
%                          Cognition Project in the Visual Thinking Lab, Northwestern University. 
%
%  Reviewed: Ruilin & David [Sept 25 2016]
%  Verified: []
%
%  INPUT: User-provided input: gender, whether they're colourblind, their econ
%  experience, their math experience.
%
%  OUTPUT: 
%
%  Additional Scripts Used: Requires inputsdlg
%  (http://www.mathworks.com/matlabcentral/fileexchange/25862-inputsdlg--enhanced-input-dialog-box)
%
%  Additional Comments: Inspired by http://blogs.mathworks.com/pick/2009/12/25/input-dialog-box-on-steroids/
%
%  [todo]: update with more approrpriate questions for the present study 

prompt = {'What is the number of the computer you are using?'; 'Are you on a Mac or PC?';'Please indicate your gender';'Are you colour blind?';'Have you studied economics?';'Have you studied math or statistics since high school?'};
name = 'Welcome to the experiment. Please fill out the following to get started.';

formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

formats(1,1).type   = 'edit';
formats(1,1).format = 'integer';
formats(1,1).limits = [1 50];

formats(2,1).type   = 'list';
formats(2,1).style  = 'popupmenu';
formats(2,1).items  = {'PC', 'iMac', 'MacBook'};

formats(3,1).type   = 'list';
formats(3,1).style  = 'popupmenu';
formats(3,1).items  = {'Select one','Female', 'Male', 'Other', 'Prefer not to answer'};

formats(4,1).type   = 'list';
formats(4,1).style  = 'popupmenu';
formats(4,1).items  = {'Select one','Yes', 'No', 'I do not know', 'Prefer not to answer'};

formats(5,1).type   = 'list';
formats(5,1).style  = 'popupmenu';
formats(5,1).items  = {'Select one','No, never', 'No, but I know a bit about it', 'No, but I know a lot about it', 'Yes, I have had one economics class', 'Yes, I have taken more than once class', 'Prefer not to answer'};

formats(6,1).type   = 'list';
formats(6,1).style  = 'popupmenu';
formats(6,1).items  = {'Select one','No, never', 'No, but I know a bit about it', 'No, but I know a lot about it', 'Yes, I have had one math or stats class', 'Yes, I have taken more than once math or stats class', 'Prefer not to answer'};

defaultanswer = {1,1,1,1,1,1};
finished = 0;
while finished == 0
    finished = 1;
    [demoResp, cancelledInput]= inputsdlg(prompt, name, formats, defaultanswer);
    if ~cancelledInput % added after review when I realized we were trapped in having to complete this -CM [Oct. 9 2016]
        for i = 3:6 % changed from '2' because I want default to be '2' and not force selection re: PC/Mac -CM [9/27/2016]
            
            defaultanswer{i} = demoResp{i,1};
            if demoResp{i,1} == 1 && finished == 1
                finished = 0;
                waitfor(msgbox('Please fill in all the fields'));
            end
        end
    end
end

clearvars finished;
