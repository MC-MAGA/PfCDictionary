% figure properties for PLoS Biology paper

format = 'png'; % for panels tricky for EPS (e.g. Pcolor plots)
color = 'rgb';
dpi = 600;
fontsize = 7;
fontname = 'Arial';
M = 4; % marker size for univariate scatter plots
sym = 'o';  % markers for scatters and strip plots

Units = 'centimeters';

% line widths
widths.plot = 0.75;
widths.error = 0.5;
widths.axis = 0.5;


% panel sizes
figsize = [4 4];

% colors for rule/strategy types
% Left, Right, Light
Rules.Left = [0.9451    0.6392    0.2510];
Rules.Right = [0.9686    0.4    0.4];
Rules.Light =  [0.6000    0.5569    0.7647];

% colours for maze bits
ClrChoice = [0.8 0.2 0];

Maze.Pre = [0.7 0.4 0.4];
Maze.Choice = [0.9 0.6 0.3];
Maze.ArmEnd = [0.2 0.6 0.9];


% colours for everything

colours.shuf.line = [0.6 0.6 0.6];
colours.all.line = [0 0 0];

% comparing epochs
colours.trials.marker = [0.8 0.2 0.2];
colours.pre.marker = [0.2 0.2 0.8];
colours.post.marker = [0.7 0.3 0.7];
colours.trials.edge = [1 1 1];
colours.pre.edge = [1 1 1];
colours.post.edge = [1 1 1];
colours.trials.error = [0.7 0.7 0.7];
colours.pre.error = [0.7 0.7 0.7];
colours.post.error = [0.7 0.7 0.7];

% colors for comparing session types
colours.learning.marker = [1 0.27 0];
colours.learning.line = [1 0.27 0];
colours.learning.error = [0.7 0.7 0.7];
colours.learning.edge = [1 1 1];

% colours.stable.marker = [0.3 0.5 0.8];
% colours.stable.line = [0.3 0.5 0.8];
colours.stable.marker = [0 0 0];
colours.stable.line = [0 0 0];
colours.stable.error = [0.7 0.7 0.7];
colours.stable.edge = [1 1 1];

colours.rule.marker = [0.8 0.2 0.2];
colours.rule.line = [0 0 0];
colours.rule.error = [0.7 0.7 0.7];
colours.rule.edge = [1 1 1];

colours.rest.marker = [0.7 0.4 0.7];
colours.rest.line = [0 0 0];
colours.rest.error = [0.7 0.7 0.7];
colours.rest.edge = [1 1 1];

% plotting ticks and limits for binsize plots
xtick = [1,2,5,10,20,50,100];
strXlabel = {'1','2','5','10','20','50','100'};

xtickSmall = [2,5,20,100];
strXlabelSmall = {'2','5','20','100'};

xmin = 0.5; xmax = 200;

% exportpath
if ispc
    exportpath = 'C:/Users/lpzmdh/Dropbox/My Papers/PfC sampling hypothesis/Dictionary version 2/Figures/Panels/';
else
    exportpath = '/Users/mqbssmhg/Dropbox/My Papers/PfC sampling hypothesis/Dictionary version 2/Figures/Panels/';
end