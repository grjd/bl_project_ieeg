function []  = anovatesthypnosis(patidx, eegcond)
%% anovatesthypnosis relative power per band for one patient and one condition
% at a time
%INPUT: patidx= 1...5, eegcond = 'HYP', 'ECPRE' ...
%E.g. (TWH028) patidx = 2; eegcond = 'HYP' anovatesthypnosis(patidx, eegcond)

total_channel_list_labels = {'LHD1','LHD2','LHD3', 'LHD4', 'LAT1','LAT2'...
    ,'LAT3','LAT4', 'LMT1','LMT2', 'LMT3','LMT4','LPT1' ,'LPT2','LPT3','LPT4','LPT5','LPT6','RHD1'...
    ,'RHD2','RHD3','RHD4','RAT1','RAT2','RAT3','RAT4','RMT1','RMT2','RMT3', 'RMT4','RPT1','RPT2'...
    ,'RPT3','RPT4','RPT5','RPT6'};
dirlist = {'D:\BIAL PROJECT\patients\TWH027\data','D:\BIAL PROJECT\patients\TWH028\data','D:\BIAL PROJECT\patients\TWH030\data','D:\BIAL PROJECT\patients\TWH033\data','D:\BIAL PROJECT\patients\TWH034\data'};
matfilelist = {'EEG_cut_BL_HYP_bs27_10222015_s2.mat', 'EEG_cut_BL_HYP_cj28_10202015_s1.mat','EEG_cut_BL_HYP_was30_11172015_s1.mat', 'EEG_cut_BL_HYP_nk33_02032016_s1.mat','EEG_cut_BL_HYP_mj34_02092016_s2.mat'};
freq_bands = {'\delta'; '\theta'; '\alpha'; '\beta'; '\gamma'};
num_bands = 5;
% Labels concident with TMPBMP
%       patient 1 = 36/36
%       patient 2 = 0/88
%       patient 3 = 34/36
%       patient 4 = 36/82
%       patient 5 = 16/108

%patientlist = {'TWH027', 'TWH028','TWH030','TWH031', 'TWH033', 'TWH034'};
patientlist = {'TWH027','TWH028','TWH030','TWH033', 'TWH034'};
% patidx = 2; %
% eegcond = 'HYP';
listoffrqperband = zeros(size(patientlist,2),[],num_bands);
percentlistoffrqperband  = zeros(size(patientlist,2),[],num_bands);
%for patidx=patienttodisplay:patienttodisplay % size(patientlist,2)
fprintf('Calculating for patient %s relative power vector\n', patientlist{patidx});

myfullname = fullfile(dirlist{patidx}, matfilelist{patidx});
EEG = load(myfullname);
if strcmp(patientlist(patidx),'TWH027') == 1
    mattoload = 'fft_BLHYP_bs27_10222015_s2.mat' ;
    EEG = EEG.EEG_cut_BL_HYP;
elseif strcmp(patientlist(patidx),'TWH028') == 1
    mattoload = 'fft_BLHYP_cj28_10202015_s1.mat';
    EEG = EEG.EEG_cut_BL_HYP;
elseif strcmp(patientlist(patidx),'TWH030') == 1
    mattoload = 'fft_BLHYP_was30_11172015_s1.mat';
    EEG =  EEG.EEG_cut_BL_HYP;
elseif   strcmp(patientlist(patidx),'TWH033') == 1
    mattoload = 'fft_BLHYP_nk33_02032016_s1.mat';
    EEG =  EEG.EEG;
elseif   strcmp(patientlist(patidx),'TWH034') == 1
    mattoload = 'fft_BLHYP_mj34_02092016_s2.mat';
    EEG =  EEG.EEG;
