# PfC Dictionary: analysis code for the PfC dictionary paper

Code (Matlab) to do all analyses and reproduce all figure panels from: [citation to come]

## Figures
Each figure has a separate script, that loads data from a combination of this repository and the intermediate results files (see below)

## Basic data
Folder "Processed data" contains the collated behavioural and spike data used for all analyses in the paper. 
Almost all analyses can be re-run based on the data files in this folder.

These basic data are processed from the 53 sessions made available to us by Adrien Peyrache. The full set of experimental sessions are available on CRCNS at: http://crcns.org/data-sets/pfc/pfc-6/about-pfc-6

## Intermediate results files
The output of the further analysis scripts for word, dictionaries, and locations are too large for GitHub. These are available here:

## Key scripts
Shuffle_PartitionedSpike_Data: creates the shuffled data sets from the supplied partitioned spike data
Jitter_PartitionedSpike_Data: creates the jittered data sets from the supplied partitioned spike data
(both the above load the spike data from the "Processed data" folder)

All of the following appear in versions for Data, Shuffled, and Jittered spike trains:
(They each expect to read and write data from the Analysis/ folder)

* GetWords_And_Count_Them: creates the words from the partitioned spike data 

* Data_Pword: probability of each word appearing in each epoch 
* Data_UniqueWord: comparing dictionary contents between epochs

* Data_Sleep_Changes : distances between P(word) distributions of each sleep epoch 
* Data_Sleep_ChangesK2 : distances between P(word) distributions of each sleep epoch, restricted to K>=2 words
* Data_DeltaPWord : change in word probability between epochs (no Jittered version of this)

## Position-dependent analyses
Full data from the CRCNS.org repository is needed for the initial "CheckAndProcess_PositionData" script.
The Location_Of_Words and Location_Of_Shuffled_Words scripts can be run using the intermediate results files


