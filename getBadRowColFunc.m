function [label, cr_mask, CR_Num, A_CR_Num] = getBadRowColFunc(data, BCDetectionThres)
label = -1;
% ���л����ж�
[cr_mask, colIndex, rowIndex] = NewBadColMask(data, BCDetectionThres);
% ��״�쳣��
[hasManyCol, cc_mask, ccolIndex] = checkColCrowd(data, BCDetectionThres / 2);
if hasManyCol
	label = 3;
end
if ~isempty(rowIndex)
	label = 2;
end
if ~isempty(colIndex)
	label = 1;
end
cr_mask = cr_mask | cc_mask;
colIndex = unique([ccolIndex, colIndex]);
colNum = numel(colIndex); % ��������
rowNum = numel(rowIndex); % ��������
CR_Num = rowNum + colNum;
A_CR_Num = isInCenterRegion(rowIndex, colIndex);
end

function [A_CR_Num] = isInCenterRegion(rowIndex, colIndex)
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