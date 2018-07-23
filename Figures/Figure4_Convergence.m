% script to build Figure 3: changes between Sleep epochs
% general format:
% run plotting function
% tidy plot (ticks, ranges)
% export
% exportfig(h,[figpath 'Fig_' figID],'Color',color,'Format',format,'Resolution',dpi)


clear all; close all


% where are the data? Intermediate results too large for GitHub
filepath = 'C:\Users\lpzmdh\Dropbox\My Papers\PfC sampling hypothesis\Dictionary version 2\figures\Large_Intermediate_Results\';

localpath = '../Analysis code/';

% style sheet
run figure_properties

% which data for examples
type = 'Learn';
N = 35;
iBin = 4; % 5 ms
iSession = 8;

Convergefigsize = [6 4];
lW = 0.05;  % spacing of strip plots around the binsize tick mark

strDlabel = {'D(T|Pre)','D(T|Post)'};


%% panel: example P(Trial) vs P(Pre) scatter
load([filepath 'Pword_Data_N' num2str(N) '_' type], 'PWord');  % data Pword, and the binary IDs of each word
pPre = PWord(iSession).Bins(iBin).Pre.P; IDpre = PWord(iSession).Bins(iBin).Pre.binaryIDs;
pTrial = PWord(iSession).Bins(iBin).Trials.P; IDtrial = PWord(iSession).Bins(iBin).Trials.binaryIDs;
[~,cmnPre,cmnTrial] = intersect(IDpre,IDtrial);
plotScatter(pTrial(cmnTrial),pPre(cmnPre),[],figsize,colours.learning,widths,fontsize,fontname,'P(Trials)','P(Pre)',1,3);
set(gca,'XScale','log','YScale','log','XLim',[1e-6 1],'yLim',[1e-6 1])
set(gca,'XTick',[1e-6 1e-4 1e-2 1],'YTick',[1e-6 1e-4 1e-2 1])
%print([exportpath 'Fig4_TrialVsPre_Scatter'],'-dsvg'); 

load([localpath 'Dictionary_Convergence_Analyses_N35_Learn'])
% use Trial dictionary only Distances (as plotted here)
D_Trial_Pre = Data.DTrial.TrialsPre(iSession,iBin) 
D_Trial_Post = Data.DTrial.TrialsPost(iSession,iBin)

%% panel: example P(Trial) vs P(Post) scatter
pPost = PWord(iSession).Bins(iBin).Post.P; IDpost = PWord(iSession).Bins(iBin).Post.binaryIDs;
[~,cmnPost,cmnTrial] = intersect(IDpost,IDtrial);
plotScatter(pTrial(cmnTrial),pPost(cmnPost),[],figsize,colours.learning,widths,fontsize,fontname,'P(Trials)','P(Post)',1,3);
set(gca,'XScale','log','YScale','log','XLim',[1e-6 1],'yLim',[1e-6 1])
set(gca,'XTick',[1e-6 1e-4 1e-2 1],'YTick',[1e-6 1e-4 1e-2 1])
%print([exportpath 'Fig4_TrialVsPost_Scatter'],'-dsvg'); 


%% linked strip-plot: Learn, at 5 ms (Trial only)

% load
load([localpath 'Dictionary_Convergence_Analyses_N35_Learn'])

% trials-only
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 2 3.5]); 
LinkedUnivariateScatterPlots(gca,[1,2],[Data.DTrial.TrialsPre(:,iBin) Data.DTrial.TrialsPost(:,iBin)],colours.learning.line,...
    'MarkerFaceColor',[colours.learning.marker; colours.learning.marker],'MarkerEdgeColor',[colours.learning.edge; colours.learning.edge],...
    'MarkerSize',M,'Linewidth',widths.error,'strXlabel',strXlabel);
ylabel('Distance')
set(gca,'YLim',[0 0.4])
set(gca,'XTick',xtick,'XTickLabel',strDlabel,'XMinorTick','off')
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis);
%print([exportpath 'Fig4_Learn_Distance_5ms_TrialOnly'],'-dsvg');     


%% linked strip-plot: Stable, at 5ms (Trial only)

% load
load([localpath 'Dictionary_Convergence_Analyses_N35_Stable85'])

% trials-only
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 2 3.5]); 
LinkedUnivariateScatterPlots(gca,[1,2],[Data.DTrial.TrialsPre(:,iBin) Data.DTrial.TrialsPost(:,iBin)],colours.stable.line,...
    'MarkerFaceColor',[colours.stable.marker; colours.stable.marker],'MarkerEdgeColor',[colours.stable.edge; colours.stable.edge],...
    'MarkerSize',M,'Linewidth',widths.error,'strXlabel',strXlabel);
