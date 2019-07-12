% 漏检率和误判率统计
[flag, ODpath, DRfile, CPpath, chipType] = ChoosePathGUI();
% if exist('CPpath', 'var') && ~isempty(CPpath)
% 	useCPfile = 1;
% else
% 	useCPfile = 0;
% end
% subpathList = dir(ODpath); % 批次文件夹列表
% xlsRowNum = 1;
% if length(subpathList) < 3 % 没有批次文件夹
% 	return;
% end
% totalBatchNum = 0;
% batchList = [];
% for k1 = 3 : length(subpathList)
% 	if subpathList(k1).isdir == 1
% 		batchList = [batchList; subpathList(k1)];
% 		totalBatchNum = totalBatchNum + 1;
% 	end
% end
reportFileName = sprintf('%s\\CountRate.xlsx', ODpath);
title = {'ID', '人工结果', '程序结果', '误判', '漏检'};
xlswrite(reportFileName, title, 1, 'A1');
% dataList = [];
% for k1 = 1 : totalBatchNum
% 	subpathName = batchList(k1).name;
% 	subsubpathList = dir([ODpath, '\', subpathName]); % 晶圆文件夹列表
% 	for k2 = 3 : length(subsubpathList)
% 		subsubpathName = subsubpathList(k2).name; % 晶圆文件夹名
% 		outputFolder = [ODpath, '\', subpathName, '\', subsubpathName,  '测试结果\']; % 测试结果文件夹
% 		if ~exist(outputFolder, 'dir')
% 			continue;
% 		end
% 		fileList = dir([ODpath, '\', subpathName, '\', subsubpathName, '\NUCDAC_*.xls']); % 数据文件
% 		if isempty(fileList)
% 			continue;
% 		end
% 		parts = strsplit(subsubpathName, '-');
% 		if numel(parts) > 2
% 			waferName = sprintf('%s-%s', parts{end-1}, parts{end});
% 		else
% 			waferName = subsubpathName;
% 		end
% 		if useCPfile == 1
% 			CPFileName = [CPpath, '\611FPA-Report-', waferName, '.xls'];
% 			CPmap = checkCP(CPFileName, chipType);
% 			AuditFileName = [ODpath, '\', subpathName, '\', waferName, '_Audit.xls'];
% 			humanAuditMap = getHumanAudit(AuditFileName, 2, chipType);
% 		end
% 		dataNum = length(fileList);
% 		for k3 = 1 : dataNum
% 			filename = fileList(k3).name;
% 			row = str2num(filename(end-7 : end-6));
% 			col = str2num(filename(end-5 : end-4));
% 			if useCPfile == 1
% 				if CPmap(row, col) == 0
% 					continue;
% 				end
% 				auditLevel = humanAuditMap(row, col);
% 				X = floor(auditLevel / 10);
% 				Y = mod(auditLevel, 10);
% 				switch Y
% 					case {2}
% 						humanLabel = 1;
% 					case {3,4}
% 						humanLabel = 4;
% 					case {5,6}
% 						humanLabel = 5;
% 					case {7,8}
% 						humanLabel = 6;
% 					case {1,9}
% 						humanLabel = 7;
% 					case {0}
% 						humanLabel = 8;
% 				end
% 				dataItem.humanLabel = humanLabel;
% 				dataItem.auditLevel = auditLevel;
% 			end
% 			xlsRowNum = xlsRowNum + 1;
% 			ID = sprintf('%s-%s', waferName, filename(end-7 : end-4));
% 			dataItem.ID = ID;
% 			dataList = [dataList; dataItem];
% 		end
% 	end
% end
autoLabelList = xlsread(DRfile, 1, sprintf('B2:B%d', xlsRowNum));
underKillArr = zeros(length(dataList), 1);
overKillArr = zeros(length(dataList), 1);
allData = cell(length(dataList), 5);
for i = 1 : length(dataList)
	if dataList(i).humanLabel == 8 && autoLabelList(i) < 8
		overKillArr(i) = 1;
	elseif dataList(i).humanLabel < 8 && autoLabelList(i) == 8
		underKillArr(i) = 1;
	end
	singleItem = {dataList(i).ID, dataList(i).auditLevel, autoLabelList(i), overKillArr(i), underKillArr(i)};
	allData(i,:) = singleItem;% = [allData; singleItem];
end
xlswrite(reportFileName, allData, 1, 'A2');