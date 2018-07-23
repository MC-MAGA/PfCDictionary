%% get locations of every word...

clear all; close all;

type = 'Learn';  % 'Stable85'
N = 35;          

% get data
load(['PosData_' type]);
switch type
    case{'Learn'}
        load(['Shuffled_Words_and_Counts_N' num2str(N) '_' type]);  % time-series of words
    case{'Stable85'}
        load(['Shuffled_Trials_Words_and_Counts_N' num2str(N) '_' type]);  % time-series of words
        % NB not coded yet: will need below changing in order to use the
        % struct format in this save file
end
load(['Pword_Shuffled_N' num2str(N) '_' type]);           % time-steps of each unique word

%%
Nsessions = numel(PWord);
Nshuffles = numel(PWord(1).Shuffle);

frate = 1000/30;   % 30 Hz frame-rate, expressed in milliseconds

% get locations
LocData = emptyStruct({'Shuffle'},[Nsessions,1]);

parfor iS = 1:Nsessions 
% for iS = 1:Nsessions   % over all sessions
    for iSh = 1:Nshuffles 
        for iB = 1:numel(binsizes) % for each bin-size
            % for each word
            for iW = 1:numel(PWord(iS).Shuffle(iSh).Bins(iB).Trials.binaryIDs)
                % iW
                % get time-steps of occurrence of binaryID;
                ixT = full(PWord(iS).Shuffle(iSh).Bins(iB).Trials.binaryIDs(iW)) == PWord(iS).Shuffle(iSh).Bins(iB).Trials.tsbinaryIDs; % indices into time-series of binary words
                ixEdges = WordData(iS).Shuffle(iSh).Bins(iB).Trials.ts_array(ixT);                            % indices into original time-stamp array

                % look-up time-stamps in EDGES array
                Ts = WordData(iS).Shuffle(iSh).Bins(iB).Trials.edges(ixEdges);  % the actual time-stamps

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
                LocData(iS).Shuffle(iSh).Bins(iB).Word(iW).xy = xy;
                LocData(iS).Shuffle(iSh).Bins(iB).Word(iW).binaryID = full(PWord(iS).Shuffle(iSh).Bins(iB).Trials.binaryIDs(iW));
                LocData(iS).Shuffle(iSh).Bins(iB).Word(iW).K = full(sum(PWord(iS).Shuffle(iSh).Bins(iB).Trials.WordSet(:,iW)));
                % process median and IQR
                LocData(iS).Shuffle(iSh).Bins(iB).Word(iW).Xspread = prctile(xy(:,1),[25,50,75]); % median and IQR
                LocData(iS).Shuffle(iSh).Bins(iB).Word(iW).Yspread = prctile(xy(:,2),[25,50,75]); % median and IQR     
                LocData(iS).Shuffle(iSh).Bins(iB).Word(iW).mean = [mean(xy(:,1)) mean(xy(:,2))];
                LocData(iS).Shuffle(iSh).Bins(iB).Word(iW).std = [std(xy(:,1)) std(xy(:,2))];
            end
        end
    end
end

save(['LocationWord_Shuffled_N' num2str(N) '_' type], 'LocData');

