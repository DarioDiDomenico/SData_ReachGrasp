% This script the averaged duration of each particular task
% across the subjects during experiments Reach Grasp
%
% Please select the 'Reach&Grasp' folder containing all the subjects' subfolders

%% TODO add the path to load the events!
% is better to save events as the extra data in dataverse and load from the
% path

clc
clear
close all

load ('Events_Reach&Grasp.mat') 
subjs = {'sub-01','sub-02','sub-03','sub-04', 'sub-05', 'sub-06', 'sub-07', 'sub-08', 'sub-09', 'sub-10'};
tasks = {'HO','HC','WP','WS','WF','WE','Cyl','Sph','Trid','Thumb','FroRea','ReaCyl','ReaSph','Pour','Screw','EatFruit'};

% find longest duration of the task
% this dimension will be used to initialize the time duration matrix
dim = nan(length(tasks),length(subjs)); % inizialize with NaN of the longest joint
for s = 1:length(Events_ReachGrasp.subjects)
    for t = 1:length(Events_ReachGrasp.subjects(s).tasks)        
        tmp = length(Events_ReachGrasp.subjects(s).tasks(t).time2cut);  
        dim (t,s) = tmp/2;    
    end
end
dim = max(dim,[],'all');
%% initialize duration matrix 
matrix = NaN(dim,length(Events_ReachGrasp.subjects(s).tasks),length(Events_ReachGrasp.subjects)); 
for s = 1:length(Events_ReachGrasp.subjects)
    for t = 1:length(Events_ReachGrasp.subjects(s).tasks)
        time1 = Events_ReachGrasp.subjects(s).tasks(t).time2cut; 
        % convert to sec
        time1 = time1*1/100;
        % find the longest duration in the time array
        k=1:length(time1);
        evens=k(mod(k,2)==0);
        odds=k(mod(k,2)==1);
        duration = time1(evens)-time1(odds);
        D = size(duration);
        % 1st dimenstion is duratin, 2nd dim is per task, 3d dim is
        % per subject
        matrix (1:D,t,s) = duration;
    end
end
%% plot task duration
task_dur = squeeze(nanmean(matrix,1));
figure;
boxplot(task_dur); xlabel('subjects');
set(gca,'YGrid','on')
ylabel('Duration [s]');
title('Task performance across subjects')
f = figure('units','centimeters','position',[8 8 14.5 7.8]); % parameter of the figure 
                                          % position is taken from the screen size
boxplot(task_dur'); xlabel('tasks');title('Task performance across tasks')
ylabel('Duration [s]');
set(gca,'YGrid','on')
set(gca, 'XTickLabel', tasks);
set(gca,'FontSize',12)
% saveas(f,'Task performance across tasks.fig')
% exportgraphics(f,'Task performance across tasks.pdf','Resolution',300)
%% Bar plot across tasks for each subject
meanT = squeeze(nanmean(matrix,1));% mean across tasks and sub
stdT = squeeze(nanstd(matrix,0,1));% std across tasks and sub
[ngroups,nbars] = size(meanT);
f = figure('Position',[1 41 1536 748.8]);
for kk = 1:size(meanT,2)
    subplot(5,2,kk)
    text = strcat(subjs{kk});
    hold on
    bar((meanT(:,kk)+stdT(:,kk)),'Barwidth',0.2,'FaceColor','k')
    bar(meanT(:,kk))
    set(gca,'xtick',[])
    if kk ==size(meanT,2)-1
        ylabel('Duration [s]');
        XTickLabel=tasks;
        XTick=1:ngroups;
        set(gca, 'XTick',XTick);
        set(gca, 'XTickLabel', XTickLabel);
        set(gca, 'XTickLabelRotation', 45);
        set(gca,'Ygrid','on')
    end
    title(text,'Interpreter', 'none');
    ylim([0 9])
    hold off
    set(gca, 'YGrid', 'on')
    set(gca,'FontSize',12)
    sgtitle('Task duration across subjects and tasks')
end
% saveas(f,'Task duration across subjects and tasks.fig')
% exportgraphics(f,'Task duration across subjects and tasks.pdf','Resolution',300)
