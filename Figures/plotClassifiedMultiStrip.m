function h = plotClassifiedMultiStrip(xData,yData,Class,figsize,colours,widths,fontsize,fontname,xtext,ytext,XTick,XTickLabel,XLim,YLim,M)

% PLOTCLASSIFIEDMULTISTRIP multiple strip-plots with classified symbols (assumes semi-logx)
% H = PLOTMUTLISTRIP(X,Y,SIZE,C,W,F,NAME,strX,strY,XTick,XTickLabel,XLim,YLim,M,SYM)
% X : m size array of x-axis data points
% Y : n x m size array of y-axis data - 1 column per x-axis point
% CLASS: n x m size array of classified symbols (0, 1) e.g. 1: for P<alpha
% SIZE: [w h] of figure (in cms)
% 
% C: struct of colours with fields: 
%       .marker : face colour 
%       .line   : unused here
%       .error  : CI bar coloure
%       .edge   : outline of markers
% W : struct of line widths (in pts) with fields:
%       .plot   : lines on graph
%       .error  : CI lines
%       .axis   : axis lines
%
% F: fontsize (in pts)
% NAME: fontname
% strX, strY: text strings for axis labels
% XLim: 2 element array of [min max] for X-axis
% XTick, XTickLabel: array of tick locations, and cell array of tick labels 
% M : marker size
%
% Mark Humphries 12/2/2018

[r,~] = size(xData);
if r > 1 xData = xData'; end % need a row vector

% matrix for x-axis
xMat = repmat(xData,size(yData,1),1);

% strip-plot
h = figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 figsize]);
set(gca,'XScale','log')
line(XLim,[0 0],'Color',[0 0 0],'Linewidth',widths.axis); hold on
semilogx(xMat(Class==0),yData(Class==0),'o','MarkerFaceColor',colours.error,'MarkerEdgeColor',colours.edge,'Linewidth',widths.axis,'MarkerSize',M); hold on
semilogx(xMat(Class==1),yData(Class==1),'o','MarkerFaceColor',colours.marker,'MarkerEdgeColor',colours.edge,'Linewidth',widths.axis,'MarkerSize',M); hold on
ylabel(ytext)
xlabel(xtext) 
set(gca,'XTick',XTick,'XTickLabel',XTickLabel,'XMinorTick','off')

% arrange axes
set(gca,'XLim',XLim,'YLim',YLim)

% label axes
xlabel(xtext); 
ylabel(ytext); 

FormatFig_For_Export(h,fontsize,fontname,widths.axis);




