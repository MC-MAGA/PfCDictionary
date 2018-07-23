%% divide spike data into trials and bouts
% uses the original data format (one session per folder, all in same
% directory)
% Creates "PartitionedSpike_Data..." files, that are provided as basis for
% rest of analysis
%
% Mark Humphries 30/10/17


clear all; close all

type = 'Stable85';  % 'Learn','Stable85'
N = 35;  % 35, 15

% where are the original data?
filepath = 'C:...';


%% get all trial and bout times
switch type
    case 'Learn'
        % learning sessions
        analyse_trial_session = {'201222','201227','201229','181012','181020','150628','150630','150707','190214','190228'};
        Nsessions = numel(analyse_trial_session);
        % load set of neurons...
        if N == 35
            load('Neurons_35_MinWord_0Method_hellinger_Common_postlearn_success_trial_intervals_Latter_post_sleep_times_Res_2_','comparison1_dist')
        elseif N == 15
            % to be finished
        end
        
    case 'Stable85'
        load SimpleStable_0.85.mat
        Nsessions = numel(SimpleStable.Names);
        for iN = 1:Nsessions
            analyse_trial_session{iN} = num2str(SimpleStable.Names(iN));
        end
        % load set of neurons
        if N == 35
            load('Plos_analysis_Neurons_35simple_stable_0.85__firing_rate_MinWord_2Method_hellinger_Common_all_trials_Latter_post_sleep_Res_2_.mat','comparison1_dist');
        elseif N == 15
            % to be finished
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

Data = emptyStruct({'Trials','PreEpoch','PostEpoch'},[Nsessions,1]);
Times = emptyStruct({'WakeEpoch','PreEpoch','PostEpoch','Trials'},[Nsessions,1]);

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
        spkdata = importdata([filepath session(iS).names '/' session(iS).names '_SpikeData.dat']);  % [time-stamp (ms); neuron]

        % chunk spike periods from SWS and task
        Times(Sctr).WakeEpoch = importdata([filepath session(iS).names '/' session(iS).names '_WakeEpoch.dat'],',');
        Times(Sctr).PreEpoch = importdata([filepath session(iS).names '/' session(iS).names '_SwsPRE.dat'],',');
        Times(Sctr).PostEpoch = importdata([filepath session(iS).names '/' session(iS).names '_SwsPOST.dat'],',');
        Times(Sctr).Trials = importdata([filepath session(iS).names '/' session(iS).names '_Behavior.txt']);
                
        % WHICH IDS are being used in all our analyses?
        for iC = 1:numel(analyse_trial_session)
            if strcmp(comparison1_dist(iC).session,session(iS).names)
                Data(Sctr).NeuronIDs = comparison1_dist(iC).neurons_select;
            end
        end
        
        nTrials = size(Times(Sctr).Trials,1);
        nNeurons = numel(Data(Sctr).NeuronIDs);
        
        % now create per-neuron ISI sets
        for iN = 1:nNeurons
            ixNeu = find(spkdata(:,2) == Data(Sctr).NeuronIDs(iN)); % BLN this neuron
            for iT = 1:nTrials
                ixTs = spkdata(ixNeu,1) >= Times(Sctr).Trials(iT,1) & spkdata(ixNeu,1) <= Times(Sctr).Trials(iT,2);
                Data(Sctr).Trials(iN,iT).spks = spkdata(ixNeu(ixTs),:);
                Data(Sctr).Trials(iN,iT).isis = diff(Data(Sctr).Trials(iN,iT).spks(:,1));
            end
            for iP = 1:size(Times(Sctr).PreEpoch,1)
                ixTs = spkdata(ixNeu,1) >= Times(Sctr).PreEpoch(iP,1) & spkdata(ixNeu,1) <= Times(Sctr).PreEpoch(iP,2);
                Data(Sctr).PreEpoch(iN,iP).spks = spkdata(ixNeu(ixTs),:);
                Data(Sctr).PreEpoch(iN,iP).isis = diff(Data(Sctr).PreEpoch(iN,iP).spks(:,1));
            end
            
            for iP = 1:size(Times(Sctr).PostEpoch,1)
                ixTs = spkdata(ixNeu,1) >= Times(Sctr).PostEpoch(iP,1) & spkdata(ixNeu,1) <= Times(Sctr).PostEpoch(iP,2);
                Data(Sctr).PostEpoch(iN,iP).spks = spkdata(ixNeu(ixTs),:);
                Data(Sctr).PostEpoch(iN,iP).isis = diff(Data(Sctr).PostEpoch(iN,iP).spks(:,1));
            end
        end
    end
end

save(['PartitionedSpike_Data_N' num2str(N) '_' type],'Data','Times');


