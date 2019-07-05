function [maxLen, maxArea, maxSlope, minSlope, maxRatio, minRatio] = getShadingInfo(ed, lenThres)
edgeThres = 2;
ed(1:edgeThres, :) = 0;
ed(end-edgeThres+1:end, :) = 0;
ed(:, 1:edgeThres) = 0;
ed(:, end-edgeThres+1:end) = 0;
[mark, snum] = bwlabel(ed, 8);
[h, w] = size(ed);
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
		(rows < kThres && cols < kThres) || (ratio > 0.4)
		mark(index) = 0;
	end
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