# Human Genome Assemblies

Genome assemblies are comprehensive representations of the genetic material found within the DNA of a species, specifically the human species in the case of the human genome assembly. These assemblies serve as a critical resource for understanding the genetic blueprint that underlies human biology and health. They are the result of extensive scientific efforts aimed at deciphering the entire sequence of DNA base pairs that make up the human genome.

The Human Pangenome Reference Consortium produced sequencing data for assembly of 30 samples. Multiple data types including PacBio HiFi, Nanopore, Hi-C, and Bionano are avaiable. Strand-seq is available for 7 samples. Data created and hosted by the HPRC is open and available for download in S3 & GCP buckets. Select data is also uploaded to international nucleotide sequencing databases (SRA/ENA/DDBJ) under the HPRC Genome Sequencing BioProject (PRJNA701308). For information about data reuse and publicating with HPRC data please see the HPRC's Data Use Protocol (https://github.com/human-pangenomics/HPP_Year1_Data_Freeze_v1.0).

This protocol can be utilized to filter specific regions of interest within assemblies, making them suitable for various other applications.

### Step 1. Define the target region of interest
This step is customized, employing an In-Silico PCR strategy that involves searching a sequence database using a pair of PCR primers.

