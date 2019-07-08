function varargout = NUA_GUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
	'gui_Singleton',  gui_Singleton, ...
	'gui_OpeningFcn', @NUA_GUI_OpeningFcn, ...
	'gui_OutputFcn',  @NUA_GUI_OutputFcn, ...
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

function singleDataInit()
global ori mask detectionDone loadDone;
ori = [];
mask = [];
detectionDone = 0;
loadDone = 0;

function NUA_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
global processMode centerCol centerRow windowRadius settingDone;
singleDataInit();
uiSingleInit(handles);
centerCol = [];
centerRow = [];
windowRadius = [];
settingDone = [];
processMode = 1;
handles.output = hObject;
guidata(hObject, handles);

function varargout = NUA_GUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function filepathText_Callback(hObject, eventdata, handles)

function filepathText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

function [height, width] = getDataSize(handles)
num = get(handles.dataSizeMenu, 'value');
if num == 1
	height = 512; width = 640;
elseif num == 2
	height = 288; width = 384;
else
	height = 1024; width = 1280;
end

function choosePathButton_Callback(hObject, eventdata, handles)
global processMode ori ori3sig loadDone newpath single_filename detectionDone;
set(handles.filepathText, 'String', []);
detectionDone = 0;
loadDone = 0;
if processMode == 1
	singleDataInit();
	[height, width] = getDataSize(handles);
	oldpath = cd;
	if isempty(newpath) || ~exist('newpath', 'var')
		newpath=cd;
	end
	cd(newpath);
	[ filename, folder ] = uigetfile({'NUCDAC_*.xls'}, 'ѡ�������ļ�');
	if isequal(filename, 0) || isequal(folder, 0)
		errordlg('û��ѡ���ļ�', '����');
		cd(oldpath);
		return;
	else
		newpath = folder;
		cd(oldpath);
	end
	single_filename = filename;
	filepath = [folder, filename];
	set(handles.filepathText, 'String', filepath);
	% ��������
	startRow = str2num(get(handles.StartRowText, 'string'));
	startCol = str2num(get(handles.StartColText, 'string'));
	[ori, ori3sig] = loadData(filepath, height, width, startRow, startCol);
	loadDone = 1;
	% չʾ����
	set(handles.resultText, 'String', []);
	axes(handles.displayAxes1);
	cla reset;
	% 	ave = mean(ori(:));
	% 	sigma = std(ori(:));
	imshow(ori3sig, []);
	% 	imagesc(ori, [ave - 3 * sigma, ave + 3 * sigma]); colormap('gray');
	set(handles.displayAxes1, 'xTick', []);
	set(handles.displayAxes1, 'ytick', []);
	set(handles.showBPResButton,'visible','off');
	set(handles.showBSResButton,'visible','off');
	set(handles.showISResButton,'visible','off');
	set(handles.showAllResButton,'visible','off');
else
	oldpath = cd;
	if isempty(newpath) || ~exist('newpath', 'var')
		newpath=cd;
	end
	cd(newpath);
	[ folder ] = uigetdir('ѡ�������ļ���');
	if isequal(folder, 0)
		errordlg('û��ѡ���ļ���', '����');
		cd(oldpath);
		return;
	else
		newpath = folder;
		cd(oldpath);
	end
	set(handles.filepathText, 'String', folder);
end

function chooseCPPathButton_Callback(hObject, eventdata, handles)
global newCPpath
set(handles.CPfilepathText, 'String', []);
oldpath = cd;
if isempty(newCPpath) || ~exist('newCPpath', 'var')
	newCPpath = cd;
end
cd(newCPpath);
[ folder ] = uigetdir('ѡ�������ļ���');
if isequal(folder, 0)
	errordlg('û��ѡ���ļ���', '����');
	cd(oldpath);
	return;
else
	newCPpath = folder;
	cd(oldpath);
end
set(handles.CPfilepathText, 'String', folder);


