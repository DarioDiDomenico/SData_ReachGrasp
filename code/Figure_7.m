%This code provides visualization of Vicon data distribution across
%acquired subjects and tasks. This code provides the visualizaton
%of the Wrist tasks.
%The visualization is done with violin plots. The function to perfrom it is
%described on https://github.com/Nabarb/Stradivari.

clc
clear 
close all
% set the path of data storage
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

% call the function to load Vicon data
Joint2plot = loadDataJointWrist(selpath);
%find the first and the second longest dimension in the data structure
%this variables are used to define the dimensions of the future data matrix
dim1 = nan;
dim2 = nan;
for s = 1:length(Joint2plot.subjects)
    for t = 1:length(Joint2plot.subjects(s).tasks)        
        joints = Joint2plot.subjects(s).tasks(t).joint;  
        dim1 (1,:,t,s) = size(joints,1); % sample length
        dim2 (1,:,t,s) = size(joints,2); % joint variables length   
    end
end
dim1 = max(dim1,[],'all');
dim2 = max(dim2,[],'all');
%inizialize matrix which contains all data from all subjects
matrix = NaN(dim1,dim2,t,s); 
for s = 1:length(Joint2plot.subjects)
    for t = 1:length(Joint2plot.subjects(s).tasks)   
        joints = Joint2plot.subjects(s).tasks(t).joint;          
        D1 = size(joints,1); % sample length
        D2 = size(joints,2);  % joint variables length
        matrix (1:D1,1:D2,t,s) = joints; % store all joint variables       
    end
end
labels = Joint2plot.subjects(1).tasks(1).joint_name; % labels of joints
%rename labels and keep the anatomical joint names
labels{1,1}= 'T_{IP}'; 
labels{1,2}= 'T_{MCP}';
labels{1,3}= 'I_{MCP}';
labels{1,4}= 'M_{MCP}';
labels{1,5}= 'R_{MCP}';
labels{1,6}= 'P_{MCP}';
labels{1,7}= 'W_{FE}';
labels{1,8}= 'W_{PS}';
labels{1,9}= 'E_{FE}';
labels{1,10}= 'S_{FE}';
for tt = 1:length(Joint2plot.subjects(1).tasks)
    % go through each task
    tmp = squeeze(matrix(:,:,tt,:));   
    % for each new task inizialize M_temp
    % each column of M_temp contains the distribution of the single joint
    % across all subjects for particular task tt
    M_temp = [];
    for ss = 1:s
        M_temp = cat(1,M_temp, tmp(:,:,ss)-tmp(1,:,ss)); % substruct the 1st value
    end   
    %append data from all tasks in a single matrix M_Wrist
    if tt == 1
        M_Wrist = M_temp;
    elseif tt>1 
        M_Wrist = cat(2,M_Wrist,M_temp);
    end
 end
M_Wrist = M_Wrist';
%% plot results
%in the next plot two opposite tasks are combined on the single subplot
f = figure('units','centimeters','Position',[8 8 14.5000 7.8]);
ax = subplot(1,1,1);
% get the idices to couple violins
ind1 = [1 11 ;2 12;3 13; 4 14;5 15;6 16;7 17;8 18; 9 19; 10 20]';
% define the colors of violins
clr1 = repmat([0.9843    0.7059    0.6824],10,1);
clr2 = repmat([0.8706    0.7961    0.8941],10,1);
h = stradivari(ax,M_Wrist(1:20,:),'ViolinColor',[clr1;clr2],'Coupled',ind1,...
    'BoxOn',1,'Vertical',1,'Normalization','max','ScatterWidth',NaN);
% define figure properties for each sigle violin plot
WF = h{1, 1}{1, 1};
WE = h{2, 1}{1, 1};
set(gca,'Ygrid','on')
set(gca,'xtick',[])
% set(gca, 'XTickLabel', XTickLabel);
set(gca,'xlim',[-1.5 20.5])
ylim([-200 200])
title_y = append('Degree [°]');
ylabel(title_y);
legend([WF  WE], {'WF ','WE '},'Location','northeast');
f2 = figure('units','centimeters','Position',[8 8 14.5000 7.8]);
ax = subplot(1,1,1);% define the colors of violin plot
clr3 = repmat([0.7020    0.8039    0.8902],10,1);
clr4 = repmat([0.9961    0.8510    0.6510],10,1);
h = stradivari(ax,M_Wrist(21:end,:),'ViolinColor',[clr3;clr4],'Coupled',ind1,...
    'BoxOn',1,'Vertical',1,'Normalization','max','ScatterWidth',NaN);
