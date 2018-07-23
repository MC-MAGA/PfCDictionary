%% Figure 1: task and performance
clear all; close all

run figure_properties
addpath('../Helper functions/');

% Original code: given original data (on CRCNS.org) organised into one folder per session
% this processes breakdown of defined list of sessions into trials and epochs
% Note: this breakdown only used to plot a panel in this figure, not for
% any analysis
% datapath = 'C:....';  % location of folders 
% learning_Sessions = {'150628','150630','150707',...
%                      '181012','181020',...
%                      '190214','190228',...
%                      '201222','201227','201229'};
% SessionElements = BreakdownSessionTimes(datapath,learning_Sessions);
% save SessionElements SessionElements   % save the breakdown

ixExample = 6;     % which example learning session> 150628 (index is into "session" struct)
                 

load SessionElements    % breakdown of learning sessions into components
load('../Processed data/SessionReward');  % reward curve data per learning session (from "reward_rates.m")

n = numel(SessionElements);     % number of learning sessions

%% panel b: distribution of session components
pwidth = 0.4;

%1 = rest; 2 = SWS; 3 =task; 4 = correct trial; 5 = incorrect trial
seqcmap = [0.6 0.6 0.6;...
           0 0 0;... 
           1 1 1;...
           0.8 0.4 0.2;... 
           0.2 0.4 0.8];

% sequential durations of events
figure('Units', Units, 'PaperPositionMode', 'auto','Position',[10 15 7 5]); hold on;

for iS = 1:n
    ts = SessionElements (iS).allperiod ./ 1000; % in seconds
    v = [];
    f = []; fctr = 1;
    % plot a patch sequence for each session 
    for iT = 1:numel(ts)-1
        v = [v; ts(iT) iS-pwidth; ts(iT) iS+pwidth; ts(iT+1) iS-pwidth; ts(iT+1) iS+pwidth]; 
        f = [f; [1 2 4 3]+(iT-1)* 4];
    end
    
    patch('Faces',f,'Vertices',v,'FaceVertexCData',SessionElements(iS).periodtype(1:end-1)'./4,'FaceColor','flat','EdgeColor','none');
end
colormap(seqcmap)
axis([0 10000 0.5 10.5]);

xlabel('Time(s)','FontSize',fontsize); 
ylabel('Session','FontSize',fontsize); 
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis)

% exportfig(gcf,'Fig2c_network','Color',color,'Format',format,'Resolution',dpi)
%print([exportpath 'Fig1_session_durations'],'-dsvg');



%% learning curves
nSessions = numel(session);

% single example

figure('Units', Units, 'PaperPositionMode', 'auto','Position',[10 15 4 3]); hold on;
% line([0 0],[-15 20],'Color',[0.7 0.7 0.7])
% x = [1:session(iS).nTrials] - session(iS).learningtrial;
line([session(ixExample).learningtrial session(ixExample).learningtrial],[0 max(session(ixExample).cumR)+2],'Color',[0.7 0.7 0.7])
stairs(1:session(ixExample).nTrials,session(ixExample).cumR,'Linewidth',widths.plot)
axis tight

xlabel('Trial','FontSize',fontsize); 
ylabel('Cumulative reward','FontSize',fontsize); 
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis)

%print('-dsvg',[exportpath 'Fig1_cumulative_reward']);


%% a heat-map
maxPre = min([session.learningtrial])-1;  % number of trials before learning trial
maxPost = min([session.nTrials] - [session.learningtrial]); % number of trials after learning trial

matRcumul = zeros(nSessions,maxPre + maxPost+1);
for iS = 1:nSessions
    % normR = session(iS).cumR - session(iS).cumR(session(iS).learningtrial);
    normR = session(iS).cumR - session(iS).cumR(session(iS).learningtrial - maxPre);
    matRcumul(iS,:) = normR(session(iS).learningtrial - maxPre:session(iS).learningtrial+maxPost);
    matD_Rcumul(iS,:) = diff(matRcumul(iS,:));
end

Rcmap = brewermap(maxPre + maxPost+1,'*Reds');
figure('Units', Units, 'PaperPositionMode', 'auto','Position',[10 15 4 6]); hold on;
imagesc(-maxPre:maxPost,1:nSessions,matRcumul); 
colormap(Rcmap)
axis tight
line([0 0],[0.5 10.5],'Color',[0.7 0.7 0.7],'LineWidth',widths.plot)
ylabel('Session','FontSize',fontsize); 
xlabel('Trial','FontSize',fontsize);
posI = get(gca,'Position');
set(gca,'Position',[posI(1) posI(2) posI(3) posI(4)-0.05])
posI=get(gca,'pos');
hc = colorbar('location','northoutside','position',[posI(1) posI(2)+posI(4)+0.03 posI(3) 0.03])
set(hc,'xaxisloc','top')
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis)

%print('-dsvg',[exportpath 'Heatmap_cumulative_reward']);


%% example time-series of strategy choice
% sliding window analysis from Simple-Strategy here....

