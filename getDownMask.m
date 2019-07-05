function [mask, stopFlag] = getDownMask(ed, lenThres)
edgeThres = 2;
[h, w] = size(ed);
mask = zeros(h*2, w*2);
% ed(1:edgeThres, :) = 0;
% ed(end-edgeThres+1:end, :) = 0;
% ed(:, 1:edgeThres) = 0;
% ed(:, end-edgeThres+1:end) = 0;
[mark, snum] = bwlabel(ed, 8);
kThres = lenThres / 3 * 2;
for k = 1 : snum
	[r,c] = find(mark == k);
	index = find(mark(:) == k);
	rows = max(r) - min(r) + 1;
	cols = max(c) - min(c) + 1;
	slope = rows / cols;
	len = length(index);
	area = rows * cols;
	ratio = len / area;
	if rows <= 1 || cols <= 1 || len < lenThres || slope>4 || slope<0.25 || ...
		(rows < 3 && cols < 3) || (rows >= 3 && cols >= 3 && ratio > 0.4) || ...
		((rows < 3 || cols < 3) && len < 1.5 * lenThres)
		mark(index) = 0;
	end
end

win = 2;
[rh, rw] = size(mark);
rMask = zeros(rh, rw);
for i = 1 : rh
	for j = 1 : rw
		if mark(i, j) > 0
			up = max(1, i - win);
			down = min(rh, i + win);
			left = max(1, j - win);
			right = min(rw, j + win);
			rMask(up:down, left:right) = 1;
		end
	end
end
for i = 1 : rh
	for j = 1 : rw
		if rMask(i, j) > 0
			mask((i-1)*2+1:i*2, (j-1)*2+1:j*2) = 1;
		end
	end
end
if sum(mask(:)) == 0
	stopFlag = 1;
else
	stopFlag = 0;
end
end