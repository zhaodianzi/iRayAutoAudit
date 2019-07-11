function [mask, flag, depth] = windowSearchSpot(img, winSize, edgeThres, magThres, denseThres)
[h, w] = size(img);
hh = h - winSize + 1;
ww = w - winSize + 1;
mask = zeros(h, w);
flag = 0;
[Ix, Iy] = gradient(img);
Ix2 = Ix.^2;
Iy2 = Iy.^2;
Ixy = Ix.*Iy;
% lmin = imregionalmin(img);
% lmax = imregionalmax(img);
lmax = myRegionalMax(img, magThres);
lmin = myRegionalMax(-img, magThres);
lmin = getDenseArea(lmin, denseThres, edgeThres);
lmax = getDenseArea(lmax, denseThres, edgeThres);
rowIndex = repmat((1 : h)', 1, w);
colIndex = repmat(1 : w, h, 1);
if magThres > 6
	ratio = 1.02;
else
	ratio = 1.05;
end

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
	
	if (img(i,j) / magThres < ratio && abs(min(box(:)) / img(i,j)) > 0.5) ...
			|| (max(box(:)) > img(i,j)) %|| (img(i,j) / magThres < 1.05)
		continue;
	end
	if (magThres < 6) && (img(i,j) / magThres < ratio) && (i <= edgeThres || i > h - edgeThres || j <= edgeThres || j > w - edgeThres)
		continue;
	end
	st = [sum(Ix2(index(:))), sum(Ixy(index(:))); sum(Ixy(index(:))), sum(Iy2(index(:)))];
	lam = eig(st);
	if max(lam) > 0 && max(lam) / min(lam) > 3.5
		continue;
	end
	flag = 1;
	circleIndex = (((rowIndex - i) / cenSize).^2 + ((colIndex - j) / cenSize).^2) <= 1;
	mask(circleIndex) = 1;
	if abs(img(i,j)) > maxDepth
		maxDepth = abs(img(i,j));
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
	if (-img(i,j) / magThres < ratio && abs(max(box(:)) / img(i,j)) > 0.5) ...
			|| (min(box(:)) < img(i,j)) %|| (-img(i,j) / magThres < 1.05)
		continue;
	end
	if (magThres < 6) && (-img(i,j) / magThres < ratio) && (i <= edgeThres || i > h - edgeThres || j <= edgeThres || j > w - edgeThres)
		continue;
	end
	st = [sum(Ix2(index(:))), sum(Ixy(index(:))); sum(Ixy(index(:))), sum(Iy2(index(:)))];
	lam = eig(st);
	if max(lam) > 0 && max(lam) / min(lam) > 3
		continue;
	end
	flag = 1;
	circleIndex = (((rowIndex - i) / cenSize).^2 + ((colIndex - j) / cenSize).^2) <= 1;
	mask(circleIndex) = 1;
	if abs(img(i,j)) > maxDepth
		maxDepth = abs(img(i,j));
	end
end
depth = maxDepth;
end

function [init] = getDenseArea(init, win, edgeThres)
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