# Automated ChIP-seq data analysis scripts, requiring the SRR numbers of the analysis. 

Create a folder with the right GEO number
Clone the current git inside this folder (git clone https://github.com/CellFateNucOrg/ChIP_seq_data_GEO.git)

Look for the SRR numbers of the ChIP-seq datasets which you want to use (online on the GEO server).
Save this as a ";" separated file (see below)

To use this script, you will need to modify 3 files.

1. **file_locations.sh** In this file, you need to define a. where is the fasta of your genome of interest (only the path), as well as the bwa index (obtained using bwa index genome_fasta.fa) b. where is trim_galore (only the path)

2. **SRR_names.csv** this is a semicolon separated file with the SRR numbers and the name of the target, plus any comment 

  1. _**column 1: input**_ 

  2. _**column 2: IP**_
  
  3. _**column 3: name**_ IMPORTANT: this name needs to be unique to this dataset (ie if you have repeats, use "\_1" and "\_2"  to differentiate them 4: comments (optional) On the first 2 columns, if there are several SRR numbers, separate them by space. This you can use as a "group" marker to make averages of duplicates  later (ie ChIP repeats get the same group number)

  4. _**column 4: group**_ This is to designate grouping that is above the level of replicates in a single experiment.. i.e. if there are two entirely separate IP experiments for H3K9me3, then you can give them the same number here, making it easier to 

3. Update the **looper.sh** file, modifying line 4 
  #SBATCH --array=2-3%1 
                    ^ ^ 
                    1 2 
  Modify 1 with the number of datasets which you have in the SRR_names.csv, plus 1 Modify 2 with the number of cores which you want to use. More cores, faster results. But be reasonable and a good citizen, 10 is a good number.
  Modify the email address to yours in 
  #SBATCH --mail-user=peter.meister@izb.unibe.ch

All set? Run with sbatch **looper.sh**
The scripts outputs an enrichment (normalized RPM IP - normalized RPM input; in the enrichment folder, bw format), plus a normalized bw for IP and input (for checking purposes) 


# modENCONDE data
Not all modencode data has an associated GEO ID. But the modencode ftp site is terrible at providing metadata, and you have to guess from the often messy names. Also, the metadata on modENCODE is not as precise as that found via GEO, for instance, many histone marks just say "L3" and one might assume these are hermaphrodites only, but if you look at the annotation on GEO you see that these are mixed male and female hermaphrodites). So when possible we want to get the GEO accessions and download metadata, and for those that fail, we want to get data via ftp directly from modENCODE and get any metadata possible. 

## Getting data with GEO ID
1. From the main website of modENCONDE, navigate to the project you are interested in http://www.modencode.org, which will take you to the intermine site. I manually copied the html table to Excel for the following experiments: 

  **Chromatin ChIP-seq of non-Histone Chromosomal Proteins in C. elegans** *http://intermine.modencode.org/query/experiment.do?experiment=Chromatin+ChIP-seq+of+non-Histone+Chromosomal+Proteins+in+C.+elegans* to create the **modEncode_chromatinChipSeq_nonHistone.xlsx** table.  

  **Chromatin ChIP-seq of Modified Histones in C. elegans** *http://intermine.modencode.org/query/experiment.do?experiment=Chromatin+ChIP-seq+of+Modified+Histones+in+C.+elegans* to create the **modEncode_ChromatinChipSeq_modHistone.xlsx** table.

  **Chromatin ChIP-seq** *http://intermine.modencode.org/query/experiment.do?experiment=Chromatin+ChIP-seq* to create the **ChromatinChipSeq_mix.xlsx** table.

2. TODO: processing table
This was pasted onto the next sheet as plain text. 

3. To get SRR names from GEO ids, used the reutils package, see the script **getSRRfromGSM.R**. 

## Getting data from ftp server
1. To get data from ftp site click on the "Dataset" button on the main modencode page http://www.modencode.org, and then select criteria on the left hand side: 

  Organism - C . elegans, 
  Project Category - Histone modification and replacement,
  Technique - Chip-Seq:
  
  79 datasets. Made sure all the rows of the table were visible and copy pasted into text file **metadata_histoneMod.tsv**.
  Selected all the datasets by clicking on the Dataset button at the top of that column in the table, and got the ftp addresses by clicking on the now visible "List Download URLs" button. Copied the download urls in to the test file **downloadursl_histoneMod.txt**


  Organism - C . elegans, 
  Project Category - Other chromatin binding sites,
  Technique - Chip-Seq:
  
  56 datasets. Made sure all the rows of the table were visible and copy pasted into text file **metadata_otherChrBind.tsv**.
  Selected all the datasets by clicking on the Dataset button at the top of that column in the table, and got the ftp addresses by clicking on the now visible "List Download URLs" button. Copied the download urls in to the test file **downloadursl_otherChrBind.txt**

2. processing
