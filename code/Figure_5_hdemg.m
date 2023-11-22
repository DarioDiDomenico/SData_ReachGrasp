% Script intended to compute the average spectrum of the 64 HD-sEMG channels acquired
% during experiments Reach Grasp
%
% Please select the 'Reach&Grasp' folder containing all the subjects' subfolders
%

clear
close all
clc

selpath = 0;
nChann = 64; % Number of HD-sEMG channels
fs = 2000; % Sampling freuqency [Hz]
unit_factor = 1e-3; % factor used to convert mV in V
window = hamming(fs);
noverlap = 500;
nfft = 4001;
[b,a]=butter(4,[10 500]/(fs/2)); % Definition of the Butterworth filter 4th order

%Notch Filter initialization
N = 6; % Order
F0 = 50; % Center frequency
BW = 0.2; % Bandwidth
h = fdesign.notch('N,F0,BW', N, F0, BW, fs);
Hd = design(h,'butter','SOSScaleNorm', 'Linf');

% Define your path

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

subj = {'sub-01','sub-02','sub-03','sub-04','sub-05','sub-06','sub-07','sub-08','sub-09','sub-10'};
data_type = {'emg','motion','tactile'};
devices = {'sessantaquattro','cometa','vicon','cyberglove','tactileglove'};
tasks = {'HO','HC','WP','WS','WF','WE','Cyl','Sph','Trid','Thumb','FroRea','ReaCyl','ReaSph','Screw','Pour','EatFruit'};
cnt = 0;
sub_cnt = 0;

for s = 1:length(subj)
    sub_cnt = sub_cnt + 1;
    P_subj = [];
    for t = 1:length(tasks)
        sel_subj = subj(s); % selected subject
        sel_task = tasks(t); % selected task
        col = [];
        %%% Checking the correctness of the selected folder %%%
        sel_dir = dir(selpath);
        subdirs = {sel_dir.name};
        if ~ismember(subj,subdirs)
            msg = sprintf('[ERROR]: The selected folder does not contain sub-XX subfolders.');
            h = msgbox(msg)
            waitfor(msgbox(msg));
            delete(h);
            return
        end

        file_name_hd = strcat(selpath,'\',sel_subj,'\',data_type(1),'\',sel_subj, '_task-',sel_task,'_acq-',devices{1},'_emg.csv');
        data_emg_table = readtable(file_name_hd{1});
        Data_emg = table2array(data_emg_table);
        Data_emg = Data_emg*unit_factor; % Conversion mV in V
        
%         [data_emg,rising_trig_64,ind_falling_edge] = trig_sessantaquattro(logsout);
        
        Data_emg_notch = zeros(size(Data_emg)); % Initialization
        for j = 2:nChann+1  % The first column contains time samples
            j_upd = j+nChann*cnt;
%             Data_emg_notch(:,j) = filter(Hd,Data_emg(:,j));
            [P(:,j_upd),f]=pwelch(filtfilt(b,a,Data_emg(:,j)),window,noverlap,nfft,fs);
        end
        proc = ['Subject    ',subj{s},'-----task    ', tasks{t}];
        disp(proc)
        cnt = cnt + 1;
    end
    %% Spectra Analysis for each subject
    P_subj = P(:,length(tasks)*nChann*(sub_cnt-1)+1:length(tasks)*nChann*sub_cnt);
    Y = prctile(P_subj',[25 50 75],1); % Compute the 25th 50th and 75th percentile
    median_P_subj = median(P_subj,2);
    fig = figure(1);
    set(fig,'units','centimeters','position',[8 8 5.3 2.7])
    hold on
    plot(f(:,1),Y(1,:),'Color',[0.9290, 0.6940, 0.1250]);
    plot(f(:,1),Y(3,:),'Color',[0.9290, 0.6940, 0.1250]);
    p1 = patch([f(:,1)' fliplr(f(:,1)')], [Y(1,:) fliplr(Y(3,:))],[0.9290, 0.6940, 0.1250],'FaceAlpha',.3,'EdgeAlpha',.3);
    plot(f(:,1),median_P_subj,'Color',[0.8500, 0.3250, 0.0980])
    xlim([0,500]);
    ylim([0 2.5e-10]);
    xticks(linspace(0,500,11))
    yticks(linspace(0,2.5e-10,6))
    xticklabels([]);
    yticklabels([]);
    grid on
%     xlabel('Frequency [Hz]')
%     ylabel('Power Spectral density [V^{2}/Hz]')
%     legend(h,{'25^{th} percentile','75^{th} percentile','Median'})
%     title(['HD-sEMG signal spectra on ',subj{s}])
    status = mkdir(strcat(selpath,'\Figures\emg\'));
    fig_filename_subj = strcat(selpath,'\Figures\emg\',sel_subj,'_acq-',devices{1},'_spectra_emg');
    saveas(fig,fig_filename_subj{1},'png')
    close all
end

%% Cumulative Spectra Analysis

Y = prctile(P',[25 50 75],1); % Compute the 25th 50th and 75th percentile
median_P = median(P,2);
fig_tot = figure(2);
set(fig_tot,'units','centimeters','position',[8 8 16 8.89])
grid on, hold on
plot(f(:,1),Y(1,:),'Color',[0.9290, 0.6940, 0.1250]);
plot(f(:,1),Y(3,:),'Color',[0.9290, 0.6940, 0.1250]);
p1 = patch([f(:,1)' fliplr(f(:,1)')], [Y(1,:) fliplr(Y(3,:))],[0.9290, 0.6940, 0.1250],'FaceAlpha',.3,'EdgeAlpha',.3);
plot(f(:,1),median_P,'Color',[0.8500, 0.3250, 0.0980],'LineWidth',1.5)
xlim([0,500]);
ylim([0 2.5e-10]);
xticks(linspace(0,500,11))
yticks(linspace(0,2.5e-10,6))
xlabel('Frequency [Hz]')
ylabel('Power Spectral density [V^{2}/Hz]')
% legend(h,{'25^{th} percentile','75^{th} percentile','Median'})
% title('High-density signal spectra')
fig_filename = strcat(selpath,'\Figures\','sub-all_acq-',devices{1},'_spectra_emg');
saveas(fig_tot,fig_filename,'png')