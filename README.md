# PfC Dictionary: analysis code for the PfC dictionary paper

Folder "Processed data" contains the collated behavioural and spike data used for all analyses in the paper. 
(N.B. many intermediate analysis results are missing, as they are too large for GitHub)


## Key scripts
Shuffle_PartitionedSpike_Data: creates the shuffled data sets from the supplied partitioned spike data
Jitter_PartitionedSpike_Data: creates the jittered data sets from the supplied partitioned spike data

All of the following appear in versions for Data, Shuffled, and Jittered spike trains:

* GetWords_And_Count_Them: creates the words from the partitioned spike data 

* Data_Pword: probability of each word appearing in each epoch 
* Data_UniqueWord: comparing dictionary contents between epochs

* Data_Sleep_Changes : distances between P(word) distributions between sleep epochs 
* Data_Sleep_ChangesK2 : distances between P(word) distributions between sleep epochs, restricted to K>=2 words
* Data_DeltaPWord : change in word probability between epochs (no Jittered version of this)

## Position-dependent analyses
Full data from the CRCNS.org repository is needed for this