function startDetectionButton_Callback(hObject, eventdata, handles)
global single_filename ori ori3sig mask bp_mask cr_mask is_mask spot_mask processMode ...
	centerCol centerRow windowRadius settingDone loadDone detectionDone ...
	reportFileName oriDataList
labelName = {'����', '����', '��״����', '�߿�', 'б��', '����', '����', '����'};
BPDetectionThres = str2double(get(handles.BPDetectionThres, 'string'));% äԪ�����ֵ
BCDetectionThres = str2double(get(handles.BCDetectionThres, 'string'));% ���л��м����ֵ
BSDetectionThres4 = str2double(get(handles.BSDetectionThres4, 'string'));% �߿�1/8�����ֵ
BSDetectionThres3 = str2double(get(handles.BSDetectionThres3, 'string'));% �߿�1/4�����ֵ
BSDetectionThres2 = str2double(get(handles.BSDetectionThres2, 'string'));% �߿�1/2�����ֵ
BSDetectionThres1 = str2double(get(handles.BSDetectionThres1, 'string'));% �߿�����ֵ
BSDetectionThres = [BSDetectionThres4, BSDetectionThres3, BSDetectionThres2, BSDetectionThres1];
is_lambda = 0.008; bp_lambda = 0.08; tol = 1e-7; maxIter = 1000;
startRow = str2double(get(handles.StartRowText, 'string'));
startCol = str2double(get(handles.StartColText, 'string'));
filepath = get(handles.filepathText, 'String');
CPpath = get(handles.CPfilepathText, 'String');
saveRes = get(handles.SaveResCheckBox, 'Value');
[height, width] = getDataSize(handles);
chipType = get(handles.dataSizeMenu, 'value');
if ~isempty(CPpath)
	useCPfile = 1;
else
	useCPfile = 0;
end
if settingDone
	windowInfo = sprintf('����[%d,%d]<%.1f', centerCol, centerRow, windowRadius);
	par.windowInfo = windowInfo;
else
	par.windowInfo = '�޴���';
end
if processMode == 1 % ��оƬģʽ
	if ~loadDone
		errordlg('����·��δѡ������ݼ���ʧ��', '����');
		return;
	end
	hWait = waitbar(0, '���ڼ��㣬���Ե�');
	img3sig = ori3sig;
	mask = zeros(size(ori)); spot_mask = mask; is_mask = mask;
	[bg, candidate] = LowRankByRPCA(img3sig, bp_lambda, tol, maxIter);
	[label, cr_mask, CR_Num, A_CR_Num] = getBadRowColFunc(img3sig, BCDetectionThres); % ���л���
	if label == -1
		[label, spot_mask, maxSpotScale, maxSpotDepth, A_spot] = getSpotFunc(bg, BSDetectionThres); % �߿�
		if label == -1
			[label] = getSlopingFunc(single_filename(1:end-4)); % б��
			if label == -1
				[label, is_mask, maxLen4, maxArea4, minRatio4, ...
					maxLen8, maxArea8, minRatio8, A_shadow] = getShadingFunc(img3sig); % ���ƺ�����
			end
		end
	end
	[bp_mask, BP_Num, maxCrowd, A_BP_Num, A_maxCrowd] = getBlindPixelFunc(ori, candidate, cr_mask, BPDetectionThres);
	if label == 8 && (maxCrowd >= 14 || BP_Num >= 100)
		label = 7;
	end
	singleOutput = {single_filename(1:end-4), ['ȱ������Ϊ: ', labelName{label}]};
	mask = cr_mask | spot_mask | is_mask | bp_mask;
	detectionDone = 1;
	if ishandle(hWait)
		close(hWait); delete(hWait);
	end
	set(handles.resultText, 'String', singleOutput);
	set(handles.showBPResButton,'visible','on');
	set(handles.showBSResButton,'visible','on');
	set(handles.showISResButton,'visible','on');
	set(handles.showAllResButton,'visible','on');
	% ��ʾͼ����
	axes(handles.displayAxes1);
	ave = mean(ori(:)); sigma = std(ori(:));
	imagesc(ori, [ave - 3 * sigma, ave + 3 * sigma]); colormap('gray'), hold on;
	Lrgb = label2rgb(mask, 'jet', 'w', 'shuffle');
	himage = imshow(Lrgb);
	set(himage, 'AlphaData', 0.2);
