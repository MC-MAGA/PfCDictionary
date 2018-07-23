% script to assess position data
clear all; close all

type = 'Learn';  % 'Learn','Stable85'

% path to location of CRCNS data files
filepath = 'C:\Users\lpzmdh\Dropbox\SpikeData\Adriens sample of Behaviour and Spikes\';

localpath = '../Analysis code/';

load(['../Processed data/PartitionedSpike_Data_N35_' type],'Times');

% properties of the Y-maze
arm_length = 85;  % cm
arm_width = 8; % cm
arm_angle = 120;  % degrees


%% get all positions
switch type
    case 'Learn'
        % learning sessions
        load LearningSessions.mat
        Nsessions = numel(analyse_trial_session);
        
    case 'Stable85'
        load([localpath 'SimpleStable_0.85.mat'])
        Nsessions = numel(SimpleStable.Names);
        for iN = 1:Nsessions
            analyse_trial_session{iN} = num2str(SimpleStable.Names(iN));
        end
end

% get list of all sessions
files = dir(filepath);
files(1:2) = [];
ctr = 1;
for iF = 1:numel(files)
    if files(iF).isdir == 1
        session(ctr).names = files(iF).name;
    end
    ctr = ctr+1;
end

%% for each session of this type, get timing data and count all words
Sctr = 0;

PosData = emptyStruct({'data','XLim','YLim'},[Nsessions,1]);

for iS = 1:numel(session)
    % is this an analysed session?
    blnAnalyse = 0;
    for iC = 1:numel(analyse_trial_session)
        if strcmp(analyse_trial_session{iC},session(iS).names)
            blnAnalyse = 1;
            Sctr = Sctr + 1;
        end
    end
    
    if blnAnalyse % for each analysed session
        PosData(Sctr).data = importdata([filepath session(iS).names '/' session(iS).names '_Pos.txt']);  % [time-stamp (ms), x, y]

        PosData(Sctr).ixWake(1) = find(PosData(Sctr).data(:,1) >= Times(Sctr).WakeEpoch(1),1);
        PosData(Sctr).ixWake(2) = find(PosData(Sctr).data(:,1) <= Times(Sctr).WakeEpoch(2),1,'last');

        PosData(Sctr).ixTrial(1) = find(PosData(Sctr).data(:,1) >= Times(Sctr).Trials(1,1),1);
        PosData(Sctr).ixTrial(2) = find(PosData(Sctr).data(:,1) <= Times(Sctr).Trials(end,2),1,'last');

        figure
        subplot(311),plot(PosData(Sctr).data(:,2),PosData(Sctr).data(:,3),'o')
        subplot(312),plot(PosData(Sctr).data(PosData(Sctr).ixWake(1):PosData(Sctr).ixWake(2),2),PosData(Sctr).data(PosData(Sctr).ixWake(1):PosData(Sctr).ixWake(2),3),'o')
        subplot(313),plot(PosData(Sctr).data(PosData(Sctr).ixTrial(1):PosData(Sctr).ixTrial(2),2),PosData(Sctr).data(PosData(Sctr).ixTrial(1):PosData(Sctr).ixTrial(2),3),'o')
        
        PosData(Sctr).XLim = [min(PosData(Sctr).data(PosData(Sctr).ixTrial(1):PosData(Sctr).ixTrial(2),2)) max(PosData(Sctr).data(PosData(Sctr).ixTrial(1):PosData(Sctr).ixTrial(2),2))];
        PosData(Sctr).YLim = [min(PosData(Sctr).data(PosData(Sctr).ixTrial(1):PosData(Sctr).ixTrial(2),3)) max(PosData(Sctr).data(PosData(Sctr).ixTrial(1):PosData(Sctr).ixTrial(2),3))];
    end
end

%% set limits, linearise, and normalise all, 
% invert Y-axis, define "decision" area
PosLimits.XLimits = [floor(min([PosData(:).XLim])),ceil(max([PosData(:).XLim]))];
PosLimits.YLimits = [floor(min([PosData(:).YLim])),ceil(max([PosData(:).YLim]))];

PosLimits.Centre = [(PosLimits.XLimits(2) - PosLimits.XLimits(1))/2 + PosLimits.XLimits(1),...
                        (PosLimits.YLimits(2) - PosLimits.YLimits(1))/2 + PosLimits.YLimits(1)];

PosLimits.Centre = [165,110]; % was 100
PosLimits.ChoiceY = [0.4, 0.6];

for iS = 1:Nsessions
    %% linearise
    
    % to origin
    shiftData = PosData(iS).data(PosData(iS).ixTrial(1):PosData(iS).ixTrial(2),2:3); 
    shiftData(:,1) = shiftData(:,1) - PosLimits.Centre(1); 
    shiftData(:,2) = shiftData(:,2) - PosLimits.Centre(2); 
    
