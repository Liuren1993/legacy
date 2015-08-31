function varargout = NettedSen(varargin)
% NETTEDSEN MATLAB code for NettedSen.fig
%      NETTEDSEN, by itself, creates a new NETTEDSEN or raises the existing
%      singleton*.
%
%      H = NETTEDSEN returns the handle to a new NETTEDSEN or the handle to
%      the existing singleton*.
%
%      NETTEDSEN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NETTEDSEN.M with the given input arguments.
%
%      NETTEDSEN('Property','Value',...) creates a new NETTEDSEN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NettedSen_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NettedSen_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NettedSen

% Last Modified by GUIDE v2.5 25-May-2013 11:44:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @NettedSen_OpeningFcn, ...
    'gui_OutputFcn',  @NettedSen_OutputFcn, ...
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
% End initialization code - DO NOT EDIT
end

% --- Executes just before NettedSen is made visible.
function NettedSen_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NettedSen (see VARARGIN)

% Choose default command line output for NettedSen
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%*****************************  Initialize ****************************

handles.Selection = 0;
handles.Resolution = 200;
handles.CoverFlag = 0;

%******** initialize variables of Node Attribute Data Callbacks *******
handles.RCS = 0;
handles.CompressRatio = 0;
handles.Node_Sensitivity = 15;
handles.Node_SigBandWidth = 0;
handles.NoiseFigure = 0;
handles.Freq = 0;
handles.ReGain = 0;
handles.TrGain = 0;
handles.PowerAvg = 0;
handles.NodeY = 0;
handles.NodeX = 0;
handles.NodeLoss = 0;

%******** initialize variables of Data About Axis **********************
handles.axis_coordinateX = 0;
handles.axis_coordinateY = 0;
handles.axisXStart = 0;
handles.axisXEnd = 100;
handles.axisYStart = 0;
handles.axisYEnd = 100;

%******** initialize variables of Double Linklist Control **************
handles.NodeIndex = 0 ;
handles.MaxIndexNum = 0;
handles.NodeMode = 1; 
handles.Name = [1,2,3,4,5];
handles.NameUncode = {'Transmitter','Receiver','Radar','ESMreceiver','None'};
handles.ConfirmFlag = 0;
handles.DoubleConfirmFlag = 0;
handles.ConfirmColor = [0.9,0.95,1];
handles.ModifyColor = [1,1,1];
handles.UnchangedColor = [1,0.97,0.92];
handles.ForbiddenColor = [0,0,0];
handles.NodeData = NamedNode('Transmitter',0);
handles.CurrentData = FMCW_Radar;

guidata(hObject, handles);

% UIWAIT makes NettedSen wait for user response (see UIRESUME)
% uiwait(handles.NettedSen);
end

% --- Outputs from this function are returned to the command line.
function varargout = NettedSen_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


%% Main Function

function node_ButtonGroup_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in node_ButtonGroup
% eventdata  structure with the following fields (see UIBUTTONGROUP)
% EventName: string 'SelectionChanged' (read only)
% OldValue: handle of the previously selected object or empty if none was selected
% NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag')
    case 'draw_SNRandBeta'
        handles.Selection = 5;
        guidata(hObject, handles);
        handles.NettedReceiverArray = NettedReceiverArray;
        handles.NettedTransmitterArray = NettedTransmitterArray;
        handles.ESMReceiverArray = ESMReceiverArray;
        for n = 1 : handles.MaxIndexNum
            if (handles.NodeData(n).Name == 1)||(handles.NodeData(n).Name == 3)
                handles.NettedTransmitterArray = [handles.NettedTransmitterArray,handles.NodeData(n).Data];
                guidata(hObject, handles);
            end
            if (handles.NodeData(n).Name == 2)||(handles.NodeData(n).Name == 3)
                handles.NettedReceiverArray = [handles.NettedReceiverArray,handles.NodeData(n).Data];
                guidata(hObject, handles);
            end
            if (handles.NodeData(n).Name == 4)
                handles.ESMReceiverArray = [handles.ESMReceiverArray,handles.NodeData(n).Data];
                guidata(hObject, handles);
            end
        end
        handles.LPIBeta = LPI_NettedSystemSNR(handles.Resolution,...
            handles.axisXStart,handles.axisXEnd,handles.axisYStart,...
            handles.axisYEnd,handles.NettedTransmitterArray,handles.NettedReceiverArray,...
            handles.ESMReceiverArray);
        guidata(hObject, handles);  
        handles.NettedSystem = FMCW_NettedSystemSNR(handles.Resolution,...
            handles.axisXStart,handles.axisXEnd,handles.axisYStart,...
            handles.axisYEnd,handles.NettedTransmitterArray,handles.NettedReceiverArray);
        guidata(hObject, handles);        
    case 'draw_MIMObeta'
        handles.Selection = 4;
        guidata(hObject, handles);
        handles.NettedReceiverArray = NettedReceiverArray;
        handles.NettedTransmitterArray = NettedTransmitterArray;
        handles.ESMReceiverArray = ESMReceiverArray;
        for n = 1 : handles.MaxIndexNum
            if (handles.NodeData(n).Name == 1)||(handles.NodeData(n).Name == 3)
                handles.NettedTransmitterArray = [handles.NettedTransmitterArray,handles.NodeData(n).Data];
                guidata(hObject, handles);
            end
            if (handles.NodeData(n).Name == 2)||(handles.NodeData(n).Name == 3)
                handles.NettedReceiverArray = [handles.NettedReceiverArray,handles.NodeData(n).Data];
                guidata(hObject, handles);
            end
            if (handles.NodeData(n).Name == 4)
                handles.ESMReceiverArray = [handles.ESMReceiverArray,handles.NodeData(n).Data];
                guidata(hObject, handles);
            end
        end
        handles.LPIBeta = LPI_NettedSystemSNR(handles.Resolution,...
            handles.axisXStart,handles.axisXEnd,handles.axisYStart,...
            handles.axisYEnd,handles.NettedTransmitterArray,handles.NettedReceiverArray,...
            handles.ESMReceiverArray);
        guidata(hObject, handles);  
    case 'draw_NettedSystem'
        handles.Selection = 3;
        guidata(hObject, handles);
        handles.NettedReceiverArray = NettedReceiverArray;
        handles.NettedTransmitterArray = NettedTransmitterArray;
        for n = 1 : handles.MaxIndexNum
            if (handles.NodeData(n).Name == 1)||(handles.NodeData(n).Name == 3) 
                handles.NettedTransmitterArray = [handles.NettedTransmitterArray,handles.NodeData(n).Data];
                guidata(hObject, handles);
            end
            if (handles.NodeData(n).Name == 2)||(handles.NodeData(n).Name == 3)
                handles.NettedReceiverArray = [handles.NettedReceiverArray,handles.NodeData(n).Data];
                guidata(hObject, handles);
            end
        end
        handles.NettedSystem = FMCW_NettedSystemSNR(handles.Resolution,...
            handles.axisXStart,handles.axisXEnd,handles.axisYStart,...
            handles.axisYEnd,handles.NettedTransmitterArray,handles.NettedReceiverArray);
        guidata(hObject, handles);
    case 'draw_NettedRadar'
        handles.Selection = 2;
        guidata(hObject, handles);
        for n = 1 : handles.MaxIndexNum
            if handles.NodeData(n).Name == 3  % from handles.NameUncode 3 means 'Radar'
                DataArray(n)= handles.NodeData(n).Data;
            else
                error('Each node must be a radar! But node %d is not',n)
            end
        end
        DrawDataArray = FMCW_RadarArray(DataArray);
        handles.NettedRadar = FMCW_NettedRadarSNR(handles.Resolution,...
            handles.axisXStart,handles.axisXEnd,handles.axisYStart,...
            handles.axisYEnd,DrawDataArray);
        guidata(hObject, handles);
    case 'None'
        handles.Selection = 1;
        guidata(hObject, handles);
        % clear axe
        cla(handles.mainaxes);
        % Set background Color and Hold on
        set(handles.mainaxes,'Color',[0.95, 0.95, 1]);
        hold on
        DrawPointAll(hObject,handles)
        
