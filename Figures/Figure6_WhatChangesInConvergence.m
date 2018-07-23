% script to build Figure 7: what changes during Convergence - rates,
% covariation, spike times?
% general format:
% run plotting function
% tidy plot (ticks, ranges)
% exports
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
iBin = 4; % example binsize: 5 ms
iShuffle = 1; % example shuffle
iSession = 7; % example session
iJit = 3;  % 10ms jitter (for 5 ms binsize)

strDlabel = {'D(T_S|Pre_S)','D(T_S|Post_S)'};
strSlabel = {'Data','Shuffle'};
strJlabel = {'Data','Jitter'};

Convergefigsize = [4 4];

shuflearn.marker = colours.shuf.line;
shuflearn.edge = colours.learning.line;
shuflearn.error = colours.shuf.line;

shufstable.marker = colours.shuf.line;
shufstable.edge = colours.stable.line;
shufstable.error = colours.shuf.line;

%% load
load([localpath 'Dictionary_Convergence_Analyses_N35_Learn'])
LearnData = Data; LearnSData = SData; 
NShuffles = size(LearnSData.Delta,3);

load([localpath 'Dictionary_Convergence_Analyses_N35_Stable85'])
StableData = Data; StableSData = SData;

%% linked strip-plot: Learn, at 5 ms (Trial only)
% trials-only
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 2 3.5]); 
LinkedUnivariateScatterPlots(gca,[1,2],[LearnSData.DTrial.TrialsPre(:,iBin,iShuffle) LearnSData.DTrial.TrialsPost(:,iBin,iShuffle)],colours.learning.line,...
    'MarkerFaceColor',[shuflearn.marker; shuflearn.marker],'MarkerEdgeColor',[shuflearn.edge; shuflearn.edge],...
    'MarkerSize',M,'Linewidth',widths.error,'strXlabel',strXlabel);
ylabel('Distance')
set(gca,'YLim',[0 0.4])
set(gca,'XTick',xtick,'XTickLabel',strDlabel,'XMinorTick','off')
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis);
%print([exportpath 'Fig7_Shuffled_Learn_Distance_5ms_TrialOnly'],'-dsvg');     


%% linked strip-plot: Stable, at 5ms (Trial only)

% trials-only
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 2 3.5]); 
LinkedUnivariateScatterPlots(gca,[1,2],[StableSData.DTrial.TrialsPre(:,iBin,iShuffle) StableSData.DTrial.TrialsPost(:,iBin,iShuffle)],colours.stable.line,...
    'MarkerFaceColor',[shufstable.marker; shufstable.marker],'MarkerEdgeColor',[shufstable.edge; shufstable.edge],...
    'MarkerSize',M,'Linewidth',widths.error,'strXlabel',strXlabel);
ylabel('Distance')
set(gca,'YLim',[0 0.4])
set(gca,'XTick',xtick,'XTickLabel',strDlabel,'XMinorTick','off')
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis);
%print([exportpath 'Fig7_Shuffled_Stable_Distance_5ms_TrialOnly'],'-dsvg');     

%% take means of Iconvergence over shuffled data (double-check SEM is tiny)
load([filepath 'DataWords_And_Counts_N' num2str(N) '_' type],'binsizes')

LearnS.Iconverge.M = squeeze(mean(LearnSData.IConvergence,3));
LearnS.Iconverge.SEM = squeeze(std(LearnSData.IConvergence,[],3)) ./ sqrt(NShuffles);
StableS.Iconverge.M = squeeze(mean(StableSData.IConvergence,3));
StableS.Iconverge.SEM = squeeze(std(StableSData.IConvergence,[],3)) ./ sqrt(NShuffles);

%% plot difference in Iconvergence: Data-Shuffled (mean of differences between each Data session and Shuffled sessions)

LearnDiff = LearnData.IConvergence - LearnS.Iconverge.M;
LearnPDiff = LearnDiff ./ LearnData.IConvergence;
h = plotMultiStrip(binsizes,LearnData.DiffTrial.IConvergence.M,Convergefigsize,colours.learning,widths,fontsize,fontname,...
                    'Word binsize (ms)','\Delta convergence (Data-Shuffle)',xtickSmall,strXlabelSmall,[xmin xmax],[-0.05 0.2],M);
line([eps xmax],[0 0],'Color',colours.shuf.line,'Linewidth',widths.axis); 
%print([exportpath 'Fig7_ConvergenceDifferenceShuffle'],'-dsvg');     

%% plot difference for K>=2 
load([localpath '/Plasticity_K2_Convergence_Analyses_N35_Learn.mat'])
h = plotMultiStrip(binsizes,Data.DiffTrial.IConvergence.M,Convergefigsize,colours.learning,widths,fontsize,fontname,...
                    'Word binsize (ms)','\Delta convergence (Data-Shuffle)',xtickSmall,strXlabelSmall,[xmin xmax],[-0.05 0.2],M);