ylabel('Distance')
set(gca,'YLim',[0 0.4])
set(gca,'XTick',xtick,'XTickLabel',strDlabel,'XMinorTick','off')
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis);
%print([exportpath 'Fig4_Stable_Distance_5ms_TrialOnly'],'-dsvg');     



%% panel: summary over binsizes Learn (Trial only)
% load
load([filepath 'DataWords_And_Counts_N' num2str(N) '_' type],'binsizes')
load([localpath 'Dictionary_Convergence_Analyses_N35_Learn'])

h = plotMultiStrip(binsizes,Data.DTrial.IConvergence,Convergefigsize,colours.learning,widths,fontsize,fontname,...
                    'Word binsize (ms)','Convergence',xtickSmall,strXlabelSmall,[xmin xmax],[-0.4 0.4],M);
line([eps xmax],[0 0],'Color',colours.shuf.line,'Linewidth',widths.axis); 
for iB = 1:numel(binsizes)
    str = sprintf('%.2g',round(1000*Data.DTrial.P.IConvergence(iB))/1000);  % round up annoying one
    % text(binsize(iB)-lW*binsize(iB),65,str,'Fontsize',fontsize-3);
    h = text(binsizes(iB)-lW*binsizes(iB),0.35,str,'Fontsize',fontsize-1);
    set(h,'Rotation',45)
end
%print([exportpath 'Fig4_LearnConvergence_TrialOnly'],'-dsvg');     

%% panel: summary over binsizes Stable 85 (Trial only)

load([filepath 'DataWords_And_Counts_N' num2str(N) '_' type],'binsizes')
load([localpath 'Dictionary_Convergence_Analyses_N35_Stable85'])

h = plotMultiStrip(binsizes,Data.DTrial.IConvergence,Convergefigsize,colours.stable,widths,fontsize,fontname,...
                    'Word binsize (ms)','Convergence',xtickSmall,strXlabelSmall,[xmin xmax],[-0.4 0.4],M);
line([eps xmax],[0 0],'Color',colours.shuf.line,'Linewidth',widths.axis); 
for iB = 1:numel(binsizes)
    str = sprintf('%.2g',round(1000*Data.DTrial.P.IConvergence(iB))/1000);  % round up annoying one
    % text(binsize(iB)-lW*binsize(iB),65,str,'Fontsize',fontsize-3);
    h = text(binsizes(iB)-lW*binsizes(iB),0.35,str,'Fontsize',fontsize-1);
    set(h,'Rotation',45)
end
%print([exportpath 'Fig4_StableConvergence_TrialOnly'],'-dsvg');     



%% panel: summary over binsizes Learn (all dictionary)
load([filepath 'DataWords_And_Counts_N' num2str(N) '_' type],'binsizes')
load([localpath 'Dictionary_Convergence_Analyses_N35_Learn'])

h = plotMultiStrip(binsizes,Data.IConvergence,Convergefigsize,colours.learning,widths,fontsize,fontname,...
                    'Word binsize (ms)','Convergence',xtickSmall,strXlabelSmall,[xmin xmax],[-0.4 0.4],M);
line([eps xmax],[0 0],'Color',colours.shuf.line,'Linewidth',widths.axis); 
for iB = 1:numel(binsizes)
    str = sprintf('%.2g',round(1000*Data.D.IConvergence.P(iB))/1000);  % round up annoying one
    % text(binsize(iB)-lW*binsize(iB),65,str,'Fontsize',fontsize-3);
    h = text(binsizes(iB)-lW*binsizes(iB),0.35,str,'Fontsize',fontsize-1);
    set(h,'Rotation',45)
end
%print([exportpath 'Fig4_LearnConvergence_All'],'-dsvg');     


%% panel: summary over binsizes Stable 85 (all dictionary)

load([filepath 'DataWords_And_Counts_N' num2str(N) '_' type],'binsizes')
load([localpath 'Dictionary_Convergence_Analyses_N35_Stable85'])

h = plotMultiStrip(binsizes,Data.IConvergence,Convergefigsize,colours.stable,widths,fontsize,fontname,...
                    'Word binsize (ms)','Convergence',xtickSmall,strXlabelSmall,[xmin xmax],[-0.4 0.4],M);
line([eps xmax],[0 0],'Color',colours.shuf.line,'Linewidth',widths.axis); 
for iB = 1:numel(binsizes)
    str = sprintf('%.2g',round(1000*Data.D.IConvergence.P(iB))/1000);  % round up annoying one
    % text(binsize(iB)-lW*binsize(iB),65,str,'Fontsize',fontsize-3);
    h = text(binsizes(iB)-lW*binsizes(iB),0.35,str,'Fontsize',fontsize-1);
    set(h,'Rotation',45)
end
%print([exportpath 'Fig4_StableConvergence_All'],'-dsvg');     
