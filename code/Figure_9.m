%This code provides visualization of the averaged taxel activation for each
%single task. The coordination of the glove's taxels were detected manually
%by visualizion the glove image and selecting each taxel's position on the image.


clc
clear
close all

%set the path of data storage
selpath = 0;
while selpath == 0
    selpath = uigetdir(path,'Select the path of the rawdata folder');
    if selpath == 0
        msg = sprintf('[ERROR]: Please select the Reach&Grasp path.');
        h = msgbox(msg)
        waitfor(msgbox(msg));
        delete(h);
        return
    end
end
%load curser data
load('Curser_Reach&Grasp');
%list of subjects
subjects = {'sub-01','sub-02','sub-03','sub-04','sub-05', 'sub-06', 'sub-07','sub-08', 'sub-09','sub-10'};
% list of tasks
tasks = {'HO','HC','WF','WE','WP','WS','Cyl','Sph','Trid','Thumb','FroRea','ReaCyl','ReaSph','Screw','EatFruit','Pour'};
devices = {'sessantaquattro','cometa','vicon','cyberglove','tactileglove'};
%call the function to load Tactileglove data and curser data
[Taxel2plot] = loadData_tactileglove(selpath,subjects,tasks);
%load taxel positions
Position = {curser.Position}';
Position = flip(Position);
% x- and y-coordinate of taxel
x = zeros(length(Position), 1);
y = x;
% write coordinates into variables
for xx=1:length(Position)
    x(xx) = Position{xx}(1);
    y(xx) = Position{xx}(2);
end
% size of taxels on the figure
sz = 100;
%plot averaged activation for each task
matrix_avr = zeros(length(tasks),58);
for t = 1:length(tasks)
    matrix = [];
    for s = 1:length(Taxel2plot.subjects)
        joints = Taxel2plot.subjects(s).tasks(t).taxel_data; 
        matrix = cat(1,matrix,joints);
    end
    matrix_avr(t,:) = mean(matrix);
    % init figure
    f = figure;
    f.Position = [488.0000   95.4000  666.6000  666.6000];
    f.Units = 'points';
    % load glove picture
    img = imread('glove_mapping.jpg');
    image('CData',img,'XData',[0 4],'YData',[1/4 -1/4])
    axis off
    hold on
    c = log(matrix_avr(t, :));
    scatter(x, y, sz, c, 'filled')
    colorbar;
    drawnow;
    status = mkdir(strcat(selpath,'\Figures\tactileglove'));
    fig_filename_subj = strcat(selpath,'\Figures\tactileglove\','sub-ALL_task-',tasks{1,t},'_acq-',devices{5});
    saveas(f,fig_filename_subj,'png')
    close all
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%used function
% Below the fuction loads raw Cyberglove data in csv. and strores it in mat. format.
% This data does not contain raw data of Wrist tasks
function[Taxel2plot] = loadData_tactileglove(path,subjects,tasks)
for subject=1:length(subjects)
    for task=1:length(tasks)
        %skip the missing data
        if strcmp(subjects(subject),'sub-03') && strcmp(tasks(task),'FroRea')
            continue
        elseif strcmp(subjects(subject),'sub-03') && strcmp(tasks(task),'ReaCyl')
            continue
        end        
        % load single tactileglove joint data
        file_name_tactile = strcat(path,{'\'},subjects(subject),{'\'},{'tactile'},{'\'},subjects(subject),'_task-', tasks(task),'_acq-tactileglove_tactile', {'.csv'});
        % load header file
        header_tactile = strcat(path,{'\'},subjects(subject),{'\'},{'tactile'},{'\'},subjects(subject),'_task-', tasks(task),'_acq-tactileglove_channels', {'.tsv'});
        tactileglove = readtable(file_name_tactile{:});
        tactileglove_channels = tdfread(header_tactile{:});
        tactileglove_data = table2array(tactileglove(:,2:end));
        tactileglove_labels = cellstr(tactileglove_channels.name);
        % store data as struct
        subject_name = strcat(subjects{subject});
        task_name_storage = strcat(tasks{task});
        Taxel2plot.subjects(subject).subject_name = subject_name;
        Taxel2plot.subjects(subject).tasks(task).task_name = task_name_storage;
        Taxel2plot.subjects(subject).tasks(task).taxel_name = tactileglove_labels;
        Taxel2plot.subjects(subject).tasks(task).taxel_data = tactileglove_data;
    end
end
end