# ChIP-seq-analysis
This is a script that takes in *fastq.gz* files from paired-end or single-end ChIP-seq experiments and generates *fastqc*, *sam*, sorted and unsorted *bam* and *Bigwig* files. All the generated files are in separate appropriately named directories.
You will need to supply two text files: **Samples.txt** and **Info.txt** and load the following modules programs:
- Fastqc
- Bowtie2
- Samtools
- Deeptools
## Samples.txt
This is a tab-delimited txt file or table. The first column should be the name that you want this particular sample output files to have. For example, if you want the files of a particular sample to have the name **Sample_1** so that the bam file is **Sample_1.bam**. Then, the first column should be **Sample_1**. 
The second column should be the name of the *fastq.gz* file of the sample, if single-end, or the first read file if its a paired-end experiment. The Third column, *which will only be completed if paired-end*, will have the *fastq.gz* file of the second read associated with the sample. 
## Info.txt
This is a text file that has the following information in separate lines
- **line 1** The full path to the directory containing the *fastq.gz* files. This will also be the directory where all the output files and directories will be present.
- **line 2** The full path to the bowtie-2 index
- **line 3** The type of the experiment. This can only be **Single**, for single-end experiments, or **Paired**, for paired-end experiments
- **line 4** The number of processors available for analysis
