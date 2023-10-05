#!/bin/bash
#
# this file is myjob.sh
#
#SBATCH --job-name Task1-RetrieveGenomicRegion
#SBATCH --mail-type BEGIN,END
#
# load cutadapt/4.0
module load cutadapt/4.0

##########################
## == Set Parameters == ##

genomicRegion="hg38_chr5_1250000_1450000"

# External Primers
forwardPOS1="GCTGAGAGTCACTCTGAGAACTGTC"
reversePOS1="GCATCAGGTTCATCATCTAGCCAAG"
forwardNEG1="CGACTCTCAGTGAGACTCTTGACAG"
reverseNEG1="CGTAGTCCAAGTAGTAGATCGGTTC"

# Internal Primers
forwardPOS2="CCTGTATTCATTTCCCTGTACTGCT"
reversePOS2="CCCAGTGGGCACATATTCAAACCAT"
forwardNEG2="GGACATAAGTAAAGGGACATGACGA"
reverseNEG2="GGGTCACCCGTGTATAAGTTTGGTA"

# Define the error rate
error_rate=0.1  # 10% error rate

## Set path to where FASTA files are being stored
PATH_TO_FILES=/data/Prokunina_Group/GenomeAssemblies/KolmogorovLab/assemblies
OUTDIR=/data/Prokunina_Group/GenomeAssemblies/KolmogorovLab/retrievedRegions

##########################


if [ ! -d $OUTDIR/$genomicRegion ]; then
  mkdir -p $OUTDIR/$genomicRegion;
fi

## Loop for the set of primers POSITIVE strand
for i in $(ls "$PATH_TO_FILES"/*.fasta); do \
        
	filename=$(basename "$i")
	temporal_file="$OUTDIR/$genomicRegion/tmpPOS_${filename%???}"
	output_file="$OUTDIR/$genomicRegion/setPOS_${filename%???}"

	## Perform the first in-silico PCR
        cutadapt --discard-untrimmed \
        -g "$forwardPOS1;max_error_rate=$error_rate...$reversePOS1;max_error_rate=$error_rate" \
	-o "$temporal_file" "$i" 2> /dev/null

	## Perform the second in-silico PCR
  	cutadapt --discard-untrimmed \
	-g "$forwardPOS2;max_error_rate=$error_rate...$reversePOS2;max_error_rate=$error_rate" \
	-o "$output_file" "$temporal_file" 2> /dev/null

	## Delete the temporal file
	rm "$temporal_file"

	## Check if the output file is empty and remove it if it is
	if [ ! -s "$output_file" ]; then
      		rm "$output_file"
	fi
        
done


## Loop for the set of primers NEGATIVE strand
for i in $(ls "$PATH_TO_FILES"/*.fasta); do \

        filename=$(basename "$i")
        temporal_file="$OUTDIR/$genomicRegion/tmpNEG_${filename%???}"
        output_file="$OUTDIR/$genomicRegion/setNEG_${filename%???}"

        ## Perform the first in-silico PCR
        cutadapt --discard-untrimmed \
        -g "$reverseNEG1;max_error_rate=$error_rate...$forwardNEG1;max_error_rate=$error_rate" \
        -o "$output_file" "$i" 2> /dev/null

        ## Perform the second in-silico PCR
        cutadapt --discard-untrimmed \
        -g "$reverseNEG2;max_error_rate=$error_rate...$forwardNEG2;max_error_rate=$error_rate" \
        -o "$OUTDIR/$genomicRegion/setNEG_${filename%???}" "$output_file" 2> /dev/null

        ## Delete the temporal file
        rm "$temporal_file"

        ## Check if the output file is empty and remove it if it is
        if [ ! -s "$output_file" ]; then
                rm "$output_file"
        fi

done

