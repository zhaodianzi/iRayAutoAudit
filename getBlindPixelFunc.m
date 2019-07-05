function [bp_mask, BP_Num, maxCrowd, A_BP_Num, A_maxCrowd] = ...
	getBlindPixelFunc(img, bp_candidate, cr_mask, BPDetectionThres)
distanceThreshold = 2; % 判定是否属于一簇的像素间隔阈值
crowdCountThreshold = 3; % 判定异常像元成簇的阈值
% w_border = 0.01; % 边缘or内部权重因子

% 筛选异常像元
bp_mask = BlindMaskByThreshold(bp_candidate, BPDetectionThres);
mask255 = img == 255;
mask0 = img == 0;
bp_mask = bp_mask | mask0 | mask255;
bp_mask(cr_mask) = 0;

[crowdNum, spotCrowd, crowdMemNum, maxCrowd, A_maxCrowd] = ...
	getBrightSpotCrowd(bp_mask, crowdCountThreshold, distanceThreshold);
BP_Num = sum(bp_mask(:) == 1); % 异常像元总数
A_bp_mask = bp_mask(113:400, 129:512);
A_BP_Num = sum(A_bp_mask(:) == 1); % 异常像元总数
end