function varargout = ChoosePathGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ChoosePathGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ChoosePathGUI_OutputFcn, ...
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

function ChoosePathGUI_OpeningFcn(hObject, eventdata, handles, varargin)
global choosePathDone ODpathDone DRfileDone
choosePathDone = -1;
ODpathDone = 0;
DRfileDone = 0;
handles.output = hObject;
guidata(hObject, handles);
uiwait(handles.ChoosePathGUI);

function varargout = ChoosePathGUI_OutputFcn(hObject, eventdata, handles) 
global choosePathDone
varargout{1} = choosePathDone;
if choosePathDone == 1
	varargout{2} = get(handles.OriginalDataPathText, 'string');
	varargout{3} = get(handles.DetectionResultFileText, 'string');
	varargout{4} = get(handles.CPFilePathText, 'string');
	varargout{5} = get(handles.dataTypeMenu, 'value');
	delete(handles.ChoosePathGUI);
elseif choosePathDone == 0 % δ���
	varargout{2} = []; varargout{3} = [];
	varargout{4} = []; varargout{5} = [];
	delete(handles.ChoosePathGUI);
else % ���˹ر�
	varargout{2} = []; varargout{3} = [];
	varargout{4} = []; varargout{5} = [];
end

function ChooseODPathButton_Callback(hObject, eventdata, handles)
global ODpathDone newODpath
set(handles.OriginalDataPathText, 'String', []);
oldpath = cd;
if isempty(newODpath) || ~exist('newODpath', 'var')
	newODpath = cd;
end
cd(newODpath);
[ folder ] = uigetdir('ѡ��ԭʼ�����ļ���');
if isequal(folder, 0)
	ODpathDone = 0;
	errordlg('û��ѡ���ļ���', '����');
	cd(oldpath);
	return;
end
ODpathDone = 1;
newODpath = folder;
cd(oldpath);
set(handles.OriginalDataPathText, 'String', folder);


function ChooseDRFileButton_Callback(hObject, eventdata, handles)
global DRfileDone
set(handles.DetectionResultFileText, 'String', []);
DRfolder = get(handles.OriginalDataPathText, 'String');
oldpath = cd;
cd(DRfolder);
[ filename, folder ] = uigetfile({'*.xlsx;*.xls'}, 'ѡ�������ļ�');
if isequal(filename, 0) || isequal(folder, 0)
	DRfileDone = 0;
	errordlg('û��ѡ���ļ�', '����');
	cd(oldpath);
	return;
end
DRfileDone = 1;
cd(oldpath);
filepath = [folder, filename];
set(handles.DetectionResultFileText, 'String', filepath);

function StartHumanAuditButton_Callback(hObject, eventdata, handles)
global choosePathDone ODpathDone DRfileDone
if ODpathDone && DRfileDone
	choosePathDone = 1;
	uiresume(handles.ChoosePathGUI);
else
	errordlg('û������ļ���ѡ��', '����');
	return;
end

function ChooseCPPathButton_Callback(hObject, eventdata, handles)
global newCPpath
set(handles.CPFilePathText, 'String', []);
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
set(handles.CPFilePathText, 'String', folder);


function OriginalDataPathText_Callback(hObject, eventdata, handles)

function OriginalDataPathText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ChoosePathGUI_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);

function ChoosePathGUI_DeleteFcn(hObject, eventdata, handles)

function dataTypeMenu_Callback(hObject, eventdata, handles)

function dataTypeMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function StartColEdit_Callback(hObject, eventdata, handles)

function StartColEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function StartRowEdit_Callback(hObject, eventdata, handles)

function StartRowEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function DetectionResultFileText_Callback(hObject, eventdata, handles)

function DetectionResultFileText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CPFilePathText_Callback(hObject, eventdata, handles)


function CPFilePathText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
