function [label, mask, maxLen4, maxArea4, minRatio4, ...
	maxLen8, maxArea8, minRatio8, A_shadow] = getShadingFunc(data, ISDetectionThres)
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
% [edge4, edgeThres4] = edge(data4, 'canny', [0.3, 0.4]);
[mask4, mstopFlag4, maxLen4] = getDownMask(edge4, lenThres4, ISDetectionThres);
% if maxLen4 >= 8
% 	[mark4, edgeFlag4, maxLen4, maxArea4, minRatio4] = getMaxLen(edge4, lenThres4, ISDetectionThres);
% 	if edgeFlag4 == 1
% 		flag = 1;
% 		mask = resizeMask(mark4, 4);
% 	end
% end

data8 = imresize(img, 1 / 8);
[edge8, edgeThres8] = edge(data8, 'sobel');
% [edge8, edgeThres8] = edge(data8, 'canny', [0.2, 0.3]);
[mask8, stopFlag8, maxLen8] = getDownMask(edge8, lenThres8, ISDetectionThres);
% if maxLen8 >= 6
% 	[mark8, edgeFlag8, maxLen8, maxArea8, minRatio8] = getMaxLen(edge8, lenThres8, ISDetectionThres);
% 	if edgeFlag8 == 1
% 		flag = 1;
% 		mask = resizeMask(mark8, 8);
% 	end
% else
if stopFlag8 == 0
	[mark4, edgeFlag4, maxLen4, maxArea4, minRatio4] = getMaxLen(edge4 .* mask8, lenThres4, ISDetectionThres);
	if edgeFlag4 == 1
		flag = 1;
		mask = resizeMask(mark4, 4);
	end
end

data16 = imresize(img, 1 / 16);
[edge16, edgeThres16] = edge(data16, 'sobel');
% [edge16, edgeThres16] = edge(data16, 'canny', [0.15, 0.3]);
[mask16, stopFlag16] = getDownMask(edge16, lenThres16, ISDetectionThres);
if stopFlag16 == 0
	[mark8, edgeFlag8, maxLen8, maxArea8, minRatio8] = getMaxLen(edge8 .* mask16, lenThres8, ISDetectionThres);
	if edgeFlag8 == 1
		flag = 1;
		mask = resizeMask(mark8, 8);
	end
end

% if stopFlag8 == 1 && stopFlag16 == 1
% 	[mark4, edgeFlag4, maxLen4, maxArea4, minRatio4] = getMaxLen(edge4, 8, ISDetectionThres);
% 	if edgeFlag4 == 1
% 		flag = 1;
% 		mask = resizeMask(mark4, 4);
% 	end
% end
% if stopFlag4 == 1 && stopFlag16 == 1
% 	[mark8, edgeFlag8, maxLen8, maxArea8, minRatio8] = getMaxLen(edge8, lenThres8, ISDetectionThres);
% 	if edgeFlag8 == 1
% 		flag = 1;
% 		mask = resizeMask(mark8, 8);
% 	end
% end
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