end
end


% --- Executes on button press in node_Cover.
function node_Cover_Callback(hObject, eventdata, handles)
% clear axe
cla(handles.mainaxes);
% Set background Color and Hold on
set(handles.mainaxes,'Color',[0.95, 0.95, 1]);
%set(gca,'Color',Color)
hold on
% Drawing

switch handles.Selection
    case 5
        figure(3)
        [~,h] = contour( handles.LPIBeta.Grid_X , handles.LPIBeta.Grid_Y ,...
            transpose(handles.LPIBeta.Convert2dB('Mag')) ); grid on;
        set(h,'ShowText','on','Color','r','LevelStep',0.5);%,'LevelStep',5,'LevelStep',0.5
        [~,y] = contour( handles.NettedSystem.Grid_X , handles.NettedSystem.Grid_Y ,...
            transpose(handles.NettedSystem.Convert2dB('LogdB')) );
        set(y,'ShowText','on','LevelStep',handles.Node_Sensitivity);
    case 4
        [~,h] = contour( handles.LPIBeta.Grid_X , handles.LPIBeta.Grid_Y ,...
            transpose(handles.LPIBeta.Convert2dB('Mag')) ); grid on;
        set(h,'ShowText','on','Color','r');%,'LevelStep',5,'LevelStep',1
    case 3
        [~,y] = contour( handles.NettedSystem.Grid_X , handles.NettedSystem.Grid_Y ,...
            transpose(handles.NettedSystem.Convert2dB('LogdB')) );
        set(y,'ShowText','on','LevelStep',handles.Node_Sensitivity);
    case 2
        [~,y] = contour( handles.NettedRadar.Grid_X , handles.NettedRadar.Grid_Y ,...
            transpose(handles.NettedRadar.Convert2dB('LogdB')) );
        set(y,'ShowText','on','LevelStep',handles.Node_Sensitivity);
    case 1
        
    case 0
end
% Draw Grid
% XTick = get(handles.mainaxes,'XTick');
% YTick = get(handles.mainaxes,'YTick');
hold off
end

function node_graph_Callback(hObject, eventdata, handles)
% clear axe
cla(handles.mainaxes);
% Set background Color and Hold on
set(handles.mainaxes,'Color',[0.95, 0.95, 1]);
%set(gca,'Color',Color)
hold on
% Drawing

switch handles.Selection
    case 5
        [~,h] = contour( handles.LPIBeta.Grid_X , handles.LPIBeta.Grid_Y ,...
            transpose(handles.LPIBeta.Convert2dB('Mag')) ); grid on;
        set(h,'ShowText','on','Color','r','LevelStep',1);%,
        [~,y] = contour( handles.NettedSystem.Grid_X , handles.NettedSystem.Grid_Y ,...
            transpose(handles.NettedSystem.Convert2dB('LogdB')) );
        set(y,'ShowText','on','Color','b','LevelStep',15);
    case 4
        [~,h] = contour( handles.LPIBeta.Grid_X , handles.LPIBeta.Grid_Y ,...
            transpose(handles.LPIBeta.Convert2dB('Mag')) ); grid on;
        set(h,'ShowText','on','Color','r');%,'LevelStep',5
        
    case 3
            [~,y] = contour( handles.NettedSystem.Grid_X , handles.NettedSystem.Grid_Y ,...
                transpose(handles.NettedSystem.Convert2dB('LogdB')) );
            set(y,'ShowText','on');
            
    case 2
            [~,y] = contour( handles.NettedRadar.Grid_X , handles.NettedRadar.Grid_Y ,...
                transpose(handles.NettedRadar.Convert2dB('LogdB')) );
            set(y,'ShowText','on');
            
    case 1
        
    case 0
        
