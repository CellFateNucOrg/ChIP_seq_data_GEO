# Automated ChIP-seq data analysis scripts, requiring the SRR numbers of the analysis. 

Create a folder with the right GEO number
Clone the current git inside this folder (git clone https://github.com/CellFateNucOrg/ChIP_seq_data_GEO.git)

Look for the SRR numbers of the ChIP-seq datasets which you want to use (online on the GEO server).
Save this as a ";" separated file (see below)

To use this script, you will need to modify 3 files.

1. **file_locations.sh** In this file, you need to define a. where is the fasta of your genome of interest (only the path), as well as the bwa index (obtained using bwa index genome_fasta.fa) b. where is trim_galore (only the path)

2. **SRR_names.csv** this is a semicolon separated file with the SRR numbers and the name of the target, plus any comment 

  > _**column 1: input**_ 
  >
  > _**column 2: IP**_
  >
  > _**column 3: name**_ IMPORTANT: this name needs to be unique to this dataset (ie if you have repeats, use "\_1" and "\_2"  to differentiate them 
  >
  > _**column 4: groupDataset** (optional)_ This number designates grouping indicating which replicates belong to a single experiment. This is useful for averaging later.
  > 
  > _**column 5: groupTarget** (optional)_ This number designates grouping that is above the level of replicates from a single experiment. i.e. if there are two entirely separate IP experiments for H3K9me3, then you can give them the same number here, making it easier to average them.


3. Update the **looper.sh** file, modifying line 4:

```
  #SBATCH --array=2-3%1 
                    ^ ^ 
                    A B 
```
  
  Modify A with the number of datasets which you have in the SRR_names.csv, plus 1. Modify B with the number of cores which you want to use. More cores, more jobs get processed in parallel. But be reasonable and a good citizen, 10 is a good number (but don't use more than your maximum number of jobs, as that is meaningless).
  
  Modify the email address to yours in:
 
```
  #SBATCH --mail-user=peter.meister@izb.unibe.ch
```

All set? Run with sbatch **looper.sh**
The scripts outputs an enrichment (normalized RPM IP - normalized RPM input; in the enrichment folder, bw format), plus a normalized bw for IP and input (for checking purposes) 

# GEO datasets of interest
## GSE45678 data from Kranz _et al._(2013)
Embryo data from the following paper: Kranz AL et al., "Genome-wide analysis of condensin binding in Caenorhabditis elegans.", Genome Biol, 2013;14(10):R112
can be processed using the **SRR_namesGSE45678kranz.csv** file. **TODO**: get L3 data!

## GSE67650 data from Kramer _et al._(2015)
L3 data from the following paper:Kramer M, Kranz AL, Su A, Winterkorn LH et al. Developmental Dynamics of X-Chromosome Dosage Compensation by the DCC and H4K20me1 in C. elegans. PLoS Genet 2015 Dec;11(12):e1005698 can be processed using the **SRR_namesGSE67650kramer.csv** file. **TODO**: get embryo data!

## PRJNA63455 - modEncode project
Most epigenetic ChIP (but not all?) in the modEncode datasets are part of GEO Bioproject PRJNA63455. The full table of data was downloaded from SRR selector, and processed in R to find L3 datasets. The **SRR_namesPRJNA63455.csv** file contains SRR numbers for these datasets.

# modENCODE data
Not all modencode data has an associated GEO ID. But the modencode ftp site is terrible at providing metadata, and you have to guess from the often messy names. Also, the metadata on modENCODE is not as precise as that found via GEO, for instance, many histone marks just say "L3" and one might assume these are hermaphrodites only, but if you look at the annotation on GEO you see that these are mixed male and female hermaphrodites). So when possible we want to get the GEO accessions and download metadata, and for those that fail, we want to get data via ftp directly from modENCODE and get any metadata possible. 
**TODO**: compare SRRs obtained via modencode and via PRJNA63455.

## Getting data with GEO ID
1. From the main website of modENCONDE, navigate to the project you are interested in http://www.modencode.org, which will take you to the intermine site. I manually copied the html table to Excel for the following experiments: 

> **Chromatin ChIP-seq of non-Histone Chromosomal Proteins in C. elegans** *http://intermine.modencode.org/query/experiment.do?experiment=Chromatin+ChIP-seq+of+non-Histone+Chromosomal+Proteins+in+C.+elegans* to create the **modEncode_chromatinChipSeq_nonHistone.xlsx** table.  
>
> **Chromatin ChIP-seq of Modified Histones in C. elegans** *http://intermine.modencode.org/query/experiment.do?experiment=Chromatin+ChIP-seq+of+Modified+Histones+in+C.+elegans* to create the **modEncode_ChromatinChipSeq_modHistone.xlsx** table.
>
> **Chromatin ChIP-seq** *http://intermine.modencode.org/query/experiment.do?experiment=Chromatin+ChIP-seq* to create the **ChromatinChipSeq_mix.xlsx** table.

2. Pasted the data from the excel table into Sheet2 of the same excel file as plain text. Used the script **cleanExcelTable.R** to create a cleaned up Excel table for the data.

3. To get SRR names from GEO ids, used the reutils package, see the script **getSRRfromGSM.R**. The input is the modEncode_chromatinChipSeq_modHistone.csv file and the output is modEncode_chromatinChipSeq_modHistone_fullTable.tsv file with both GEO numbers and SRR numbers. This table is left with multiple similar columns in order to be sure that there is no mixup in the samples (i.e. the metadata downloaded with the SRR numbers (designaated withh _1 in the column name) is the same as that found with the GEO numbers.

4. To construct appropriate input table for the pipeline, use the **makeSRRtable.R** script. Output are the **SRR_modEncode_chromatinChipSeq_modHistone.csv**, **SRR_modEncode_chromatinChipSeq_nonHistone.csv**, and **SRR_modEncode_chromatinChipSeq_mix.csv** files, which are added to the top level of the repository.

## Getting data from ftp server
1. To get data from ftp site click on the "Dataset" button on the main modencode page http://www.modencode.org, and then select criteria on the left hand side: 

  >Organism - C . elegans, 
  >Project Category - Histone modification and replacement,
  >Technique - Chip-Seq:
  >
  >79 datasets. Made sure all the rows of the table were visible and copy pasted into text file **metadata_histoneMod.tsv**.
  >Selected all the datasets by clicking on the Dataset button at the top of that column in the table, and got the ftp addresses by clicking on the now visible "List Download URLs" button. Copied the download urls in to the test file **downloadursl_histoneMod.txt**


  >Organism - C . elegans, 
  >Project Category - Other chromatin binding sites,
  >Technique - Chip-Seq:
  >
  >56 datasets. Made sure all the rows of the table were visible and copy pasted into text file **metadata_otherChrBind.tsv**.
  >Selected all the datasets by clicking on the Dataset button at the top of that column in the table, and got the ftp addresses by clicking on the now visible "List Download URLs" button. Copied the download urls in to the test file **downloadursl_otherChrBind.txt**

2. All data sets that do not have GEO numbers are processed to check if they belong to one of the previous datasets using the second half of **makeSRRtable.R** script.
