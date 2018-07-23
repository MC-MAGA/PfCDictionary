%% get reward rates
clear all; close all

% from Adrien's data
learning_trial_number = [23;23;14;5;10;12;5;18;11;8];
learning_trial_session = {'201222','201227','201229','181012','181020','150628','150630','150707','190214','190228'};

if ispc
    filepath = 'C:\Users\mqbssmhg.DS\Dropbox\SpikeData\Adriens sample of Behaviour and Spikes\';
else
    filepath = '/Users/mqbssmhg/Dropbox/SpikeData/Adriens sample of Behaviour and Spikes/';
    
end


%% get rates

for iS = 1:numel(learning_trial_session)
    session(iS).names = learning_trial_session{iS};
    session(iS).learningtrial = learning_trial_number(iS);
    data = importdata([filepath session(iS).names '/' session(iS).names '_Behavior.txt']);
    session(iS).outcome = data(:,4); % fourth column
    

    
    % number of trials
    session(iS).nTrials = numel(session(iS).outcome);
    session(iS).preTrials = session(iS).outcome(1:session(iS).learningtrial);
    session(iS).postTrials = session(iS).outcome(session(iS).learningtrial+1:end);

    
    % reward rate
    session(iS).cumR = cumsum(session(iS).outcome);
    session(iS).allRR = sum(session(iS).outcome) / numel(session(iS).outcome);
    session(iS).preRR = sum(session(iS).preTrials) / numel(session(iS).preTrials);
    session(iS).postRR = sum(session(iS).postTrials) / numel(session(iS).postTrials);
       
end

save SessionReward session

