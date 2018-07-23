function h = plotScatter(xData,yData,yCI,figsize,colours,widths,fontsize,fontname,xtext,ytext,blnDiagonal,M)

% PLOTSCATTER duh, for equal, positive axes
% H = PLOTSCATTER(X,Y,YCI,SIZE,C,W,F,NAME,strX,strY,B,M)
% X : n-length array of x-axis data
% Y : n-length array of y-axis data
% YCI: n x 2 array of required y-axis confidence interval (set [] to omit)
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
% blnDiagonal: {0,1}: draw an equality line diagonal  
% M:    markersize
%
% Mark Humphries 8/2/2018

% blnDiagonal = 1;

[r,~] = size(xData);
if r == 1 xData = xData'; end % need a column vector

% maximum of axis
axmax = ceil(max([xData; yData])*10) / 10;  % self-determined (or pass)
axmin = 0; % floor(min([xData; yData])*10) / 10;  % self-determined (or pass)

% plot diagonal line; scatter+CI
h = figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 figsize]);
if blnDiagonal line([eps axmax],[eps axmax],'Linewidth',widths.axis,'Color',[0 0 0]); hold on; end  % line of equality
plot(xData,yData,'o','MarkerFaceColor',colours.marker,'MarkerEdgeColor',colours.edge,'MarkerSize',M);  hold on; % scatter of data
if ~isempty(yCI) line([xData';xData'],yCI,'Color',colours.error,'Linewidth',widths.error);  end % CI on the y-axis


% arrange axes
axis([axmin axmax axmin axmax])
% axis equal
axis square

% label axes
xlabel(xtext); 
ylabel(ytext); 

FormatFig_For_Export(h,fontsize,fontname,widths.axis);




