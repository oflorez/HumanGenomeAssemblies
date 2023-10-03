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
Applications needed: 
`cutadapt` (biowulf cutadapt/4.0)

#### Example application

```
cutadapt --discard-untrimmed -g "GCTGAGAGTCACTCTGAGAACTGTC;max_error_rate=0...GCATCAGGTTCATCATCTAGCCAAG;max_error_rate=0" $INPUT.fa 2> /dev/null > OUTPUTp.fa
cutadapt --discard-untrimmed -g "CGTAGTCCAAGTAGTAGATCGGTTC;max_error_rate=0...CGACTCTCAGTGAGACTCTTGACAG;max_error_rate=0" $INPUT.fa 2> /dev/null > OUTPUTn.fa
```


### Step 3. Verify the size of the retrieved region(s) as part of the analysis
Applications needed: 
`bioawk` (biowulf bioawk/1.0)

#### Example application

```
bioawk -c fastx '{ print $name, length($seq) }' < OUTPUTp.fa
bioawk -c fastx '{ print $name, length($seq) }' < OUTPUTn.fa
```



GCTGAGAGTCACTCTGAGAACT
GCTGAGAGTCACTCTGAGAACTGTCCCTGTATTCATTTCCCTGTACTGCTATTCCATTTG
AAGAAAGCTTCCCAGTGGGCACATATTCAAACCATGCATCAGGTTCATCATCTAGCCAAG
                                      TCAGGTTCATCATCTAGCCAAG
