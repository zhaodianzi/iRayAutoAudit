function [bp_mask, bc_mask, resText, BP_Num, maxCrowd, CR_Num, ...
	A_BP_Num, A_maxCrowd, A_CR_Num, hasManyCol, BP_Score] = ...
	BlindPixelDetection(img, bp_candidate, BPDetectionThres, BCDetectionThres)
[h, w] = size(img);
distanceThreshold = 2; % �ж��Ƿ�����һ�ص����ؼ����ֵ
crowdCountThreshold = 3; % �ж��쳣��Ԫ�ɴص���ֵ
w_bp = 0.2; % äԪ����Ȩ������
w_bg = 0.4; % äԪ��Ȩ������
w_rc = 100; % ���л���Ȩ������
% w_border = 0.01; % ��Եor�ڲ�Ȩ������

% ���л����ж�
[bc_mask, colIndex, rowIndex] = NewBadColMask(img, BCDetectionThres);
% ��״�쳣��
[hasManyCol, cc_mask, ccolIndex] = checkColCrowd(img, 2);
bc_mask = bc_mask | cc_mask;

colIndex = unique([ccolIndex, colIndex]);
colNum = numel(colIndex); % ��������
rowNum = numel(rowIndex); % ��������
CR_Num = rowNum + colNum;

% ɸѡ�쳣��Ԫ
bp_mask = BlindMaskByThreshold(bp_candidate, BPDetectionThres);
mask255 = img == 255;
mask0 = img == 0;
bp_mask(:, colIndex) = 0;
bp_mask(rowIndex, :) = 0;
% mask = bc_mask | bp_mask | mask0 | mask255; % �õ������쳣��Ԫλ��

% �ۺϳɴص��쳣��Ԫ
maxCrowd = 0;
%[crowdNum, crowdMemNum] = getCrowd(bp_mask);
bp_mask = bp_mask | mask0 | mask255;
[crowdNum, spotCrowd, crowdMemNum, A_crowdSum, A_crowdNum, A_maxCrowd] = ...
	getBrightSpotCrowd(bp_mask, crowdCountThreshold, distanceThreshold);
BP_Num = sum(bp_mask(:) == 1); % �쳣��Ԫ����
[A_BP_Num, A_CR_Num] = isInCenterRegion(bp_mask, rowIndex, colIndex);
if BP_Num == 0 && colNum == 0 && rowNum == 0
	BP_Score = 0;
else
	if crowdNum == 0
		blindPixelPerCrowd = 1;
	else
		maxCrowd = max(crowdMemNum);
		blindPixelPerCrowd = sum(crowdMemNum) / crowdNum; % ÿ����ƽ�����м����쳣��Ԫ
	end
	BP_Score = w_bg * blindPixelPerCrowd + w_bp * BP_Num + w_rc * CR_Num;
end
if A_BP_Num == 0 && A_CR_Num == 0
	A_BP_Score = 0;
else
	if A_crowdNum == 0
		A_blindPixelPerCrowd = 1;
	else
		A_blindPixelPerCrowd = A_crowdSum / A_crowdNum; % ÿ����ƽ�����м����쳣��Ԫ
	end
	A_BP_Score = w_bg * A_blindPixelPerCrowd + w_bp * A_BP_Num + w_rc * A_CR_Num;
end
if hasManyCol == 1
	resText = sprintf('äԪ��: %d��, ���äԪ��: %d����, ����/��: %d��, äԪ��������: %.2f, A��äԪ��: %d��, A�����äԪ��: %d����, A������/��: %d��, ����״�쳣��', ...
		BP_Num, maxCrowd, CR_Num, BP_Score, A_BP_Num, A_maxCrowd, A_CR_Num);
else
	resText = sprintf('äԪ��: %d��, ���äԪ��: %d����, ����/��: %d��, äԪ��������: %.2f, A��äԪ��: %d��, A�����äԪ��: %d����, A������/��: %d��, ����״�쳣��', ...
		BP_Num, maxCrowd, CR_Num, BP_Score, A_BP_Num, A_maxCrowd, A_CR_Num);
end
end


function [A_BP_Num, A_CR_Num] = isInCenterRegion(bp_mask, rowIndex, colIndex)
A_bp_mask = bp_mask(113:400, 129:512);
A_BP_Num = sum(A_bp_mask(:) == 1); % �쳣��Ԫ����
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