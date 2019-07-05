is_lambda = 0.008; bp_lambda = 0.08; tol = 1e-7; maxIter = 1000;
BCDetectionThres = 4;
h = 512; w = 640;
dataPath = 'E:\BIT\iRay\code\data\all_dataset\';
outputNormalPath = 'E:\BIT\iRay\code\data\output_normal\';
outputDefectPath = 'E:\BIT\iRay\code\data\output_defect\';
reportFileName = 'E:\BIT\iRay\code\data\all_dataset\info.xls';
dataList = dir([dataPath, '*.png']);
dataNum = length(dataList);
pred_label = zeros(dataNum, 1);
real_label = zeros(dataNum, 1);
score = zeros(dataNum, 1);
% title = {'ID', '标签', '等级', '斑块深度', '斑块加和', '4最大长度', '4最大面积', '4最小占比', ...
% 	'8最大长度', '8最大面积', '8最小占比'};
% xlswrite(reportFileName, title, 1, 'A1');
for itr = 3305:dataNum
	ID = dataList(itr).name;
% 	real_label(itr) = str2double(dataList(itr).name(1));
	data = double(imread([dataPath, ID]));
	spotDepth = -1; spotSum = -1;
	maxLen4 = -1; maxArea4 = -1; minRatio4 = -1;
	maxLen8 = -1; maxArea8 = -1; minRatio8 = -1;
	[label, cr_score] = getBadRowColFunc(data, BCDetectionThres); % 坏行坏列
	if label == -1
		[img, ~] = LowRankByRPCA(data, bp_lambda, tol, maxIter);
		[label, sp_score, sp_mask, spotDepth, spotSum] = getSpotFunc(img); % 斑块
		if label == -1
			[label, ss_score] = getSlopingFunc(ID(1:end-4)); % 斜纹
			if label == -1
				[label, is_score, is_mask, maxLen4, maxArea4, minRatio4, ...
					maxLen8, maxArea8, minRatio8] = getShadingFunc(data); % 底纹和正常
				pred_label(itr) = label;
				score(itr) = is_score;
			else
				pred_label(itr) = label;
				score(itr) = ss_score;
			end
		else
			pred_label(itr) = label;
			score(itr) = sp_score;
		end
	else
		pred_label(itr) = label;
		score(itr) = cr_score;
	end
	if label == 8
		imwrite(uint8(data), [outputNormalPath, num2str(label), '_', ID]);
	else
		imwrite(uint8(data), [outputDefectPath, num2str(label), '_', ID]);
	end
	item = {ID(1:end-4), pred_label(itr), score(itr), spotDepth, spotSum, maxLen4, ...
		maxArea4, minRatio4, maxLen8, maxArea8, minRatio8};
	xlswrite(reportFileName, item, 1, ['A', num2str(itr+1)]);
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