line([eps xmax],[0 0],'Color',colours.shuf.line,'Linewidth',widths.axis); 
%print([exportpath 'Fig7_K2ConvergenceDifferenceShuffle'],'-dsvg');     

%% plot as proportion of 
K2S.Iconverge.M = squeeze(mean(SData.IConvergence,3));
K2S.Iconverge.SEM = squeeze(std(SData.IConvergence,[],3)) ./ sqrt(NShuffles);

K2Diff = Data.IConvergence - K2S.Iconverge.M;
K2PDiff = K2Diff ./ Data.IConvergence;

h = plotMultiStrip(binsizes,K2PDiff*100,Convergefigsize,colours.learning,widths,fontsize,fontname,...
                    'Word binsize (ms)','\Delta convergence (Data-Shuffle)',xtickSmall,strXlabelSmall,[xmin xmax],[-100 100],M);
line([eps xmax],[0 0],'Color',colours.shuf.line,'Linewidth',widths.axis); 
%print([exportpath 'Fig7_K2ConvergenceDifferenceShuffleProp'],'-dsvg');     

%% and repeat for Jittered data  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %% linked strip-plot: Learn, at 5 ms (Trial only)
% % trials-only
% figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 2 3.5]); 
% LinkedUnivariateScatterPlots(gca,[1,2],[LearnJData.DTrial.TrialsPre(:,iBin,iShuffle) LearnJData.DTrial.TrialsPost(:,iBin,iShuffle)],colours.learning.line,...
%     'MarkerFaceColor',[shuflearn.marker; shuflearn.marker],'MarkerEdgeColor',[shuflearn.edge; shuflearn.edge],...
%     'MarkerSize',M,'Linewidth',widths.error,'strXlabel',strXlabel);
% ylabel('Distance')
% set(gca,'YLim',[0 0.4])
% set(gca,'XTick',xtick,'XTickLabel',strDlabel,'XMinorTick','off')
% FormatFig_For_Export(gcf,fontsize,fontname,widths.axis);
% %print([exportpath 'Fig7_Jittered_Learn_Distance_5ms_TrialOnly'],'-dsvg');     
% 
% %% linked strip-plot: Stable, at 5ms (Trial only)
% 
% % trials-only
% figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 2 3.5]); 
% LinkedUnivariateScatterPlots(gca,[1,2],[StableJData.DTrial.TrialsPre(:,iBin,iShuffle) StableJData.DTrial.TrialsPost(:,iBin,iShuffle)],colours.stable.line,...
%     'MarkerFaceColor',[shufstable.marker; shufstable.marker],'MarkerEdgeColor',[shufstable.edge; shufstable.edge],...
%     'MarkerSize',M,'Linewidth',widths.error,'strXlabel',strXlabel);
% ylabel('Distance')
% set(gca,'YLim',[0 0.4])
% set(gca,'XTick',xtick,'XTickLabel',strDlabel,'XMinorTick','off')
% FormatFig_For_Export(gcf,fontsize,fontname,widths.axis);
% %print([exportpath 'Fig7_Jittered_Stable_Distance_5ms_TrialOnly'],'-dsvg');     


%% plot difference for K>=2 
load([filepath 'Jittered_TrialsSpike_Data_N' num2str(N) '_' type],'jittersize')
load([localpath '/Plasticity_K2_Convergence_Analyses_N35_Learn.mat'])
h = plotMultiStrip(jittersize,JData.DiffTrial.IConvergence.M,Convergefigsize,colours.learning,widths,fontsize,fontname,...
                    'Jitter (ms)','\Delta convergence (Data-Jittered)',jittersize,{'2','5','10','20','50'},[0.5 100],[-0.05 0.2],M);
line([eps xmax],[0 0],'Color',colours.shuf.line,'Linewidth',widths.axis); 
%print([exportpath 'Fig7_K2ConvergenceDifferenceJitter'],'-dsvg');     


%% showing co-variation changes using population coupling

iSession = 5;

load([filepath 'SDF_Data_N' num2str(N) '_' type '_Session' num2str(iSession) '_SD100ms'])
load([localpath 'PopCouple_Data_N' num2str(N) '_' type '_SD100ms']) 

iNeuron = 6;  % 6 is good
block = 1000:3000;
figsize = [5 1.5];

xtick = [1,floor(numel(block)/2), numel(block)-1]; % time-steps
strlabel = [1 xtick(2:end) * Qt];  % in ms


[nTimeTrial,nNeurons] = size(SDF.Trial);
ixs = 1:nNeurons;

