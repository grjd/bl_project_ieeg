function [quantitytomeasure,frqperband ] = loadconditionpowerdata(myfullname,patientid,condition)
%% load power data , mat file, containing the variable for a specific condition
% a patient
fprintf('Calling loadconditionpowerdata function, patient%s, %condition..\n',patientid,condition)
fprintf('Cleaning workspace..\n')
patientdir = 'D:\BIAL PROJECT\patients\'
fpatientpower = fullfile(patientdir,patientid)
fpatientpowerdata = fullfile(fpatientpower,'data')
fpatientpowerdatafig = fullfile(fpatientpowerdata,'figures')
if strcmp(patientid, 'TWH030') ==1
    if strcmp('HYP',condition) == 1
        %must change for different sessions
        matfileh = 'fft_BLHYP_was30_11172015_s1.mat';
        fileh = fullfile(fpatientpowerdatafig,matfileh);
    elseif strcmp('ECPRE',condition) == 1
        matfileh = 'fft_BLECPRE_was30_11172015_s1.mat';
        fileh = fullfile(fpatientpowerdatafig,matfileh);
    elseif strcmp('EOPRE',condition) == 1
        matfileh = 'fft_BLEOPRE_was30_11172015_s1.mat';
        fileh = fullfile(fpatientpowerdatafig,matfileh);
    elseif strcmp('ECPOST',condition) == 1
        matfileh = 'fft_BLECPOST_was30_11172015_s1.mat';
        fileh = fullfile(fpatientpowerdatafig,matfileh);
    end
elseif strcmp(patientid, 'TWH033') ==1
    if strcmp('HYP',condition) == 1
        %must change for different sessions
        matfileh = 'fft_BLHYP_nk33_02032016_s1.mat';
        fileh = fullfile(fpatientpowerdatafig,matfileh);
    elseif strcmp('ECPRE',condition) == 1
        matfileh = 'fft_BLECPRE_nk33_02032016_s1.mat';
        fileh = fullfile(fpatientpowerdatafig,matfileh);
    elseif strcmp('EOPRE',condition) == 1
        matfileh = 'fft_BLEOPRE_nk33_02032016_s1.mat';
        fileh = fullfile(fpatientpowerdatafig,matfileh);
    elseif strcmp('ECPOST',condition) == 1
        matfileh = 'fft_BLECPOST_nk33_02032016_s1.mat';
        fileh = fullfile(fpatientpowerdatafig,matfileh);
    elseif strcmp('EOPOST',condition) == 1
        matfileh = 'fft_BLEOPOST_nk33_02032016_s1.mat';
        fileh = fullfile(fpatientpowerdatafig,matfileh);
    end
elseif strcmp(patientid, 'TWH027') ==1
    matfileh = 'fft_BLHYP_bs27_10222015_s2.mat';
    fileh = fullfile(fpatientpowerdatafig,matfileh);
elseif strcmp(patientid, 'TWH028') ==1
    if strcmp('HYP',condition) == 1
        matfileh = 'fft_BLHYP_cj28_10202015_s1.mat';
        fileh = fullfile(fpatientpowerdatafig,matfileh);
    end
elseif strcmp(patientid, 'TWH034') ==1
    matfileh = 'fft_BLHYP_mj34_02092016_s2.mat';
    fileh = fullfile(fpatientpowerdatafig,matfileh);
else
    error('Error in loadconditionpowerdata, couldnt find patient:%s', patientid);
end
fprintf('Loading in memory file %s:\n',fileh);
load(fileh,'quantitytomeasure','frqperband');
fprintf('Done');

end