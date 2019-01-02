function [doaEst, delayEst] = fChannelEstimation(array, symbolsOut, goldSeq, nPaths)
% Function:
%   - perform channel estimation for the desired source using the received
%  signal
%
% InputArg(s):
%   - array: array locations in half unit wavelength. If no array then
%  should be [0,0,0]
%   - symbolsOut: channel symbol chips received
%   - goldSeq: gold sequence used in the modulation process
%   - nPaths: number of paths for each source
%
% OutputArg(s):
%   - doaEst: estimated direction of arrival of the signal paths
%   - delayEst: estimated delay of the signal paths
%
% Comments:
%   - number of paths for each source should be known
%
% Author & Date: Yang (i@snowztail.com) - 21 Dec 18

%% Initialisation
% obtain the maximum possible relative delay and number of signals
[nDelays, nSignals] = size(goldSeq);
% chip length
nChips = length(goldSeq);
% number of receiving antennas
nAnts = length(array);
% Fourier transformation vector
ftVect = zeros(2 * nChips, 1);
% Fourier transformation matrix
ftMatrix = zeros(2 * nChips);
% estimated DOA of each signal
doaEst = cell(nSignals, 1);
% estimated delay of each signal
delayEst = cell(nSignals, 1);
% data vectorisation
[symbolsMatrix] = data_vectorisation(symbolsOut, nAnts, nChips);
% number of samples
nSamples = size(symbolsMatrix, 2);
% extend the gold sequence by padding zeros to double length
goldSeqExtend = [goldSeq; zeros(size(goldSeq))];
% Fourier transformation constant
ftConst = exp(-1i * pi / nChips);
% construct Fourier transformation vector with ft constant
for iPos = 1: 2 * nChips
    ftVect(iPos) = ftConst ^ (iPos - 1);
end
% construct Fourier transformation matrix with ft vector
for iPos = 1: 2 * nChips
    ftMatrix(:, iPos) = ftVect .^ (iPos - 1);
end
%% delay and doa estimation
for iSignal = 1: nSignals
    % overall transformation matrix for certain signal
    tfMatrix = kron(eye(nAnts), diag(ftMatrix * goldSeqExtend(:, iSignal)) \  ftMatrix);
    % transformed signal
    tfSignal = tfMatrix * symbolsMatrix;
    % covariance matrix of transformed signal
    covTfSignal = tfSignal * tfSignal' / size(tfSignal, 2);
    % number of submatrices of spatial smoothing
    nSubMats = nPaths(iSignal);
    nSubMats = 2;
    % number of space-time subvectors
    nSubVects = nPaths(iSignal);
    % length of space-time subvectors (d + Q - 1 <= 2 * Nc)
    lenSubVect = 2 * nChips - 1 - nSubVects;
    % obtain Fourier transformation subvector
    ftSubVect = ftVect(1: lenSubVect);
    % first perform spatial smoothing for signal
    [tfSignalSpatial] = spatial_smoothing(nSubMats, nAnts, covTfSignal);
    tfSignalSpatial = covTfSignal;
    % then temporal smoothing
    [tfSignalSmooth] = temporal_smoothing(nSubVects, lenSubVect, nChips, tfSignalSpatial);
%     [tfSignalSmooth] = temporal_smoothing(nSubVects, lenSubVect, nAnts - nSubMats + 1, nChips, tfSignalSpatial);
    
    % first perform temporal smoothing for transformation
    tfMatrixTemporal = temporal_smoothing(nSubVects, lenSubVect, nChips, diag(diag(tfMatrix * tfMatrix')));
%     [tfMatrixTemporal] = temporal_smoothing(nSubVects, lenSubVect, nAnts, nChips, tfMatrix * tfMatrix');
    % then spatial smoothing
    [tfMatrixSmooth] = spatial_smoothing(nSubMats, nAnts, tfMatrixTemporal);
    tfMatrixSmooth = tfMatrixTemporal;
%     [tfMatrixSpatial] = spatial_smoothing(nSubMats, nAnts, tfMatrix * tfMatrix');
%     [tfMatrixSmooth] = temporal_smoothing(nSubVects, lenSubVect, nAnts - nSubMats + 1, nChips, tfMatrixSpatial);

%     [nSourcesAic] = detector_aic(nSamples, tfSignalSmooth, tfMatrixSmooth);
    [nSourcesMdl] = detector_mdl(nSamples, tfSignalSmooth);
    [doaEst{iSignal}, delayEst{iSignal}] = music(array, tfSignalSmooth, tfMatrixSmooth, nSourcesMdl, ftSubVect, nDelays, nAnts, nSubMats, nPaths(iSignal));
end
% store the estimations in matrices as required
doaEst = [cell2mat(doaEst)', zeros(length(cell2mat(doaEst)), 1)];
delayEst = cell2mat(delayEst)';
% set the invalid estimation as zero
delayEst(delayEst < 0) = 0;
end
