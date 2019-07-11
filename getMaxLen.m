function [mark, flag, maxLen, maxArea, minRatio] = getMaxLen(ed, lenThres, ratioThres)
edgeThres = 2;
ed(1:edgeThres, :) = 0;
ed(end-edgeThres+1:end, :) = 0;
ed(:, 1:edgeThres) = 0;
ed(:, end-edgeThres+1:end) = 0;
[mark, snum] = bwlabel(ed, 8);
edgeThres = 5;
[h, w] = size(ed);
for k = 1 : snum
	[r,c] = find(mark == k);
	index = find(mark(:) == k);
	rows = max(r) - min(r) + 1;
	cols = max(c) - min(c) + 1;
	len = length(index);
	area = rows * cols;
	ratio = len / area;
	if len < lenThres || (rows > 1 && cols > 1 && ratio > ratioThres) ...
			|| (rows >= 3 && cols >= 3 && ratio > 0.5) ...
			|| (cols == 1 && (max(c) > w - edgeThres || min(c) <= edgeThres)) ...
			|| (rows == 1 && (max(r) > h - edgeThres || min(r) <= edgeThres)) ...
			|| ((rows == 2 || cols == 2) && len < 4)
		mark(index) = 0;
	end
end
mark = mark > 0;
if sum(mark(:)) > 0
	flag = 1;
else
	flag = 0;
end
minRatio = -1;
maxLen = -1; maxArea = -1;
if sum(mark(:)) > 0
	maxLen = -1; maxArea = -1;
	minRatio = 1000;
	[mark, snum] = bwlabel(mark, 8);
	for k = 1 : snum
		[r,c] = find(mark == k);
		index = find(mark(:) == k);
		rows = max(r) - min(r) + 1;
		cols = max(c) - min(c) + 1;
		len = length(index);
		area = rows * cols;
		ratio = len / area;
		if len > maxLen
			maxLen = len;
		end
		if area > maxArea
			maxArea = area;
		end
		if ratio < minRatio
			minRatio = ratio;
		end
	end
end
end