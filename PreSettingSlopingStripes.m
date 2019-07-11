function varargout = PreSettingSlopingStripes(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PreSettingSlopingStripes_OpeningFcn, ...
                   'gui_OutputFcn',  @PreSettingSlopingStripes_OutputFcn, ...
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

function PreSettingSlopingStripes_OpeningFcn(hObject, eventdata, handles, varargin)
global SlopingSetUpDone chipType
SlopingSetUpDone = 0;
if isempty(varargin)
	chipType = 1;
else
	chipType = varargin{2};
end
loadLocalConfigFile(handles);
handles.output = hObject;
guidata(hObject, handles);
uiwait(handles.PreSettingSlopingStripes);

function varargout = PreSettingSlopingStripes_OutputFcn(hObject, eventdata, handles) 
global SlopingSetUpDone 
varargout{1} = SlopingSetUpDone;
if SlopingSetUpDone == 1
	delete(handles.PreSettingSlopingStripes);
end

function [] = loadLocalConfigFile(handles)
global chipType
if chipType == 1
	totalRow = 10; totalCol = 9;
elseif chipType == 2
	totalRow = 12; totalCol = 11;
elseif chipType == 3
	totalRow = 8; totalCol = 7;
end
configFile = 'SlopingConfig.mat';
if ~exist(configFile, 'file')
	req = questdlg('斜纹配置文件不存在，是否创建？','警告','是','否','是');
	if strcmp(req, '是') == 1
		slopingFlag = cell(totalRow, totalCol);
		save('SlopingConfig.mat', 'slopingFlag');
	else
		return;
	end
end
load(configFile);
set(handles.SlopingFlagTable, 'Data', slopingFlag);

function Save2FileButton_Callback(hObject, eventdata, handles)
global SlopingSetUpDone
slopingFlag = get(handles.SlopingFlagTable, 'Data');
[row, col] = size(slopingFlag);
flag = 1;
for i = 1 :row
	for j = 1 : col
		if ~isempty(slopingFlag{i,j})
			if (slopingFlag{i,j} ~= 0 && slopingFlag{i,j} ~= 1)
				flag = 0;
			end
		end
	end
end
if flag == 1
	SlopingSetUpDone = 1;
	save('SlopingConfig.mat', 'slopingFlag');
	uiresume(handles.PreSettingSlopingStripes);
else
	errordlg('配置不正确！请用数字0或1填写表格！','错误');
end