% get population rate
PRtrial = sum(SDF.Trial(:,ixs~=iNeuron),2);
PRpre = sum(SDF.PreEpoch(:,ixs~=iNeuron),2);
PRpost = sum(SDF.PostEpoch(:,ixs~=iNeuron),2);



% panel 1: example of one neuron versus population rate

figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 figsize]); 
plot(zscore(PRpre(block)),'LineWidth',widths.plot,'Color',colours.pre.marker); hold on
plot(zscore(SDF.PreEpoch(block,iNeuron)),'LineWidth',widths.plot,'Color',colours.learning.error)
axis tight
set(gca,'XTick',xtick,'XTickLabel',strlabel);
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis)
%print([exportpath 'Fig7_NeuronTs_Pre'],'-dsvg');     

figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 figsize]); 
plot(PRtrial(block) ./ max(PRtrial(block)),'LineWidth',widths.plot,'Color',colours.trials.marker); hold on
plot(SDF.Trial(block,iNeuron) ./ max(SDF.Trial(block,iNeuron)),'LineWidth',widths.plot,'Color',colours.learning.error)
axis tight
set(gca,'XTick',xtick,'XTickLabel',strlabel);
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis)
%print([exportpath 'Fig7_NeuronTs_Trial'],'-dsvg');     

figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 figsize]); 
plot(PRpost(block) ./ max(PRpost(block)),'LineWidth',widths.plot,'Color',colours.post.marker); hold on
plot(SDF.PostEpoch(block,iNeuron) ./ max(SDF.PostEpoch(block,iNeuron)),'LineWidth',widths.plot,'Color',colours.learning.error)
axis tight
set(gca,'XTick',xtick,'XTickLabel',strlabel);
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis)
%print([exportpath 'Fig7_NeuronTs_Post'],'-dsvg');     


%% 2. correlation between population coupling
figcorr = [3 3];

relPre = PCple(iSession).Pre; % ./max(PCple(iSession).Pre);
relPost = PCple(iSession).Post; % ./max(PCple(iSession).Post);
relTrial = PCple(iSession).Trials; % ./max(PCple(iSession).Trials);
pltmin = min([min(relPre) min(relPost) min(relTrial)]);
% pltmin = 0;
pltmax = 0.5;

figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 4 4]); 
line([pltmin pltmax],[pltmin pltmax],'Linewidth',widths.axis,'Color',[0 0 0]); hold on
plot(relTrial,relPre,'o','MarkerSize',M,'MarkerFaceColor',colours.pre.marker,'MarkerEdgeColor',colours.pre.edge)
xlabel('Trial coupling')
ylabel('Pre-training coupling')
str = sprintf('%.2g',round(1000*PCple(iSession).rho.trialpre)/1000);
text(0,0.4,['R = ' str])
set(gca,'XTick',[0:0.2:1],'YTick',[0:0.2:1])
axis square; axis tight
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis)
%print([exportpath 'Fig7_TrialPre_Couple_Scatter'],'-dsvg');     


figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 4 4]); 
line([pltmin pltmax],[pltmin pltmax],'Linewidth',widths.axis,'Color',[0 0 0]); hold on
plot(relTrial,relPost,'o','MarkerSize',M,'MarkerFaceColor',colours.post.marker,'MarkerEdgeColor',colours.post.edge)
xlabel('Trial coupling')
str = sprintf('%.2g',round(1000*PCple(iSession).rho.trialpost)/1000);
text(0,0.4,['R = ' str])
ylabel('Post-training coupling')
set(gca,'XTick',[0:0.2:1],'YTick',[0:0.2:1])
axis square; axis tight
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis)
%print([exportpath 'Fig7_TrialPost_Couple_Scatter'],'-dsvg');     

%% 3. summary of correlations: linked strip plot of Pre-Trial and
% Post-Trial: to go next to correlations
for iS = 1:numel(PCple)
    pre(iS) = PCple(iS).rho.trialpre;
    post(iS) = PCple(iS).rho.trialpost;
end
strXlabel = {'Trial:Pre','Trial:Post'};

[P,H,STATS] = signrank(pre,post)

figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 1.5 4]); 
LinkedUnivariateScatterPlots(gca,[1,2],[pre' post'],colours.learning.line,...
    'MarkerFaceColor',[colours.learning.marker; colours.learning.marker],'MarkerEdgeColor',[colours.learning.edge; colours.learning.edge],...
    'MarkerSize',M,'Linewidth',widths.error,'strXlabel',strXlabel);
ylabel('Correlation')
%set(gca,'YLim',[0 0.4])
% set(gca,'XTick',xtick,'XTickLabel',strDlabel,'XMinorTick','off')
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis);
%print([exportpath 'Fig7_CouplingCorrelation'],'-dsvg');     









