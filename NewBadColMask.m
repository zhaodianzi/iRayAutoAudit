function [mask, colIndex, rowIndex] = NewBadColMask(img, BCDetectionThres)
lenThres = 9;
[h, w] = size(img);
mask = zeros(h, w);
win = 20;
edgeThreshold = 3;
kTimesPixel = BCDetectionThres / 2;

colS = sum(img, 1);
% smcolS = floess(colS, 0.1);
smcolS = smoothing(colS, 0.03, 'rlowess');
colS = colS - smcolS';
maskCol = zeros(1, w);
for i = 1 + edgeThreshold : w - edgeThreshold
	colIndex = find(maskCol ~= 0);
	left = max(1, i - win); right = min(w, i + win);
	index = [left : i - 1, i + 1 : right];
	index = setdiff(index, colIndex);
	avr = mean(colS(index)); sig = std(colS(index));
	flag = zeros(h, 1);
	maxLen = 0; preLen = 0;
	colI = img(:, i);
	if colS(i) > avr + BCDetectionThres * sig || sum(colI == 255) > 5
		token = 1;
		for k = 1 : h
			pavr = mean(img(k, index));
			psig = std(img(k, index));
			if img(k, i) > pavr + kTimesPixel * psig
				flag(k) = 1;
				preLen = preLen + 1;
				if preLen > maxLen
					maxLen = preLen;
				end
			else
				preLen = 0;
			end
		end
	elseif colS(i) < avr - BCDetectionThres * sig || sum(colI == 0) > 5
		token = -1;
		for k = 1 : h
			pavr = mean(img(k, index));
			psig = std(img(k, index));
			if img(k, i) < pavr - kTimesPixel * psig
				flag(k) = 1;
				preLen = preLen + 1;
				if preLen > maxLen
					maxLen = preLen;
				end
			else
				preLen = 0;
			end
		end
	end
	if preLen > maxLen
		maxLen = preLen;
	end
	if sum(flag) >= h * 0.4
		flag = ones(h, 1);
		maskCol(i) = token;
		mask(:, i) = flag;
	elseif maxLen >= lenThres
		maskCol(i) = token;
		flag = getLongSeg(flag, lenThres);
		mask(:, i) = flag;
	end
end

rowS = sum(img, 2);
% smrowS = floess(rowS, 0.1);
smrowS = smooth(rowS, 0.03, 'rlowess');
rowS = rowS - smrowS;
maskRow = zeros(h, 1);
for i = 1 + edgeThreshold : h - edgeThreshold
	rowIndex = find(maskRow ~= 0);
	top = max(1, i - win); bottom = min(h, i + win);
	index = [top : i - 1, i + 1 : bottom];
	index = setdiff(index, rowIndex);
	avr = mean(rowS(index)); sig = std(rowS(index));
	flag = zeros(1, w);
	maxLen = 0; preLen = 0;
	rowI = img(i, :);
	if rowS(i) > avr + BCDetectionThres * sig || sum(rowI == 255) > 5
		token = 1;
		for k = 1 : w
			pavr = mean(img(index, k));
			psig = std(img(index, k));
			if img(i, k) > pavr + kTimesPixel * psig
				flag(k) = 1;
				preLen = preLen + 1;
				if preLen > maxLen
					maxLen = preLen;
				end
			else
				preLen = 0;
			end
		end
	elseif rowS(i) < avr - BCDetectionThres * sig || sum(rowI == 0) > 5
		token = -1;
		for k = 1 : w
			pavr = mean(img(index, k));
			psig = std(img(index, k));
			if img(i, k) < pavr - kTimesPixel * psig
				flag(k) = 1;
				preLen = preLen + 1;
				if preLen > maxLen
					maxLen = preLen;
				end
			else
				preLen = 0;
			end
		end
	end
	if preLen > maxLen
		maxLen = preLen;
	end
	if sum(flag) >= w * 0.5
		flag = ones(1, w);
		maskRow(i) = token;
		mask(i, :) = flag;
	elseif maxLen >= lenThres
		maskRow(i) = token;
		flag = getLongSeg(flag, lenThres);
		mask(i, :) = flag;
	end
end
colIndex = find(maskCol ~= 0);
rowIndex = find(maskRow ~= 0);
end

function [flag] = getLongSeg(flag, lenThres)
preLen = 0;
startPos = 0;
for i = 1 : length(flag)
	if flag == 1
		if preLen == 0 %坏列段开始
			startPos = i;
			preLen = 1;
		else % 坏列段继续
			preLen = preLen + 1;
		end
	else % 坏列段中止并重置
		if preLen > 0 && preLen < lenThres % 不够长的删除
			flag(startPos:i-1) = 0;
		end
		startPos = 0;
		preLen = 0;
	end
end
end