% script to analyse changes in ISI distributions per neuron

clear all; close all

type = 'Learn';  % 'Learn','Stable85'
N = 35;  % 35, 15

load(['PartitionedSpike_Data_N' num2str(N) '_' type])

Nsessions = numel(Data);

binwidth = 10;
bins = 0:binwidth:5000;  % in ms

pre = [0.7 0.6 0.5];
post = [0.8 0.5 0.8];

%% pool ISIs, make histograms, get distance
for iS = 1:Nsessions
    
    [Nneurons,Nprebouts] = size(Data(iS).PreEpoch);
    Npostbouts = size(Data(iS).PostEpoch,2);
    allPre = []; allPost = [];
    % make single ISI distributions for pre and post
    for iN = 1:Nneurons
        isisPre = []; isisPost = [];
        for iP = 1:Nprebouts
            isisPre = [isisPre;Data(iS).PreEpoch(iN,iP).isis];
        end
        for iP = 1:Npostbouts
            isisPost = [isisPost;Data(iS).PostEpoch(iN,iP).isis];
        end

%         [ISIs(iS).pPre{iN},ISIs(iS).ePre{iN}] = histcounts(isisPre,'BinWidth',binwidth,'Normalization','probability');
%         [ISIs(iS).pPost{iN},ISIs(iS).ePost{iN}]= histcounts(isisPost,'BinWidth',binwidth,'Normalization','probability');
%         ISIs(iS).D(iN) = Hellinger(ISIs(iS).pPre{iN},ISIs(iS).ePre{iN}(1:end-1),ISIs(iS).pPost{iN},ISIs(iS).ePost{iN}(1:end-1));
 
%         [ISIs(iS).pPre{iN},ISIs(iS).ePre{iN}] = histcounts(isisPre,bins,'Normalization','cdf');
%         [ISIs(iS).pPost{iN},ISIs(iS).ePost{iN}]= histcounts(isisPost,bins,'Normalization','cdf');
% 
        ISIs(iS).spreadPre(iN,:) = prctile(isisPre,[5 25 50 75 95]);
        ISIs(iS).spreadPost(iN,:) = prctile(isisPost,[5 25 50 75 95]);
        
        allPre = [allPre; isisPre];
        allPost = [allPost; isisPost];
        
%         figure
% %         ecdf(isisPre); hold on
% %         ecdf(isisPost);
%         plot(ISIs(iS).ePre{iN}(1:end-1)+binwidth/2,ISIs(iS).pPre{iN},'Color',[0.7 0.6 0.5]); hold on
%         plot(ISIs(iS).ePost{iN}(1:end-1)+binwidth/2,ISIs(iS).pPost{iN},'Color',[0.8 0.5 0.8]); 
    end
    
    % sort by various properties
    [~,ISIs(iS).ixSrt50] = sort(ISIs(iS).spreadPre(:,3));
    [~,ISIs(iS).ixSrt75] = sort(ISIs(iS).spreadPre(:,4));
    [~,ISIs(iS).ixSrtMedDiff] = sort(ISIs(iS).spreadPre(:,3) - ISIs(iS).spreadPost(:,3));
    [~,ISIs(iS).ixSrtAbsMedDiff] = sort(abs(ISIs(iS).spreadPre(:,3) - ISIs(iS).spreadPost(:,3)));
   
    
    ixSrt = ISIs(iS).ixSrtMedDiff;
    yoff = 0.3;
    ygap = 0.01;
    f = [1 2 3 4];
    figure
    for iN=1:Nneurons
        v = [ISIs(iS).spreadPre(ixSrt(iN),1) iN+ygap; ISIs(iS).spreadPre(ixSrt(iN),5) iN+ygap; ISIs(iS).spreadPre(ixSrt(iN),5),iN+yoff; ISIs(iS).spreadPre(ixSrt(iN),1),iN+yoff];
        patch('Faces',f,'Vertices',v,'FaceColor',pre,'EdgeColor','none')
        v = [ISIs(iS).spreadPre(ixSrt(iN),2) iN+ygap; ISIs(iS).spreadPre(ixSrt(iN),4) iN+ygap; ISIs(iS).spreadPre(ixSrt(iN),4),iN+yoff; ISIs(iS).spreadPre(ixSrt(iN),2),iN+yoff];
        patch('Faces',f,'Vertices',v,'FaceColor',pre.*1.2,'EdgeColor','none')
       
        line([ISIs(iS).spreadPre(ixSrt(iN),3),ISIs(iS).spreadPre(ixSrt(iN),3)],[iN+ygap iN+yoff],'Color',[1 1 1],'Linewidth',2)
        
        v = [ISIs(iS).spreadPost(ixSrt(iN),1) iN-ygap; ISIs(iS).spreadPost(ixSrt(iN),5) iN-ygap; ISIs(iS).spreadPost(ixSrt(iN),5),iN-yoff; ISIs(iS).spreadPost(ixSrt(iN),1),iN-yoff];
        patch('Faces',f,'Vertices',v,'FaceColor',post,'EdgeColor','none')
        v = [ISIs(iS).spreadPost(ixSrt(iN),2) iN-ygap; ISIs(iS).spreadPost(ixSrt(iN),4) iN-ygap; ISIs(iS).spreadPost(ixSrt(iN),4),iN-yoff; ISIs(iS).spreadPost(ixSrt(iN),2),iN-yoff];
        patch('Faces',f,'Vertices',v,'FaceColor',post.*1.2,'EdgeColor','none')

        line([ISIs(iS).spreadPost(ixSrt(iN),3),ISIs(iS).spreadPost(ixSrt(iN),3)],[iN-ygap iN-yoff],'Color',[1 1 1],'Linewidth',2)
        
    end
    axis tight
    title(['Session ' num2str(iS)])
    %set(gca,'XScale','log')
    
    figure
    ecdf(allPre); hold on
    ecdf(allPost)
    title(['Session ' num2str(iS)])
    set(gca,'XScale','log')
end

save(['ExciteChangeSleep_Data_N' num2str(N) '_' type],'ISIs')