function [CPmap] = checkCP(filename, chipType)
if chipType == 1
	totalRow = 10; totalCol = 9;
elseif chipType == 2
	totalRow = 12; totalCol = 11;
elseif chipType == 3
	totalRow = 8; totalCol = 7;
end
if exist(filename, 'file')
	CPmap = zeros(totalRow, totalCol);
else
	CPmap = ones(totalRow, totalCol);
	return;
end

startCol = 'F'; startRow = 10;
eRange = sprintf('%s%d:%s%d', startCol + 1, startRow + 1, ...
	startCol + totalCol, startRow + totalRow);
[~, text, ~] = xlsread(filename, 1, eRange);
for i = 1 : totalRow
	for j = 1 : totalCol
		if strcmp(text{i,j}, 'BIN6') || strcmp(text{i,j}, 'BIN7')
			CPmap(i, j) = 1;
		end
	end
end
end