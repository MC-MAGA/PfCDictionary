function h = DiffClosenessOnMaze(meds,closeness,Limits,divs,alpha,figsize,colour,width)

YPost = meds(closeness < divs(1));  % tail closer to Post
YMid = meds(closeness  >= divs(1) & closeness  <= divs(2));  % centre mass
YPre = meds(closeness  > divs(2));  % tail closer to Pre

%% get proportions
Props = [sum(YPost >= Limits(1) & YPost <= Limits(2)) ./ numel(YPost);...
                sum(YMid >= Limits(1) & YMid <= Limits(2)) ./ numel(YMid);...
                sum(YPre >= Limits(1) & YPre <= Limits(2)) ./ numel(YPre)];
            
CIProps = [JeffreyCI(numel(YPost),Props(1).*numel(YPost),alpha);...
                    JeffreyCI(numel(YMid),Props(2).*numel(YMid),alpha);...
                    JeffreyCI(numel(YPre),Props(3).*numel(YPre),alpha)];

%% plot
x = [-1 + (divs(1) +1)/2, divs(1) + (divs(2)-divs(1))/2, divs(2) + (1-divs(2))/2 ]; % get these x positions for the plots
h = figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[10 15 figsize+0.5]);

set(gca,'Units','centimeters','Position',[0.5 0.5 figsize-0.5])
plot(x,Props,'o','Color',colour,'MarkerFaceColor',colour,'MarkerSize',5); hold on
line([x;x],CIProps','Color',colour,'Linewidth',width);
y = get(gca,'YLim');
set(gca,'XLim',[-1 1],'XTick',divs,'YLim',[0 y(2)]);

line([divs; divs],[0 0; y(2) y(2)],'Color',[0.8 0.8 0.8],'Linewidth',0.5)
% ylabel('Proportion of words'); 
% xlabel('Closeness')


