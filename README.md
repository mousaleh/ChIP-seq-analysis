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
- **line 2** The full path to the bowtie-2 index
- **line 3** The type of the experiment. This can only be **Single**, for single-end experiments, or **Paired**, for paired-end experiments
- **line 4** The number of processors available for analysis
## quickstart

#### Installing bowtie2 index
You can download bowtie2 index of your genome of choice from [here] (http://bowtie-bio.sourceforge.net/bowtie2/index.shtml)

#### loading Conda environment
load the conda environment using the following command:
```
conda activate ChIP-seq 
```
#### Running the script

Specify the path for Samples.txt and Info.txt files in the code using any text editor
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
