function [mark, flag, maxLen, maxArea, maxSlope, minSlope, maxRatio, minRatio] = getMaxLen(ed, lenThres)
edgeThres = 2;
ed(1:edgeThres, :) = 0;
ed(end-edgeThres+1:end, :) = 0;
ed(:, 1:edgeThres) = 0;
ed(:, end-edgeThres+1:end) = 0;
[mark, snum] = bwlabel(ed, 8);
kThres = min(lenThres / 3 * 2, 5);
for k = 1 : snum
	[r,c] = find(mark == k);
	index = find(mark(:) == k);
	rows = max(r) - min(r) + 1;
	cols = max(c) - min(c) + 1;
	slope = rows / cols;
	len = length(index);
	area = rows * cols;
	ratio = len / area;
	if rows <= 1 || cols <= 1 || len < lenThres ...
		|| (rows < 3 && cols < 3) || (rows >= 3 && cols >= 3 && ratio > 0.5) ...
		|| ((rows < 3 || cols < 3) && len < 4)
		mark(index) = 0;
	end
end
mark = mark > 0;
if sum(mark(:)) > 0
	flag = 1;
else
	flag = 0;
end
maxSlope = -1; minSlope = -1;
maxRatio = -1; minRatio = -1;
maxLen = -1; maxArea = -1;
if sum(mark(:)) > 0
	maxLen = -1; maxArea = -1;
	maxSlope = -1; minSlope = 1000;
	maxRatio = -1; minRatio = 1000;
	[mark, snum] = bwlabel(mark, 8);
	for k = 1 : snum
		[r,c] = find(mark == k);
		index = find(mark(:) == k);
		rows = max(r) - min(r) + 1;
		cols = max(c) - min(c) + 1;
		slope = rows / cols;
		len = length(index);
		area = rows * cols;
		ratio = len / area;
		if len > maxLen
			maxLen = len;
		end
		if area > maxArea
			maxArea = area;
		end
		if slope > maxSlope
			maxSlope = slope;
		end
		if slope < minSlope
			minSlope = slope;
		end
		if ratio > maxRatio
			maxRatio = ratio;
		end
		if ratio < minRatio
			minRatio = ratio;
		end
	end
end
end