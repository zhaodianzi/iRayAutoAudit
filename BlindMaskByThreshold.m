function [mask] = BlindMaskByThreshold(S, givenThres)
[h, w] = size(S);
mask = zeros(h, w);
avr = mean(S(:)); 
sig = std(S(:));
thresHigh = givenThres;
thresLow = avr - givenThres;
% thresHigh = avr + givenThres * sig;
% thresLow = avr - givenThres * sig;
hot = find(S > thresHigh);
dead = find(S < thresLow);
blind = [dead; hot];
mask(blind) = 1;
end