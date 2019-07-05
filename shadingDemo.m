is_lambda = 0.008; bp_lambda = 0.08; tol = 1e-7; maxIter = 1000;
h = 512; w = 640;
dataPath = 'E:\BIT\iRay\code\data\重新清洗数据\580(1比1)\';
reportFileName = 'E:\BIT\iRay\code\data\重新清洗数据\shadingInfo.xls';
dataList = dir([dataPath, '*.png']);
dataNum = length(dataList);
pos_class = 6;
% pred_label = zeros(dataNum, 1);
% real_label = zeros(dataNum, 1);

upThres = 8; downThres = 8; leftThres = 8; rightThres = 8; 
edgeThres = 2;
lenThres4 = 6; lenThres8 = 4; lenThres16 = 3;
title = {'ID', '4最大长度', '4最大面积', '4最大斜率', '4最小斜率', '4最大占比', '4最小占比', ...
	'8最大长度', '8最大面积', '8最大斜率', '8最小斜率', '8最大占比', '8最小占比',...
	'16最大长度', '16最大面积', '16最大斜率', '16最小斜率', '16最大占比', '16最小占比'};
xlswrite(reportFileName, title, 1, 'A1');
for itr = 1:210
% 	real_label(itr) = str2double(dataList(itr).name(1));
	ID = dataList(itr).name;
	data = double(imread([dataPath, ID]));
	
	data = data(upThres+1:end, :);
	data = data(1:end-downThres, :);
	data = data(:, leftThres+1:end);
	data = data(:, 1:end-rightThres);
	data = verticalStripeSuppression(data);
	data = horizontalStripeSuppression(data);
	img = removeNUA(data);
	
	data4 = imresize(img, 1 / 4);
	[edge4, thres] = edge(data4, 'sobel');
	[maxLenArr4(itr), maxArea4(itr), maxSlope4(itr), minSlope4(itr), maxRatio4(itr), minRatio4(itr)] = getShadingInfo(edge4, lenThres4);
	thresArr4(itr) = thres;
	
	data8 = imresize(img, 1 / 8);
	[edge8, thres] = edge(data8, 'sobel');
	[maxLenArr8(itr), maxArea8(itr), maxSlope8(itr), minSlope8(itr), maxRatio8(itr), minRatio8(itr)] = getShadingInfo(edge8, lenThres8);
	thresArr8(itr) = thres;
	
	data16 = imresize(img, 1 / 16);
	[edge16, thres] = edge(data16, 'sobel');
	[maxLenArr16(itr), maxArea16(itr), maxSlope16(itr), minSlope16(itr), maxRatio16(itr), minRatio16(itr)] = getShadingInfo(edge16, lenThres16);
	thresArr16(itr) = thres;

	item = {ID(1:end-4), ...
		maxLenArr4(itr), maxArea4(itr), maxSlope4(itr), minSlope4(itr), maxRatio4(itr), minRatio4(itr), ...
		maxLenArr8(itr), maxArea8(itr), maxSlope8(itr), minSlope8(itr), maxRatio8(itr), minRatio8(itr), ...
		maxLenArr16(itr), maxArea16(itr), maxSlope16(itr), minSlope16(itr), maxRatio16(itr), minRatio16(itr)};
	xlswrite(reportFileName, item, 1, ['A', num2str(itr+1)]);
	
% 	if itr >= 25 && mod(itr, 25) == 0
% 		fprintf('iter %d, shading: %d, correct: %.2f\n', itr, sum(pred_label), sum(pred_label(1:itr) == real_label(1:itr)));
% 	end
end
return;
acc = 0;
tp = 0; % 正确正样本
fp = 0; % 错误正样本
fn = 0; % 错误负样本
tn = 0;
for itr = 1 : dataNum
	if pred_label(itr) == real_label(itr)
		acc = acc + 1;
	else
		fprintf('%d\t%s\n', itr, dataList(itr).name);
	end
	if pred_label(itr) == pos_class
		if real_label(itr) == pos_class
			tp = tp + 1;
		else
			fp = fp + 1;
		end
	else
		if real_label(itr) == pos_class
			fn = fn + 1;
		else
			tn = tn + 1;
		end
	end
end
acc = acc / dataNum;
fprintf('Accuracy is %f\n', acc);
precision = tp / (tp + fp);
recall = tp / (tp + fn);
fprintf('precision: %f, recall: %f\n', precision, recall);