end

DrawPointAll(hObject,handles);
% Draw Grid
% XTick = get(handles.mainaxes,'XTick');
% YTick = get(handles.mainaxes,'YTick');
hold off

end



% --- Executes on button press in node_Savegraph.
function node_Savegraph_Callback(hObject, eventdata, handles)
new_f_handle=figure('visible','off');
new_axes=copyobj(handles.mainaxes,new_f_handle); %axes1是GUI界面绘图的坐标系
set(new_axes,'units','default','position','default');
[filename,pathname fileindex]=uiputfile({'*.jpg';'*.bmp'},'save picture as');
if ~filename
    return
else
    file=strcat(pathname,filename);
    switch fileindex %根据不同的选择保存为不同的类型
        case 1
            print(new_f_handle,'-djpeg',file);
        case 2
            print(new_f_handle,'-dbmp',file);
    end
end
delete(new_f_handle);

end

% --- Executes on button press in node_save.
function node_save_Callback(~, ~, handles)

% RCS = handles.RCS;
% nodeMode = handles.NodeMode;
% NodeData = handles.NodeData;
% NettedRadar = handles.NettedRadar;
% NettedReceiverArray = handles.NettedReceiverArray;
% NettedTransmitterArray = handles.NettedTransmitterArray;
% ESMReceiverArray = handles.ESMReceiverArray;
% NettedSystem = handles.NettedSystem;
% SingleRadar = handles.SingleRadar;
NodeData = handles.NodeData;
MaxIndexNum = handles.MaxIndexNum;
axisXStart = handles.axisXStart;
axisXEnd = handles.axisXEnd;
axisYStart = handles.axisYStart;
axisYEnd = handles.axisYEnd;
[newmatfile,newpath] = uiputfile('*.mat', 'Save As');
if newpath==0,
    disp 'Program ended. User cancel file saving.'
else
    wd=cd; %cd = Current Dictory
    cd(newpath); %Change to New Path
    save(newmatfile,'NodeData','MaxIndexNum','axisXStart','axisXEnd','axisYStart','axisYEnd');
    cd(wd);
    disp('Program ended. Simulation File was saved in: ');
    disp(['    ', newpath, newmatfile]);
end

end

% --- Executes on button press in node_load.
function node_load_Callback(hObject, eventdata, handles)
[newmatfile,newpath] = uigetfile('*.mat', 'Open');
if newpath~=0,
    
    wd=cd; %cd = Current Dictory
    cd(newpath); %Change to New Path
    
    load(newmatfile,'NodeData','MaxIndexNum','axisXStart','axisXEnd','axisYStart','axisYEnd');
    cd(wd);
    handles.NodeData = NodeData;
    handles.MaxIndexNum = MaxIndexNum;
    handles.axisXStart = axisXStart;
    handles.axisXEnd = axisXEnd;
    handles.axisYStart = axisYStart;
    handles.axisYEnd = axisYEnd;
    guidata(hObject, handles);
    
    handles.NodeIndex = 1;
    set(handles.node_Index , 'String',handles.NodeIndex);
    
    set(handles.mainaxes,'XLim',[handles.axisXStart,handles.axisXEnd]);    
    set(handles.mainaxes,'YLim',[handles.axisYStart,handles.axisYEnd]);
    set(handles.axis_XLeft,'String',handles.axisXStart);    
    set(handles.axis_XRight,'String',handles.axisXEnd);
    set(handles.axis_YBottom,'String',handles.axisYStart);
    set(handles.axis_YTop,'String',handles.axisYEnd);
    
    SetLoad(hObject,handles);
    guidata(hObject, handles);
end

end

%% ************************************** Get Input Data  **************************************
%   to get all essential data from GUI
%

%%   Data About Axis


function NettedSen_WindowButtonDownFcn(hObject, ~, handles)

if (handles.axis_coordinateX >= handles.axisXStart)&&...
        (handles.axis_coordinateX <= handles.axisXEnd)&&...
        (handles.axis_coordinateY >= handles.axisYStart)&&...
        (handles.axis_coordinateY <= handles.axisYEnd)
    set(handles.node_X,'String',handles.axis_coordinateX,'BackgroundColor', handles.ModifyColor);
    set(handles.node_Y,'String',handles.axis_coordinateY,'BackgroundColor', handles.ModifyColor );
    handles.NodeX = handles.axis_coordinateX;
    handles.NodeY = handles.axis_coordinateY;
    guidata(hObject,handles);
end


end


function mainaxes_CreateFcn(hObject, ~, handles)          %#ok<DEFNU>

set(hObject,'XLim',[0,100],'YLim',[0,100]);
set(hObject,'Color',[0.95, 0.95, 1]);
grid on ;
guidata(hObject,handles)

end

function NettedSen_WindowButtonMotionFcn(hObject, ~, handles)  %#ok<DEFNU>


axes(handles.mainaxes);
currPt = get(gca, 'CurrentPoint');
handles.axis_coordinateX = str2double(sprintf('%0.2f',currPt(1,1) ));
handles.axis_coordinateY = str2double(sprintf('%0.2f',currPt(1,2) ));
guidata(hObject,handles);

