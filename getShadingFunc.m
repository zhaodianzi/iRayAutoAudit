function [label, mask, maxLen4, maxArea4, minRatio4, ...
	maxLen8, maxArea8, minRatio8, A_shadow] = getShadingFunc(data)
% 输入为3sigma数据，输出各个尺度的参数
maxLen4 = -1; maxArea4 = -1; minRatio4 = -1;
maxLen8 = -1; maxArea8 = -1; minRatio8 = -1;
% 阈值和参数
upThres = 8; downThres = 8; leftThres = 8; rightThres = 8; 
lenThres4 = 4; lenThres8 = 3; lenThres16 = 3;
[h, w] = size(data);
data = data(upThres+1:end, :);
data = data(1:end-downThres, :);
data = data(:, leftThres+1:end);
data = data(:, 1:end-rightThres);
data = verticalStripeSuppression(data);
data = horizontalStripeSuppression(data);
img = removeNUA(data);

flag = 0;
data4 = imresize(img, 1 / 4);
[edge4, edgeThres4] = edge(data4, 'sobel');

data8 = imresize(img, 1 / 8);
[edge8, edgeThres8] = edge(data8, 'sobel');
[mask8, stopFlag8] = getDownMask(edge8, lenThres8);
if stopFlag8 == 0
	[mark4, edgeFlag4, maxLen4, maxArea4, minRatio4] = getMaxLen(edge4 .* mask8, lenThres4);
	if edgeFlag4 == 1
		flag = 1;
		mask = resizeMask(mark4, 4);
	end
end

data16 = imresize(img, 1 / 16);
[edge16, edgeThres16] = edge(data16, 'sobel');
[mask16, stopFlag16] = getDownMask(edge16, lenThres16);
if stopFlag16 == 0
	[mark8, edgeFlag8, maxLen8, maxArea8, minRatio8] = getMaxLen(edge8 .* mask16, lenThres8);
	if edgeFlag8 == 1
		flag = 1;
		mask = resizeMask(mark8, 8);
	end
end

if stopFlag8 == 1 && stopFlag16 == 1
	[mark4, edgeFlag4, maxLen4, maxArea4, minRatio4] = getMaxLen(edge4, 8);
	if edgeFlag4 == 1
		flag = 1;
		mask = resizeMask(mark4, 4);
	end
end
if flag == 1
	label = 6;
	mask = padarray(mask, [8, 8], 0, 'both');
	A_mask = mask(113:400, 129:512);
	if sum(A_mask(:)) > 0
		A_shadow = 1;
	else
		A_shadow = 0;
	end
else
	label = 8;
	mask = zeros(h, w);
	A_shadow = 0;
end

end