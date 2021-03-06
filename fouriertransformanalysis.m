%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. fouriertransformanalysis() extracts power-freq per one patient-condition for each channel and band
%  OUT:  mat file (fft_%s_%s_%s_%s.mat',eegcond, eegpatient,eegdate,eegsession) and fig files (1 per channel) in figures directory
% 1.1 plotpowerspectrum  display power spectra (powerxfreq) REQ: mat file above
% 1.2 plotspectograme display spectograme (powerxfreqXtime)REQ: mat file above
% 2. powerpercentchannelandband_all(list_of_patientid, list_of_patientcond) compares power-frequency across conditions per same patient or accross patients per one condition
%  Req: Needs the variable 'percentlistoffrqperband' in the fft_%s_%s_%s_%s.mat file
%  OUT: [] (display figure, save manually)
% 3. changecolorpialelectrodes (depicts brain with some values)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% connectivity and correlation %%%%%%%%%%%%%%%%%%
% 4. powerbasedconnectivityall (creates the mat file powerconnectivity_freq_2_HYP_TWH027_10222015_s2 for each freq band which contains the corr. matrix)
%   calls to: powerbasedconnectivity(input_args) create correlation matrix using wavelets
%   creaes the mat file with the corr_matrix powerconnectivity_freq_2_EC_POST_TWH030_11172015_s1.mat
% 5. displaypowerconnectivity (display corr.matrx per subj and band)
%  needs the mat with the corr_matrix  
%6.  graphtheoryanalysis(corrMatrix), generates
%networkmetrics_freq_2_HYP.mat
%calls to [allmetrics] = calculategraphmatrixmetrics(corrmatrix, legend)
% 8. comparecorrelationmatrix  (distance and mean of correlation matrix, display results) 
% 9. testofsignificance  (PCA)
%Updated 12/05/2016  

function [] = fouriertransformanalysis()
%%fouriertransformanalysis, function that extracts power from the time series
%Fourier transform analysis to get power spectra and time frequency spectrum per
%channel using the Fourier Transform
% IN: 
% OUT: mat file with power vectors and figures in figures directory
%% 1. Load epoch and Initialize data
disp('Loading the EEG data....')
global eegpatient;eegpatient = 'TWH033'
global eegcond; eegcond = 'EO_PRE'; 
global eegcondtxt; eegcondtxt ='EO\_PRE'; % for title in chart
fprintf('Loading EEG for patient: %s and condition: %s\n', eegpatient,eegcond);
label = 'All';
[myfullname, EEG, channel_labels,eegdate,eegsession] = initialize_EEG_variables(eegpatient,eegcond);
%patientcond, patientid, patdate, patsession
% get condition, sesssion, patient and date
[eegpathname eegfilename eegextname]= fileparts(myfullname);

%[eegcond, eegpatient,eegdate,eegsession] = getsessionpatient(eegfilename)
%EEG = EEG_study;
times2plot =  dsearchn(EEG.times',[ EEG.times(1) EEG.times(end)]');
trial2plot = EEG.trials;
%[pathstr, subjandcond, matext] = fileparts(myfullname);
% Choose the channel(s) we want to analyze
chani = 2;
chanend = EEG.nbchan;
tot_channels = chanend - chani+1;
figcounter = 1;
hfigures = [];
%scaledlog = 1 10*log(abs(fft(signal))
scaledlog = 0;
disp('Data Loaded OK!');

disp(['Total number of channels=' num2str(EEG.nbchan)]);
% sampling rate
srate = EEG.srate;
disp(['Sampling rate=', num2str(srate)]);
%total seconds of the epoch
tot_seconds = floor(EEG.pnts/srate);
disp(['Total seconds of the session=' num2str(tot_seconds)])
% remaining points beyond tot_seconds
remainingpoints = EEG.pnts - tot_seconds*srate;
%time vector normalized
t = 0:1/srate:(tot_seconds + ((remainingpoints/srate)) );
% end -1 to have samne length as signal
t = t(1:end-1);
% t =horzcat(t,restsecondslist);
n = length(t); % = EEG.pnts
nyquistfreq = srate/2;
% There is one half only of frequencies of fourier coefficients
hz = linspace(0,nyquistfreq,floor(n/2)+1);
%initialize vectors that contain the pwer/amplitude values
ampli_fft = zeros(tot_channels, length(hz));
power_fft = zeros(tot_channels, length(hz));
ampli_mt =  zeros(tot_channels, length(hz)); %MT is multitaper
power_mt = zeros(tot_channels, length(hz));
ampli_onetaper = zeros(tot_channels, length(hz));
total_bands = 5;
requested_frequences_amp_bnds =zeros(tot_channels,total_bands);
requested_frequences_power_bnds=zeros(tot_channels,total_bands);

%vector of channels (0,1) 1 when to display that channel
vectorofchannelsprint = zeros(1,EEG.nbchan);
vectorofchannelsprint(chani:chanend) = 1;

%Techniques used to calculate power spectra
%fftidx = 1 to use fft, much faster
fftidx  = 1;
%multitaper =1, to calculate power spectra with multitaper method
multitaper = 1;
%savefigurespc = 0; when no necesssary to generate figures per channel
savefigurespc = 0;
fprintf('Loop to calculate FFT, for number of channel,  = %d \n', chanend);

% Choose the channel(s) we want to analyze
chani = 2;
chanend = EEG.nbchan;

tot_channels = chanend - chani + 1;
%vector of channels (0,1) 1 when to display that channel
vectorofchannelsprint = zeros(1,EEG.nbchan);
vectorofchannelsprint(chani:chanend) = 1;

for irow =chani:chanend
    figcounter = 1;
    chan2use = channel_labels(irow);
    % avoid broken channels
    [toskip] = interictalspikeschannels(eegpatient, irow-1);
    if toskip == 1
        %if channel broken 
        fprintf('Fund interictal channel!!')
        %signal = EEG.data(1,:,trial2plot);
    end
    signal = EEG.data(irow,:,trial2plot);  
    fprintf('Calculating FFT for channel = %s, channel_id=%d / channel_total=%d ...\n', chan2use{1}, irow-1, chanend-1);
    signalX = zeros(size(signal));
    % fourier time is not the time in seconds but the time normalized
    fouriertime = (0:n)/n;
    fouriertime = fouriertime(1:end-1);
    % discrete fourier Transform
    if fftidx == 1
        %% FFT fft(X) computes the discrete Fourier transform (DFT) of X using a fast Fourier transform (FFT) algorithm.
        if vectorofchannelsprint(irow) == 1
            signalXF = fft(signal)/n;
            msgtitle = sprintf('Cond=%s Channel=%s Patient=%s Date=%s Session=%s',eegcondtxt,chan2use{1},eegpatient,eegdate,eegsession);
            ampli_fft(irow-1,:) = 2*abs(signalXF(1:length(hz)));
            if scaledlog == 1
                ampli_fft = scalebylogarithm(ampli_fft);
            end
            power_fft(irow-1,:) = abs(signalXF(1:length(hz))).^2;
            if scaledlog == 1
                power_fft = scalebylogarithm(power_fft);
            end
        end
    else
        % not fast fourier very inefficient just to see how conceptually
        % works
        for fi = 1:length(signalX)
            csw=exp(-1i*2*pi*(fi-1)*fouriertime);
            signalX(fi) = sum(csw.*signal)/n;
            formatSpec = 'Calculating freq=%d/totalfreqs=%d';
            sprintf(formatSpec, fi, EEG.pnts)
        end
    end
    %%Multitaper method for power spectra
    %multitaper method may be useful in situations of low SNR
    %The multitaper method is an extension of the Fourier transform, in which the Fourier 
    %transform is computed several times, each time tapering the data using a different taper. 
    %The tapers are taken from the "Slepian sequence," in which each taper is orthogonal to each other taper.
    %how much noise to add. It estimates spectral peaks that are wider than the frequencies present in 
    %the original time series (this is called spectral leakage or frequency smearing). 
    %Thus, if isolating closely spaced frequencies is important, the multitaper method may not be a preferable option.
    %noisefactor = 20;

    % calculate power spectra with multitaper method
    multitaper = 1;
    if multitaper == 1
        disp(['Multitaper method to calculate the power spectrum for channel=' num2str(irow)])
        % define Slepian tapers.
        tapers = dpss(n,3)';
        % initialize multitaper power matrix
        mtPow = zeros(floor(n/2)+1,1);
        ampimt = zeros(floor(n/2)+1,1);
        hz = linspace(0,srate/2,floor(n/2)+1);
        % loop through tapers
        for tapi = 1:size(tapers,1)-1 % -1 because the last taper is typically not used
            % scale the taper for interpretable FFT result
            temptaper = tapers(tapi,:)./max(tapers(tapi,:));
            % FFT of tapered data
            x = abs(fft(signal.*temptaper)/n).^2;

            ax = 2*(abs(fft(signal.*temptaper)/n));
            if scaledlog == 1
                x = scalebylogarithm(x);
                ax = scalebylogarithm(ax);
            end
            % add this spectral estimate to the total power estimate
            mtPow = mtPow + x(1:length(hz))';
            ampimt = ampimt + ax(1:length(hz))';
        end
        % power spectra were summed over many tapers,
        % divide by the number of tapers to get the average.
        mtPow = mtPow./tapi;
        ampimt = ampimt./tapi;
        power_mt(irow-1,:) = mtPow;
        ampli_mt(irow-1,:) = ampimt;
        
        % compute the 'normal' power spectra using one taper
        hann   = .5*(1-cos(2*pi*(1:n)/(n-1)));
        x      = abs(fft(signal.*hann)/n).^2;
        axonet = 2*(abs(fft(signal.*hann)/n));
        if scaledlog == 1
            x = scalebylogarithm(x);
            axonet = scalebylogarithm(axonet);
        end
        ampli_onetaper = axonet(1:length(hz));
        regPow = x(1:length(hz)); % regPow = regular power
        
        % plot both power spectra, ome and multi tapper. Note that power is plotted here instead of
        % amplitude because of the amount of noise. Try plotting amplitude by
        % multiplying the FFT result by 2 instead of squaring.
        clf
        msgtitle = sprintf('Cond=%s Channel=%s Patient=%s Date=%s Session=%s',eegcondtxt,chan2use{1},eegpatient,eegdate,eegsession);
    end
    fprintf('Showing chart for patient:%s , condition:%s , channel:%s\n',eegpatient,eegcond,chan2use{1});
    msgtitle = sprintf('Cond=%s Channel=%s Patient=%s Date=%s Session=%s',eegcondtxt,chan2use{1},eegpatient,eegdate,eegsession);
    hfigures(figcounter) = figure;
    subplot(3,1,1)
    plot(t,signal, 'b')
    xlabel('Time (s)'), ylabel('Amplitude')
    set(gca,'xlim',[0 tot_seconds])
    legend({'time series'})
    title(msgtitle)
    subplot(3,1,2)
    plot(hz,power_fft(irow-1,:),'b')
    xlabel('Frequencies (Hz)'), ylabel('Power')
    set(gca,'xlim',[0 50])
    legend({'FFT, Power'})
    subplot(3,1,3)
    plot(hz,mtPow,'.-') %, hold on
    set(gca,'xlim',[0 50])
    xlabel('Frequencies (Hz)'),ylabel('Power')
    legend('Power spectra Multi Taper');
    savefigure(myfullname, hfigures(figcounter),irow-1,'powerperchannel');
    figcounter = figcounter + 1;
    
    %% Extract information about specific frequencies.
    %frequencies vector
    f = 0:50;
    freq_bands = {'\delta'; '\theta'; '\alpha'; '\beta'; '\gamma'};
     %   freq_bands = ['\delta' '\theta' '\alpha' '\beta' '\gamma' ]
    requested_frequences_amp = zeros(size(f,1),size(f,2));
    requested_frequences_power = zeros(size(f,1),size(f,2));
    frex_idx = sort(dsearchn(hz',f'));
    %amplitude for req frequencies vector
    requested_frequences_amp = 2*abs(signalXF(frex_idx));
    if scaledlog == 1
        requested_frequences_amp = scalebylogarithm(requested_frequences_amp);
    end
    requested_frequences_amp_bnds(irow-1,1) = mean(requested_frequences_amp(1:4));
    requested_frequences_amp_bnds(irow-1,2) = mean(requested_frequences_amp(5:8));
    requested_frequences_amp_bnds(irow-1,3) = mean(requested_frequences_amp(9:13));
    requested_frequences_amp_bnds(irow-1,4) = mean(requested_frequences_amp(14:30));
    requested_frequences_amp_bnds(irow-1,5) = mean(requested_frequences_amp(31:end));
    %poweer for req frequencies vector
    requested_frequences_power = abs(signalXF(frex_idx)).^2;
    if scaledlog == 1
        requested_frequences_power = scalebylogarithm(requested_frequences_power);
    end
    requested_frequences_power_bnds(irow-1,1) = mean(requested_frequences_power(1:4));
    requested_frequences_power_bnds(irow-1,2) = mean(requested_frequences_power(5:8));
    requested_frequences_power_bnds(irow-1,3) = mean(requested_frequences_power(9:13));
    requested_frequences_power_bnds(irow-1,4) = mean(requested_frequences_power(14:30));
    requested_frequences_power_bnds(irow-1,5) = mean(requested_frequences_power(31:end));
    %clf
    hfigures(figcounter) = figure;
    set(hfigures(figcounter), 'Visible','on')
%     subplot(3,1,1)
%     bar(requested_frequences_amp_bnds)
%     xlabel('Frequency Bands'), ylabel('Amplitude')
%     set(gca, 'XTickLabel',freq_bands)
    msgtitle = sprintf('Cond=%s Channel=%s Patient=%s Date=%s Session=%s',eegcondtxt,chan2use{1},eegpatient,eegdate,eegsession);
    subplot(2,1,1);
    bar(requested_frequences_power_bnds(irow-1,:))
    xlabel('Frequency Bands'), ylabel('Power')
    set(gca, 'XTickLabel',freq_bands);
    title(msgtitle);
    subplot(2,1,2)
    bar(requested_frequences_power)
    xlabel('Frequencies (Hz)'), ylabel('Power')
    %set(gca,'xtick',1:length(frex_idx),'xticklabel',cellstr(num2str(round(hz(frex_idx))')))
    % %hold on
    x1 = 4.5;
    x2 = 8.5;
    x3 = 12.5;
    x4 = 40.5;

    y1=get(gca,'ylim');
    set(gca, 'xlim',[1:5])
    hold on
    plot([x1 x1],y1)
    plot([x2 x2],y1)
    plot([x3 x3],y1)
    plot([x4 x4],y1)

    savefigure(myfullname, hfigures(figcounter),irow-1, 'barfreqonechannel');
    figcounter = figcounter + 1;

end
% save chart with power per band
figcounter = 1;
hfigures(figcounter) = figure;
% trasp(bands, channels)
traspreqf = requested_frequences_power_bnds'; 
frqperband = [];
totpower = 0;
for k =1:5 
    frqperband(k,:) = mean(traspreqf(k,:));
end
%normalize the frq band
totpower = sum(frqperband);
bar(frqperband);
bar(frqperband/totpower);
xlabel('Frequency Bands'), ylabel('Power')
set(gca, 'XTickLabel',freq_bands, 'YLim', [0 1])
msgtitle = sprintf('Mean Power per Band, Condition=%s, Patient=%s',eegcondtxt, eegpatient);           
title(msgtitle);
savefigure(myfullname, hfigures(figcounter),figcounter,'barfreqonecondition');
figcounter = figcounter +1 ;

%build vector of maxima channel value
fprintf('Saving chart A/P for all channels...\n');
nbofmaxchtodisp = 6;

hfigures(figcounter) = figure;
label_quantitytomeasure = 'mean' % mean, max, median ;
fprintf('Calculating power across channels using the %s\n',label_quantitytomeasure);
[leg,quantitytomeasure] = calculatelegfootnote(channel_labels,ampli_fft,label_quantitytomeasure,nbofmaxchtodisp,tot_channels);
bar([1:tot_channels], quantitytomeasure);
xlabel({[leg{1} ',' leg{2}],[leg{3} ',' leg{4}], [leg{5} ',' leg{6}]}),ylabel('Amplitude')
set(gca,'xlim',[1 tot_channels])
msgtitle = sprintf('Cond=%s Patient=%s Date=%s Session=%s',eegcondtxt,eegpatient,eegdate,eegsession);           
title(msgtitle);
filefigname = sprintf('fft_Amplitude_AllCh_%s_%s_%s_%s.fig',eegcond, eegpatient,eegdate,eegsession);
tic;fprintf('Saving %s ...',filefigname);
savefig(hfigures(figcounter),filefigname);
figcounter = figcounter +1;

hfigures(figcounter) = figure;
[leg,quantitytomeasure] = calculatelegfootnote(channel_labels,power_fft,label_quantitytomeasure,nbofmaxchtodisp,tot_channels);
bar([1:tot_channels], quantitytomeasure)
xlabel({[leg{1} ',' leg{2}],[leg{3} ',' leg{4}], [leg{5} ',' leg{6}]}),ylabel('Power')
set(gca,'xlim',[1 tot_channels])
msgtitle = sprintf('Cond=%s Patient=%s Date=%s Session=%s',eegcondtxt,eegpatient,eegdate,eegsession);           
title(msgtitle);
filefigname = sprintf('fft_Power_AllCh_%s_%s_%s_%s.fig',eegcond, eegpatient,eegdate,eegsession);
tic;fprintf('Saving %s ...',filefigname);
savefig(hfigures(figcounter),filefigname);
figcounter = figcounter +1;

hfigures(figcounter) = figure;
[leg,quantitytomeasure] = calculatelegfootnote(channel_labels,power_mt,label_quantitytomeasure,nbofmaxchtodisp,tot_channels);
bar([1:tot_channels], quantitytomeasure)
xlabel({[leg{1} ',' leg{2}],[leg{3} ',' leg{4}], [leg{5} ',' leg{6}]}),ylabel('Power')
set(gca,'xlim',[1 tot_channels])
msgtitle = sprintf('Cond=%s Patient=%s Date=%s Session=%s',eegcondtxt,eegpatient,eegdate,eegsession);           
title(msgtitle);
filefigname = sprintf('fft_Power_MT_AllCh_%s_%s_%s_%s.fig',eegcond, eegpatient,eegdate,eegsession);
tic;fprintf('Saving %s ...',filefigname);
savefig(hfigures(figcounter),filefigname);

%save mat file
currentFolder = pwd;
tic; fprintf('Saving the mat file with power/amplitude vector in %s \n',currentFolder);
filematname = sprintf('fft_%s_%s_%s_%s.mat',eegcond, eegpatient,eegdate,eegsession);
save(filematname, 'frqperband', 'quantitytomeasure', 'ampli_fft','power_fft','power_mt','requested_frequences_power_bnds', 'channel_labels');toc;

%%%% Calculate power per channel and band
fprintf('Calling to powerpercentchannelandband : %s %s', eegpatient,eegcond);

powerpercentchannelandband(eegpatient,eegcond, EEG, label);
fprintf('.mat file crreated at %s', filematname)

end

function [leg,quantitytomeasure] = calculatelegfootnote(channel_labels,fft_coefs,label_quantitytomeasure,nbofmaxchtodisp,tot_channels)
%% [leg,quantitytomeasure] = calculatelegfootnote(channel_labels,fft_coefs,label_quantitytomeasure,nbofmaxchtodisp,tot_channels)
%makes the footnote with the "nbofmaxchtodisp" channels with largest power
%for the fft_[Power_MT|Powe|Amplitude]_AllCh_patient files 
%when 
%Input: channel_labels,fft_coefs,label_quantitytomeasure,nbofmaxchtodisp,tot_channels
%Output: leg: footnote text, quantitytomeasure: quantity to display ,
%label_quantitytomeasure, for example the mean of the power, or the median
quantitytomeasure = zeros(tot_channels,1);
for irow =2:tot_channels+1
    if strcmp(label_quantitytomeasure, 'max') 
        quantitytomeasure(irow-1,1) = max(fft_coefs(irow-1,:));
    elseif  strcmp(label_quantitytomeasure, 'mean') 
        quantitytomeasure(irow-1,1) = mean(fft_coefs(irow-1,:));
    elseif strcmp(label_quantitytomeasure, 'median')
        quantitytomeasure(irow-1,1) = median(fft_coefs(irow-1,:));
    else
        error('quantity to meaasure unknown, choose between max/mean/median');
        leg = [];
        break;
    end
end
fprintf('Calculating based on the %s',quantitytomeasure);
[sortedValues,sortIndex] = sort(quantitytomeasure,'descend');  % Sort the values indescending order
maxIndex = sortIndex(1:nbofmaxchtodisp);  %# Get a linear index into A of the 5 largest values
for i=1:nbofmaxchtodisp
   mesg = sprintf('Ch=%d, Id=%s Ampl=%.2f',maxIndex(i), channel_labels{maxIndex(i)+1} ,quantitytomeasure(maxIndex(i),1));
    leg{i} = mesg;
end
end


function [toskip] = interictalspikeschannels(patient, irow)
%% return 1 is the channel irow of patient is a channel with interictal spikes
toskip = 0;
if (strcmp(patient, 'TWH034') ==1 && (irow == 68)) ||  (strcmp(patient, 'TWH030') == 1 && (irow == 8)) || (strcmp(patient, 'TWH031') ==1 && (irow == 17) )
    %LHD4$ , irow = 68 (twh34)
    %LAT4, irow = 8  (twh30)
    %LMF5, irow = 17 (twh031)
    fprintf('Broken channel number %d, patient: %s\n', irow, patient);
    toskip = 1;   
end
end

function [scaledsignal] = scalebylogarithm(signal)
%% scalebylogarithm scaledsignal = 10*log10(signal)
    scaledsignal = 10*log(signal);
    a = 0;
end