if (handles.axis_coordinateX >= handles.axisXStart)&&...
        (handles.axis_coordinateX <= handles.axisXEnd)&&...
        (handles.axis_coordinateY >= handles.axisYStart)&&...
        (handles.axis_coordinateY <= handles.axisYEnd)
    set(handles.CoordinateX,'String',handles.axis_coordinateX);
    set(handles.CoordinateY,'String',handles.axis_coordinateY);
    
    guidata(hObject,handles);
end

end



function axis_XLeft_Callback(hObject, ~, handles)         %#ok<DEFNU>
handles.axisXStart = str2double(get(handles.axis_XLeft , 'String'));
guidata(hObject,handles);
set(handles.mainaxes,'XLim',[handles.axisXStart,handles.axisXEnd]);
guidata(hObject,handles);
end
function axis_XLeft_CreateFcn(hObject, ~, ~)          %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function axis_XRight_Callback(hObject, ~, handles)  %#ok<DEFNU>
handles.axisXEnd = str2double(get(handles.axis_XRight , 'String'));
guidata(hObject,handles);
set(handles.mainaxes,'XLim',[handles.axisXStart,handles.axisXEnd]);
guidata(hObject,handles);
end
function axis_XRight_CreateFcn(hObject, ~, ~)   %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function axis_YBottom_Callback(hObject, ~, handles) %#ok<DEFNU>
handles.axisYStart = str2double(get(handles.axis_YBottom , 'String'));
guidata(hObject,handles);
set(handles.mainaxes,'YLim',[handles.axisYStart,handles.axisYEnd]);
guidata(hObject,handles);
end
function axis_YBottom_CreateFcn(hObject, ~, ~)  %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function axis_YTop_Callback(hObject, eventdata, handles)    %#ok<INUSL,DEFNU>
handles.axisYEnd = str2double(get(handles.axis_YTop , 'String'));
guidata(hObject,handles);
set(handles.mainaxes,'YLim',[handles.axisYStart,handles.axisYEnd]);
guidata(hObject,handles);
end
function axis_YTop_CreateFcn(hObject, ~, ~)     %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end






%% Node Attribute Data Callbacks

function node_Index_Callback(~, ~, ~)        %#ok<DEFNU>
error('Do NOT change Index value! Please to restart the GUI to avoid errors!')
end
function node_Index_CreateFcn(hObject, ~, ~)           %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end




function node_mode_Callback(hObject, ~, handles)      %#ok<DEFNU>
set(handles.node_mode,'BackgroundColor', handles.ModifyColor);
handles.NodeMode =  get(handles.node_mode,'Value') ;
guidata(hObject,handles);
end
function node_mode_CreateFcn(hObject, ~, ~)          %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function node_Loss_Callback(hObject, ~, handles)
set(handles.node_Loss,'BackgroundColor', handles.ModifyColor);
handles.NodeLoss = str2double(get(handles.node_Loss , 'String'));
handles.NodeLoss = 10^(handles.NodeLoss/10);
guidata(hObject,handles);
%
end
function node_Loss_CreateFcn(hObject, ~, ~)                   %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function node_X_Callback(hObject, ~, handles)                %#ok<DEFNU>
set(handles.node_X,'BackgroundColor', handles.ModifyColor);
handles.NodeX = str2double(get(handles.node_X , 'String'));
guidata(hObject,handles);
%
end
function node_X_CreateFcn(hObject, ~, ~)                  %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function node_Y_Callback(hObject, ~, handles)               %#ok<DEFNU>
set(handles.node_Y,'BackgroundColor', handles.ModifyColor);
handles.NodeY = str2double(get(handles.node_Y , 'String'));
guidata(hObject,handles);
%
end
function node_Y_CreateFcn(hObject, ~, ~)                   %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function node_PowerAVG_Callback(hObject, eventdata, handles)      %#ok<INUSL,DEFNU>
set(handles.node_PowerAVG,'BackgroundColor', handles.ModifyColor);
handles.PowerAvg = str2double(get(handles.node_PowerAVG , 'String'));
guidata(hObject,handles);
%
end
function node_PowerAVG_CreateFcn(hObject, ~, ~)                %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function node_TransmitterGain_Callback(hObject, ~, handles)         %#ok<DEFNU>
set(handles.node_TransmitterGain,'BackgroundColor', handles.ModifyColor);
handles.TrGain = str2double(get(handles.node_TransmitterGain , 'String'));
handles.TrGain = 10^(handles.TrGain/10);
guidata(hObject,handles);
%
end
function node_TransmitterGain_CreateFcn(hObject, ~, ~)    %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function node_ReceiverGain_Callback(hObject, ~, handles)      %#ok<DEFNU>
set(handles.node_ReceiverGain,'BackgroundColor', handles.ModifyColor);
handles.ReGain = str2double(get(handles.node_ReceiverGain , 'String'));
handles.ReGain = 10^(handles.ReGain/10);
guidata(hObject,handles);
%
end
function node_ReceiverGain_CreateFcn(hObject, ~, ~)    %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function node_Frequency_Callback(hObject, eventdata, handles)    %#ok<INUSL,DEFNU>
set(handles.node_Frequency,'BackgroundColor', handles.ModifyColor);
handles.Freq = str2double(get(handles.node_Frequency , 'String'));
guidata(hObject,handles);
%
end
function node_Frequency_CreateFcn(hObject, ~, ~)     %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function node_FR_Callback(hObject, ~, handles)   %#ok<DEFNU>
set(handles.node_FR,'BackgroundColor', handles.ModifyColor);
handles.NoiseFigure = str2double(get(handles.node_FR , 'String'));
handles.NoiseFigure = 10^(handles.NoiseFigure/10);
guidata(hObject,handles);
%
end
function node_FR_CreateFcn(hObject, ~, ~)  %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function node_SignalBand_Callback(hObject, ~, handles)     %#ok<DEFNU>
set(handles.node_SignalBand,'BackgroundColor', handles.ModifyColor);
handles.Node_SigBandWidth = str2double(get(handles.node_SignalBand , 'String'));
handles.Node_SigBandWidth = handles.Node_SigBandWidth * 10^6;
guidata(hObject,handles);
%
end
function node_SignalBand_CreateFcn(hObject, ~, ~)           %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function node_Sensi_Callback(hObject, ~, handles)            %#ok<DEFNU>
set(handles.node_Sensi,'BackgroundColor', handles.ModifyColor);
handles.Node_Sensitivity = str2double(get(handles.node_Sensi , 'String'));
% handles.Node_Sensitivity = 10^(handles.Node_Sensitivity/10) ;
guidata(hObject,handles);

