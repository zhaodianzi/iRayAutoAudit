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
global humanAuditDone ODpath DRfile CPpath chipType presentNum oriDataList totalNum
humanAuditDone = -1;
presentNum = 1;
set(handles.PrevDataButton, 'Enable', 'off');
set(handles.NextDataButton, 'Enable', 'on');
if isempty(varargin) % 离线
	[flag, ODpath, DRfile, CPpath, chipType] = ChoosePathGUI();
	if flag == 1
		oriDataList = getOriDataList();
		updatePresentInfo(handles);
	else
		HumanAuditGUI_CloseRequestFcn(hObject, eventdata, handles);
		return;
	end
else % 在线
% 	set(handles.DRpathText, 'string', varargin{1});
% 	set(handles.ODpathText, 'string', varargin{2});
	ODpath = varargin{2};
	DRfile = varargin{3};
	oriDataList = varargin{4};
	updatePresentInfo(handles);
end
totalNum = length(oriDataList);
handles.output = hObject;
guidata(hObject, handles);

function [] = updatePresentInfo(handles)
global oriDataList presentNum
startCol = 5; startRow = 9;
height = 512; width = 640;
img = loadData(oriDataList(presentNum).oriDataPath, height, width, startRow, startCol);
set(handles.ChipID, 'string', oriDataList(presentNum).ID);
label = oriDataList(presentNum).label;
defectName = {'坏列', '坏行', '柱状坏列', '斑块', '斜纹', '底纹', '其他', '正常'};
% 左侧
axes(handles.LeftDisplayArea);
cla reset;
ave = mean(img(:));
sigma = std(img(:));
imagesc(img, [ave - 3 * sigma, ave + 3 * sigma]); colormap('gray');
set(handles.LeftDisplayArea, 'xTick', []);
set(handles.LeftDisplayArea, 'ytick', []);
% 右侧
axes(handles.RightDisplayArea);
cla reset;
set(handles.RightAreaName, 'string', '程序检测结果');
set(handles.DefaultLevelText, 'string', ['程序判定：', defectName(label)]);
mask = imread(oriDataList(presentNum).maskPath);
imshow(mask);
set(handles.RightDisplayArea, 'xTick', []);
set(handles.RightDisplayArea, 'ytick', []);

function [oriDataList] = getOriDataList()
global ODpath DRfile CPpath chipType
if exist('CPpath', 'var') && ~isempty(CPpath)
	useCPfile = 1;
else
	useCPfile = 0;
end
oriDataList = [];
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
		if useCPfile == 1
			CPmap = checkCP([CPpath, '\611FPA-Report-', waferName, '.xls'], chipType);
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
			xlsRowNum = xlsRowNum + 1;
			maskPath = [outputFolder, filename(1:end-4), '.png'];  % die文件名
			fullpath = [ODpath, '\', subpathName, '\', subsubpathName, '\', filename];
			ID = sprintf('%s-%s', waferName, filename(end-7 : end-4));
			dataItem.maskPath = maskPath;
			dataItem.oriDataPath = fullpath;
			dataItem.ID = ID;
			oriDataList = [oriDataList; dataItem];
		end
	end
	if ishandle(hWait)
		waitbar(k1 / totalBatchNum, hWait, ['已加载', num2str(k1), '/', num2str(totalBatchNum), '个批次，请稍等']);
	else
		hWait = waitbar(k1 / totalBatchNum, ['已加载', num2str(k1), '/', num2str(totalBatchNum), '个批次，请稍等']);
	end
end
[~, ~, labelList] = xlsread(DRfile, 1, sprintf('A2:B%d', xlsRowNum));
nameList = labelList(:, 1);
for i = 1 : length(oriDataList)
	oriDataList(i).label = labelList{strcmp(nameList, oriDataList(i).ID)};
end
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
if presentNum == 1
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
if presentNum == totalNum
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
