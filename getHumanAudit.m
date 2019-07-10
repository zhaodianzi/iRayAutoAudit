function [humanAuditMap] = getHumanAudit(filename, sheet, chipType)
if chipType == 1
	totalRow = 10; totalCol = 10;
elseif chipType == 2
	totalRow = 12; totalCol = 12;
elseif chipType == 3
	totalRow = 8; totalCol = 8;
end
% totalRow = 10; totalCol = 10;
humanAuditMap = zeros(totalRow, totalCol);
startCol = 'AG'; startRow = 33;
eRange = sprintf('%s%d:%s%d', startCol, startRow, ...
	startCol, startRow + totalCol * totalRow - 1);
[~, ~, rawdata] = xlsread(filename, sheet, eRange);
for i = 1 : totalRow
	for j = 1 : totalCol
		index = (i - 1) * totalCol + j;
		if ~isnan(rawdata{index})
			if length(rawdata{index}) == 7
				bin = rawdata{index};
				humanAuditMap(i, j) = str2double(bin(end-1:end));
			end
		end
	end
end
end