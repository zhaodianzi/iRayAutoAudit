function varargout = HumanAuditGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HumanAuditGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @HumanAuditGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function HumanAuditGUI_OpeningFcn(hObject, eventdata, handles, varargin)
global humanAuditDone ODpath DRfile CPpath chipType presentNum dataList totalNum wrongList mode
humanAuditDone = -1;
presentNum = 1;
set(handles.PrevDataButton, 'Enable', 'off');
set(handles.NextDataButton, 'Enable', 'on');
if length(varargin) < 5 % 离线
	mode = varargin{1};
	[flag, ODpath, DRfile, CPpath, chipType] = ChoosePathGUI();
	if flag == 1
		dataList = getDataList();
	else
		HumanAuditGUI_CloseRequestFcn(hObject, eventdata, handles);
		return;
	end
else % 在线
	ODpath = varargin{2};
	DRfile = varargin{3};
	dataList = varargin{4};
	mode = varargin{5};
	flag = zeros(length(dataList), 1);
	for i = 1 : length(dataList)
		if mode == 1
			if dataList(i).label == 8
				flag(i) = 1;
			end
		else
			if dataList(i).label ~= 8
				flag(i) = 1;
			end
		end
	end
	dataList = dataList(flag == 1);  % 只留下正常，待修改
end
if mode == 1
	set(handles.wrongButton, 'string', '漏检');
else
	set(handles.wrongButton, 'string', '误判');
end
totalNum = length(dataList);
wrongList = zeros(totalNum, 1);
set(handles.totalNumText, 'string', ['/ ', num2str(totalNum)]);
updatePresentInfo(handles);
handles.output = hObject;
guidata(hObject, handles);

function [] = updatePresentInfo(handles)
global dataList presentNum ori3sig mask totalNum
if presentNum <= 1
	presentNum = 1;
	set(handles.PrevDataButton, 'Enable', 'off');
end
if presentNum >= totalNum
	presentNum = totalNum;
	set(handles.NextDataButton, 'Enable', 'off');
end
if presentNum > 1
	set(handles.PrevDataButton, 'Enable', 'on');
end
if presentNum < totalNum
	set(handles.NextDataButton, 'Enable', 'on');
end
startCol = 5; startRow = 9;
height = 512; width = 640;
[~, ori3sig] = loadData(dataList(presentNum).oriDataPath, height, width, startRow, startCol);
mask = imread(dataList(presentNum).maskPath);
set(handles.ChipID, 'string', dataList(presentNum).ID);
set(handles.presentNumEdit, 'string', num2str(presentNum));
label = dataList(presentNum).label;
defectName = {'坏列', '坏行', '柱状坏列', '斑块', '斜纹', '底纹', '其他', '正常'};
labelArr = [1,1,1,2,3,4,5,6];
set(handles.DefectMenu, 'value', labelArr(label));
humanLabel = dataList(presentNum).humanLabel;
if humanLabel == 0
	set(handles.DefaultLevelText, 'string', ['无人工判定结果']);
else
	set(handles.DefaultLevelText, 'string', ['人工判定: ', num2str(humanLabel)]);
end
% 左侧
axes(handles.LeftDisplayArea);
cla reset;
imshow(ori3sig, []);
if label < 8
	hold on;
	Lrgb = label2rgb(mask, 'spring', 'k', 'shuffle');
	himage = imshow(Lrgb);
	set(himage, 'AlphaData', 0.2);
end
set(handles.LeftDisplayArea, 'xTick', []);
set(handles.LeftDisplayArea, 'ytick', []);

function [dataList] = getDataList()
global ODpath DRfile CPpath chipType mode
if exist('CPpath', 'var') && ~isempty(CPpath)
	useCPfile = 1;
else
	useCPfile = 0;
end
dataList = [];
subpathList = dir(ODpath); % 批次文件夹列表
xlsRowNum = 1;
if length(subpathList) < 3
	% 没有批次文件夹
	return;
end
totalBatchNum = 0;
batchList = [];
for k1 = 3 : length(subpathList)
	if subpathList(k1).isdir == 1
		batchList = [batchList; subpathList(k1)];
		totalBatchNum = totalBatchNum + 1;
	end