end
function node_Sensi_CreateFcn(hObject, ~, ~)              %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function node_CompressRatio_Callback(hObject, ~, handles)            %#ok<DEFNU>
handles.CompressRatio = str2double(get(handles.node_CompressRatio , 'String'));
guidata(hObject,handles);

end
function node_CompressRatio_CreateFcn(hObject, ~, ~)              %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function node_RCS_Callback(hObject, ~, handles)                %#ok<DEFNU>
set(handles.node_RCS,'BackgroundColor', handles.ModifyColor);
handles.RCS = str2double(get(handles.node_RCS , 'String'));
guidata(hObject,handles);

end
function node_RCS_CreateFcn(hObject, ~, ~)                   %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



%% ************************************** Show Data  **************************************



%%  Data About Axis


function CoordinateX_Callback(~, ~, ~)                 %#ok<DEFNU>
end
function CoordinateX_CreateFcn(hObject, ~, ~)                 %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function CoordinateY_Callback(~, ~, ~)                 %#ok<DEFNU>
end
function CoordinateY_CreateFcn(hObject, ~, ~)             %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



%% Double Linklist Control
%   it worked well by a large amount of tests(maybe not that many),so do NOT edit these codes!
%   i didn't write annotations because these codes are not optimized.
%   btw: i hope i can understand these codes some time later... XD  forgive my lazy
%

function node_forward_Callback(hObject, ~, handles)
if handles.NodeIndex == 0
    set(handles.node_Index , 'String',1);       %initialize node_Index
    guidata(hObject,handles);
end

handles.NodeIndex = str2double(get(handles.node_Index , 'String'));  %get Index
handles.MaxIndexNum = max(handles.MaxIndexNum,handles.NodeIndex);    %get MAX value of Index
guidata(hObject,handles);
handles.DoubleConfirmFlag = 0;
guidata(hObject,handles);
if handles.NodeIndex == handles.MaxIndexNum
    if handles.ConfirmFlag == 1
        if ~isempty(handles.NodeData(handles.NodeIndex).Next)
            SetDataNext(hObject,handles);
            guidata(hObject,handles);
        else
            SetAllBlanks(hObject,handles);
            guidata(hObject,handles);
        end
        handles.NodeIndex = handles.NodeIndex + 1;
        set(handles.node_Index,'String',handles.NodeIndex );
        guidata(hObject,handles);
        
    end
    
else
    
    if ~isempty(handles.NodeData(handles.NodeIndex).Next)
        SetDataNext(hObject,handles);
        guidata(hObject,handles);
    else
        SetAllBlanks(hObject,handles);
        guidata(hObject,handles);
    end
    if (handles.NodeIndex + 1) == handles.MaxIndexNum
        handles.NodeData(handles.MaxIndexNum).delete;
        guidata(hObject,handles);
    end
    handles.NodeIndex = handles.NodeIndex + 1;
    set(handles.node_Index,'String',handles.NodeIndex );
    guidata(hObject,handles);
    
end
handles.ConfirmFlag = 0;
guidata(hObject,handles);
end


function node_back_Callback(hObject, ~, handles)
if handles.NodeIndex == 0
    set(handles.node_Index , 'String',1);
    guidata(hObject,handles);
end
handles.DoubleConfirmFlag = 0;
guidata(hObject,handles);
handles.NodeIndex = str2double(get(handles.node_Index , 'String'));
handles.MaxIndexNum = max(handles.MaxIndexNum,handles.NodeIndex);    %get MAX value of Index
guidata(hObject,handles);
if handles.NodeIndex == handles.MaxIndexNum
    if handles.ConfirmFlag == 1
        if ~isempty(handles.NodeData(handles.NodeIndex).Prev)
            SetDataPrev(hObject,handles);
            guidata(hObject,handles);
        else
            SetAllBlanks(hObject,handles);
            guidata(hObject,handles);
        end
        handles.NodeIndex = handles.NodeIndex - 1;
        if handles.NodeIndex ~= 0;
            set(handles.node_Index,'String',handles.NodeIndex );
            guidata(hObject,handles);
        end
    end
    
else
    if handles.NodeIndex == 1
        
    else
        if ~isempty(handles.NodeData(handles.NodeIndex).Prev)
            SetDataPrev(hObject,handles);
            guidata(hObject,handles);
        else
            SetAllBlanks(hObject,handles);
            guidata(hObject,handles);
        end
        handles.NodeIndex = handles.NodeIndex - 1;
        if handles.NodeIndex ~= 0;
            set(handles.node_Index,'String',handles.NodeIndex );
            guidata(hObject,handles);
        end
    end
    handles.ConfirmFlag = 0;
    guidata(hObject,handles);
