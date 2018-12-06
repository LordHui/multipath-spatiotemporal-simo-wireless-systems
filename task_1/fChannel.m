% NAME, GROUP (EE4/MSc), 2010, Imperial College.
% DATE

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Models the channel effects in the system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% paths (Mx1 Integers) = Number of paths for each source in the system.
% For example, if 3 sources with 1, 3 and 2 paths respectively then
% paths=[1;3;2]
% symbolsIn (MxR Complex) = Signals being transmitted in the channel
% delay (Cx1 Integers) = Delay for each path in the system starting with
% source 1
% beta (Cx1 Integers) = Fading Coefficient for each path in the system
% starting with source 1
% DOA = Direction of Arrival for each source in the system in the form
% [Azimuth, Elevation]
% SNR = Signal to Noise Ratio in dB
% array = Array locations in half unit wavelength. If no array then should
% be [0,0,0]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% symbolsOut (FxN Complex) = F channel symbol chips received from each antenna
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [symbolsOut] = fChannel(symbolsIn, delays, fadingCoefs, varNoise, goldSeq)
[nRelativeDelays, nSignals] = size(goldSeq);
symbolsIn(length(symbolsIn) + nRelativeDelays, nSignals) = 0;
for iSignal = 1: nSignals
     symbolsIn(:, iSignal) = fadingCoefs(iSignal) * circshift(symbolsIn(:, iSignal), delays(iSignal));
%      noise = abs(fadingCoefs(iSignal)) .^2 * varNoise / sqrt(2) * (randn(length(symbolsIn), 1) + 1i * randn(length(symbolsIn), 1));
     noise = sqrt(varNoise) * (randn(length(symbolsIn), 1) + 1i * randn(length(symbolsIn), 1));
     symbolsIn(:, iSignal) = symbolsIn(:, iSignal) + noise;
end
symbolsOut = sum(symbolsIn, 2);
end
