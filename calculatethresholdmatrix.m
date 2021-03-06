function [threshold, corrMatrix] = calculatethresholdmatrix(corrMatrix, nstds, thrd)
%calculatethresholdmatrix(corrMatrix) returns the threshold and the
%threshold matrix given a correlation matrix
%IN: corrMatrix [0,1] if [-1,1] the function calculates abs(corrMatrix),
%std and threshold
%OUT: threshold, new threshold matrix
if nargin < 3
    %meanmatrix = mean2(abs(corrMatrix)); stdmatrix = std2(abs(corrMatrix));
    meanmatrix = mean(abs(corrMatrix(:))); stdmatrix = std(abs(corrMatrix(:)));
    threshold = meanmatrix + nstds*stdmatrix;
    fprintf('Corr matrix mean=%2.4f +(n)%d*(std)%2.4f = %2.4f\n', meanmatrix, nstds,stdmatrix, threshold);
else
    %threshold given as an input
    threshold = thrd;
    fprintf('Corr matrix thresold fixed =%.4f\n', threshold);
end
corrMatrix(corrMatrix <= threshold) = 0;
corrMatrix(corrMatrix >  threshold) = 1;
end