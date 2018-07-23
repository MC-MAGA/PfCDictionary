function h = plotMultiStrip(xData,yData,figsize,colours,widths,fontsize,fontname,xtext,ytext,XTick,XTickLabel,XLim,YLim,M)

% PLOTMULTISTRIP multiple strip-plots (assumes semi-logx)
% H = PLOTMUTLISTRIP(X,Y,SIZE,C,W,F,NAME,strX,strY,XTick,XTickLabel,XLim,YLim,M,SYM)
% X : n-length row vector of x-axis data points
% Y : mxn-length array of y-axis data - 1 column per x-axis point
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

% maximum of axis

% strip-plot
h = figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 figsize]);
semilogx(xData,yData,'o','MarkerFaceColor',colours.marker,'MarkerEdgeColor',colours.edge,'Linewidth',widths.axis,'MarkerSize',M); hold on
ylabel(ytext)
xlabel(xtext) 
set(gca,'XTick',XTick,'XTickLabel',XTickLabel,'XMinorTick','off')

% arrange axes
set(gca,'XLim',XLim,'YLim',YLim)

% label axes
xlabel(xtext); 
ylabel(ytext); 

FormatFig_For_Export(h,fontsize,fontname,widths.axis);




