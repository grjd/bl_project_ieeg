function [myfullname, EEG, channel_labels] =  initialize_EEG_variables()
%% initialize_EEG_variables  load mat file and initialize EEG lab variables .
%   [myfullname, EEG_study, channel_labels] = initialize_EEG_variables()
%Output: myfullname:full path of the mat file with the signal
%EEG: the struct created by EEGLAB, channel_labels:label of the channels
clear all;
patientid= 'TWH034';
patientcond = 'HYP';
[mydir, myfile] = getfullpathfrompatient(patientid,patientcond);
myfullname = fullfile(mydir, myfile);
disp('Loading mat file...')
EEG = load(myfullname);
if isstruct(EEG) == 1
    if (strcmp(mydir, 'D:\BIAL PROJECT\patients\TWH033\data') + strcmp(mydir, 'D:\BIAL PROJECT\patients\TWH034\data') + strcmp(mydir, 'D:\BIAL PROJECT\patients\TWH024\data')) == 1
        EEG = EEG.EEG
    elseif (strcmp(mydir, 'D:\BIAL PROJECT\patients\TWH030\data') + strcmp(mydir, 'D:\BIAL PROJECT\patients\TWH027\data') + strcmp(mydir, 'D:\BIAL PROJECT\patients\TWH028\data')+ strcmp(mydir, 'D:\BIAL PROJECT\patients\TWH031\data')) == 1
        EEG = EEG.EEG_cut_BL_HYP
        %EEG = EEG.EEG_cut_BL_EC_PRE
        %EEG = EEG.EEG_cut_BL_EO_PRE
        %EEG = EEG.EEG_cut_BL_EC_POST
    end
end
disp(['File ' myfile ' loaded!' ])
channel_labels = {EEG.chanlocs.labels};
disp([ 'Displaying the label of all the channels....' ])
initchan = 2 % channel 1 is the null Event channel
for i=initchan:EEG.nbchan
    disp(['Index ' i ' is the channel' channel_labels(i)])
end
end

function [patdir, patfile] = getfullpathfrompatient(patientid, patientcond)
%% [patdir, patfile] = getfullpathfrompatient(patientid, patientcond)
% returns the path and the file name of the mat file for that patient and
% condition
%Input: patientid 'TWH030' patientcond 'HYP'
%Output: patdir, patfile
patdir1 = 'D:\BIAL PROJECT\patients\';
patdir = strcat(patientid, '\data');
patdir = fullfile(patdir1, patdir);
patsession = 's1'; %by default session is s1
switch patientid
    case 'TWH024'
        if strcmp(patientcond,'HYP') == 1
            patname = 'fo24';
            patdate = '09192015';
        else
        end
    case 'TWH027'
        if strcmp(patientcond,'HYP') == 1
            patname = 'bs27';
            patdate = '10222015';
            patsession = 's2';
        else
        end
    case 'TWH028'
        if strcmp(patientcond,'HYP') == 1
            patname = 'cj28';
            patdate = '10202015';
        else
        end
    case 'TWH030'
        if strcmp(patientcond,'HYP') == 1
            patname = 'was30';
            patdate = '11172015';
        else
        end
    case 'TWH031'
        if strcmp(patientcond,'HYP') == 1
            patname = 'sm31';
            patdate = '12012015';
        else
        end
    case 'TWH033'
        if strcmp(patientcond,'HYP') == 1
            patname = 'nk33';
            patdate = '02032016';
        else
        end
    case 'TWH034'
        if strcmp(patientcond,'HYP') == 1
            patname = 'mj34';
            patdate = '02092016';
            patsession ='s2';
        else
        end
    otherwise
        warningMessage = sprintf('Error: patient%s does not exist:\n%s', patientid);
        uiwait(msgbox(warningMessage));
end

patfile1 = 'EEG_cut_BL_';
patfile2 = patientcond;
patfile3 = strcat('_', patname, '_', patdate,'_',patsession, '.mat');
patfile = strcat(patfile1,patfile2,patfile3);

fullFileName =  fullfile(patdir, patfile);

if exist(fullFileName, 'file')
    fprintf('Cool! I have found the mat file:%s, now I will load the EEG struct...',fullFileName);
else
    % File does not exist.
    warningMessage = sprintf('Warning: file does not exist:\n%s', fullFileName);
    uiwait(msgbox(warningMessage));
end
end