end
channel_labels = {EEG.chanlocs.labels}; %chan2use = channel_labels(irow);
total_chan = size(channel_labels,2);
%listoffrqperband = zeros(size(patientlist,2),total_chan,num_bands);
%percentlistoffrqperband  = zeros(size(patientlist,2),total_chan,num_bands);
fftfile = fullfile(dirlist{patidx},'figures', mattoload);
load(fftfile);
listoflabelsfound = [];
for bandidx=1:num_bands
    fprintf('Calculating for %s band relative power vector\n', freq_bands{bandidx})
    %load eeg to get chan_labels
    bitmpcounter = 0; %counts how many electrodes arelabeled as bi temp
    for chidx=2:EEG.nbchan 
        indexlabel = getnameidx(total_channel_list_labels,channel_labels(chidx));
        if indexlabel > 0
            listoffrqperband(patidx,chidx-1,bandidx) = requested_frequences_power_bnds(indexlabel,bandidx);
            bitmpcounter = bitmpcounter + 1;
            listoflabelsfound =[listoflabelsfound channel_labels(chidx)];
        else
            fprintf('Thats too bad, patient:%s has not typical bi temp config, we show what she has ch:%d\n',patientlist{patidx}, chidx);
            listoffrqperband(patidx,chidx-1,bandidx) = requested_frequences_power_bnds(chidx-1,bandidx);
        end
    end
    fprintf('Number of bitemp labeled channels is :%d, patient%d\n',bitmpcounter,patidx);
    disp(listoflabelsfound)
end
%end
%calculate vecotr of %per channel
%for patidx =patienttodisplay:patienttodisplay
for chidx=2:EEG.nbchan%size(total_channel_list_labels,2)
    for bandidx=1:5
        sumparallbands =sum(listoffrqperband(patidx,chidx-1,1:end));
        elementvalue = listoffrqperband(patidx,chidx-1,bandidx);
        percactualband = elementvalue/sumparallbands;
        percentlistoffrqperband(patidx,chidx-1,bandidx) = percactualband;
        fprintf('Patient:%d Band:%d, Channel:%d is percentlistoffrqperband:%.2f\n',patidx,bandidx,chidx-1,percactualband)
    end
end
%end
%draw the charts per eachptient and condition , 5 charts one for each band
%for patidx =  patienttodisplay:patienttodisplay  %2:2
msgtitle = sprintf('Relative P/Hz per bands, Cond=%s Patient=%s',eegcond,patientlist{patidx});
% adjust the xticklabel with the nb of channels
switch patidx
    case 1
        xlabeljump=5; %36 channels
    case {2,4,5}
        xlabeljump=15; %88 channels
    otherwise
        xlabeljump=5; %36 channels
end
%select to show all channels or only the bi temp channels
% only36bitemp = 0;
% if only36bitemp == 1
%     if patidx ==4
%         for ic=1:36
%             
%         end
%             
%     end
% end
h = figure;
%suptitle(msgtitle);
% - Build title axes and title.
axes( 'Position', [0, 0.95, 1, 0.05] ) ;
set( gca, 'Color', 'None', 'XColor', 'White', 'YColor', 'White' ) ;
text( 0.5, 0.3, msgtitle, 'FontSize', 12', 'FontWeight', 'Bold', ...
    'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' )
xchannel_limit = EEG.nbchan;
subplot(2,3,1)
plot(percentlistoffrqperband(patidx,:,1))
title(freq_bands{1});
set(gca, 'xlim', [1 xchannel_limit],'ylim', [0 1],'XTick',[1:xlabeljump:EEG.nbchan]);
xlabel('Channels'), ylabel('Power/Hz');
grid on ;
subplot(2,3,2)
plot(percentlistoffrqperband(patidx,:,2))
title(freq_bands{2})
set(gca, 'xlim', [1 xchannel_limit],'ylim', [0 1],'XTick',[1:xlabeljump:EEG.nbchan]);
xlabel('Channels'), ylabel('Power/Hz');
grid on ;
subplot(2,3,3)
plot(percentlistoffrqperband(patidx,:,3))
xlabel('Channels'), ylabel('Power/Hz')
set(gca, 'xlim', [1 xchannel_limit],'ylim', [0 1],'XTick',[1:xlabeljump:EEG.nbchan]);
title(freq_bands{3});
grid on ;
subplot(2,3,4)
plot(percentlistoffrqperband(patidx,:,4))
xlabel('Channels'), ylabel('Power/Hz')
set(gca, 'xlim', [1 xchannel_limit],'ylim', [0 0.5],'XTick',[1:xlabeljump:EEG.nbchan] );
title(freq_bands{4});
grid on ;
subplot(2,3,5)
plot(percentlistoffrqperband(patidx,:,5))
xlabel('Channels'), ylabel('Power/Hz')
set(gca, 'xlim', [1 xchannel_limit],'ylim', [0 0.5],'XTick',[1:xlabeljump:EEG.nbchan] );
title(freq_bands{5});
grid on ;
savefigure(myfullname, h,1,'powerrelativeperband')
end