end



end


function node_confirm_Callback(hObject, ~, handles)
if handles.NodeIndex == 0
    set(handles.node_Index , 'String',1);
    guidata(hObject,handles);
end
handles.NodeIndex = str2double(get(handles.node_Index , 'String'));
handles.MaxIndexNum = max(handles.MaxIndexNum,handles.NodeIndex);    %get MAX value of Index
guidata(hObject,handles);

%************* Refresh Data *******************************************
handles.NodeLoss = str2double(get(handles.node_Loss , 'String'));
handles.NodeLoss = 10^(handles.NodeLoss/10);
handles.CurrentData.Loss = handles.NodeLoss;
guidata(hObject,handles);

handles.NodeX = str2double(get(handles.node_X , 'String'));
handles.CurrentData.TransmitterPositionX = handles.NodeX;
handles.CurrentData.ReceiverPositionX = handles.NodeX;
guidata(hObject,handles);

handles.NodeY = str2double(get(handles.node_Y , 'String'));
handles.CurrentData.TransmitterPositionY = handles.NodeY;
handles.CurrentData.ReceiverPositionY = handles.NodeY;
guidata(hObject,handles);

handles.PowerAvg = str2double(get(handles.node_PowerAVG , 'String'));
handles.CurrentData.PowerAVG = handles.PowerAvg;
guidata(hObject,handles);


handles.TrGain = str2double(get(handles.node_TransmitterGain , 'String'));
handles.TrGain = 10^(handles.TrGain/10);
handles.CurrentData.Gain_Transmitter = handles.TrGain;
guidata(hObject,handles);

handles.ReGain = str2double(get(handles.node_ReceiverGain , 'String'));
handles.ReGain = 10^(handles.ReGain/10);
handles.CurrentData.Gain_Receiver = handles.ReGain;
guidata(hObject,handles);

handles.Freq = str2double(get(handles.node_Frequency , 'String'));
handles.CurrentData.Frequency = handles.Freq;
guidata(hObject,handles);

handles.NoiseFigure = str2double(get(handles.node_FR , 'String'));
handles.NoiseFigure = 10^(handles.NoiseFigure/10);
handles.CurrentData.NoiseFigure = handles.NoiseFigure;
guidata(hObject,handles);

handles.Node_SigBandWidth = str2double(get(handles.node_SignalBand , 'String'));
handles.Node_SigBandWidth = handles.Node_SigBandWidth * 10^6;
handles.CurrentData.BandWidth = handles.Node_SigBandWidth;
guidata(hObject,handles);

handles.RCS = str2double(get(handles.node_RCS , 'String'));
handles.CurrentData.RCS = handles.RCS;

handles.CompressRatio = str2double(get(handles.node_CompressRatio , 'String'));
handles.CurrentData.CompressRatio = handles.CompressRatio;

handles.NodeMode =  get(handles.node_mode,'Value') ;

guidata(hObject,handles);

%****************** Confirm Data ***************************************
handles.DoubleConfirmFlag = handles.DoubleConfirmFlag + 1;
guidata(hObject,handles);
if handles.NodeIndex == handles.MaxIndexNum
    if handles.NodeIndex == 1
        handles.NodeData(handles.NodeIndex) = NamedNode(handles.Name(handles.NodeMode),handles.CurrentData);
        if handles.MaxIndexNum >= 2
            handles.NodeData(handles.NodeIndex).insertBefore(handles.NodeData(handles.NodeIndex + 1));
            guidata(hObject,handles);
        end
    else
        if handles.DoubleConfirmFlag == 1
            handles.NodeData(handles.NodeIndex) = NamedNode(handles.Name(handles.NodeMode),handles.CurrentData);
            handles.NodeData(handles.NodeIndex).insertAfter(handles.NodeData(handles.NodeIndex - 1));
            guidata(hObject,handles);
            
        end
        if handles.NodeIndex < handles.MaxIndexNum
            handles.NodeData(handles.NodeIndex).insertBefore(handles.NodeData(handles.NodeIndex + 1));
            guidata(hObject,handles);
        end
    end
else
    if handles.NodeIndex == 1
        handles.NodeData(handles.NodeIndex).delete;
        handles.NodeData(handles.NodeIndex) = NamedNode(handles.Name(handles.NodeMode),handles.CurrentData);
        if handles.MaxIndexNum >= 2
            handles.NodeData(handles.NodeIndex).insertBefore(handles.NodeData(handles.NodeIndex + 1));
            guidata(hObject,handles);
        end
    else
        handles.NodeData(handles.NodeIndex).delete;
        handles.NodeData(handles.NodeIndex) = NamedNode(handles.Name(handles.NodeMode),handles.CurrentData);
        handles.NodeData(handles.NodeIndex).insertAfter(handles.NodeData(handles.NodeIndex - 1));
        guidata(hObject,handles);
        if handles.NodeIndex < handles.MaxIndexNum
            handles.NodeData(handles.NodeIndex).insertBefore(handles.NodeData(handles.NodeIndex + 1));
            guidata(hObject,handles);
        end
    end
end
SetConfirm(hObject,handles);
handles.ConfirmFlag = 1;
guidata(hObject,handles);
end


function node_remove_Callback(hObject, ~, handles)

handles.NodeIndex = str2double(get(handles.node_Index , 'String'));
if handles.NodeIndex ~= handles.MaxIndexNum
    handles.NodeData(handles.NodeIndex).Data = FMCW_Radar;
    handles.NodeData(handles.NodeIndex).Name = 5;
    SetAllBlanks(hObject,handles);
    guidata(hObject,handles);
