function varargout = analysis(varargin)
% ANALYSIS MATLAB code for analysis.fig
%      ANALYSIS, by itself, creates a new ANALYSIS or raises the existing
%      singleton*.
%
%      H = ANALYSIS returns the handle to a new ANALYSIS or the handle to
%      the existing singleton*.
%
%      ANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANALYSIS.M with the given input arguments.
%
%      ANALYSIS('Property','Value',...) creates a new ANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before analysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to analysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help analysis

% Last Modified by GUIDE v2.5 25-Nov-2014 22:50:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @analysis_OpeningFcn, ...
                   'gui_OutputFcn',  @analysis_OutputFcn, ...
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


% --- Executes just before analysis is made visible.
function analysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to analysis (see VARARGIN)

% Choose default command line output for analysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes analysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = analysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Open_button.
function Open_button_Callback(hObject, eventdata, handles)
% hObject    handle to Open_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global directory_name;
global fileIndex;
global current_file_index;
global files;
directory_name = uigetdir;
files = dir(directory_name);
fileIndex = find(~[files.isdir]);
if ~isempty(fileIndex)
    current_file_index = fileIndex(1);
    axes(handles.Raw_image);
    imshow(strcat(directory_name,'\',files(current_file_index).name));
    set(handles.Raw_image_label,'String',files(current_file_index).name);
    set(handles.image_name,'String',strcat(num2str(1),'/',num2str(length(fileIndex))));
end




% --- Executes on button press in Save_button.
function Save_button_Callback(hObject, eventdata, handles)
% hObject    handle to Save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global files;
global fileIndex;
global directory_name;
global Total_channel_number;
global channel_info;
global side_length;
global H_color;
global S_color;
global V_color;
format long;
%set(handles.Processed_image_label,'String','Saving Channels');
axes(handles.Processed_image);

currentFolder = pwd;
for k=1:length(fileIndex)
    rgb=imread(strcat(directory_name,'\',files(fileIndex(k)).name));
    [pathstr,name,ext]=fileparts(files(fileIndex(k)).name);
    axes(handles.Raw_image);
    imshow(rgb);
    set(handles.Raw_image_label,'String',name);
    H_color(k,1) = str2double(name(10:15));
    S_color(k,1) = H_color(k,1);
    V_color(k,1) = H_color(k,1);
    H_color_temp = zeros(1,Total_channel_number);
    S_color_temp = zeros(1,Total_channel_number);
    V_color_temp = zeros(1,Total_channel_number);
    parfor d=1:Total_channel_number
        channel_name_num = num2str(d);
        rgb_temp = imcrop(rgb,[channel_info(d,1) channel_info(d,2) side_length side_length]);
        %axes(handles.Processed_image);
        %set(handles.Processed_image_label,'String',num2str(d));
        %imshow(rgb_temp);
        hsv_image = rgb2hsv(rgb_temp);
        h_image = hsv_image(:,:,1);
        s_image = hsv_image(:,:,2);
        v_image = hsv_image(:,:,3);
        threshold = hsv_image(:,:,2) > 0.1;
        h_ave = mean(h_image(threshold));
        s_ave = mean(s_image(threshold));
        v_ave = mean(v_image(threshold));

%         h_ave = mean(mean(hsv_image(:,:,1)));
%         s_ave = mean(mean(hsv_image(:,:,2)));
%         v_ave = mean(mean(hsv_image(:,:,3)));
%        H_color(k,d+1) = h_ave*360;
        H_color_temp(d) = h_ave*360;
        
%        S_color(k,d+1) = s_ave*360;
        S_color_temp(d) = s_ave*360;
%        V_color(k,d+1) = v_ave*360;
        V_color_temp(d) = v_ave*360;
        if(~exist(channel_name_num,'dir'))
            mkdir(channel_name_num);
        end
        savewheel(hsv_image,fullfile(currentFolder,channel_name_num),name);
        %cla(handles.Processed_image);
    end
    H_color(k,2:Total_channel_number+1) = H_color_temp;
    S_color(k,2:Total_channel_number+1) = S_color_temp;
    V_color(k,2:Total_channel_number+1) = V_color_temp;
    cla(handles.Raw_image,'reset');
    set(handles.image_name,'String',strcat(num2str(k),'/',num2str(length(fileIndex))));
end
csvwrite('H_Channel.csv',H_color);
csvwrite('S_Channel.csv',S_color);
csvwrite('V_Channel.csv',V_color);


% --- Executes on button press in Previous_button.
function Previous_button_Callback(hObject, eventdata, handles)
% hObject    handle to Previous_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global current_file_index;
global fileIndex;
global directory_name;
global files;

cla(handles.Raw_image,'reset');
if (current_file_index > fileIndex(1))
    current_file_index = fileIndex(find(fileIndex ==current_file_index)-1);
    axes(handles.Raw_image);
    imshow(strcat(directory_name,'\',files(current_file_index).name));
    set(handles.Raw_image_label,'String',files(current_file_index).name);
end


% --- Executes on button press in Next_button.
function Next_button_Callback(hObject, eventdata, handles)
% hObject    handle to Next_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global current_file_index;
global fileIndex;
global directory_name;
global files;

cla(handles.Raw_image,'reset');
if (current_file_index <= fileIndex(end-1))
    current_file_index = fileIndex(find(fileIndex == current_file_index)+1);
    axes(handles.Raw_image);
    imshow(strcat(directory_name,'\',files(current_file_index).name));
    set(handles.Raw_image_label,'String',files(current_file_index).name);
%    set(handles.image_name,'String',files(current_file_index).name);
end


function Total_CH_Callback(hObject, eventdata, handles)
% hObject    handle to Total_CH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Total_CH as text
%        str2double(get(hObject,'String')) returns contents of Total_CH as a double


% --- Executes during object creation, after setting all properties.
function Total_CH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Total_CH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Est_radii_set.
function Est_radii_set_Callback(hObject, eventdata, handles)
% hObject    handle to Est_radii_set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
axes(handles.Raw_image);
if(strcmp(get(handles.Est_radii_set,'String'),'Est Radii'))
    d = imdistline;
    set(handles.Est_radii_set,'String','Set');
else
    set(handles.Est_radii_set,'String','Est Radii');
    api = iptgetapi(d);
    api.delete();
end



function Radius_Callback(hObject, eventdata, handles)
% hObject    handle to Radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Radius as text
%        str2double(get(hObject,'String')) returns contents of Radius as a double


% --- Executes during object creation, after setting all properties.
function Radius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Select_CH.
function Select_CH_Callback(hObject, eventdata, handles)
% hObject    handle to Select_CH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global h_rec;
global side_length;
%h_rec = rectangle('Position',[250 250 side_length side_length]);
%ini_rec = [250 250 side_length side_length];
%[h_rec] = dragrect(ini_rec);
%axes(handles.Raw_image);
%waitforbuttonpress;
%point1 = get(handles.Raw_image,'CurrentPoint'); % button down detected
h_rec = impositionrect(handles.Raw_image,[250 250 side_length side_length]);


function CH_Callback(hObject, eventdata, handles)
% hObject    handle to CH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CH as text
%        str2double(get(hObject,'String')) returns contents of CH as a double


% --- Executes during object creation, after setting all properties.
function CH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Set_CH.
function Set_CH_Callback(hObject, eventdata, handles)
% hObject    handle to Set_CH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Current_channel_number = floor(str2double(get(handles.CH,'String')));

global channel_info;
global h_rec;

api = iptgetapi(h_rec);
pos = api.getPosition();
channel_info(Current_channel_number,1)=pos(1);
channel_info(Current_channel_number,2)=pos(2);


% --- Executes on button press in Test_all_CH.
function Test_all_CH_Callback(hObject, eventdata, handles)
% hObject    handle to Test_all_CH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global channel_info;
global side_length;
for i=1:length(channel_info(:,1))
    rectangle('Position',[channel_info(i,1) channel_info(i,2) side_length side_length]);
    text(floor(channel_info(i,1)+side_length/2),floor(channel_info(i,2)+side_length/2),num2str(i));
end


% --- Executes on button press in Start.
function Start_Callback(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Total_channel_number;
global channel_info;
global side_length;
global H_color;
global S_color;
global V_color;
global fileIndex;

Total_channel_number = floor(str2double(get(handles.Total_CH,'String')));
channel_info = zeros(Total_channel_number,2);
side_length = floor(str2double(get(handles.Radius,'String'))*1.4);
H_color = zeros(length(fileIndex),Total_channel_number+1);
S_color = zeros(length(fileIndex),Total_channel_number+1);
V_color = zeros(length(fileIndex),Total_channel_number+1);