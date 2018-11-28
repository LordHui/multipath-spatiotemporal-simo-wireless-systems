clear;close;
surIndex = 26;
foreIndex = 25;
coeffs = [1 0 0 1 1; 1 1 0 0 1];
fileName = 'pic_1.png';
phi = (surIndex + 2 * foreIndex) / 180;
p = 1e6;
%% Gold sequence
[mSeq1] = fMSeqGen(coeffs(1, :));
[mSeq2] = fMSeqGen(coeffs(2, :));
shiftMin = ceil(1 + mod(surIndex + foreIndex, 12));
[shift] = miner(mSeq1, mSeq2, shiftMin);
[balGoldSeq] = fGoldSeq(mSeq1, mSeq2, shift);
goldSeq1 = balGoldSeq;
goldSeq2 = fGoldSeq(mSeq1, mSeq2, shift + 1);
goldSeq3 = fGoldSeq(mSeq1, mSeq2, shift + 2);
%% Signal generation
% pic1 = imread('pic_1.png');
% pic2 = imread('pic_2.png');
% pic3 = imread('pic_3.png');
% b1 = de2bi(pic1, 8);
% b2 = de2bi(pic2, 8);
% b3 = de2bi(pic3, 8);
% signal1 = reshape(b1, numel(b1), 1);
% signal2 = reshape(b2, numel(b2), 1);
% signal3 = reshape(b3, numel(b3), 1);
[bitsOut, x, y] = fImageSource(fileName, p);
bitsIn = bitsOut;
Q = x * y * 3 * 8;
[symbolsOut] = fDSQPSKModulator(bitsIn, goldSeq1, phi);
fImageSink(bitsIn, Q, x, y);
flag = 1;
