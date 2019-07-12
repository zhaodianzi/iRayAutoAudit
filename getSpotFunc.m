function [label, mask, maxSpotScale, maxSpotDepth, A_spot] = getSpotFunc(data, BSDetectionThres)
% 输入为3sigma+lowrank后的数据
label = -1; maxSpotScale = -1; A_spot = -1;
% bp_lambda = 0.08; tol = 1e-7; maxIter = 1000;
% magThres = 8;
upThres = 8; downThres = 8; leftThres = 8; rightThres = 8;
winSize = [8, 12, 20, 30]; % 判定窗口半径
edgeThres = [3, 10, 12, 18]; % 窗口中心位置半径
% magThres = [1.5, 4.2, 8, 12]; % 响应阈值
magThres = BSDetectionThres;
denseThres = [5, 5, 5, 5]; % 极值点筛选
% kernel = [0,0,0,1,1,1,1,0,0,0;0,1,1,1,1,1,1,1,1,0;0,1,1,1,1,1,1,1,1,0;1,1,1,1,1,1,1,1,1,1;1,1,1,1,1,1,1,1,1,1;1,1,1,1,1,1,1,1,1,1;1,1,1,1,1,1,1,1,1,1;0,1,1,1,1,1,1,1,1,0;0,1,1,1,1,1,1,1,1,0;0,0,0,1,1,1,1,0,0,0];
% kernel = kernel ./ sum(kernel(:));
kernel = fspecial('gaussian', 10, 3);

data = data(upThres+1:end, :);
data = data(1:end-downThres, :);
data = data(:, leftThres+1:end);
data = data(:, 1:end-rightThres);
data = verticalStripeSuppression(data);
data = horizontalStripeSuppression(data);
NUA = removeNUA(data);

% level 1
data1 = imresize(NUA, 1 / 8);
A1 = conv2(data1, kernel, 'same');
[mask, flag, maxSpotDepth] = windowSearchSpot(A1, winSize(1), edgeThres(1), magThres(1), denseThres(1));
if flag == 1
	label = 4;
	maxSpotScale = 4;
	mask = resizeMask(mask, 8);
	mask = padarray(mask, [8, 8], 0, 'both');
	A_mask = mask(113:400, 129:512);
	if sum(A_mask(:)) > 0
		A_spot = 1;
	else
		A_spot = 0;
	end
	return;
end
% level 2
data2 = imresize(NUA, 1 / 4);
A2 = conv2(data2, kernel, 'same');
[mask, flag, maxSpotDepth] = windowSearchSpot(A2, winSize(2), edgeThres(2), magThres(2), denseThres(2));
if flag == 1
	label = 4;
	maxSpotScale = 3;
	mask = resizeMask(mask, 4);
	mask = padarray(mask, [8, 8], 0, 'both');
	A_mask = mask(113:400, 129:512);
	if sum(A_mask(:)) > 0
		A_spot = 1;
	else
		A_spot = 0;
	end
	return;
end
% level 3
data3 = imresize(NUA, 1 / 2);
A3 = conv2(data3, kernel, 'same');
[mask, flag, maxSpotDepth] = windowSearchSpot(A3, winSize(3), edgeThres(3), magThres(3), denseThres(3));
if flag == 1
	label = 4;
	maxSpotScale = 2;
	mask = resizeMask(mask, 2);
	mask = padarray(mask, [8, 8], 0, 'both');
	A_mask = mask(113:400, 129:512);
	if sum(A_mask(:)) > 0
		A_spot = 1;
	else
		A_spot = 0;
	end
	return;
end
% level 4
A4 = conv2(NUA, kernel, 'same');
[mask, flag, maxSpotDepth] = windowSearchSpot(A4, winSize(4), edgeThres(4), magThres(4), denseThres(4));
if flag == 1
	label = 4;
	maxSpotScale = 1;
	mask = padarray(mask, [8, 8], 0, 'both');
	A_mask = mask(113:400, 129:512);
	if sum(A_mask(:)) > 0
		A_spot = 1;
	else
		A_spot = 0;
	end
	return;
end
mask = padarray(mask, [8, 8], 0, 'both');
end