function session = BreakdownSessionTimes(datapath,sessionList)

% BREAKDOWNSESSIONTIMES process start and end times of each session event
% S = BREAKDOWNSESSIONTIMES(PATH,LIST) processes each session in the cell
% array LIST, using the data found in PATH.
%
% Returns S, a struct containing 
%
% Mark Humphries 1/12/16

% load times of each section
n = numel(sessionList);


for iS = 1:n
    taskdata = importdata([datapath sessionList{iS} '/' sessionList{iS} '_WakeEpoch.dat']);
    preSWSdata = csvread([datapath sessionList{iS} '/' sessionList{iS} '_SwsPRE.dat']);
    postSWSdata = csvread([datapath sessionList{iS} '/' sessionList{iS} '_SwsPOST.dat']);
    behav = importdata([datapath sessionList{iS} '/' sessionList{iS} '_Behavior.txt']);
    
    % session starts
    session(iS).allperiod(1) = 0; % onset of period of type X
    session(iS).periodtype(1) = 1; % type of period X: 1 = rest; 2 = SWS; 3 =task; 4 =trial
    
    % pre-task SWS
    session(iS).preSWST = (preSWSdata(:,2) - preSWSdata(:,1)) ./ 1000;
    session(iS).preSWStotal = sum(session(iS).preSWST);
    
    for i = 1:numel(session(iS).preSWST)
        session(iS).allperiod = [session(iS).allperiod preSWSdata(i,1) preSWSdata(i,2)];
        session(iS).periodtype = [session(iS).periodtype 2 1];
    end
    
    % task starts
    session(iS).taskT = (taskdata(2) - taskdata(1)) / 1000;  % duration of task period in seconds
    
    session(iS).allperiod = [session(iS).allperiod taskdata(1)];
    session(iS).periodtype = [session(iS).periodtype 3];
    
    % trials in task
    session(iS).trialT = (behav(:,2) - behav(:,1)) / 1000;
    session(iS).total_trials = sum(session(iS).trialT);
    session(iS).outcome = behav(:,4);

    for i = 1:numel(session(iS).trialT)
        session(iS).allperiod = [session(iS).allperiod behav(i,1) behav(i,2)];
        if session(iS).outcome(i)  % success
            type = 4;
        else
            type = 5;
        end
        session(iS).periodtype = [session(iS).periodtype type 3];  % trial then task
    end
     
    % task ends
    session(iS).restT = (postSWSdata(1) - taskdata(2)) / 1000; % gap between final trial and onset of SWS
    session(iS).rest_task_ratio = session(iS).restT ./ session(iS).taskT;
    session(iS).rest_trial_ratio = session(iS).restT ./ session(iS).total_trials;
    
    session(iS).allperiod = [session(iS).allperiod taskdata(2)];  % new rest period
    session(iS).periodtype = [session(iS).periodtype 1];

    % post-task SWS
    session(iS).postSWST = (postSWSdata(:,2) - postSWSdata(:,1)) ./ 1000;
    session(iS).postSWStotal = sum(session(iS).postSWST);
    session(iS).rest_postSWS_ratio = session(iS).restT ./ session(iS).postSWStotal;
    
    for i = 1:numel(session(iS).postSWST)
        session(iS).allperiod = [session(iS).allperiod postSWSdata(i,1) postSWSdata(i,2)];
        session(iS).periodtype = [session(iS).periodtype 2 1];
    end
   
    
    % keyboard
end

% mean([session(:).restT])
% std([session(:).restT])
% 
% mean([session(:).rest_postSWS_ratio])
% std([session(:).rest_postSWS_ratio])
