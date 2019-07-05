function varargout = DetectionWindowSetting(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DetectionWindowSetting_OpeningFcn, ...
                   'gui_OutputFcn',  @DetectionWindowSetting_OutputFcn, ...
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

function DetectionWindowSetting_OpeningFcn(hObject, eventdata, handles, varargin)
global setWindowDone
setWindowDone = -1;
settingDone = varargin{1};
if settingDone
	set(handles.centerCol, 'string', num2str(varargin{2}));
	set(handles.centerRow, 'string', num2str(varargin{3}));
	set(handles.windowRadius, 'string', num2str(varargin{4}));
else
	
end
handles.output = hObject;
guidata(hObject, handles);
uiwait(handles.DetectionWindowSettingGUI);

function varargout = DetectionWindowSetting_OutputFcn(hObject, eventdata, handles) 
global setWindowDone
varargout{1} = setWindowDone;
if setWindowDone == 1
	centerCol = str2double(get(handles.centerCol, 'string'));
	centerRow = str2double(get(handles.centerRow, 'string'));
	windowRadius = str2double(get(handles.windowRadius, 'string'));
	varargout{2} = centerCol;
	varargout{3} = centerRow;
	varargout{4} = windowRadius;
	delete(handles.DetectionWindowSettingGUI);
elseif setWindowDone == 0
	varargout{2} = [];
	varargout{3} = [];
	varargout{4} = [];
	delete(handles.DetectionWindowSettingGUI);
else
	varargout{2} = [];
	varargout{3} = [];
	varargout{4} = [];
end

function OKButton_Callback(hObject, eventdata, handles)
global setWindowDone
setWindowDone = 1;
uiresume(handles.DetectionWindowSettingGUI);

function ClearButton_Callback(hObject, eventdata, handles)
global setWindowDone
setWindowDone = 0;
uiresume(handles.DetectionWindowSettingGUI);

function centerCol_Callback(hObject, eventdata, handles)

function centerCol_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function centerRow_Callback(hObject, eventdata, handles)

function centerRow_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function windowRadius_Callback(hObject, eventdata, handles)

function windowRadius_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function DetectionWindowSettingGUI_DeleteFcn(hObject, eventdata, handles)

function DetectionWindowSettingGUI_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);
