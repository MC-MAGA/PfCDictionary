%% get locations of every word...

clear all; close all;

type = 'Learn';  % 'Stable85'
N = 35;          

% get data
load(['PosData_' type]);
load(['DataWords_And_Counts_N' num2str(N) '_' type]);  % time-series of words
load(['Pword_Data_N' num2str(N) '_' type]);           % time-steps of each unique word

Nsessions = numel(PWord);

frate = 1000/30;   % 30 Hz frame-rate, expressed in milliseconds

% get locations
LocData = emptyStruct({'Bins'},[Nsessions,1]);

parfor iS = 1:Nsessions 
% for iS = 1:Nsessions   % over all sessions
    
    for iB = 1:numel(binsizes) % for each bin-size
        % for each word
        for iW = 1:numel(PWord(iS).Bins(iB).Trials.binaryIDs)
            
            % do the empty word
%             if iW == 1
%                 % is empty word, 
%                 ixEdges = setdiff(1:numel(WordData(iS).Bins(iB).Trials.edges),WordData(iS).Bins(iB).Trials.ts_array); % the set of edges not containing any words
%             else
%                 ixT = full(PWord(iS).Bins(iB).Trials.binaryIDs(iW)) == PWord(iS).Bins(iB).Trials.tsbinaryIDs; % indices into time-series of binary words
%                 ixEdges = WordData(iS).Bins(iB).Trials.ts_array(ixT);                            % indices into original time-stamp array
%             end
            
            % don't do the empty word

            % get time-steps of occurrence of binaryID;
            ixT = full(PWord(iS).Bins(iB).Trials.binaryIDs(iW)) == PWord(iS).Bins(iB).Trials.tsbinaryIDs; % indices into time-series of binary words
            ixEdges = WordData(iS).Bins(iB).Trials.ts_array(ixT);                            % indices into original time-stamp array
            
            % look-up time-stamps in EDGES array
            Ts = WordData(iS).Bins(iB).Trials.edges(ixEdges);  % the actual time-stamps
            
            % find all nearest positions
            xy = zeros(numel(Ts),2);
            for iT = 1:numel(Ts)
                ixLower = find(PosData(iS).Trials.Norm(:,1) <= Ts(iT),1,'last'); ixUpper = find(PosData(iS).Trials.Norm(:,1) > Ts(iT),1);
                upper = PosData(iS).Trials.Norm(ixUpper,:); lower = PosData(iS).Trials.Norm(ixLower,:);
                pTime = (Ts(iT) - lower(1)) ./ frate;
                % linearly interpolate between the two times            
                xy(iT,:) = PosData(iS).Trials.Norm(ixLower,2:3) + (PosData(iS).Trials.Norm(ixUpper,2:3) - PosData(iS).Trials.Norm(ixLower,2:3)).*pTime;
            end
            % store
            LocData(iS).Bins(iB).Word(iW).xy = xy;
            LocData(iS).Bins(iB).Word(iW).binaryID = full(PWord(iS).Bins(iB).Trials.binaryIDs(iW));
            LocData(iS).Bins(iB).Word(iW).K = full(sum(PWord(iS).Bins(iB).Trials.WordSet(:,iW)));
            % process median and IQR
            LocData(iS).Bins(iB).Word(iW).Xspread = prctile(xy(:,1),[25,50,75]); % median and IQR
            LocData(iS).Bins(iB).Word(iW).Yspread = prctile(xy(:,2),[25,50,75]); % median and IQR     
            LocData(iS).Bins(iB).Word(iW).mean = [mean(xy(:,1)) mean(xy(:,2))];
            LocData(iS).Bins(iB).Word(iW).std = [std(xy(:,1)) std(xy(:,2))];
            
        end
    end
end

save(['LocationWord_Data_N' num2str(N) '_' type], 'LocData');

