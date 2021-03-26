#!/bin/bash


														###fetching info from text files
Samples="Path/to/Samples text file"
Info="Path/to/Info text file"
##path to directory containing fastq files
fastqdir=$(sed "1q;d" "$Info")
##path to genome bowtie2 index
genome=$(sed "2q;d" "$Info")
myN=$(sed "3q;d" "$Info")
myP=$(sed "4q;d" "$Info")


													### Running QC programs on fastq files
cd "$fastqdir"
mkdir fastqc
#create text file with names of all fastq files
cat myfileseq.txt | ls *.fastq.gz >> myfileseq.txt
rowN=$(wc -l < myfileseq.txt)
##doing fastqc on all files
for i in $(seq "$rowN")
 do v1=$(sed "${i}q;d" myfileseq.txt)
 fastqc "$v1" -t "$myP" -o fastqc
done

																###alignment

##counting number of rows for loop
rowN=$(wc -l < "$Samples")
##changing directory to where the fastq files are
cd "$fastqdir"
mkdir SAM_files
##checking the type of experiment to specify alignment mode
if [ "$myN" == "Paired" ]; then
	#doing the for loop that gets the R1 file and R2 file from each file by row number and saves to a variable which then is feeded to bowtie2 command
	for i in $(seq "$rowN")
	#extracting the R1 file name from the samples sheet
	do v1=$(awk 'NR == '$i' { print $2 }' "$Samples")
	#extracting the R2 file name from the samples sheet
	v2=$(awk 'NR == '$i' { print $3 }' "$Samples")
	#extracting the name to be used for output file from samples sheet
	name=$(awk 'NR == '$i' { print $1 }' "$Samples")
	#aligning the files
	bowtie2 -x "$genome" -1 "$v1" -2 "$v2" -p "$myP" --no-unal --dovetail --no-mixed --no-discordant  -S "SAM_files/""$name"".SAM"
	done
elif [ "$myN" == "Single" ]; then
	#doing the for loop to align all samples
	for i in $(seq "$rowN")
	#extracting the R1 file name from the samples sheet
	do v1=$(awk 'NR == '$i' { print $2 }' "$Samples")
	#extracting the name to be used for output file from samples sheet
	name=$(awk 'NR == '$i' { print $1 }' "$Samples")
	#aligning the files
	bowtie2 -x "$genome" -U "$v1"  -p "$myP" --no-unal -S "SAM_files/""$name"".SAM"
	done
else 
	echo "Type of experiment not specified correctly. See guidelines for the right format"
fi

																	#converting SAM files to bam
##making a directory for bam files
mkdir bam
#for loop
for i in $(seq "$rowN")
#extracting the name to be used for output file from samples sheet
do name=$(awk 'NR == '$i' { print $1 }' "$Samples")
#converting sam files to bam
samtools view -@ "$myP" -S -b "SAM_files/"$name".SAM" > ""$fastqdir"bam/"$name".bam"
done

                                      ##sorting the bam files

#making a directory for sorted bam files
mkdir ""$fastqdir"sorted-bam"
#doing the for loop to sort each file
for i in $(seq "$rowN")
#Extracting name of the file
do v1=$(awk 'NR == '$i' { print $1 }' "$Samples")
#sorting the bam file
samtools sort "bam/"$v1".bam" -@ "$myP" -o ""$fastqdir"sorted-bam/"$v1".bam"
done

##indexing the sorted bam files
for i in $(seq "$rowN")
do v1=$(awk 'NR== '$i' { print $1 }' "$Samples")
samtools index -@ "$myP" -b ""$fastqdir"sorted-bam/"$v1".bam"
done

##making CPM normalized bw
#making a directory for BigWig files
mkdir ""$fastqdir"bw"
##making CPM normalized bigwigs and using right command based on experiment type specified
if [ "$myN" == "Single" ]; then
then
  for i in $(seq "$rowN") #doing the for loop to run bamCoverage on the different files
  #extracting the name for files from sample sheet
  do v1=$(awk 'NR == '$i' { print $1 }' "$Samples")
  #making the bam files
  bamCoverage -b ""$fastqdir"sorted-bam/"$v1".bam" -e -bs 10 -p max --normalizeUsing CPM --ignoreDuplicates -o ""$fastqdir"bw/"$v1".bw"
  done
elif [ "$myN" == "Paired" ]; then
  for i in $(seq "$rowN")#doing the for loop to run bamCoverage on the different files
  do v1=$(awk 'NR == '$i' { print $1 }' "$Samples")
  bamCoverage -b ""$fastqdir"sorted-bam/"$v1".bam" -e 150 -bs 10 -p max --normalizeUsing CPM --ignoreDuplicates -o ""$fastqdir"bw/"$v1".bw"
  done
else 
	echo "Type of experiment not specified correctly. See guidelines for the right format"
fi



