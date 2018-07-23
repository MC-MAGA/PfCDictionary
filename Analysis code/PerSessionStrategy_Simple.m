% within-session simple analysis of strategy
%
% Matrix "Data" contains the trial-level behaviour of all 53 sessions that formed the basis for the
% "dictonary" paper. (These 53 were from the 4 rats that learnt at least one rule) 
% 
% Each row in Data is a single trial, listed in temporal order within a
% session
%
% In Data columns:
% 1st column : Animal ID (from 1 to 4)
% 2nd column : Session (from 1 to 46)
% 3rd column : Direction (0=right, 1=left)
% 4th column : Reward (0=incorrect/no reward, 1=correct/reward)
% 5th column : Rule (1=go right, 2=go to the lit arm, 3=go left, 4=go to the dark arm)
% 6th column : Light (0=right, 1=left)
% (7) Session name (Rat_Month_Day)
% 8 : learning session - per trial (1/0)
%
% Mark Humphries 25/11/2016

clearvars; close all

addpath('../Helper functions/')

load('../Processed data/SummaryDataTable_AllSessions','Data');

% excluded from analysis by hand
% [session; OK for behaviour?] A 0 in column 2 indicates some odd
% influences on behaviour (e.g. experimenter moved rat); a -1 indicates missing sleep; 
Excluded = [...
150704, -1;...	
150708, 0; ...	
200104, 0;];

% analysis set-up
pars.WinSize = 7;  %trials for computing P(s)

% classification
pars.PwinStable = 0.9; % at least this many windows with the same dominant rule
pars.ThetaP = 0.75; % at least this mean P per win
pars.ThetaStable = 0.85; % global P
pars.PwinContEnd = 0.3;
pars.minTrials = pars.WinSize + 3;

%% analyse
[r nData] = size(Data);
nSessions = unique(Data(:,2));

