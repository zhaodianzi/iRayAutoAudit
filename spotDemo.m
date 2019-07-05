is_lambda = 0.008; bp_lambda = 0.08; tol = 1e-7; maxIter = 1000;
h = 512; w = 640;
dataPath = 'D:\BIT\iray\data\重新清洗\spot\';
resPath = 'D:\BIT\iray\data\重新清洗\spot\mask\';
reportFileName = 'D:\BIT\iray\data\重新清洗\spotInfo.xls';
dataList = dir([dataPath, '*.png']);
dataNum = length(dataList);
pos_class = 4;
% pred_label = zeros(dataNum, 1);
% real_label = zeros(dataNum, 1);

upThres = 8; downThres = 8; leftThres = 8; rightThres = 8; 
edgeThres = 2;
lenThres4 = 6; lenThres8 = 4; lenThres16 = 3;
title = {'ID', '最大尺度', '最大深度'};
xlswrite(reportFileName, title, 1, 'A1');
for itr = 1:555
% 	real_label(itr) = str2double(dataList(itr).name(1));
	data = double(imread([dataPath, dataList(itr).name]));
	ID = dataList(itr).name;
	[label, scale, mask, depth] = getSpotFunc(data); % 斑块
	sp_score(itr) = scale;
	imwrite(mask, [resPath, ID]);
	pred_label(itr) = label;
	item = {ID(1:end-4), scale, depth};
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