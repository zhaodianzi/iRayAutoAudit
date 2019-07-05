function [bp_mask, BP_Num, maxCrowd, A_BP_Num, A_maxCrowd] = ...
	getBlindPixelFunc(img, bp_candidate, cr_mask, BPDetectionThres)
distanceThreshold = 2; % �ж��Ƿ�����һ�ص����ؼ����ֵ
crowdCountThreshold = 3; % �ж��쳣��Ԫ�ɴص���ֵ
% w_border = 0.01; % ��Եor�ڲ�Ȩ������

% ɸѡ�쳣��Ԫ
bp_mask = BlindMaskByThreshold(bp_candidate, BPDetectionThres);
mask255 = img == 255;
mask0 = img == 0;
bp_mask = bp_mask | mask0 | mask255;
bp_mask(cr_mask) = 0;

[crowdNum, spotCrowd, crowdMemNum, maxCrowd, A_maxCrowd] = ...
	getBrightSpotCrowd(bp_mask, crowdCountThreshold, distanceThreshold);
BP_Num = sum(bp_mask(:) == 1); % �쳣��Ԫ����
A_bp_mask = bp_mask(113:400, 129:512);
A_BP_Num = sum(A_bp_mask(:) == 1); % �쳣��Ԫ����
end