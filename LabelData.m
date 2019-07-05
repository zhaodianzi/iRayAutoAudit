% [ folder ] = uigetdir('ѡ�������ļ���');
% if isequal(folder, 0)
% 	return;
% end
resultPath = 'E:\BIT\iRay\code\data\all_dataset\';
filepath = 'E:\BIT\iRay\code\data\ȫ������\';
subpathList = dir(filepath); % �����ļ����б�
if length(subpathList) < 3
	% û�������ļ���
	return;
end
rowNum = 1;
% xlswrite(reportName, {'ID', 'X', 'Y', 'OriName'}, 1, 'A1');
% levelArr = [10,20,24,26,28,30,31,32,33,35,37,39,40,44,46,48,52,53,55,57,59]';
% labelArr = [ 8; 2; 3; 4; 5; 8;-1; 6; 7; 8; 9;10;-1;11;12;13;14;15;16;17;18];
% 10,20: BIN0, 32,52: ����, 24,33,44,53: �߿�, 26,35,46,55: б��, 28,37,48,57: ����, 39,59: ����,
% classArr = zeros(max(labelArr), 1);
% train_label = []; test_label = [];
% train_data = []; test_data = [];
% train_name = {}; test_name = {};
train_ori_name = {};
for k1 = 3 : length(subpathList)
	subpathName = subpathList(k1).name; % �����ļ�����
	subsubpathList = dir([filepath, '\', subpathName]); % ��Բ�ļ����б�
	for k2 = 3 : length(subsubpathList)
		subsubpathName = subsubpathList(k2).name; % ��Բ�ļ�����
		fileList = dir([filepath, '\', subpathName, '\', subsubpathName, '\NUCDAC_*.xls']); % �����ļ�
		if isempty(fileList)
			continue;
		end
		parts = strsplit(subsubpathName, '-');
		if numel(parts) > 2
			waferName = sprintf('%s-%s', parts{end-1}, parts{end});
		else
			waferName = subsubpathName;
		end
% 		AuditFileName = [filepath, '\', subpathName, '\', waferName, '_Audit.xls'];
% 		humanAuditMap = getHumanAudit(AuditFileName, 2);
		dataNum = length(fileList);
		for k3 = 1 : dataNum
			filename = fileList(k3).name; % die�ļ���
			fullpath = [filepath, '\', subpathName, '\', subsubpathName, '\', filename];
			row = str2num(filename(end-7 : end-6));
			col = str2num(filename(end-5 : end-4));
% 			auditLevel = humanAuditMap{row, col};
% 			if isempty(auditLevel)
% 				continue;
% 			end
% 			Y = auditLevel(end) - '0';
% 			if auditLevel(end-1) < '0' || auditLevel(end-1) > '9'
% 				continue;
% % 				X = [];
% 			else
% 				X = auditLevel(end-1) - '0';
% 			end
			[~, data] = loadData(fullpath, 512, 640, 9, 5);
			oriName = sprintf('%s-%s', waferName, filename(end-7 : end-4));
% 			label = labelText(X, Y, levelArr, labelArr);
% 			if isempty(label) || label < 0
% 				continue;
% 			end
			% ԭͼ
			ID = sprintf('%s.png', oriName);
			imwrite(im2uint8(data / 255), [resultPath, ID]);
			rowNum = rowNum + 1;
% 			fprintf('%s:\t%d\n', oriName, label);
		end
	end
end
% save('train_data.mat', 'train_data', 'train_label');
% save('test_data.mat', 'test_data', 'test_label');
% save('test_name.mat', 'test_name');
% save('train_name.mat', 'train_name');