else
    error('You can NOT delete the current node! This BUG in the GUI-function node_remove_Callback will be solved later')
end

end









%% Set Data or Blanks


function SetAllBlanks(hObject,handles)
   set(handles.node_Loss,'String', '','BackgroundColor', handles.ModifyColor );
   set(handles.node_X,'String', '','BackgroundColor', handles.ModifyColor );
   set(handles.node_Y,'String', '' ,'BackgroundColor', handles.ModifyColor);
   set(handles.node_PowerAVG,'String', '','BackgroundColor', handles.ModifyColor );
   set(handles.node_TransmitterGain,'String', '','BackgroundColor', handles.ModifyColor );
   set(handles.node_ReceiverGain,'String', '','BackgroundColor', handles.ModifyColor );
   set(handles.node_Frequency,'String', '','BackgroundColor', handles.ModifyColor );
   set(handles.node_FR,'String', '','BackgroundColor', handles.ModifyColor );
   set(handles.node_SignalBand,'String', '','BackgroundColor', handles.ModifyColor );
   set(handles.node_RCS,'String', '','BackgroundColor', handles.ModifyColor );
   set(handles.node_CompressRatio,'String', '','BackgroundColor', handles.ModifyColor );
   set(handles.node_mode,'BackgroundColor', handles.ModifyColor );
   
   guidata(hObject,handles);
end

function SetDataPrev(hObject,handles)
%*********************** Without Convert ********************************
   set(handles.node_X,'String', handles.NodeData(handles.NodeIndex).Prev.Data.TransmitterPositionX,'BackgroundColor', handles.UnchangedColor );
   set(handles.node_Y,'String', handles.NodeData(handles.NodeIndex).Prev.Data.TransmitterPositionY ,'BackgroundColor',handles.UnchangedColor);
   set(handles.node_PowerAVG,'String', handles.NodeData(handles.NodeIndex).Prev.Data.PowerAVG,'BackgroundColor', handles.UnchangedColor);
   set(handles.node_Frequency,'String', handles.NodeData(handles.NodeIndex).Prev.Data.Frequency ,'BackgroundColor', handles.UnchangedColor );
   set(handles.node_SignalBand,'String', handles.NodeData(handles.NodeIndex).Prev.Data.BandWidth,'BackgroundColor', handles.UnchangedColor );
   set(handles.node_RCS,'String',handles.NodeData(handles.NodeIndex).Prev.Data.RCS,'BackgroundColor', handles.UnchangedColor );
   set(handles.node_CompressRatio,'String',handles.NodeData(handles.NodeIndex).Prev.Data.CompressRatio,'BackgroundColor', handles.UnchangedColor );
   set(handles.node_mode,'Value',handles.NodeData(handles.NodeIndex).Prev.Name,'BackgroundColor', handles.UnchangedColor );   
   
   guidata(hObject,handles);
%*********************** Need Convert ***********************************
   ConvertLoss = 10*log10(handles.NodeData(handles.NodeIndex).Prev.Data.Loss);
   set(handles.node_Loss,'String',ConvertLoss,'BackgroundColor', handles.UnchangedColor );
   ConvertTrGain = 10*log10(handles.NodeData(handles.NodeIndex).Prev.Data.Gain_Transmitter);
   set(handles.node_TransmitterGain,'String',ConvertTrGain,'BackgroundColor',handles.UnchangedColor);
   ConvertReGain = 10*log10(handles.NodeData(handles.NodeIndex).Prev.Data.Gain_Receiver);
   set(handles.node_ReceiverGain,'String',ConvertReGain,'BackgroundColor', handles.UnchangedColor );
   ConvertFR = 10*log10(handles.NodeData(handles.NodeIndex).Prev.Data.NoiseFigure);
   set(handles.node_FR,'String',ConvertFR,'BackgroundColor', handles.UnchangedColor );
   ConvertSB = handles.NodeData(handles.NodeIndex).Prev.Data.BandWidth / (10^6);
   set(handles.node_SignalBand,'String',ConvertSB,'BackgroundColor', handles.UnchangedColor );
   
   guidata(hObject,handles);
end

function SetDataNext(hObject,handles)
%*********************** Without Convert ********************************
   set(handles.node_X,'String', handles.NodeData(handles.NodeIndex).Next.Data.TransmitterPositionX,'BackgroundColor', handles.UnchangedColor );
   set(handles.node_Y,'String', handles.NodeData(handles.NodeIndex).Next.Data.TransmitterPositionY ,'BackgroundColor',handles.UnchangedColor);
   set(handles.node_PowerAVG,'String', handles.NodeData(handles.NodeIndex).Next.Data.PowerAVG,'BackgroundColor', handles.UnchangedColor);
   set(handles.node_Frequency,'String', handles.NodeData(handles.NodeIndex).Next.Data.Frequency ,'BackgroundColor', handles.UnchangedColor );
   set(handles.node_RCS,'String',handles.NodeData(handles.NodeIndex).Next.Data.RCS,'BackgroundColor', handles.UnchangedColor );
   set(handles.node_CompressRatio,'String',handles.NodeData(handles.NodeIndex).Next.Data.CompressRatio,'BackgroundColor', handles.UnchangedColor );
   set(handles.node_mode,'Value',handles.NodeData(handles.NodeIndex).Next.Name,'BackgroundColor', handles.UnchangedColor );      
   
   guidata(hObject,handles);