end
hWait = waitbar(0, '正在加载数据，请稍等');
for k1 = 1 : totalBatchNum
	subpathName = batchList(k1).name;
	subsubpathList = dir([ODpath, '\', subpathName]); % 晶圆文件夹列表
	for k2 = 3 : length(subsubpathList)
		subsubpathName = subsubpathList(k2).name; % 晶圆文件夹名
% 		dataItem.waferName = subsubpathName;
		outputFolder = [ODpath, '\', subpathName, '\', subsubpathName,  '测试结果\']; % 测试结果文件夹
		if ~exist(outputFolder, 'dir')
			continue;
		end
		fileList = dir([ODpath, '\', subpathName, '\', subsubpathName, '\NUCDAC_*.xls']); % 数据文件
		if isempty(fileList)
			continue;
		end
		parts = strsplit(subsubpathName, '-');
		if numel(parts) > 2
			waferName = sprintf('%s-%s', parts{end-1}, parts{end});
		else
			waferName = subsubpathName;
		end
		humanFlag = 0;
		if useCPfile == 1
			CPFileName = [CPpath, '\611FPA-Report-', waferName, '.xls'];
			CPmap = checkCP(CPFileName, chipType);
		end
		AuditFileName = [ODpath, '\', subpathName, '\', waferName, '_Audit.xls'];
		if exist(AuditFileName,'file')
			humanFlag = 1;
			humanAuditMap = getHumanAudit(AuditFileName, 2, chipType);
		end
		dataNum = length(fileList);
		for k3 = 1 : dataNum
			filename = fileList(k3).name;
			row = str2num(filename(end-7 : end-6));
			col = str2num(filename(end-5 : end-4));
			if useCPfile == 1
				if CPmap(row, col) == 0
					continue;
				end
			end
			if humanFlag == 1
				auditLevel = humanAuditMap(row, col);
				dataItem.humanLabel = auditLevel;
			else
				dataItem.humanLabel = 0;
			end
			xlsRowNum = xlsRowNum + 1;
			maskPath = [outputFolder, filename(1:end-4), '.png'];  % die文件名
			fullpath = [ODpath, '\', subpathName, '\', subsubpathName, '\', filename];
			ID = sprintf('%s-%s', waferName, filename(end-7 : end-4));
			dataItem.maskPath = maskPath;
			dataItem.oriDataPath = fullpath;
			dataItem.ID = ID;
			dataList = [dataList; dataItem];
		end
	end
	if ishandle(hWait)
		waitbar(k1 / totalBatchNum, hWait, ['已加载', num2str(k1), '/', num2str(totalBatchNum), '个批次，请稍等']);
	else
		hWait = waitbar(k1 / totalBatchNum, ['已加载', num2str(k1), '/', num2str(totalBatchNum), '个批次，请稍等']);
	end
end
[~, ~, rawList] = xlsread(DRfile, 1, sprintf('A2:B%d', xlsRowNum));
nameList = rawList(:, 1);
labelList = rawList(:, 2);
flag = zeros(length(dataList), 1);
for i = 1 : length(dataList)
	temp = labelList{strcmp(nameList, dataList(i).ID)};
	if ~isempty(temp)
		dataList(i).label = temp;
	else
		dataList(i).label = 0;
	end
	if mode == 1
		if dataList(i).label == 8
			flag(i) = 1;
		end
	else
		if dataList(i).label < 8 && dataList(i).label > 0
			flag(i) = 1;
		end
	end
end
dataList = dataList(flag == 1);
if ishandle(hWait)
	close(hWait); delete(hWait);
end

function varargout = HumanAuditGUI_OutputFcn(hObject, eventdata, handles) 
global humanAuditDone
varargout{1} = humanAuditDone;
if humanAuditDone == 1
	delete(handles.HumanAuditGUI);
elseif humanAuditDone == 0
	delete(handles.HumanAuditGUI);
else
end

function HumanAuditGUI_DeleteFcn(hObject, eventdata, handles)

function HumanAuditGUI_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);

function HumanLevelMenu_Callback(hObject, eventdata, handles)

function HumanLevelMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SaveLevelButton_Callback(hObject, eventdata, handles)
% 保存当前评级
defectMap = [1,4,5,6,7,8];
defect = get(handles.DefectMenu, 'value');
writeHumanLevel(defectMap(defect));

function QuickPassButton_Callback(hObject, eventdata, handles)
global presentNum totalNum
% 保存当前评级 
writeHumanLevel(8);
% 切换下一个
if presentNum == totalNum
	set(handles.QuickPassButton, 'Enable', 'off');
else
	NextDataButton_Callback(hObject, eventdata, handles);
end

function PrevDataButton_Callback(hObject, eventdata, handles)
global presentNum totalNum
presentNum = presentNum - 1;
if presentNum <= totalNum && presentNum >= 1
	updatePresentInfo(handles);
end
if presentNum <= 1
	presentNum = 1;
	set(handles.PrevDataButton, 'Enable', 'off');
end
if presentNum < totalNum
	set(handles.NextDataButton, 'Enable', 'on');
end

function NextDataButton_Callback(hObject, eventdata, handles)
global presentNum totalNum
% 切换下一个
presentNum = presentNum + 1;
if presentNum <= totalNum
	updatePresentInfo(handles);
end
if presentNum > 1
	set(handles.PrevDataButton, 'Enable', 'on');
end
if presentNum >= totalNum
	presentNum = totalNum;
	set(handles.NextDataButton, 'Enable', 'off');
end

function [] = writeHumanLevel(humanLevel)
global DRfile presentNum
xlswrite(DRfile, {humanLevel}, 1, sprintf('B%d', presentNum + 1));

function TypeMenu_Callback(hObject, eventdata, handles)

function TypeMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function DefectMenu_Callback(hObject, eventdata, handles)

function DefectMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function showOriButton_Callback(hObject, eventdata, handles)
global ori3sig
axes(handles.LeftDisplayArea);
imshow(ori3sig, []);
set(handles.LeftDisplayArea, 'xTick', []);
set(handles.LeftDisplayArea, 'ytick', []);

function showResButton_Callback(hObject, eventdata, handles)
global ori3sig mask
axes(handles.LeftDisplayArea);
imshow(ori3sig, []); hold on;
Lrgb = label2rgb(mask, 'spring', 'k', 'shuffle');
himage = imshow(Lrgb);
set(himage, 'AlphaData', 0.2);
set(handles.LeftDisplayArea, 'xTick', []);
set(handles.LeftDisplayArea, 'ytick', []);

function HumanAuditGUI_WindowKeyPressFcn(hObject, eventdata, handles)
kid = eventdata.Key;
% fprintf('%s\n', kid);
if strcmp(kid, 'leftarrow')
	PrevDataButton_Callback(hObject, eventdata, handles);
end
if strcmp(kid, 'rightarrow')
	NextDataButton_Callback(hObject, eventdata, handles);
end

function presentNumEdit_Callback(hObject, eventdata, handles)

function presentNumEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function wrongButton_Callback(hObject, eventdata, handles)
global presentNum totalNum wrongList
% 保存当前评级
wrongList(presentNum) = 1;
% 切换下一个
if presentNum == totalNum
	set(handles.wrongButton, 'Enable', 'off');
else
	NextDataButton_Callback(hObject, eventdata, handles);
end

function printWrongListButton_Callback(hObject, eventdata, handles)
global totalNum wrongList dataList mode
if mode == 1
	fprintf('以下芯片存在漏检: \n');
else
	fprintf('以下芯片存在误判: \n');
end
for i = 1 : totalNum
	if wrongList(i) == 1
		fprintf('%s\n', dataList(i).ID);
	end
end

function QuickJumpButton_Callback(hObject, eventdata, handles)
global totalNum presentNum
num = str2num(get(handles.presentNumEdit, 'string'));
if ~isempty(num) && num == fix(num) && num >= 1 && num <= totalNum
	presentNum = num;
	updatePresentInfo(handles);
else
	errordlg('输入序号不合法！', '出错');
end
