# Retrieving Target Regions from Human Genome Assemblies

Genome assemblies are comprehensive representations of the genetic material found within the DNA of a species, specifically the human species in the case of the human genome assembly. These assemblies serve as a critical resource for understanding the genetic blueprint that underlies human biology and health. They are the result of extensive scientific efforts aimed at deciphering the entire sequence of DNA base pairs that make up the human genome.

The [Human Pangenome Reference Consortium](https://humanpangenome.org/) produced sequencing data for assembly of 30 samples. Multiple data types including PacBio HiFi, Nanopore, Hi-C, and Bionano are avaiable. Strand-seq is available for 7 samples. Data created and hosted by the HPRC is open and available for [download](https://github.com/human-pangenomics/HPP_Year1_Data_Freeze_v1.0) in buckets. Select data is also uploaded to international nucleotide sequencing databases (SRA/ENA/DDBJ) under the HPRC Genome Sequencing BioProject (PRJNA701308). For information about data reuse and publicating with HPRC data please see the HPRC's Data Use Protocol.

This protocol can be utilized to filter specific regions of interest within assemblies, making them suitable for various other applications.


### Step 1. Define the target region of interest
This step is customized, employing an *In-Silico* PCR strategy that involves searching a sequence database using a pair of PCR primers. See an example [video](https://www.youtube.com/watch?v=U8_QYwmdGYU) on YouTube.

#### Example application
UCSC Genome Browser (hg38) chr5:1,250,000-1,450,000
This region that includes the genes *TERT*, *CLPTM1L*, and *SLC6A3.*

Given the uncertainty regarding the orientation of the genome assembly, it is advisable to retrieve sequences in both positive and negative orientations. To accomplish this, we should prepare two sets of primers. The orientation adjustment can be facilitated using the 'complement' function available through the [Reverse Complement](https://www.bioinformatics.org/sms/index.html) web application.  

To POSITIVE orientation; Forward Primer: `GCTGAGAGTCACTCTGAGAACTGTC`  Reverse Primer: `GCATCAGGTTCATCATCTAGCCAAG`  
To NEGATIVE orientation; Forward Primer: `CGACTCTCAGTGAGACTCTTGACAG`  Reverse Primer: `CGTAGTCCAAGTAGTAGATCGGTTC`


### Step 2. Retrieve the region of interest using the specified set of primers
Applications: 
`cutadapt` (cutadapt/4.0)

#### Example application

```
cutadapt --discard-untrimmed -g "GCTGAGAGTCACTCTGAGAACTGTC;max_error_rate=0...GCATCAGGTTCATCATCTAGCCAAG;max_error_rate=0" $INPUT.fa 2> /dev/null > OUTPUTp.fa
cutadapt --discard-untrimmed -g "CGTAGTCCAAGTAGTAGATCGGTTC;max_error_rate=0...CGACTCTCAGTGAGACTCTTGACAG;max_error_rate=0" $INPUT.fa 2> /dev/null > OUTPUTn.fa
```

The implementation of Steps 1 and 2 is contained within the script named "script_toRetrieveGenomeRegion.sh". Users are only required to modify the parameters specified between lines 16 and 35.

### Step 3. Verify the size of the retrieved region(s) as part of the analysis
Applications: 
`bioawk` (bioawk/1.0)

#### Example application

```
bioawk -c fastx '{ print $name, length($seq) }' < OUTPUTp.fa
bioawk -c fastx '{ print $name, length($seq) }' < OUTPUTn.fa
```

### Step 4. Align the FASTA sequences to the reference human genome build hg38
Applications: 
`minimap2` (minimap2/2.26)
`samtools` (samtools/1.19)

#### Example application

```
minimap2 -t 6 -a /fdb/igenomes/Homo_sapiens/UCSC/hg38/Sequence/WholeGenomeFasta/genome.fa input.fa | samtools sort -@ 6 -o output.bam
```

```
# -a: Generate CIGAR and output alignments in the SAM format
# -Y: In SAM output, use soft clipping for supplementary alignments.
# -t/-@: how many thread
```

### Step 5. Detect repeat use starglr
Application: 
`straglr` (straglr v1.4)

#### Example application

*Generate a target_region.txt file that includes the repeat consensus sequence to facilitate scoring tandem repeats within the genomic region of interest*
```
chr5  1332762  1333968  GGGACTACTGTATACACACCGGATGAGGATAAGGG
```

*Run straglr with target_region.txt file*
```
straglr.py input.bam /fdb/igenomes/Homo_sapiens/UCSC/hg38/Sequence/WholeGenomeFasta/genome.fa output --min_support 1 --min_cluster_size 1 --loci target_region.txt
```

Upon completion, the process will generate two files: output.bed and output.tsv. The latter, output.tsv, will be utilized for consolidating the tandem repeats detected by read, corresponding to each assembly sample. If users need more information about the tool, they can visit its GitHub page at: https://github.com/bcgsc/straglr