%*********************** Need Convert ***********************************
   ConvertLoss = 10*log10(handles.NodeData(handles.NodeIndex).Next.Data.Loss);
   set(handles.node_Loss,'String',ConvertLoss,'BackgroundColor', handles.UnchangedColor );
   ConvertTrGain = 10*log10(handles.NodeData(handles.NodeIndex).Next.Data.Gain_Transmitter);
   set(handles.node_TransmitterGain,'String',ConvertTrGain,'BackgroundColor',handles.UnchangedColor);
   ConvertReGain = 10*log10(handles.NodeData(handles.NodeIndex).Next.Data.Gain_Receiver);
   set(handles.node_ReceiverGain,'String',ConvertReGain,'BackgroundColor', handles.UnchangedColor );
   ConvertFR = 10*log10(handles.NodeData(handles.NodeIndex).Next.Data.NoiseFigure);
   set(handles.node_FR,'String',ConvertFR,'BackgroundColor', handles.UnchangedColor );
   ConvertSB = handles.NodeData(handles.NodeIndex).Next.Data.BandWidth / (10^6);
   set(handles.node_SignalBand,'String',ConvertSB,'BackgroundColor', handles.UnchangedColor );
   
   guidata(hObject,handles);
end

function SetConfirm(hObject,handles)
if (handles.DoubleConfirmFlag == 1)
    set(handles.node_Loss,'BackgroundColor', handles.ConfirmColor );
    set(handles.node_X,'BackgroundColor', handles.ConfirmColor );
    set(handles.node_Y,'BackgroundColor', handles.ConfirmColor);
    set(handles.node_PowerAVG,'BackgroundColor', handles.ConfirmColor );
    set(handles.node_TransmitterGain,'BackgroundColor', handles.ConfirmColor );
    set(handles.node_ReceiverGain,'BackgroundColor', handles.ConfirmColor );
    set(handles.node_Frequency,'BackgroundColor', handles.ConfirmColor );
    set(handles.node_FR,'BackgroundColor', handles.ConfirmColor );
    set(handles.node_SignalBand,'BackgroundColor', handles.ConfirmColor );
    set(handles.node_RCS,'BackgroundColor', handles.ConfirmColor );
    set(handles.node_CompressRatio,'BackgroundColor', handles.ConfirmColor );
    set(handles.node_mode,'BackgroundColor', handles.ConfirmColor );
    
    guidata(hObject,handles);
end

end

function SetLoad(hObject,handles)
%*********************** Without Convert ********************************
   set(handles.node_X,'String', handles.NodeData(handles.NodeIndex).Data.TransmitterPositionX,'BackgroundColor', handles.UnchangedColor );
   set(handles.node_Y,'String', handles.NodeData(handles.NodeIndex).Data.TransmitterPositionY ,'BackgroundColor',handles.UnchangedColor);
   set(handles.node_PowerAVG,'String', handles.NodeData(handles.NodeIndex).Data.PowerAVG,'BackgroundColor', handles.UnchangedColor);
   set(handles.node_Frequency,'String', handles.NodeData(handles.NodeIndex).Data.Frequency ,'BackgroundColor', handles.UnchangedColor );
   set(handles.node_RCS,'String',handles.NodeData(handles.NodeIndex).Data.RCS,'BackgroundColor', handles.UnchangedColor );
   set(handles.node_CompressRatio,'String',handles.NodeData(handles.NodeIndex).Data.CompressRatio,'BackgroundColor', handles.UnchangedColor );
   set(handles.node_mode,'Value',handles.NodeData(handles.NodeIndex).Name,'BackgroundColor', handles.UnchangedColor );      
   
   guidata(hObject,handles);
%*********************** Need Convert ***********************************
   ConvertLoss = 10*log10(handles.NodeData(handles.NodeIndex).Data.Loss);
   set(handles.node_Loss,'String',ConvertLoss,'BackgroundColor', handles.UnchangedColor );
   ConvertTrGain = 10*log10(handles.NodeData(handles.NodeIndex).Data.Gain_Transmitter);
   set(handles.node_TransmitterGain,'String',ConvertTrGain,'BackgroundColor',handles.UnchangedColor);
   ConvertReGain = 10*log10(handles.NodeData(handles.NodeIndex).Data.Gain_Receiver);
   set(handles.node_ReceiverGain,'String',ConvertReGain,'BackgroundColor', handles.UnchangedColor );
   ConvertFR = 10*log10(handles.NodeData(handles.NodeIndex).Data.NoiseFigure);
   set(handles.node_FR,'String',ConvertFR,'BackgroundColor', handles.UnchangedColor );
   ConvertSB = handles.NodeData(handles.NodeIndex).Data.BandWidth / (10^6);
   set(handles.node_SignalBand,'String',ConvertSB,'BackgroundColor', handles.UnchangedColor );
   
   guidata(hObject,handles);


end
%% Draw Transmitter and Receiver Point


function DrawPointAll(hObject,handles)
      NumRe =  size(handles.NettedReceiverArray,2);
      NumTr =  size(handles.NettedTransmitterArray,2);
%       NumEsm = size(handles.ESMReceiverArray,2);
      for n = 2:NumRe
          x = handles.NettedReceiverArray(1,n).FMCWRadarArray.ReceiverPositionX;
          y = handles.NettedReceiverArray(1,n).FMCWRadarArray.ReceiverPositionY;
          plot(x,y,'o','linewidth',1.5,'Color',[0 0 0]);
          
      end
      for n = 2:NumTr
          x = handles.NettedTransmitterArray(1,n).FMCWRadarArray.TransmitterPositionX;
          y = handles.NettedTransmitterArray(1,n).FMCWRadarArray.TransmitterPositionY;
          plot(x,y,'*','linewidth',1,'Color',[0 0 0]);
          
      end


end

