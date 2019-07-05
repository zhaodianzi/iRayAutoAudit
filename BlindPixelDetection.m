function [bp_mask, bc_mask, resText, BP_Num, maxCrowd, CR_Num, ...
	A_BP_Num, A_maxCrowd, A_CR_Num, hasManyCol, BP_Score] = ...
	BlindPixelDetection(img, bp_candidate, BPDetectionThres, BCDetectionThres)
[h, w] = size(img);
distanceThreshold = 2; % 判定是否属于一簇的像素间隔阈值
crowdCountThreshold = 3; % 判定异常像元成簇的阈值
w_bp = 0.2; % 盲元总数权重因子
w_bg = 0.4; % 盲元簇权重因子
w_rc = 100; % 坏行坏列权重因子
% w_border = 0.01; % 边缘or内部权重因子

% 坏行坏列判定
[bc_mask, colIndex, rowIndex] = NewBadColMask(img, BCDetectionThres);
% 柱状异常列
[hasManyCol, cc_mask, ccolIndex] = checkColCrowd(img, 2);
bc_mask = bc_mask | cc_mask;

colIndex = unique([ccolIndex, colIndex]);
colNum = numel(colIndex); % 坏列数量
rowNum = numel(rowIndex); % 坏行数量
CR_Num = rowNum + colNum;

% 筛选异常像元
bp_mask = BlindMaskByThreshold(bp_candidate, BPDetectionThres);
mask255 = img == 255;
mask0 = img == 0;
bp_mask(:, colIndex) = 0;
bp_mask(rowIndex, :) = 0;
% mask = bc_mask | bp_mask | mask0 | mask255; % 得到所有异常像元位置

% 聚合成簇的异常像元
maxCrowd = 0;
%[crowdNum, crowdMemNum] = getCrowd(bp_mask);
bp_mask = bp_mask | mask0 | mask255;
[crowdNum, spotCrowd, crowdMemNum, A_crowdSum, A_crowdNum, A_maxCrowd] = ...
	getBrightSpotCrowd(bp_mask, crowdCountThreshold, distanceThreshold);
BP_Num = sum(bp_mask(:) == 1); % 异常像元总数
[A_BP_Num, A_CR_Num] = isInCenterRegion(bp_mask, rowIndex, colIndex);
if BP_Num == 0 && colNum == 0 && rowNum == 0
	BP_Score = 0;
else
	if crowdNum == 0
		blindPixelPerCrowd = 1;
	else
		maxCrowd = max(crowdMemNum);
		blindPixelPerCrowd = sum(crowdMemNum) / crowdNum; % 每个簇平均含有几个异常像元
	end
	BP_Score = w_bg * blindPixelPerCrowd + w_bp * BP_Num + w_rc * CR_Num;
end
if A_BP_Num == 0 && A_CR_Num == 0
	A_BP_Score = 0;
else
	if A_crowdNum == 0
		A_blindPixelPerCrowd = 1;
	else
		A_blindPixelPerCrowd = A_crowdSum / A_crowdNum; % 每个簇平均含有几个异常像元
	end
	A_BP_Score = w_bg * A_blindPixelPerCrowd + w_bp * A_BP_Num + w_rc * A_CR_Num;
end
if hasManyCol == 1
	resText = sprintf('盲元数: %d个, 最大盲元簇: %d像素, 坏行/列: %d个, 盲元坏列评分: %.2f, A区盲元数: %d个, A区最大盲元簇: %d像素, A区坏行/列: %d个, 有柱状异常列', ...
		BP_Num, maxCrowd, CR_Num, BP_Score, A_BP_Num, A_maxCrowd, A_CR_Num);
else
	resText = sprintf('盲元数: %d个, 最大盲元簇: %d像素, 坏行/列: %d个, 盲元坏列评分: %.2f, A区盲元数: %d个, A区最大盲元簇: %d像素, A区坏行/列: %d个, 无柱状异常列', ...
		BP_Num, maxCrowd, CR_Num, BP_Score, A_BP_Num, A_maxCrowd, A_CR_Num);
end
end


function [A_BP_Num, A_CR_Num] = isInCenterRegion(bp_mask, rowIndex, colIndex)
A_bp_mask = bp_mask(113:400, 129:512);
A_BP_Num = sum(A_bp_mask(:) == 1); % 异常像元总数
A_CR_Num = 0;
for i = 1 : numel(rowIndex)
	if rowIndex(i) >= 113 && rowIndex(i) <= 400
		A_CR_Num = A_CR_Num + 1;
	end
end
for i = 1 : numel(colIndex)
	if colIndex(i) >= 129 && colIndex(i) <= 512
		A_CR_Num = A_CR_Num + 1;
	end
end
end