%separate Violins by tasks
WP = h{1, 1}{1, 1};
WS = h{2, 1}{1, 1};
%set figure properties
set(gca,'Ygrid','on')
set(gca,'xlim',[-1.5 20.5])
XTickLabel=labels;
set(gca, 'XTickLabel', XTickLabel);
legend([WP WS],{'WP','WS'},'Location','northeast');
title_y = append('Degree [°]');
ylabel(title_y);
% saveas(f,'Joint variation Wrist_new.fig')
% exportgraphics(f,'Joint variation Wrist.pdf','Resolution',300)

% This fuction loads raw Vicon data in csv. and strores it in mat. format.
% This data contains raw data only of Wrist tasks
function[Joint2plot] = loadDataJointWrist(path)
%list of subjects
subjects = {'sub-01','sub-02','sub-03','sub-04','sub-05', 'sub-06', 'sub-07','sub-08', 'sub-09','sub-10'};
%list of tasks
tasks = {'WF','WE','WP','WS'};
for subject=1:length(subjects)
    for task=1:length(tasks)
        % load single vicon joint data
        file_name_motion = strcat(path,{'\'},subjects(subject),{'\'},{'motion'},{'\'},subjects(subject),'_task-', tasks(task),'_acq-vicon_motion', {'.csv'});
        % load the header file
        header_motion = strcat(path,{'\'},subjects(subject),{'\'},{'motion'},{'\'},subjects(subject),'_task-', tasks(task),'_acq-vicon_channels', {'.tsv'});
        vicon = readtable(file_name_motion{:});
        vicon_channels = tdfread(header_motion{:});
        time_vicon = table2array(vicon(:,1)); % time is the 1st column        
        vicon_data = table2array(vicon(:,2:end)); 
        vicon_labels = cellstr(vicon_channels.name);       
        % list of kinemtatic joint variables to be stored (based on header data)
        str = {'ThumbJ2Abs','ThumbJ1Proj_Y','IndexJ1Proj_Y','ThirdJ1Proj_Y',...
            'RingJ1Proj_Y','PinkieJ1Proj_Y','Wrist_Y','Wrist_Z','Elbow_X','Shoulder_X',};
%         if ismember(tasks(task),{'WF'}) || ismember(tasks(task),{'WE'}) 
%              str = {'ThumbJ2Abs','ThumbJ1Proj_Y','IndexJ1Proj_Y','ThirdJ1Proj_Y',...
%             'RingJ1Proj_Y','PinkieJ1Proj_Y','Wrist_Y','Wrist_Z','Elbow_X','Shoulder_X',};
%         elseif ismember(tasks(task),{'WP'}) || ismember(tasks(task),{'WS'})
%              str = {'ThumbJ2Abs','ThumbJ1Proj_Y','IndexJ1Proj_Y','ThirdJ1Proj_Y',...
%             'RingJ1Proj_Y','PinkieJ1Proj_Y','Wrist_Y','Wrist_Z','Elbow_X','Shoulder_X',};
%         end

        % initialize temporal variable
        joints = zeros(length(time_vicon),length(str));
        label_joints = zeros(1,length(str));
        for r = 1:length(str)
            %% Select data according relevant joints
            % select data according to the list of kinemtatic joint variables
            selectedcolumns = find(contains(vicon_labels, str(r)));
            label_joints(r) = selectedcolumns;
            % data of one selected joint
            vicon_joint = vicon_data(:,(selectedcolumns));
            joints(:,r) = vicon_joint;           
            % store data as struct
            subject_name = strcat(subjects{subject});
            task_name_storage = strcat(tasks{task});           
            Joint2plot.subjects(subject).subject_name = subject_name;
            Joint2plot.subjects(subject).tasks(task).task_name = task_name_storage;
            Joint2plot.subjects(subject).tasks(task).joint_name = str;
            Joint2plot.subjects(subject).tasks(task).joint = joints;
        end
    end
end

end