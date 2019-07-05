function [] = writeAuditFile(fileName, waferName, auditMap)
[totalRow, totalCol] = size(auditMap);
% Connect to Excel
Excel = actxserver('excel.application');
if exist(fileName, 'file')
	WB = Excel.Workbooks.Open(fileName, 0, false);
else
	WB = Excel.Workbooks.Add;
end
% WB.Worksheets.Item(1).Range('A2').Interior.Color = hex2dec('00FF00');
WB.Worksheets.Item(1).Range('A1').Value = 'Wafer Test Report';
WB.Worksheets.Item(1).Range('A1').Font.Size = 26;
WB.Worksheets.Item(1).Range('A1').Font.Bold = 1;

firstRow = 2; lastRow = firstRow + totalRow + 2;
firstCol = 'A'; lastCol = 'S'; middleCol = 'J'; tableFirstCol = 'G';
% 子表标题
eRange = sprintf('%s%d', firstCol, firstRow);
WB.Worksheets.Item(1).Range(eRange).Value = 'Wafer NO:';
eRange = sprintf('%s%d', middleCol, firstRow);
WB.Worksheets.Item(1).Range(eRange).Value = waferName;
WB.Worksheets.Item(1).Range(eRange).Font.Size = 20;
% WB.Worksheets.Item(1).Range('I171').Font.Size = 26;
eRange = sprintf('%s%d:%s%d', firstCol, firstRow, lastCol, firstRow);
WB.Worksheets.Item(1).Range(eRange).Borders.Item('xlEdgeBottom').LineStyle = 1;
WB.Worksheets.Item(1).Range(eRange).Borders.Item('xlEdgeBottom').Weight    = 3;
% 子表底部
eRange = sprintf('%s%d:%s%d', firstCol, firstRow + totalRow + 2, lastCol, lastRow);
WB.Worksheets.Item(1).Range(eRange).Borders.Item('xlEdgeBottom').LineStyle = 1;
WB.Worksheets.Item(1).Range(eRange).Borders.Item('xlEdgeBottom').Weight    = 3;
% 子表右部
eRange = sprintf('%s%d:%s%d', lastCol, firstRow, lastCol, lastRow);
WB.Worksheets.Item(1).Range(eRange).Borders.Item('xlEdgeRight').LineStyle = 1;
WB.Worksheets.Item(1).Range(eRange).Borders.Item('xlEdgeRight').Weight    = 3;
% map边框
eRange = sprintf('%s%d:%s%d', tableFirstCol, firstRow + 2, tableFirstCol + totalCol - 1, firstRow + totalRow + 1);
WB.Worksheets.Item(1).Range(eRange).Borders.Item('xlEdgeLeft').LineStyle = 1;
WB.Worksheets.Item(1).Range(eRange).Borders.Item('xlEdgeLeft').Weight    = 3;
WB.Worksheets.Item(1).Range(eRange).Borders.Item('xlEdgeRight').LineStyle = 1;
WB.Worksheets.Item(1).Range(eRange).Borders.Item('xlEdgeRight').Weight    = 3;
WB.Worksheets.Item(1).Range(eRange).Borders.Item('xlEdgeTop').LineStyle = 1;
WB.Worksheets.Item(1).Range(eRange).Borders.Item('xlEdgeTop').Weight    = 3;
WB.Worksheets.Item(1).Range(eRange).Borders.Item('xlEdgeBottom').LineStyle = 1;
WB.Worksheets.Item(1).Range(eRange).Borders.Item('xlEdgeBottom').Weight    = 3;
WB.Worksheets.Item(1).Range(eRange).Borders.Item('xlInsideHorizontal').LineStyle = 1;
WB.Worksheets.Item(1).Range(eRange).Borders.Item('xlInsideHorizontal').Weight    = 2;
WB.Worksheets.Item(1).Range(eRange).Borders.Item('xlInsideVertical').LineStyle = 1;
WB.Worksheets.Item(1).Range(eRange).Borders.Item('xlInsideVertical').Weight    = 2;
% map序号
for i = 1 : totalRow
	num = sprintf('%02d', i);
	eRange = sprintf('%s%d', tableFirstCol - 1, firstRow + i + 1);
	WB.Worksheets.Item(1).Range(eRange).Value = num;
end
for i = 1 : totalCol
	num = sprintf('%02d', i);
	eRange = sprintf('%s%d', tableFirstCol + i - 1, firstRow + 1);
	WB.Worksheets.Item(1).Range(eRange).Value = num;
end

for i = 1 : totalRow
	for j = 1 : totalCol
		value = auditMap{i,j};
		eRange = sprintf('%s%d', tableFirstCol + j - 1, firstRow + i + 1);
		WB.Worksheets.Item(1).Range(eRange).Value = value;
	end
end

if ~exist(fileName, 'file')
	WB.SaveAs(fileName);
else
	WB.Save;
end
% Close Workbook
WB.Close();
% Quit Excel
Excel.Quit();
end