%     figure
%     plot(shiftData(:,1),shiftData(:,2),'o'); hold on
%     line([0 0],[-150 150],'Color',[0 0 0])
%     line([-150 150],[0 0],'Color',[0 0 0])
   
    % find arms in y-axis
    ixArmsY = shiftData(:,2) < 0;  % all points below choice points
    ixArm1X = shiftData(:,1) < 0;  % all points in right arm (from perspective of rat) 
    ixArm2X = shiftData(:,1) > 0;   % all points in left arm (from perspective of rat) 
    
    % rotate
    linData = shiftData;
   
    % linData = rand(size(shiftData));
    
    theta = 2*pi * (arm_angle/2)/360; % counter-clockwise rotation, in radians                                   
    linData(ixArmsY & ixArm1X,:) = [linData(ixArmsY & ixArm1X,1) * cos(theta) - linData(ixArmsY & ixArm1X,2) * sin(theta),...
                                        linData(ixArmsY & ixArm1X,1) * sin(theta) + linData(ixArmsY & ixArm1X,2) * cos(theta)];
                                
    theta = -2*pi * (arm_angle/2)/360; % clockwise, in radians                           
    linData(ixArmsY & ixArm2X,:) = [linData(ixArmsY & ixArm2X,1) * cos(theta) - linData(ixArmsY & ixArm2X,2) * sin(theta),...
                                        linData(ixArmsY & ixArm2X,1) * sin(theta) + linData(ixArmsY & ixArm2X,2) * cos(theta)];
                             
%     figure
%     plot(linData(~ixArmsY,1),linData(~ixArmsY,2),'o'); hold on
%     plot(linData(ixArmsY&ixArm1X,1),linData(ixArmsY&ixArm1X,2),'ro');
%     plot(linData(ixArmsY&ixArm2X,1),linData(ixArmsY&ixArm2X,2),'go');
%     line([0 0],[-150 150])
%     line([-150 150],[0 0])
%     axis square
    PosData(iS).Trials.ixArmsY = ixArmsY;
    PosData(iS).Trials.ixArm1X = ixArm1X;
    PosData(iS).Trials.ixArm2X = ixArm2X;    
    
    PosData(iS).Trials.Lin = linData;
    PosData(iS).Trials.XLimLin = [min(linData(:,1)) max(linData(:,1))];
    PosData(iS).Trials.YLimLin = [min(linData(:,2)) max(linData(:,2))];
    
    % normalise each one
    PosData(iS).Trials.Norm = [PosData(iS).data(PosData(iS).ixTrial(1):PosData(iS).ixTrial(2),1),...
                                (PosData(iS).Trials.Lin(:,1) - PosData(iS).Trials.XLimLin(1))  ./ (PosData(iS).Trials.XLimLin(2) - PosData(iS).Trials.XLimLin(1)),...
                                 1 - (PosData(iS).Trials.Lin(:,2) - PosData(iS).Trials.YLimLin(1))  ./ (PosData(iS).Trials.YLimLin(2) - PosData(iS).Trials.YLimLin(1))];
    
    
end

% tmp = [PosData(:).Trials];
% PosLimits.Trials.XLimitsLin = [floor(min([tmp(:).XLimLin])),ceil(max([tmp(:).XLimLin]))];
% PosLimits.Trials.YLimitsLin = [floor(min([tmp(:).YLimLin])),ceil(max([tmp(:).YLimLin]))];


%% plot final results
for iS = 1:Nsessions
    
    figure
    plot(PosData(iS).Trials.Norm(~PosData(iS).Trials.ixArmsY,2),PosData(iS).Trials.Norm(~PosData(iS).Trials.ixArmsY,3),'o'); hold on
    plot(PosData(iS).Trials.Norm(PosData(iS).Trials.ixArmsY&PosData(iS).Trials.ixArm1X,2),PosData(iS).Trials.Norm(PosData(iS).Trials.ixArmsY&PosData(iS).Trials.ixArm1X,3),'ro');
    plot(PosData(iS).Trials.Norm(PosData(iS).Trials.ixArmsY&PosData(iS).Trials.ixArm2X,2),PosData(iS).Trials.Norm(PosData(iS).Trials.ixArmsY&PosData(iS).Trials.ixArm2X,3),'go');
    line([0 0],[0 1])
    line([0 1],[0 0])
    axis square

    hold on; line([0 1],[PosLimits.ChoiceY(1) PosLimits.ChoiceY(1)],'Color',[0.7 0.3 0.3])  
    hold on; line([0 1],[PosLimits.ChoiceY(2) PosLimits.ChoiceY(2)],'Color',[0.7 0.3 0.3])
end

save(['PosData_' type],'PosData','PosLimits')
        