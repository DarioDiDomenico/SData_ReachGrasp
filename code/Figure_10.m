% This script provides a visualization of joint angles and EMG signals
% with repsect to the rising and falling time points calculated from
% kinemtic data during experiments Reach Grasp
%
% Please select the 'Reach&Grasp' folder containing all the subjects' subfolders

clc
clear
close all

selpath = 0;
fs_Vicon = 100;
fs_Sessantaquattro = 2000;
fs_Cometa = 2000;
fs_Cyberglove = 100;

% load rising and falling time events
load('Events_Reach&Grasp.mat');

while selpath == 0
    selpath = uigetdir(path,'Select the path of the rawdata folder');
    if selpath == 0
        msg = sprintf('[ERROR]: Please select the Reach&Grasp path.');
        h = msgbox(msg);
        waitfor(msgbox(msg));
        delete(h);
        return
    end
end

% define the path of storaged data
subjects = {'sub-01','sub-02','sub-03','sub-04','sub-05', 'sub-06', 'sub-07','sub-08', 'sub-09','sub-10'};
tasks = {'HO','HC','WP','WS','WF','WE','Cyl','Sph','Trid','Thumb','FroRea','ReaCyl','ReaSph','Pour','Screw','EatFruit'};
data_events = Events_ReachGrasp.subjects; % load time events

%% plot events together with kinematic data
for ss = 4    % select the subjects
    for tt = 1  % select the task
        % load vicon data
        file_name_vicon = strcat(selpath,{'\'}, subjects(ss), {'\'}, {'motion'},{'\'}, subjects(ss), '_task-', tasks(tt), '_acq-vicon_motion', {'.csv'});
        raw_vicon = table2array(readtable(file_name_vicon{:}));
        file_name_vicon_header = strcat(selpath,{'\'}, subjects(ss), {'\'}, {'motion'},{'\'}, subjects(ss), '_task-', tasks(tt), '_acq-vicon_channels', {'.tsv'});
        header_vicon = tdfread(file_name_vicon_header{:});
        labels_vicon = cellstr(header_vicon.name);
        label_vicon_to_plot = find(contains(labels_vicon,'ThirdJ1Proj_Y'));
        joint_vicon = raw_vicon(:,label_vicon_to_plot+1); % add +1 to the label 
        % bc th 1st column in raw_vicon is time

        % load cyberglove data
        file_name_cyberglove = strcat(selpath,{'\'}, subjects(ss), {'\'}, {'motion'},{'\'}, subjects(ss), '_task-', tasks(tt), '_acq-cyberglove_motion', {'.csv'});
        raw_cyberglove = table2array(readtable(file_name_cyberglove{:}));
        file_name_cyberglove_header = strcat(selpath,{'\'}, subjects(ss), {'\'}, {'motion'},{'\'}, subjects(ss), '_task-', tasks(tt), '_acq-cyberglove_channels', {'.tsv'});
        header_cyberglove = tdfread(file_name_cyberglove_header{:});
        labels_cyberglove = cellstr(header_cyberglove.name);
        label_cyberglove_to_plot = find(contains(labels_cyberglove,'MiddleMPJ'));
        joint_cyberglove = raw_cyberglove(:,label_cyberglove_to_plot+1); % add +1 to the label 
      
        % load emg data
        file_name_hd = strcat(selpath,{'\'}, subjects(ss), {'\'}, {'emg'},{'\'}, subjects(ss), '_task-', tasks(tt), '_acq-sessantaquattro_emg', {'.csv'});
        file_name_ld = strcat(selpath,{'\'}, subjects(ss), {'\'}, {'emg'},{'\'}, subjects(ss), '_task-', tasks(tt), '_acq-cometa_emg', {'.csv'});
        file_name_ld_header = strcat(selpath,{'\'}, subjects(ss), {'\'}, {'emg'},{'\'}, subjects(ss), '_task-', tasks(tt), '_acq-cometa_channels', {'.tsv'});
        header_ld = tdfread(file_name_ld_header{:});
        labels_ld = cellstr(header_ld.name);
        labels_ld_to_plot = find(contains(labels_ld,'Brachiorad'));
        raw_ld_emg = table2array(readtable(file_name_ld{:})); 
        raw_hd_emg = table2array(readtable(file_name_hd{:}));
        data_hd = raw_hd_emg(:,50); % 50 is the 49th channel of right muscel extensor      
        data_ld = raw_ld_emg(:,labels_ld_to_plot+1);  % add +1 to the label 
        % bc th 1st column in raw_vicon is time   
        % load time events
        trigger = data_events(ss).tasks(tt).time2cut;   
        % plot in seconds by deviding samples to fs
        %%
        figure('units','centimeters','position',[8 8 14.5 7.8]);  
        yyaxis left
        p4 = plot((1:1:length(joint_cyberglove))/fs_Cyberglove,joint_cyberglove,'Color',"#80B3FF",'LineWidth',1.2);
        hold on
        p3 = plot((1:1:length(joint_vicon))/fs_Vicon,joint_vicon,'-','Color',"#7E2F8E",'LineWidth',1.2);
        ylabel('Degree [°]');
        yyaxis right
        p1 = plot((1:1:length(data_hd))/fs_Sessantaquattro,data_hd,'Color','#E690B8');       
        hold on
        yyaxis right
        p2 = plot((1:1:length(data_ld))/fs_Cometa,data_ld,'-','Color','#C71D1D');  
        ylabel('Voltage [mV]');  
        hold off
        for kk = 1:length(trigger)
            xline(trigger(kk)/fs_Vicon,'--','LineWidth',1.2,'Color','k')
        end
%        title({strcat(data_events(ss).subject_name),data_events(ss).tasks(tt).task_name,...
%             char(labels_cyberglove(label_cyberglove_to_plot))},'Interpreter', 'none')
        set(gca,'Ygrid','on')
        
        xlabel('Time [s]')
        xlim([0 length(joint_vicon)/fs_Vicon])
        legend([p1 p2 p3 p4],{'Sessantaquattro','Cometa', 'Vicon','Cyberglove'},'Location','best')
   end

end