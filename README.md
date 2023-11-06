# Human Genome Assemblies

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
`cutadapt` (biowulf cutadapt/4.0)

#### Example application

```
cutadapt --discard-untrimmed -g "GCTGAGAGTCACTCTGAGAACTGTC;max_error_rate=0...GCATCAGGTTCATCATCTAGCCAAG;max_error_rate=0" $INPUT.fa 2> /dev/null > OUTPUTp.fa
cutadapt --discard-untrimmed -g "CGTAGTCCAAGTAGTAGATCGGTTC;max_error_rate=0...CGACTCTCAGTGAGACTCTTGACAG;max_error_rate=0" $INPUT.fa 2> /dev/null > OUTPUTn.fa
```


### Step 3. Verify the size of the retrieved region(s) as part of the analysis
Applications: 
`bioawk` (biowulf bioawk/1.0)

#### Example application

```
bioawk -c fastx '{ print $name, length($seq) }' < OUTPUTp.fa
bioawk -c fastx '{ print $name, length($seq) }' < OUTPUTn.fa
```

### Step 4. Align the FASTA sequences to the reference human genome build hg38
Applications: 
`minimap2` (biowulf minimap2/2.26)

in Biowulf environmet, module load the minimamp2 and Samtools to run the script

- creat a sinteractive envirnment
`
sinteractive --cpus-per-task=10 --mem=50g
`
- Once created, load module
`ml minimap2 samtools`

- run the minimap2 commnad

```
minimap2 -Y -t 6 -a /fdb/igenomes/Homo_sapiens/UCSC/hg38/Sequence/WholeGenomeFasta/genome.fa input.fa | samtools sort -@ 6 -o output.bam
```

```
# -a: Generate CIGAR and output alignments in the SAM format
# -Y: In SAM output, use soft clipping for supplementary alignments.
# -t/-@: how many thread
```

### Step 5. Detect repeat use starglr

Application: `straglr` (biowulf straglr v1.4)


in Biowulf environmet, module load the straglr to run the tool

```
ml straglr
```

to see if it can execute, and check version type

```
straglr.py --version 
```
for more information about this tool, visit their github page:
https://github.com/bcgsc/straglr

**Making bed file for region of interest**

To utilize the Straglr tool for repeat detection, you need to create a BED file that defines the regions of interest and the repeat sequences you want to analyze.

For example, if we want to find the number of repeats inside CLPTM1L exon 7 and exon 8.

1. Retrive sequence from UCSC genome browser or other similiar tools. Access the human genome version 38 in the UCSC Genome Browser (https://genome.ucsc.edu/cgi-bin/hgGateway).

2. Search for the gene of interest, in this case, CLPTM1L.

3. Zoom in on the location that cover the repeat region between exon 7 and exon 8. Once you've located it, the information box at the top will display the chromosome location. `chr5:1332762-1333968`

4. To obtain the sequence, select `View` and then choose `DNA` Next, click on `get DNA` with `Mask repeats: to lower case` selected. it will show the sequenec of this target region.

5. Once click `get DNA`, the window will show the sequence in FASTA format of this region, copy the information and go to Tandem Repeat Finder website (https://tandem.bu.edu/trf/submit_options)

6. Select `Basic` and paste the sequence with header in the box and click `Submit sequence`

7. Once it's done, click `Tandem Repeats Report` and it will show the result window. Select the highest score row and copy the `Consensus pattern`. For this example: `GGGACTACTGTATACACACCGGATGAGGATAAGGG`

8. Now open new text file, input the info in tab seperate format `chr5  1332762  1333968  GGGACTACTGTATACACACCGGATGAGGATAAGGG` and save the file such as `target_region.txt`


**Run straglr with region file**

After creating region file for straglr tool, we can now run the tool.

1. Activate mamba environmet `mamba activate straglr` and run the command line below:

```
straglr.py input.bam /fdb/igenomes/Homo_sapiens/UCSC/hg38/Sequence/WholeGenomeFasta/genome.fa output --min_support 1 --min_cluster_size 1 --loci target_region.txt
```

Once finished, it will generate `output.bed` and `output.tsv` files, we will use `output.tsv` to combined genotype result using the script called `Task3_scoringTRnSNP_xxx.sh`


