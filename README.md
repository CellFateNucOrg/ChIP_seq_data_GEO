#Automated ChIP-seq data analysis scripts, requiring the SRR numbers of the analysis. 

Create a folder with the right GEO number
Clone the current git inside this folder (git clone https://github.com/CellFateNucOrg/ChIP_seq_data_GEO.git)

Look for the SRR numbers of the ChIP-seq datasets which you want to use (online on the GEO server).
Save this as a ";" separated file (see below)

To use this script, you will need to modify 3 files.

The file_locations.sh In this file, you need to define a. where is the fasta of your genome of interest (only the path), as well as the bwa index (obtained using bwa index genome_fasta.fa) b. where is trim_galore (only the path)

the SRR_names.csv this is a semicolon separated file with the SRR numbers and the name of the target, plus any comment column 1: input column 2: IP column 3: name column IMPORTANT: this name needs to be unique to this dataset (ie if you have repeats, use "_1" and "_2"  to differentiate them 4: comments (optional) On the first 2 columns, if there are several SRR numbers, separate them by space. This you can use as a "group" marker to make averages of duplicates later (ie ChIP repeats get the same group number)

3.Finally, you need to update the looper.sh file, modifying line 4 
#SBATCH --array=2-3%1 
                  ^ ^ 
                  1 2 
Modify 1 with the number of datasets which you have in the SRR_names.csv, plus 1 Modify 2 with the number of cores which you want to use. More cores, faster results. But be reasonable and a good citizen, 10 is a good number.
Modify the email address to yours in 
#SBATCH --mail-user=peter.meister@izb.unibe.ch

All set? Run with sbatch looper.sh
The scripts outputs an enrichment (normalized RPM IP - normalized RPM input; in the enrichment folder, bw format), plus a normalized bw for IP and input (for checking purposes) 


# modENCONDE data
Not all modencode data has an associated GEO ID. But the modencode ftp site is terrible at providing metadata, and you have to guess from the often messy names. Also, the metadata on modENCODE is not as precise as that found via GEO, for instance, many histone marks just say "L3" and one might assume these are hermaphrodites only, but if you look at the annotation on GEO you see that these are mixed male and female hermaphrodites). So when possible we want to get the GEO accessions and download metadata, and for those that fail, we want to get data via ftp directly from modENCODE and get any metadata possible. 

## Getting data with GEO ID
1) From the main website of modENCONDE, navigate to the project you are interested in http://www.modencode.org, which will take you to the intermine site. I manually copied the html table to Excel for the following repositories: 

**Chromatin ChIP-seq of non-Histone Chromosomal Proteins in C. elegans** *http://intermine.modencode.org/query/experiment.do?experiment=Chromatin+ChIP-seq+of+non-Histone+Chromosomal+Proteins+in+C.+elegans* to create the **modEncode_chromatinChipSeq_nonHistone.xlsx** table;  

**Chromatin ChIP-seq of Modified Histones in C. elegans** *http://intermine.modencode.org/query/experiment.do?experiment=Chromatin+ChIP-seq+of+Modified+Histones+in+C.+elegans* to create the **modEncode_ChromatinChipSeq_modHistone.xlsx** table; 

**Chromatin ChIP-seq** *http://intermine.modencode.org/query/experiment.do?experiment=Chromatin+ChIP-seq* to create the **ChromatinChipSeq_mix.xlsx**.

TODO: processing table

To get SRR names from GEO data the script **using_retutils.R** was used 

## Getting data from ftp server
1) This was pasted onto the next sheet as plain text. To get data from ftp site click on the "Dataset" button on the main modencode page. http://www.modencode.org and then select criteria: 

  Organism - C . elegans, 
  Project Category - Histone modification and replacement
  Technique - Chip-Seq
  79 datasets, made sure all the rows of the table were visible and copy pasted into text file **metadata_histoneMod.tsv**
  selected all the datasets by clicking on the Dataset button at the top of that column in the table, and got the ftp addresses by clicking on the now visible "List Download URLs" button. Copied the download urls in to the test file **downloadursl_histoneMod.txt**


  Organism - C . elegans, 
  Project Category - Other chromatin binding sites
  Technique - Chip-Seq
  56 datasets, made sure all the rows of the table were visible and copy pasted into text file **metadata_otherChrBind.tsv**
  selected all the datasets by clicking on the Dataset button at the top of that column in the table, and got the ftp addresses by clicking on the now visible "List Download URLs" button. Copied the download urls in to the test file **downloadursl_otherChrBind.txt**

