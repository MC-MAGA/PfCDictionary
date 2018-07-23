%% script to build figure for Data vs Shuffle dictionary comparisons
clear all; close all

% where are the data? Intermediate results too large for GitHub
filepath = 'C:\Users\lpzmdh\Dropbox\My Papers\PfC sampling hypothesis\Dictionary version 2\figures\Large_Intermediate_Results\';

localpath = '../Analysis code/';

% style sheet
run figure_properties
figsize = [4 3];

type = 'Learn';
N = 35;

load([filepath 'DataWords_And_Counts_N' num2str(N) '_' type],'binsizes')
load ([localpath 'ActivityPattern_Analyses_N' num2str(N) '_' type],'Data','SData','CI')

%% binary error: Shuffled
load([filepath 'DataWords_And_Counts_N' num2str(N) '_' type],'binsizes')
load ([localpath 'ActivityPattern_Analyses_N' num2str(N) '_' type],'Data','SData','CI')

figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 figsize]);
loglog(binsizes,100*SData.MeanPChange.Trials,'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.trials.marker,'MarkerFaceColor',colours.trials.marker,'MarkerEdgeColor',colours.trials.edge); hold on
loglog(binsizes,100*SData.MeanPChange.Pre,'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.pre.marker,'MarkerEdgeColor',colours.pre.edge); hold on
loglog(binsizes,100*SData.MeanPChange.Post,'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.post.marker,'MarkerEdgeColor',colours.post.edge); hold on

set(gca,'XTick',xtick,'XTickLabel',strXlabel,'XMinorTick','off')
set(gca,'YTick',[1e-6 1e-5 1e-4,1e-3,1e-2,1e-1,1]*100,'YTickLabel',{'0.0001','0.001','0.01','0.1','1','10','100'},'YMinorTick','off')
set(gca,'YLim',[1e-6 1].*100,'XLim',[xmin xmax])
xlabel('Word binsize (ms)')
ylabel('Binary error (%)')
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis)

%print([exportpath 'Fig5_ShuffledError_' type],'-dsvg'); 


%% binary error: Data vs Shuffled

figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 figsize]);
semilogx(binsizes,100*Data.PChange.Diff.Trials,'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.trials.marker,'MarkerFaceColor',colours.trials.marker,'MarkerEdgeColor',colours.trials.edge); hold on
semilogx(binsizes,100*Data.PChange.Diff.Pre,'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.pre.marker,'MarkerFaceColor',colours.pre.marker,'MarkerEdgeColor',colours.pre.edge); hold on
semilogx(binsizes,100*Data.PChange.Diff.Post,'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.post.marker,'MarkerFaceColor',colours.post.marker,'MarkerEdgeColor',colours.post.edge); hold on

line([xmin xmax],[0 0],'Color',colours.shuf.line,'Linewidth',widths.error)
set(gca,'XTick',xtickSmall,'XTickLabel',strXlabelSmall,'XMinorTick','off','XLim',[xmin xmax])
% set(gca,'YLim',[-1 0.5]);
xlabel('Word binsize (ms)')
ylabel('Difference in error (points)')

FormatFig_For_Export(gcf,fontsize,fontname,widths.axis)
%print([exportpath 'Fig5_DifferenceInError_' type],'-dsvg'); 

% express difference in binary error in proportion to the actual error (for Data)
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 figsize]);
semilogx(binsizes(2:end),100*Data.PChange.Diff.Trials(2:end)./Data.PChange.Trials(2:end),'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.trials.marker,'MarkerFaceColor',colours.trials.marker,'MarkerEdgeColor',colours.trials.edge); hold on
semilogx(binsizes(2:end),100*Data.PChange.Diff.Pre(2:end)./Data.PChange.Pre(2:end),'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.pre.marker,'MarkerFaceColor',colours.pre.marker,'MarkerEdgeColor',colours.pre.edge); hold on
semilogx(binsizes(2:end),100*Data.PChange.Diff.Post(2:end)./Data.PChange.Post(2:end),'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.post.marker,'MarkerFaceColor',colours.post.marker,'MarkerEdgeColor',colours.post.edge); hold on
line([xmin xmax],[0 0],'Color',colours.shuf.line,'Linewidth',widths.error)
set(gca,'XTick',xtickSmall,'XTickLabel',strXlabelSmall,'XMinorTick','off','XLim',[xmin xmax])
% set(gca,'YLim',[-1 0.5]);
xlabel('Word binsize (ms)')
ylabel('Proportional difference (%)')

FormatFig_For_Export(gcf,fontsize,fontname,widths.axis)
%print([exportpath 'Fig5_PropDifferenceInError_' type],'-dsvg'); 

%% Co-activation: Shuffled!
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 figsize]);
loglog(binsizes,100*SData.MeanProp.Trials,'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.trials.marker,'MarkerFaceColor',colours.trials.marker,'MarkerEdgeColor',colours.trials.edge); hold on
loglog(binsizes,100*SData.MeanProp.Pre,'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.pre.marker,'MarkerEdgeColor',colours.pre.edge); hold on
loglog(binsizes,100*SData.MeanProp.Post,'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.post.marker,'MarkerEdgeColor',colours.post.edge); hold on

set(gca,'XTick',xtick,'XTickLabel',strXlabel,'XMinorTick','off')
set(gca,'YTick',[1e-3,1e-2,1e-1,1]*100,'YTickLabel',{'0.1','1','10','100'},'YMinorTick','off')
set(gca,'YLim',[1e-3 1].*100,'XLim',[xmin xmax])
xlabel('Word binsize (ms)')
ylabel('Word with co-activity (%)')
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis)

%print([exportpath 'Fig5_ShuffledCoActivation_' type],'-dsvg'); 


%% panel: proportions of co-active words in Data and Shuffled 

% plot medians over sessions
MdiffTrial = squeeze(mean(Data.Prop.EachDiff.Trials,1));  % mean over all shuffles of difference between data and shuffles
MdiffPre = squeeze(mean(Data.Prop.EachDiff.Pre,1));  % mean over all shuffles of difference between data and shuffles
MdiffPost = squeeze(mean(Data.Prop.EachDiff.Post,1));  % mean over all shuffles of difference between data and shuffles


figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 figsize]);
semilogx(binsizes,100*median(MdiffTrial),'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.trials.marker,'MarkerFaceColor',colours.trials.marker,'MarkerEdgeColor',colours.trials.edge); hold on
semilogx(binsizes,100*median(MdiffPre),'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.pre.marker,'MarkerFaceColor',colours.pre.marker,'MarkerEdgeColor',colours.pre.edge); hold on
semilogx(binsizes,100*median(MdiffPost),'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.post.marker,'MarkerFaceColor',colours.post.marker,'MarkerEdgeColor',colours.post.edge); hold on

line([xmin xmax],[0 0],'Color',colours.shuf.line,'Linewidth',widths.error)
set(gca,'XTick',xtickSmall,'XTickLabel',strXlabelSmall,'XMinorTick','off','XLim',[xmin xmax])
set(gca,'YLim',[-1 1]);
xlabel('Word binsize (ms)')
ylabel('Median difference (points)')

FormatFig_For_Export(gcf,fontsize,fontname,widths.axis)
%print([exportpath 'Fig5_DifferenceInCoAct_' type],'-dsvg'); 

% also a proportional difference here? 
PEachSession.Trials = Data.K2.Trials./Data.Nwords.Trials;
PEachSession.Pre = Data.K2.Pre./Data.Nwords.Pre;
PEachSession.Post = Data.K2.Post./Data.Nwords.Post;

PropDiff.Trials = MdiffTrial ./ PEachSession.Trials;
PropDiff.Pre = MdiffPre ./ PEachSession.Pre;
PropDiff.Post = MdiffPost ./ PEachSession.Post;

figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 figsize]);
semilogx(binsizes,100*median(PropDiff.Trials),'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.trials.marker,'MarkerFaceColor',colours.trials.marker,'MarkerEdgeColor',colours.trials.edge); hold on
semilogx(binsizes,100*median(PropDiff.Pre),'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.pre.marker,'MarkerFaceColor',colours.pre.marker,'MarkerEdgeColor',colours.pre.edge); hold on
semilogx(binsizes,100*median(PropDiff.Post),'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.post.marker,'MarkerFaceColor',colours.post.marker,'MarkerEdgeColor',colours.post.edge); hold on

line([xmin xmax],[0 0],'Color',colours.shuf.line,'Linewidth',widths.error)
set(gca,'XTick',xtickSmall,'XTickLabel',strXlabelSmall,'XMinorTick','off','XLim',[xmin xmax])
% set(gca,'YLim',[-1 1]);
xlabel('Word binsize (ms)')
ylabel('Proportional difference (%)')

FormatFig_For_Export(gcf,fontsize,fontname,widths.axis)

%print([exportpath 'Fig5_PropDifferenceInCoAct_' type],'-dsvg'); 
