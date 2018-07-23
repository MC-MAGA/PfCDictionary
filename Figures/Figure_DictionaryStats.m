% script to build panels for making dictionary (Fig 2)
% and statistics of dictionary (panels in Figs...)
% these were all one figure, now used in different figures

clear all; close all

% where are the data? Intermediate results too large for GitHub
filepath = 'C:\Users\lpzmdh\Dropbox\My Papers\PfC sampling hypothesis\Dictionary version 2\figures\Large_Intermediate_Results\';

% style sheet
run figure_properties

figsize = [4 3];
smallstrp = [4.5 3.5];

% which data?
type = 'Learn';
N = 35;

%% example raster and checkerboard plot of words....
load(['../Processed data/PartitionedSpike_Data_N' num2str(N) '_' type]);
% load words
load([filepath 'DataWords_And_Counts_N' num2str(N) '_' type]);

iSession = 2;
iBin = 5;  % 10 ms bins
strtbin = 10;
bins = 50; % how many words to plot

% make single spike-array from binned spikes
fullIndices = arrayfun(@(x) ~isempty(x.spks), Data(iSession).PreEpoch); % find all non-empty Neuron+Chunk combinations
tsFull = vertcat(Data(iSession).PreEpoch(fullIndices).spks);   % concatenate the time-stamps
IDs = unique(tsFull(:,2)); 
nIDs = numel(IDs);

Tstrt = WordData(iSession).Bins(iBin).Pre.edges(strtbin);
Tend = WordData(iSession).Bins(iBin).Pre.edges(strtbin+bins);
ixChunk = tsFull(:,1) >= Tstrt & tsFull(:,1) <= Tend;  % indices of spikes within time bounds

% find non-empty words in this time-span
iNotEmpty = WordData(iSession).Bins(iBin).Pre.ts_array(WordData(iSession).Bins(iBin).Pre.ts_array >= strtbin & WordData(iSession).Bins(iBin).Pre.ts_array <= strtbin+bins-1);  % indices into the array of time-stamped egdes
iStrt = find(WordData(iSession).Bins(iBin).Pre.ts_array == iNotEmpty(1));  % start index into the stored arry of non-empty binary words
matWords = zeros(numel(IDs),bins);  % matrix of all words, with zeros already filled in
for i = 1:numel(iNotEmpty) % fill in all non-empty words
    matWords(:,iNotEmpty(i)-strtbin+1) = WordData(iSession).Bins(iBin).Pre.binary_array(:,iStrt+i-1); 
end

% plot raster
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 10 2]);
plot(tsFull(ixChunk,1),tsFull(ixChunk,2),'k.','Markersize',M)
line([Tstrt Tstrt],[0.5,nIDs+0.5],'Color',colours.shuf.line,'Linewidth',widths.axis);
for i = 1:bins
    t = Tstrt + i*binsizes(iBin);
    line([t t],[0.5,nIDs+0.5],'Color',colours.shuf.line,'Linewidth',widths.axis);
end
axis off
axis tight
set(gca,'YLim',[0.5,nIDs+0.5]);
set(gca,'Position',[0.1 0.1 0.8 0.8]);
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis)
%print([exportpath 'Fig2_Raster_' type],'-dsvg'); 

% plot checkerboard
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 10 2]);
imagesc(matWords)
set(gca','YDir','normal')

drawgrid(gca,[0.5:1:bins+0.5],[0.5:1:nIDs+0.5],[0.5 bins+0.5],[0.5,nIDs+0.5],colours.shuf.line,widths.axis/2)

colormap([1 1 1; 0 0 0]);
axis off
set(gca,'Position',[0.1 0.1 0.8 0.8]);
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis)
%print([exportpath 'Fig2_Checkerboard_' type],'-dsvg'); 

%% panel: proportions of word elements with more than 1 spike

% general format:
% run plotting function
% tidy plot (ticks, ranges)
% export

load([filepath 'DataWords_And_Counts_N' num2str(N) '_' type],'binsizes')
load (['../Analysis code/ActivityPattern_Analyses_N' num2str(N) '_' type],'Data','SData','CI')

figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 figsize]);
loglog(binsizes,100*Data.PChange.Trials,'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.trials.marker,'MarkerFaceColor',colours.trials.marker,'MarkerEdgeColor',colours.trials.edge); hold on
loglog(binsizes,100*Data.PChange.Pre,'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.pre.marker,'MarkerEdgeColor',colours.pre.edge); hold on
loglog(binsizes,100*Data.PChange.Post,'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.post.marker,'MarkerEdgeColor',colours.post.edge); hold on

set(gca,'XTick',xtick,'XTickLabel',strXlabel,'XMinorTick','off')
set(gca,'YTick',[1e-6 1e-5 1e-4,1e-3,1e-2,1e-1,1]*100,'YTickLabel',{'0.0001','0.001','0.01','0.1','1','10','100'},'YMinorTick','off')
set(gca,'YLim',[1e-6 1].*100,'XLim',[xmin xmax])
xlabel('Word binsize (ms)')
ylabel('Binary error (%)')
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis)

%print([exportpath 'Fig2_Error_' type],'-dsvg'); 

%% panel: proportion of co-active words
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 figsize]);
loglog(binsizes,100*Data.Prop.Trials,'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.trials.marker,'MarkerFaceColor',colours.trials.marker,'MarkerEdgeColor',colours.trials.edge); hold on
loglog(binsizes,100*Data.Prop.Pre,'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.pre.marker,'MarkerEdgeColor',colours.pre.edge); hold on
loglog(binsizes,100*Data.Prop.Post,'o-','Linewidth',widths.plot,'MarkerSize',M,'Color',colours.post.marker,'MarkerEdgeColor',colours.post.edge); hold on

set(gca,'XTick',xtick,'XTickLabel',strXlabel,'XMinorTick','off')
set(gca,'YTick',[1e-3,1e-2,1e-1,1]*100,'YTickLabel',{'0.1','1','10','100'},'YMinorTick','off')
set(gca,'YLim',[1e-3 1].*100,'XLim',[xmin xmax])
xlabel('Word binsize (ms)')
ylabel('Word with co-activity (%)')
FormatFig_For_Export(gcf,fontsize,fontname,widths.axis)

%print([exportpath 'Fig2_CoActivation_' type],'-dsvg'); 

%% panel: proportion of dictionary common to all epochs
load([filepath 'DataWords_And_Counts_N' num2str(N) '_' type],'binsizes')

% NB could also do these locally, by just reformatting UWord into matrices,
% as done in "ConservationOfDictionary_Properties"
load(['../Analysis code/ConservationOfDictionary_Analyses_N' num2str(N) '_' type],'Data','SData','CI','alpha')

h = plotMultiStrip(binsizes,Data.Pre.PCommonWords.*100,smallstrp,colours.pre,widths,fontsize,fontname,'Word binsize (ms)','Common words (%)',...
                        xtickSmall,strXlabelSmall,[xmin xmax],[0 100],M);
%print([exportpath 'Fig2_Pre_Common'],'-dsvg'); 

h = plotMultiStrip(binsizes,Data.Trials.PCommonWords*100,smallstrp,colours.trials,widths,fontsize,fontname,'Word binsize (ms)','Common words (%)',...
                        xtickSmall,strXlabelSmall,[xmin xmax],[0 100],M);                    
%print([exportpath 'Fig2_Trials_Common'],'-dsvg'); 

h = plotMultiStrip(binsizes,Data.Post.PCommonWords*100,smallstrp,colours.post,widths,fontsize,fontname,'Word binsize (ms)','Common words (%)',...
                        xtickSmall,strXlabelSmall,[xmin xmax],[0 100],M);
%print([exportpath 'Fig2_Post_Common'],'-dsvg'); 
                    
%% panel: proportions vs shuffled

h = plotClassifiedMultiStrip(binsizes,Data.Pre.Diff.PCommonWords*100,Data.Pre.common_P <= alpha,figsize,colours.pre,widths,fontsize,fontname,...
                                'Word binsize (ms)','Excess common words (%)',xtickSmall,strXlabelSmall,[xmin xmax],[-20 20],M);
%print([exportpath 'Fig2_Pre_Diff'],'-dsvg'); 

h = plotClassifiedMultiStrip(binsizes,Data.Trials.Diff.PCommonWords*100,Data.Trials.common_P <= alpha,figsize,colours.trials,widths,fontsize,fontname,...
                                'Word binsize (ms)','Excess common words (%)',xtickSmall,strXlabelSmall,[xmin xmax],[-20 20],M);
%print([exportpath 'Fig2_Trials_Diff'],'-dsvg'); 

h = plotClassifiedMultiStrip(binsizes,Data.Post.Diff.PCommonWords*100,Data.Post.common_P <= alpha,figsize,colours.post,widths,fontsize,fontname,...
                                'Word binsize (ms)','Excess common words (%)',xtickSmall,strXlabelSmall,[xmin xmax],[-20 20],M);
%print([exportpath 'Fig2_Post_Diff'],'-dsvg'); 

%% panel: proportion of dictionary unique to this epoch

h = plotMultiStrip(binsizes,Data.Pre.Punique.*100,figsize,colours.pre,widths,fontsize,fontname,'Word binsize (ms)','Dictionary unique to epoch (%)',...
                        xtickSmall,strXlabelSmall,[xmin xmax],[0 100],M);
%print([exportpath 'Fig2_Pre_Unique'],'-dsvg'); 

h = plotMultiStrip(binsizes,Data.Trials.Punique*100,figsize,colours.trials,widths,fontsize,fontname,'Word binsize (ms)','Dictionary unique to epoch (%)',...
                        xtickSmall,strXlabelSmall,[xmin xmax],[0 100],M);                    
%print([exportpath 'Fig2_Trials_Unique'],'-dsvg'); 

h = plotMultiStrip(binsizes,Data.Post.Punique*100,figsize,colours.post,widths,fontsize,fontname,'Word binsize (ms)','Dictionary unique to epoch (%)',...
                        xtickSmall,strXlabelSmall,[xmin xmax],[0 100],M);
%print([exportpath 'Fig2_Post_Unique'],'-dsvg'); 

%% panel: proportion of time taken up by common words
load([filepath 'DataWords_And_Counts_N' num2str(N) '_' type],'binsizes')
load(['../Analysis code/PropTime_Data_N' num2str(N) '_' type])

Nsessions = numel(PTime); 

for iS = 1:Nsessions
    for iB = 1:numel(binsizes)
        Plot.Trials.Common(iS,iB) = PTime(iS).Bins(iB).Trials.CommonPtime;
        Plot.Pre.Common(iS,iB) = PTime(iS).Bins(iB).Pre.CommonPtime;
        Plot.Post.Common(iS,iB) = PTime(iS).Bins(iB).Post.CommonPtime;
        Plot.Trials.Unique(iS,iB) = PTime(iS).Bins(iB).Trials.UniquePtime;
        Plot.Pre.Unique(iS,iB) = PTime(iS).Bins(iB).Pre.UniquePtime;
        Plot.Post.Unique(iS,iB) = PTime(iS).Bins(iB).Post.UniquePtime;       
    end
end

% common words
h = plotMultiStrip(binsizes,Plot.Pre.Common.*100,smallstrp,colours.pre,widths,fontsize,fontname,'Word binsize (ms)','Time spent on common words (%)',...
                        xtickSmall,strXlabelSmall,[xmin xmax],[0 100],M);
%print([exportpath 'Fig2_Pre_PTimeCommon'],'-dsvg'); 

h = plotMultiStrip(binsizes,Plot.Trials.Common*100,smallstrp,colours.trials,widths,fontsize,fontname,'Word binsize (ms)','Time spent on common words (%)',...
                        xtickSmall,strXlabelSmall,[xmin xmax],[0 100],M);                    
%print([exportpath 'Fig2_Trials_PTimeCommon'],'-dsvg'); 

h = plotMultiStrip(binsizes,Plot.Post.Common*100,smallstrp,colours.post,widths,fontsize,fontname,'Word binsize (ms)','Time spent on common words (%)',...
                        xtickSmall,strXlabelSmall,[xmin xmax],[0 100],M);
%print([exportpath 'Fig2_Post_PTimeCommon'],'-dsvg'); 

% unique words
h = plotMultiStrip(binsizes,Plot.Pre.Unique.*100,smallstrp,colours.pre,widths,fontsize,fontname,'Word binsize (ms)','Time spent on unique words (%)',...
                        xtickSmall,strXlabelSmall,[xmin xmax],[0 100],M);
%print([exportpath 'Fig2_Pre_PTimeUnique'],'-dsvg'); 

h = plotMultiStrip(binsizes,Plot.Trials.Unique*100,smallstrp,colours.trials,widths,fontsize,fontname,'Word binsize (ms)','Time spent on unique words (%)',...
                        xtickSmall,strXlabelSmall,[xmin xmax],[0 100],M);                    
%print([exportpath 'Fig2_Trials_PTimeUnique'],'-dsvg'); 

h = plotMultiStrip(binsizes,Plot.Post.Unique*100,smallstrp,colours.post,widths,fontsize,fontname,'Word binsize (ms)','Time spent on unique words (%)',...
                        xtickSmall,strXlabelSmall,[xmin xmax],[0 100],M);
%print([exportpath 'Fig2_Post_PTimeUnique'],'-dsvg'); 