elseif processMode == 2 % ����Բģʽ
	if isempty(filepath)
		errordlg('����·��δѡ��', '����');
		return;
	end
	splitPath = strsplit(filepath, '\');
	folderName = splitPath{end}; % �ָԲ�ļ�����
	outputText = {};
	set(handles.BatchOutputText, 'String', []);
	if saveRes % �����ͷ
		outputFolder = [filepath, '���Խ��\']; % ������Խ��·��
		if ~exist(outputFolder,'dir')
			mkdir(outputFolder);
		end
		reportFileName = sprintf('%s%s_��ֵ%.1f_%.1f_%.1f_%.1f_%.1f_%.1f.xlsx', ...
			outputFolder, folderName, BPDetectionThres, BCDetectionThres, ...
			BSDetectionThres4, BSDetectionThres3, BSDetectionThres2, BSDetectionThres1);
		par.resultFileName = reportFileName;
		par.settingDone = settingDone;
		write2xls(par, 1);
	end
	parts = strsplit(folderName, '-');
	if numel(parts) > 2
		waferName = sprintf('%s-%s', parts{end-1}, parts{end});
	else
		waferName = folderName;
	end
	if useCPfile == 1
		CPFileName = [CPpath, '\611FPA-Report-', waferName, '.xls'];
		CPmap = checkCP(CPFileName, chipType);
	end
	filelist = dir([filepath, '/NUCDAC_*.xls']);
	dataNum = length(filelist);
	hWait = waitbar(0, '���ڼ��㣬���Ե�');
	xlsRowNum = 1;
	auditMap = initEmptyAuditMap(chipType);
	for i = 1 : dataNum
		filename = filelist(i).name;
		fullpath = fullfile(filepath, filename);
		row = str2num(filename(end-7 : end-6));
		col = str2num(filename(end-5 : end-4));
		if useCPfile == 1
			if CPmap(row, col) == 0
				continue;
			end
		end
		% ������ʼ��
		A_spot = -1; maxSpotScale = -1; maxSpotDepth = -1;
		A_shadow = -1;
		maxLen4 = -1; maxArea4 = -1; minRatio4 = -1;
		maxLen8 = -1; maxArea8 = -1; minRatio8 = -1;
		[img, img3sig]= loadData(fullpath, height, width, startRow, startCol);
		mask = zeros(size(img3sig)); spot_mask = mask; is_mask = mask;
		[bg, candidate] = LowRankByRPCA(img3sig, bp_lambda, tol, maxIter);
		[label, cr_mask, CR_Num, A_CR_Num] = getBadRowColFunc(img3sig, BCDetectionThres); % ���л���
		if label == -1
			[label, spot_mask, maxSpotScale, maxSpotDepth, A_spot] = getSpotFunc(bg, BSDetectionThres); % �߿�
			if label == -1
				[label] = getSlopingFunc(filename(1:end-4)); % б��
				if label == -1
					[label, is_mask, maxLen4, maxArea4, minRatio4, ...
						maxLen8, maxArea8, minRatio8, A_shadow] = getShadingFunc(img3sig); % ���ƺ�����
				end
			end
		end
		[bp_mask, BP_Num, maxCrowd, A_BP_Num, A_maxCrowd] = getBlindPixelFunc(img, candidate, cr_mask, BPDetectionThres);
		if label == 8 && (maxCrowd >= 14 || BP_Num >= 100)
			label = 7;
		end
		singleOutput = {filename(1:end-4), ['ȱ������Ϊ: ', labelName{label}], '--------------------'};
		mask = cr_mask | spot_mask | is_mask | bp_mask;
		auditMap{row, col} = labelName{label};
		outputText = [outputText, singleOutput];
		if saveRes % �������оƬ���Խ��
			xlsRowNum = xlsRowNum + 1;
			maskName = [outputFolder, filename(1:end-4), '.png']; imwrite(mask, maskName);
			parts = strsplit(folderName, '-');
			if numel(parts) > 2
				ID = sprintf('%s-%s-%d%02d', parts{end-1}, parts{end}, row, col);
			else
				ID = sprintf('%s-%d%02d', folderName, row, col);
			end
			par.ID = ID; par.label = label;
			par.BP_Num = BP_Num; par.maxCrowd = maxCrowd;
			par.A_BP_Num = A_BP_Num; par.A_maxCrowd = A_maxCrowd;
			par.CR_Num = CR_Num; par.A_CR_Num = A_CR_Num;
			par.A_spot = A_spot; par.maxSpotScale = maxSpotScale;
			par.maxSpotDepth = maxSpotDepth; par.A_shadow = A_shadow;
			par.maxLen4 = maxLen4; par.maxArea4 = maxArea4; par.minRatio4 = minRatio4;
			par.maxLen8 = maxLen8; par.maxArea8 = maxArea8; par.minRatio8 = minRatio8;
			write2xls(par, xlsRowNum);
		end
		if ishandle(hWait)
			waitbar(i / dataNum, hWait, ['�����', num2str(i), '/' num2str(dataNum), '�����Ե�']);
		else
			hWait = waitbar(i / dataNum, ['�����', num2str(i), '/' num2str(dataNum), '�����Ե�']);
		end
	end
	if ishandle(hWait)
		close(hWait); delete(hWait);
	end
	% ���AutoAudit��
	auditFileName = [filepath, '_AutoAudit.xls'];
	writeAuditFile(auditFileName, waferName, auditMap);
	set(handles.BatchOutputText, 'String', outputText); % �ı�չʾ����оƬ�����
	detectionDone = 1;
elseif processMode == 3 % ������ģʽ
	if isempty(filepath)
		errordlg('ԭʼ����·��δѡ��', '����');
		return;
	end
	oriDataList = [];
	outputText = {};
	set(handles.BatchOutputText, 'String', []);
	subpathList = dir(filepath); % �����ļ����б�
	xlsRowNum = 1;
	dateToday = datetime('today');
	dateStr = sprintf('%d-%d-%d', dateToday.Year, dateToday.Month, dateToday.Day);
	if length(subpathList) < 3
		% û�������ļ���
		return;
	end
	if saveRes % ���������ļ� д��ͷ
		reportFileName = sprintf('%s\\%s_��ֵ%.1f_%.1f_%.1f_%.1f_%.1f_%.1f.xlsx', ...
			filepath, dateStr, BPDetectionThres, BCDetectionThres, ...
			BSDetectionThres4, BSDetectionThres3, BSDetectionThres2, BSDetectionThres1);
		par.resultFileName = reportFileName;
		par.settingDone = settingDone;
		write2xls(par, 1);
	end
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
			if useCPfile == 1
				CPFileName = [CPpath, '\611FPA-Report-', waferName, '.xls'];
				CPmap = checkCP(CPFileName, chipType);
			end
			if saveRes % ���������ͼƬ�ļ���
				outputFolder = [filepath, '\', subpathName, '\', subsubpathName, '���Խ��\'];
				if ~exist(outputFolder, 'dir')
					mkdir(outputFolder);
				end
			end
			hWait = waitbar(0, ['���ڴ���', subpathName,'/',subsubpathName, '�����Ե�']);
			dataNum = length(fileList);
			auditMap = initEmptyAuditMap(chipType);
			for k3 = 1 : dataNum
				filename = fileList(k3).name; % die�ļ���
				fullpath = [filepath, '\', subpathName, '\', subsubpathName, '\', filename];
				row = str2num(filename(end-7 : end-6));
				col = str2num(filename(end-5 : end-4));
				if useCPfile == 1
					if CPmap(row, col) == 0
						continue;
					end
				end
				% ������ʼ��
				A_spot = -1; maxSpotScale = -1; maxSpotDepth = -1;
				A_shadow = -1;
				maxLen4 = -1; maxArea4 = -1; minRatio4 = -1;
				maxLen8 = -1; maxArea8 = -1; minRatio8 = -1;
				[img, img3sig]= loadData(fullpath, height, width, startRow, startCol);
				mask = zeros(size(img3sig)); spot_mask = mask; is_mask = mask;
				[bg, candidate] = LowRankByRPCA(img3sig, bp_lambda, tol, maxIter);
				[label, cr_mask, CR_Num, A_CR_Num] = getBadRowColFunc(img3sig, BCDetectionThres); % ���л���
				if label == -1
					[label, spot_mask, maxSpotScale, maxSpotDepth, A_spot] = getSpotFunc(bg, BSDetectionThres); % �߿�
					if label == -1
						[label] = getSlopingFunc(filename(1:end-4)); % б��
						if label == -1
							[label, is_mask, maxLen4, maxArea4, minRatio4, ...
								maxLen8, maxArea8, minRatio8, A_shadow] = getShadingFunc(img3sig); % ���ƺ�����
						end
					end
				end
				[bp_mask, BP_Num, maxCrowd, A_BP_Num, A_maxCrowd] = getBlindPixelFunc(img, candidate, cr_mask, BPDetectionThres);
				if label == 8 && (maxCrowd >= 14 || BP_Num >= 100)
					label = 7;
				end
				mask = cr_mask | spot_mask | is_mask | bp_mask;
				auditMap{row, col} = labelName{label};
				if saveRes
					xlsRowNum = xlsRowNum + 1;
					maskName = [outputFolder, filename(1:end-4), '.png']; imwrite(mask, maskName);
					ID = sprintf('%s-%s', waferName, filename(end-7 : end-4));
					par.ID = ID; par.label = label;
					par.BP_Num = BP_Num; par.maxCrowd = maxCrowd;
					par.A_BP_Num = A_BP_Num; par.A_maxCrowd = A_maxCrowd;
					par.CR_Num = CR_Num; par.A_CR_Num = A_CR_Num;
					par.A_spot = A_spot; par.maxSpotScale = maxSpotScale;
					par.maxSpotDepth = maxSpotDepth; par.A_shadow = A_shadow;
					par.maxLen4 = maxLen4; par.maxArea4 = maxArea4; par.minRatio4 = minRatio4;
					par.maxLen8 = maxLen8; par.maxArea8 = maxArea8; par.minRatio8 = minRatio8;
					write2xls(par, xlsRowNum);
					dataItem.label = label;
					dataItem.maskPath = maskName;
					dataItem.oriDataPath = fullpath;
					dataItem.ID = ID;
					oriDataList = [oriDataList; dataItem];
				end
				if ishandle(hWait)
					waitbar(k3 / dataNum, hWait, ['���ڴ���', subpathName,'/',subsubpathName, '�������', num2str(k3), '/' num2str(dataNum), '�����Ե�']);
				else
					hWait = waitbar(k3 / dataNum, ['���ڴ���', subpathName,'/',subsubpathName, '�������', num2str(k3), '/' num2str(dataNum), '�����Ե�']);
				end
			end
			singleOutput = sprintf('%s/%s\n���%ddies����\n\n', subpathName, subsubpathName, dataNum);
			if ishandle(hWait)
				close(hWait); delete(hWait);
			end
			outputText = [outputText, singleOutput];
			% ���AutoAudit��
			auditFileName = [filepath, '\', subpathName, '\', waferName, '_AutoAudit.xls'];
			writeAuditFile(auditFileName, waferName, auditMap);
		end
	end
	set(handles.BatchOutputText, 'String', outputText);
	detectionDone = 1;
end

function [auditMap] = initEmptyAuditMap(chipType)
if chipType == 1
	totalRow = 10; totalCol = 9;
elseif chipType == 2
	totalRow = 12; totalCol = 11;
elseif chipType == 3
	totalRow = 8; totalCol = 7;
end
auditMap = cell(totalRow, totalCol);
% auditMap = zeros(totalRow, totalCol) - 1;

% չʾԭͼ
function showOriButton_Callback(hObject, eventdata, handles)
global loadDone ori;
if ~loadDone
	errordlg('����ѡ������·��', '����');
	return;
end
img = ori;
axes(handles.displayAxes1);
ave = mean(img(:));
sigma = std(img(:));
% imshow(img, []);
imagesc(img, [ave - 3 * sigma, ave + 3 * sigma]);
colormap('gray');
set(handles.displayAxes1, 'xTick', []);
set(handles.displayAxes1, 'ytick', []);

function displayAxes1_CreateFcn(hObject, eventdata, handles)
set(hObject,'xTick',[]);
set(hObject,'ytick',[]);

% չʾȫ�����
function showAllResButton_Callback(hObject, eventdata, handles)
global ori3sig mask detectionDone;
if detectionDone
	img = ori3sig;
	axes(handles.displayAxes1);
	% 	ave = mean(img(:));
	% 	sigma = std(img(:));
	imshow(img, []); hold on;
	% 	imagesc(img, [ave - 3 * sigma, ave + 3 * sigma]); colormap('gray'), hold on;
	Lrgb = label2rgb(mask, 'jet', 'w', 'shuffle');
	himage = imshow(Lrgb);
	set(himage, 'AlphaData', 0.2);
	set(handles.displayAxes1, 'xTick', []);
	set(handles.displayAxes1, 'ytick', []);
else
	errordlg('���ȿ�ʼ����', '����');
	return;
end

% չʾäԪ���н��
function showBPResButton_Callback(hObject, eventdata, handles)
global bp_mask cr_mask detectionDone;
if detectionDone
	axes(handles.displayAxes1);
	imshow(bp_mask | cr_mask);
else
	errordlg('���ȿ�ʼ����', '����');
	return;
end

% չʾ�߿���
function showBSResButton_Callback(hObject, eventdata, handles)
global spot_mask detectionDone;
if detectionDone
	axes(handles.displayAxes1);
	imshow(spot_mask);
else
	errordlg('���ȿ�ʼ����', '����');
	return;
end

% չʾ���ƽ��
function showISResButton_Callback(hObject, eventdata, handles)
global is_mask detectionDone;
if detectionDone
	axes(handles.displayAxes1);
	imshow(is_mask);
else
	errordlg('���ȿ�ʼ����', '����');
	return;
end

% ���ü�ⴰ��
function enterDetectionWindowButton_Callback(hObject, eventdata, handles)
global centerCol centerRow windowRadius settingDone
[flag, X, Y, R] = DetectionWindowSetting(settingDone, centerCol, centerRow, windowRadius);
if flag == 1
	settingDone = 1;
	centerCol = X; centerRow = Y; windowRadius = R;
	% 	fprintf('X:%d, Y:%d, R:%f\n', centerCol, centerRow, windowRadius);
elseif flag == 0
	settingDone = 0;
else
	% 	fprintf('����ȡ��\n');
end

%% ��оƬģʽ
function SingleData_Callback(hObject, eventdata, handles)
global processMode;
processMode = 1;
singleDataInit();
uiSingleInit(handles);

function uiSingleInit(handles)
singleDataInit();
set(handles.BatchOutputPanel,'visible','off');
set(handles.SingleDisplayPanel,'visible','on');
set(handles.showOriButton,'visible','on');
set(handles.showBPResButton,'visible','off');
set(handles.showBSResButton,'visible','off');
set(handles.showISResButton,'visible','off');
set(handles.showAllResButton,'visible','off');
set(handles.text28, 'visible', 'off');
set(handles.CPfilepathText, 'visible', 'off');
set(handles.chooseCPPathButton, 'visible', 'off');
set(handles.filepathText, 'String', []);
set(handles.resultText, 'String', []);
axes(handles.displayAxes1);
cla reset;
set(handles.displayAxes1, 'xTick', []);
set(handles.displayAxes1, 'ytick', []);
set(handles.SaveResCheckBox, 'visible', 'off');

%% ����Բģʽ
function BatchProcess_Callback(hObject, eventdata, handles)
global processMode;
processMode = 2;
uiBatchInit(handles);

function uiBatchInit(handles)
set(handles.SingleDisplayPanel,'visible','off');
set(handles.BatchOutputPanel,'visible','on');
set(handles.showOriButton,'visible','off');
set(handles.showBPResButton,'visible','off');
set(handles.showBSResButton,'visible','off');
set(handles.showISResButton,'visible','off');
set(handles.showAllResButton,'visible','off');
set(handles.filepathText, 'String', []);
set(handles.BatchOutputText, 'String', []);
set(handles.CPfilepathText, 'String', []);
set(handles.SaveResCheckBox, 'visible', 'on');
set(handles.CPfilepathText, 'visible', 'on');
set(handles.chooseCPPathButton, 'visible', 'on');
set(handles.text28, 'visible', 'on');

%% ������ģʽ
function FullpathProcess_Callback(hObject, eventdata, handles)
global processMode;
processMode = 3;
uiBatchInit(handles);

function HumanAuditNormal_Callback(hObject, eventdata, handles)
global processMode detectionDone reportFileName oriDataList
if processMode > 1 && detectionDone == 1
	ODpath = get(handles.filepathText, 'String');
	HumanAuditGUI('CALLBACK', ODpath, reportFileName, oriDataList, 1);
else
	HumanAuditGUI(1);
end

function HumanAuditBad_Callback(hObject, eventdata, handles)
global processMode detectionDone reportFileName oriDataList
if processMode > 1 && detectionDone == 1
	ODpath = get(handles.filepathText, 'String');
	HumanAuditGUI('CALLBACK', ODpath, reportFileName, oriDataList, 0);
else
	HumanAuditGUI(0);
end

function SaveResCheckBox_Callback(hObject, eventdata, handles)

function inCenterText_Callback(hObject, eventdata, handles)

function inCenterText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

function ProcessMode_Callback(hObject, eventdata, handles)

function BPDetectionThres_Callback(hObject, eventdata, handles)

function BPDetectionThres_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

function BCDetectionThres_Callback(hObject, eventdata, handles)

function BCDetectionThres_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

function dataSizeMenu_Callback(hObject, eventdata, handles)

function dataSizeMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

function BSDetectionThres4_Callback(hObject, eventdata, handles)

function BSDetectionThres4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

function BSCrowdThres_Callback(hObject, eventdata, handles)

function BSCrowdThres_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

function StartColText_Callback(hObject, eventdata, handles)

function StartColText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

function StartRowText_Callback(hObject, eventdata, handles)

function StartRowText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

function BatchOutputText_Callback(hObject, eventdata, handles)

function BatchOutputText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

function resultText_Callback(hObject, eventdata, handles)

function resultText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

function SSDetectionThres_Callback(hObject, eventdata, handles)

function SSDetectionThres_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

function CPfilepathText_Callback(hObject, eventdata, handles)

function CPfilepathText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

function BSDetectionThres3_Callback(hObject, eventdata, handles)

function BSDetectionThres3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

function BSDetectionThres2_Callback(hObject, eventdata, handles)

function BSDetectionThres2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

function BSDetectionThres1_Callback(hObject, eventdata, handles)

function BSDetectionThres1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

function HumanAudit_Callback(hObject, eventdata, handles)
