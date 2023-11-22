%This code provides visualization of Cyberglove data distribution across
%acquired subjects and tasks. This code does not provide the visualizaton
%of the Wrist tasks.
%The visualization is done with violin plots. The function to perfrom it is
%described on https://github.com/Nabarb/Stradivari.

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
%call the function to load Cyberglove data
Joint2plot = loadDataJointNoWrist_cyberglove(selpath);
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
        D2 = size(joints,2); % joint variables length
        matrix (1:D1,1:D2,t,s) = joints; % store all joint variables     
    end
end
labels = Joint2plot.subjects(1).tasks(1).joint_name; % labels of joints
%rename labels and keep the anatomical joint names 
labels{1,1}= 'T_{MCP}';
labels{1,2}= 'I_{MCP}';
labels{1,3}= 'M_{MCP}';
labels{1,4}= 'R_{MCP}';
labels{1,5}= 'P_{MCP}';
labels{1,6}= 'Wrist_{Pitch}';
labels{1,7}= 'Wrist_{Yaw}';
%% plot results
%list of the task names
names = {'Cyl','Sph','Trid','Thumb','FroRea','ReaCyl','ReaSph','Pour','Screw','EatFruit'};
devices = {'sessantaquattro','cometa','vicon','cyberglove','tactileglove'};
%count variable
xx = 1;
for tt = 1:length(Joint2plot.subjects(1).tasks)
    %through each task
    tmp = squeeze(matrix(:,:,tt,:));   
    %for each new task inizialize temp matrix 'M_temp'. Each column of
    %M_temp contains the distribution of the single joint
    M_temp = [];
    for ss = 1:s
        M_temp = cat(1,M_temp, tmp(:,:,ss)-tmp(1,:,ss));
    end
    %save data from HO and HC tasks
    if strcmp(Joint2plot.subjects(1).tasks(tt).task_name,'HO')
        M_HO = M_temp;
    elseif strcmp(Joint2plot.subjects(1).tasks(tt).task_name,'HC') 
        M_HC = M_temp; 
    else
        %store all other joint data exept of 'HO' and 'HC' tasks
        M_other = M_temp;
        [ngroups,nbars] = size(M_other);
        % set color of violins
        clr = repmat([0.8000    0.9216    0.7725],nbars,1);             
        f = figure('units','centimeters','position',[8 8 7.25 3.9]);
        ax = gca;
        stradivari(ax,M_other','ViolinColor',clr,'BoxOn',1,'Vertical',1,...
            'Normalization','max','ScatterWidth',NaN);
        axP = get(gca,'Position');
        set(gca,'xtick',[])
        set(gca,'Ygrid','on')
        if tt == length(Joint2plot.subjects(1).tasks)-1
            ylabel('Degree [°]');
            XTickLabel=labels;
            XTick=(1:nbars)-0.5;
            set(gca, 'XTick',XTick);
            set(gca, 'XTickLabel', XTickLabel);            
        end
        set(gca,'Ygrid','on')
        ylim([-100 100])
        yticks(linspace(-100,100,5))
        set(gca, 'Position', axP)
        set(gca,'FontSize', 12)
        status = mkdir(strcat(selpath,'\Figures\cyberglove\'));
        fig_filename_subj = strcat(selpath,'\Figures\cyberglove\','sub-ALL_task-',names{1,xx},'_acq-',devices{4});
        saveas(f,fig_filename_subj,'png')
        close all
        xx = xx+1; %next iteration
    end  
end
% sgtitle ('Joint variation')
% saveas(f1,'Joint variation all_new.fig')
%% plot HO and HC as grouped tasks
M_HOHC = cat(2,M_HO,M_HC);
% get the idices to couple violins
ind = [1 8; 2 9; 3 10; 4 11; 5 12; 6 13; 7 14]';                 
f2 = figure;
ax = gca; % get the current axes
% define the colors of violin plot
clr1 = repmat([ 0.9961    0.8510    0.6510],7,1);
clr2 = repmat([ 0.8980    0.8471    0.7412],7,1);
h = stradivari(ax,M_HOHC(:,1:14)','ViolinColor',[clr1;clr2],'Coupled',ind,'BoxOn',1,...
    'Vertical',1,'Normalization','max','ScatterWidth',NaN);
%separate Violins by tasks
HO = h{1, 1}{1, 1};
HC = h{2, 1}{1, 1};
%set figure properties
set(gca,'Ygrid','on')
XTickLabel=labels;
set(gca, 'XTickLabel', XTickLabel);
set(gca,'FontSize', 12)
set(gca,'xlim',[-1.5 14.5])
ylim([-100 100])
legend([HO  HC], {'HO ','HC '},'Location','northeast');
ylabel('Degree [°]');
% saveas(f2,'Joint variation HO&HC_new.fig')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%used function
% Below the fuction loads raw Cyberglove data in csv. and strores it in mat. format.
% This data does not contain raw data of Wrist tasks
function[Joint2plot] = loadDataJointNoWrist_cyberglove(path)
%list of subjects
subjects = {'sub-01','sub-02','sub-03','sub-04','sub-05', 'sub-06', 'sub-07','sub-08', 'sub-09','sub-10'};
%list of tasks
tasks = {'HO','HC','Cyl','Sph','Trid','Thumb','FroRea','ReaCyl','ReaSph','Pour','Screw','EatFruit'};
for subject=1:length(subjects)
    for task=1:length(tasks)
        %skip the missing data
        if strcmp(subjects(subject),'sub-03') && strcmp(tasks(task),'FroRea')
            continue
        elseif strcmp(subjects(subject),'sub-03') && strcmp(tasks(task),'ReaCyl')
            continue
        end
        % load single cyberglove joint data
        file_name_motion = strcat(path,{'\'},subjects(subject),{'\'},{'motion'},{'\'},subjects(subject),'_task-', tasks(task),'_acq-cyberglove_motion', {'.csv'});
        % load header file
        header_motion = strcat(path,{'\'},subjects(subject),{'\'},{'motion'},{'\'},subjects(subject),'_task-', tasks(task),'_acq-cyberglove_channels', {'.tsv'});
        cyberglove = readtable(file_name_motion{:});
        cyberglove_channels = tdfread(header_motion{:});
        time_cyberglove = table2array(cyberglove(:,1)); % time is the 1st column
        cyberglove_data = table2array(cyberglove(:,2:end));
        cyberglove_labels = cellstr(cyberglove_channels.name);
        % list of kinemtatic joint variables to be stored (based on header data)
        str = {'ThumbMPJ','IndexMPJ','MiddleMPJ','RingMIJ','PinkieMPJ','WristPitch','WristYaw'};
        % initialize temporal variable
        joints = zeros(length(time_cyberglove),length(str));
        label_joints = zeros(1,length(str));
        for r = 1:length(str)
            % select data according to the list of kinemtatic joint variables
            selectedcolumns = find(contains(cyberglove_labels, str(r)));
            label_joints(r) = selectedcolumns;
            % data of one selected joint
            cyberglove_joint = cyberglove_data(:,(selectedcolumns));
            joints(:,r) = cyberglove_joint;
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