for iS = 1:numel(nSessions)
    % get all trials in current session
    ix = find(Data(:,2)==iS);
    Sessions(iS).nTrials = numel(ix);
    Sessions(iS).RuleStart = Data(ix(1),5);
    Sessions(iS).RuleEnd = Data(ix(end),5);
    Sessions(iS).name = Data(ix(1),7);
    Sessions(iS).OfficialLearn = Data(ix(1),8);
    Sessions(iS).Rat = Data(ix(1),1);
    
    if Sessions(iS).nTrials >= pars.minTrials
        %% global P
        choice = Data(ix,3);
        light = Data(ix,6);
        Sessions(iS).All.pLeft = sum(choice == 1) ./ Sessions(iS).nTrials;
        Sessions(iS).All.pRight = sum(choice == 0) ./ Sessions(iS).nTrials;
        Sessions(iS).All.pLight = sum(choice == light) ./ Sessions(iS).nTrials;
        
        %% do per-window analysis, to get time-series of P(strategy)
        winstart = 1:Sessions(iS).nTrials - pars.WinSize;
        Sessions(iS).nWindows = numel(winstart);

        for iW = 1:Sessions(iS).nWindows
            Sessions(iS).pLeft(iW) = sum(choice(winstart(iW):winstart(iW)+pars.WinSize-1) == 1) ./ pars.WinSize;
            Sessions(iS).pRight(iW) = sum(choice(winstart(iW):winstart(iW)+pars.WinSize-1) == 0) ./ pars.WinSize;
            Sessions(iS).pLight(iW) = sum(choice(winstart(iW):winstart(iW)+pars.WinSize-1) == light(winstart(iW):winstart(iW)+pars.WinSize-1)) ./pars.WinSize;
        end

        %% classify session: compute numbers
                
        % Compute dominant strategy per session
        allP = [Sessions(iS).All.pRight Sessions(iS).All.pLight Sessions(iS).All.pLeft];  % in rule order
        Sessions(iS).All.pDominant = max(allP);
        Sessions(iS).All.DominantStrat = find(allP == Sessions(iS).All.pDominant);
        
        %% window classification numbers
        matP = [Sessions(iS).pRight' Sessions(iS).pLight' Sessions(iS).pLeft'];  %1=right; 2 = light; 3 = left
        [srt,Istrat] = sort(matP,2,'descend');  % put each window in order
        
        % proportion of windows dominated by each session
        for ii = 1:3
            Sessions(iS).propStrat(ii) = sum(Istrat(:,1)==ii) ./ Sessions(iS).nWindows;
        end

        % find proportion of trials 
        Sessions(iS).pDominant = max(Sessions(iS).propStrat);
        % for dominant strategy
        ixM = find(Sessions(iS).propStrat == Sessions(iS).pDominant);
        if numel(ixM) > 1
            Sessions(iS).DominantStrat = NaN;
            Sessions(iS).P_Dominant_Selected = NaN;
        else
            Sessions(iS).DominantStrat = ixM;  % of chosen rule-strategies to check, this is the dominant one
            Sessions(iS).P_Dominant_Selected = mean(matP(:,Sessions(iS).DominantStrat));
        end
        
        % contiguous runs at start and end
        Sessions(iS).ixStart = Istrat(1,1);  % dominant rule-strategy at end
        Sessions(iS).ixEnd = Istrat(end,1);  % dominant rule-strategy at end
        ixCont = find(diff(Istrat(:,1) == Sessions(iS).ixEnd) ~=0,1,'last')+1; % last change in dominant rule

        if isempty(ixCont)
            Sessions(iS).ixCont = 1;
        else
            Sessions(iS).ixCont = ixCont;
        end
        Sessions(iS).pCont = (Sessions(iS).nWindows-ixCont+1) ./ Sessions(iS).nWindows;  % proportion of session with contiguous windows at end


        %% label
%         if Sessions(iS).pDominant >= pars.PwinStable & Sessions(iS).P_Dominant_Selected >= pars.ThetaP 
%             Sessions(iS).ClassLabel = 'stable';
%             Sessions(iS).Class = 2;
        if Sessions(iS).All.pDominant >= pars.ThetaStable
            Sessions(iS).ClassLabel = 'stable';
            Sessions(iS).Class = 2;
        elseif Sessions(iS).ixStart ~= Sessions(iS).ixEnd && Sessions(iS).pCont >= pars.PwinContEnd
            Sessions(iS).ClassLabel = 'learn';
            Sessions(iS).Class = 1;
        else
            Sessions(iS).ClassLabel = 'unknown';
            Sessions(iS).Class = 0;
        end
    else
        Sessions(iS).ClassLabel = 'Excluded';
        Sessions(iS).Class = nan;
    end
end


Session_Strategy_Table = struct2table(Sessions)

save(['SimpleStrategy_' num2str(pars.ThetaStable) '.mat'],'Sessions','pars');


%% check stuff

% make Stable Table

ixStable = find([Sessions(:).Class] == 2 & [Sessions(:).OfficialLearn] == 0);

Names = [Sessions(ixStable).name]';

% any excluded sessions?
[cmn,iA,iB] = intersect(Excluded(Excluded(:,2)~=1),Names);
ixStable(iB) = [];  % remover excluded sessions

nStable = numel(ixStable);
Names = [Sessions(ixStable).name]';
RuleStart = [Sessions(ixStable).RuleStart]';
RuleEnd = [Sessions(ixStable).RuleEnd]';
Strategy = [Sessions(ixStable).DominantStrat]';

SimpleStable = table(Names,RuleStart,RuleEnd,Strategy);
save(['SimpleStable_' num2str(pars.ThetaStable) '.mat'],'SimpleStable','pars');


%% plot time series
cmap = brewermap(3,'Dark2');
ratIDs = [Sessions(:).Rat];
for i = 1:4
    ix = find(ratIDs == i);
    nSessions = numel(ix);
    
    xctr = 0; 
    hts = figure; hold on
    plotLeft = zeros(nSessions,1); plotRight = zeros(nSessions,1); plotLight = zeros(nSessions,1);
    for iPlot = 1:nSessions
        if Sessions(ix(iPlot)).nTrials >= pars.minTrials
            plotLeft(iPlot) = Sessions(ix(iPlot)).All.pLeft;
            plotRight(iPlot) = Sessions(ix(iPlot)).All.pRight;
            plotLight(iPlot) = Sessions(ix(iPlot)).All.pLight;
            
            figure(hts)
            x = xctr+ (1:Sessions(ix(iPlot)).nWindows);
            plot(x,Sessions(ix(iPlot)).pLeft,'Color',cmap(1,:));
            plot(x,Sessions(ix(iPlot)).pRight,'Color',cmap(2,:));
            plot(x,Sessions(ix(iPlot)).pLight,'Color',cmap(3,:));
            
            xctr = xctr + Sessions(ix(iPlot)).nWindows;
            line([xctr xctr],[0 1],'Color',[0.7 0.7 0.7],'Linewidth',0.5)
            if any(ix(iPlot) == ixStable)
                color = [0.8 0.2 0.2];
            elseif Sessions(ix(iPlot)).OfficialLearn
                color = [0.2 0.2 0.8];
            else
                color = [0.7 0.7 0.7];
            end
            text(x(2),1.025,num2str(Sessions(ix(iPlot)).name),'Color',color);
        else
            line([xctr+1 xctr+1],[0 1],'Color',[0.7 0.7 0.7],'Linewidth',2)
            xctr = xctr + 2;
            plotLeft(iPlot) = nan;
            plotRight(iPlot) = nan;
            plotLight(iPlot) = nan;

        end
    end
    set(gca,'YLim',[0.5 1.05]);
    figure(hts)
    xlabel('Trial')
    ylabel('P(strategy) [moving window]')
    
    figure
    line([1 nSessions],[pars.ThetaStable pars.ThetaStable],'LineStyle','--'); hold on
    plot(1:nSessions,plotLeft,'.-','Color',cmap(1,:)); 
    plot(1:nSessions,plotRight,'.-','Color',cmap(2,:));
    plot(1:nSessions,plotLight,'.-','Color',cmap(3,:));
    set(gca,'YLim',[0.5 1.05]);
    set(gca,'XTick',1:nSessions,'XTickLabel',[Sessions(ix).name]);
    xlabel('Session')
    ylabel('P(strategy) [whole session]')    
end


