# ChIP-seq-analysis
This is a script that takes in *fastq.gz* files from paired-end or single-end ChIP-seq experiments and generates *fastqc*, *sam*, sorted and unsorted *bam* and *Bigwig* files. All the generated files are in separate appropriately named directories.
You will need to supply two text files: **Samples.txt** and **Info.txt** and load the conda environment for ChIP-seq.

## Installing modules
Use [Conda](https://conda.io/projects/conda/en/latest/user-guide/install/) to create an environment for ChIP-seq analysis using the following command:
```
conda create -n ChIP-seq -c bioconda deeptools samtools bowtie2 fastqc
```
## Samples.txt
This is a tab-delimited txt file or table. The first column should be the name that you want this particular sample output files to have. For example, if you want the files of a particular sample to have the name **Sample_1** so that the bam file is **Sample_1.bam**. Then, the first column should be **Sample_1**. 
The second column should be the name of the *fastq.gz* file of the sample, if single-end, or the first read file if its a paired-end experiment. The Third column, *which will only be completed if paired-end*, will have the *fastq.gz* file of the second read associated with the sample. 
## Info.txt
This is a text file that has the following information in separate lines
- **line 1** The full path to the directory containing the *fastq.gz* files. This will also be the directory where all the output files and directories will be present.
- **line 2** The full path to the bowtie-2 index.
- **line 3** The type of the experiment. This can only be **Single**, for single-end experiments, or **Paired**, for paired-end experiments.
- **line 4** The number of processors available for analysis.

## quickstart

#### Installing bowtie2 index
You can download bowtie2 index of your genome of choice from [here](http://bowtie-bio.sourceforge.net/bowtie2/index.shtml)

#### loading Conda environment
load the conda environment using the following command:
```
conda activate ChIP-seq 
```
#### Running the script

Specify the path for Samples.txt and Info.txt files in the **ChIP_analysis.sh** file using any text editor
```
Samples="/full/path/Samples.txt"
Info="/full/path/Info.txt"
```

After successfully preparing your "Samples.txt" and "Info.txt" files and including the full path to these text files in the upper part of the script.
You need to make sure that your shell script is executable using the following command:
```
chmod +x ChIP_analysis.sh
```
Then you can run the script using this command:

```
./ChIP_analysis.sh
```
OR

```
bash ChIP_analysis.sh
```
## Promoter-loading Index calculation
The R-script in the repository can be used to calculate the promoter loading index using the bam files generated by the shell script. Once the functions script is ran and the "Rsubread" package is loaded. The script can be used as follows:

#### Preparing TSS and Gene body regions dataframes
First you have to import a dataframe that includes the following information about gene(s) regions:
1) A unique identifier ID 
2) Chromosome
3) Start coordinate
4) End coordinate
5) strand of the feature (running on + or - strand)

Then you can use the TSSR.calculator or GBR.caluclator functions to prepare the SAF format dataframes.
You can do that using the following command:

```
TSSR_SAF<-TSSR.calculator(myfile,strand.col,Start.col,End.col,chrom.col,Id.col, region.length)
GBR_SAF<-GBR.calculator(myfile,strand.col,Start.col,End.col,chrom.col,Id.col, TSSR.length)
```

#### Preparing bam files vector
First, a vector containing the bam files have to be prepared. To do this, you will need to set the working directory to where the sorted bam files are present:

```
setwd("/path/to/sorted-bam/")
```
Then, you will need to list the bam files only using this command:

```
bam.files<-list.files(pattern="*.bam$")
```

#### Running the region count generator

To run the count generator, You have to generate the SAF files for Transciptoin start site (TSS) regions and gene body (GB) regions using the appropriate functions.
Following, you will have to run the region count generator function as follows: 

```
mydf.TSSR<-Region_count_generator(bam.files, TSSR_SAF, "path/to/ouput/directory", Paired = True/FALSE ...)
mydf.GBR<-Region_count_generator(bam.files, GBR_SAF, "path/to/ouput/directory", Paired = True/FALSE ...)
```
To calculate the Promoter-loading index (PL_I) from the TSSR and GBR counts. You will have to run the following steps:
1) Normalize the counts by the feature length.
This can be done by using the length column that is present in the dataframes generated by the *Region_count_generator* function. 
For examaple:

```
mydf$norm_TSSR<-(mydf.TSSR$Sample_1/mydf.TSSR$length)
mydf$norm_GBR<-(mydf.GBR$Sample_1/mydf.GBR$length)
```
2) Divide the length normalized values to get the "PL_I". You can log 2 transform the values if need to
```
#normal values
mydf$PL_I<-mydf$norm_TSSR/mydf$norm_GBR

#log transformed values
mydf$log_PL_I<-log2((mydf$norm_TSSR+1)/(mydf$norm_GBR+1))
```
3) You can prepare the cumulative frequency of these values using this command:
```
PL_I <- mydf[order(mydf$PL_I), ]
PL_I$ecdf <- ave(PL_I$PL_I,
PL_I$category, #this is the identifier of the sample
FUN=function(x) seq_along(x)/length(x))
```
4) Plotting of the data can be done by ggplot2
Here is an example plotting script:
```
#loading the packages
library(ggplot2)
library(scales)
#specifying the output as pdf and its path
pdf("/Path/to/outputfile.pdf")
ggplot(PL_I, aes(PL_I, ecdf, colour = category)) + geom_line()+theme_light()+
  scale_x_continuous(trans='log10')+
  scale_y_continuous(labels = percent)+ylab("Frequency")+xlab("Promoter Loading (PL)")+
  labs(colour="mygenes")
dev.off()
```
