function [hasManyCol, cc_mask, ccolIndex] = checkColCrowd(img, BCDetectionThres)
lenThres = 12;
edgeThreshold = 20;
win = lenThres / 2;
[h, w] = size(img);
maskCol = zeros(1, w);
colS = sum(img, 1);
smoothColS = smoothing(colS, 0.03, 'rlowess');
flatColS = smoothing(colS, 0.3, 'rlowess');
colS = smoothColS - flatColS;
hasManyCol = 0;
boundThres = 4000;
sig = std(colS(1+edgeThreshold:w-edgeThreshold));
% lowThres = -BCDetectionThres * sig;
% highThres = BCDetectionThres * sig;
lowThres = min(-boundThres, -BCDetectionThres * sig);
highThres = max(boundThres, BCDetectionThres * sig);
[~,lmax] = findpeaks(colS);
[~,lmin] = findpeaks(-colS);
for i = 1 : length(lmax)
	left = max(1, lmax(i) - win);
	right = min(w, lmax(i) + win);
	subC = colS(left:right);
	if sum(subC > highThres) >= lenThres
		hasManyCol = 1;
		maskCol(left:right) = 1;
	end
end
for i = 1 : length(lmin)
	left = max(1, lmin(i) - win);
	right = min(w, lmin(i) + win);
	subC = colS(left:right);
	if sum(subC < lowThres) >= lenThres
		hasManyCol = 1;
		maskCol(left:right) = 1;
	end
end
cc_mask = repmat(maskCol, h, 1);
ccolIndex = find(maskCol ~= 0);
end