load(['../Analysis code/SimpleStrategy_0.85.mat'],'Sessions','pars'); % load Stable sessions - names and time-series
ixLearning = find([Sessions(:).OfficialLearn]);


% find index into "Session" struct
name = str2double(session(ixExample).names);
for iL = 1:numel(ixLearning)
    if  name == Sessions(ixLearning(iL)).name
        ExampleLearn = ixLearning(iL);
    end
end
% time-series of learn
winstart = 1:session(ixExample).nTrials - pars.WinSize;
winmids = winstart + floor(pars.WinSize/2);
learnWindow = find(winmids == session(ixExample).learningtrial);

figure('Units', Units, 'PaperPositionMode', 'auto','Position',[10 15 4 3]); hold on;
line([winmids(learnWindow) winmids(learnWindow)],[0 1],'Color',[0.7 0.7 0.7])
plot(winmids,Sessions(ExampleLearn).pLeft,'.-','Linewidth',widths.plot,'Color',Rules.Left)
plot(winmids,Sessions(ExampleLearn).pRight,'.-','Linewidth',widths.plot,'Color',Rules.Right)
plot(winmids,Sessions(ExampleLearn).pLight,'.-','Linewidth',widths.plot,'Color',Rules.Light)
set(gca,'XLim',[0 session(ixExample).nTrials])
xlabel('Trial','FontSize',fontsize); 
ylabel('P(strategy)','FontSize',fontsize); 
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis)

%print('-dsvg',[exportpath 'Fig1_Learn_PStrategy']);


%% Stair plots of dominant strategy: for both Learn and Stable sessions (set blnLearn)



blnLearn = 0;  % plot learn or stable?
figsize = [3 3];
load(['../Analysis code/SimpleStrategy_0.85.mat'],'Sessions','pars'); % load Stable sessions - names and time-series
load(['../Analysis code/SimpleStable_0.85.mat']); % table of chosen stable sessions - shows which ones were excluded

if blnLearn
    ixSessions = find([Sessions(:).OfficialLearn]);
    strY = 'P(correct strategy)';
    strFname = ['Fig1_Learn_P_Final_Strategy'];
    % match up session names in the two lists
    for iN = 1:numel(ixSessions)
        for iS = 1:numel(session)
            if Sessions(ixSessions(iN)).name == str2double(session(iS).names)
                iMatch = iS;
            end
        end
        align(iN) = session(iMatch).learningtrial;
    end
else

    for iN = 1:numel(SimpleStable.Names)
        ixSessions(iN) = find([Sessions(:).name] == SimpleStable.Names(iN));
        align(iN) = 0;
    end
    strFname = ['Fig1_Stable_P_Final_Strategy'];
    strY = 'P(dominant strategy)';
end

N = [Sessions(ixSessions).nTrials];

% Ddominant = zeros(numel(N),numel(winstrt));
for iS = 1:numel(ixSessions)
    Pleft = Sessions(ixSessions(iS)).pLeft;
    Pright = Sessions(ixSessions(iS)).pRight;
    Plight = Sessions(ixSessions(iS)).pLight;
    Strategy(iS).winstrt = 1:numel(Pleft);
    Strategy(iS).winmids = Strategy(iS).winstrt + floor(pars.WinSize/2);
    
    % difference between dominant and next-dominant
    allP = [Pright; Plight; Pleft]; % 1= go right; 2 = light; 3  = left
    if blnLearn
        ixEnd = find(allP(:,end) == max(allP(:,end)));  % reference strategy is the one at the end
    else
        ixEnd = Sessions(ixSessions(iS)).All.DominantStrat; % reference strategy is dominant one over session
    end
    Strategy(iS).Dend = allP(ixEnd,:) - max(allP);
    Strategy(iS).Pend = allP(ixEnd,:); % just show increase in P
end

% overlay all stair plots
cmap = brewermap(numel(ixSessions)+5,'Greys');
if blnLearn
    color = colours.learning.line;
    cmap = brewermap(numel(ixSessions)+5,'Greys');
else
    color = colours.stable.line;
    cmap = brewermap(numel(ixSessions)+5,'Blues');
end

hlight = [0.8 0.4 0.3];

figure('Units', Units, 'PaperPositionMode', 'auto','Position',[10 15 figsize]); hold on;
for iS = 1:numel(ixSessions)
    x = Strategy(iS).winmids - align(iS);
    y = Strategy(iS).Pend; %  / Strategy(iS).Pend(end);
    plot(x,y,'.-','Linewidth',widths.error,'Color',cmap(iS,:))
    % plot(x,y,'.-','Linewidth',widths.error,'Color',color)
%     if iS == 5;
%         plot(x,y,'.-','Linewidth',widths.plot,'Color',hlight)
%     end
end
if blnLearn line([0 0],[0 1],'Color',[0.7 0.7 0.7],'LineWidth',widths.plot); end
axis tight
set(gca,'YLim',[0 1])
xlabel('Trial'); 
ylabel(strY); 
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis);

%print([exportpath strFname],'-dsvg'); 















