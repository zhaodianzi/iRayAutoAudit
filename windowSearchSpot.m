function [mask, flag, depth] = windowSearchSpot(img, winSize, edgeThres, magThres, denseThres)
% magThres = 5;
[h, w] = size(img);
hh = h - winSize + 1;
ww = w - winSize + 1;
mask = zeros(h, w);
flag = 0;
[Ix, Iy] = gradient(img);
Ix2 = Ix.^2;
Iy2 = Iy.^2;
Ixy = Ix.*Iy;
lmin = imregionalmin(img);
lmax = imregionalmax(img);
lmin = getDenseArea(lmin, denseThres, edgeThres);
lmax = getDenseArea(lmax, denseThres, edgeThres);
rowIndex = repmat((1 : h)', 1, w);
colIndex = repmat(1 : w, h, 1);

p = find(lmax == 1);
num = length(p);
[r, c] = ind2sub([h, w], p);
imgIndex = reshape(1:h*w, h, w);
cenSize = floor(winSize / 3);
maxDepth = -1;
for t = 1 : num
	i = r(t); j = c(t);
	top = max(1, i - winSize);
	bottom = min(h, i + winSize);
	left = max(1, j - winSize);
	right = min(w, j + winSize);
	centertop = max(1, i - cenSize);
	centerbottom = min(h, i + cenSize);
	centerleft = max(1, j - cenSize);
	centerright = min(w, j + cenSize);
% 	box = img(top:bottom, left:right);
	index = imgIndex(top:bottom, left:right);
	centerIndex = imgIndex(centertop:centerbottom, centerleft:centerright);
	boxIndex = setdiff(index(:), centerIndex(:));
	box = img(boxIndex);
% 	avr = mean(box(:)); sig = std(box(:));
% 	if sig > 4
% 		k = kTimes - 2;
% 	elseif sig > 2
% 		k = kTimes - 0.5;
% 	else
% 		k = kTimes;
% 	end
% 	myK = abs((img(i, j) - avr) / sig);
	if img(i, j) > magThres %img(i, j) > avr + k * sig && 
		if (img(i,j) / magThres < 1.2 && abs(min(box(:)) / img(i,j)) > 0.6) ...
				|| max(box(:)) > img(i,j)
			continue;
		end
		st = [sum(Ix2(index(:))), sum(Ixy(index(:))); sum(Ixy(index(:))), sum(Iy2(index(:)))];
		lam = eig(st);
		if max(lam) > 0 && max(lam) / min(lam) > 2
			continue;
		end
		flag = 1;
% 		mask(i, j) = 1;
		circleIndex = (((rowIndex - i) / cenSize).^2 + ((colIndex - j) / cenSize).^2) <= 1;
		mask(circleIndex) = 1;
		if abs(img(i,j)) > maxDepth
			maxDepth = abs(img(i,j));
		end
	end
end

p = find(lmin == 1);
num = length(p);
[r, c] = ind2sub([h, w], p);
for t = 1 : num
	i = r(t); j = c(t);
	top = max(1, i - winSize);
	bottom = min(h, i + winSize);
	left = max(1, j - winSize);
	right = min(w, j + winSize);
	centertop = max(1, i - cenSize);
	centerbottom = min(h, i + cenSize);
	centerleft = max(1, j - cenSize);
	centerright = min(w, j + cenSize);
% 	box = img(top:bottom, left:right);
	index = imgIndex(top:bottom, left:right);
	centerIndex = imgIndex(centertop:centerbottom, centerleft:centerright);
	boxIndex = setdiff(index(:), centerIndex(:));
	box = img(boxIndex);
% 	avr = mean(box(:)); sig = std(box(:));
% 	if sig > 4
% 		k = kTimes - 2;
% 	elseif sig > 2
% 		k = kTimes - 0.5;
% 	else
% 		k = kTimes;
% 	end
	if img(i, j) < -magThres %&& img(i, j) < avr - k * sig
		if (-img(i,j) / magThres < 1.2 && abs(max(box(:)) / img(i,j)) > 0.6) ...
				|| min(box(:)) < img(i,j)
			continue;
		end
		st = [sum(Ix2(index(:))), sum(Ixy(index(:))); sum(Ixy(index(:))), sum(Iy2(index(:)))];
		lam = eig(st);
		if max(lam) > 0 && max(lam) / min(lam) > 2
			continue;
		end
		flag = 1;
% 		mask(i, j) = 2;
		circleIndex = (((rowIndex - i) / cenSize).^2 + ((colIndex - j) / cenSize).^2) <= 1;
		mask(circleIndex) = 1;
		if abs(img(i,j)) > maxDepth
			maxDepth = abs(img(i,j));
		end
	end
end
depth = maxDepth;
end

function [init] = getDenseArea(init, win, edgeThres)
% win = 8;
% edgeThres = 3;
[h, w] = size(init);
rowIndex = repmat((1 : h)', 1, w);
colIndex = repmat(1 : w, h, 1);
init(1:edgeThres, 1:edgeThres) = 0;
init(1:edgeThres, w-edgeThres+1:w) = 0;
init(h-edgeThres+1:h, 1:edgeThres) = 0;
init(h-edgeThres+1:h, w-edgeThres+1:w) = 0;
% init(1:edgeThres, :) = 0;
% init(h-edgeThres+1:h, :) = 0;
% init(:, 1:edgeThres) = 0;
% init(:, w-edgeThres+1:w) = 0;
p = find(init == 1);
num = length(p);
[r, c] = ind2sub([h, w], p);
temp = zeros(h, w);
for t = 1 : num
	i = r(t); j = c(t);
	top = max(1, i - win);
	bottom = min(h, i + win);
	left = max(1, j - win);
	right = min(w, j + win);
	temp(top:bottom, left:right) = temp(top:bottom, left:right) + 1;
% 	index = (((rowIndex - i) / win).^2 + ((colIndex - j) / win).^2) <= 1;
% 	temp(index) = temp(index) + 1;
end
init(temp > 1) = 0;
end