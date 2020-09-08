#Automated ChIP-seq data analysis scripts, requiring the SRR numbers of the analysis. 

Create a folder with the right GEO number
Clone the current git inside this folder (git clone https://github.com/CellFateNucOrg/ChIP_seq_data_GEO.git)

Look for the SRR numbers of the ChIP-seq datasets which you want to use (online on the GEO server).
Save this as a ";" separated file (see below)

To use this script, you will need to modify 3 files.

The file_locations.sh In this file, you need to define a. where is the fasta of your genome of interest (only the path), as well as the bwa index (obtained using bwa index genome_fasta.fa) b. where is trim_galore (only the path)

the SRR_names.csv this is a semicolon separated file with the SRR numbers and the name of the target, plus any comment column 1: input column 2: IP column 3: name column IMPORTANT: this name needs to be unique to this dataset (ie if you have to repeats, use "_1" and "_2"  to differentiate them 4: comments (optional) On the first 2 columns, if there are several SRR numbers, separate them by space. This you can use as a "group" marker to make averages of duplicates later (ie ChIP repeats get the same group number)

3.Finally, you need to update the looper.sh file, modifying line 4 
#SBATCH --array=2-3%1 
                  ^ ^ 
                  1 2 
Modify 1 with the number of datasets which you have in the SRR_names.csv, plus 1 Modify 2 with the number of cores which you want to use. More cores, faster results. But be reasonable and a good citizen, 10 is a good number.
Modify the email address to yours in 
#SBATCH --mail-user=peter.meister@izb.unibe.ch

All set? Run with sbatch looper.sh
The scripts outputs an enrichment (normalized RPM IP - normalized RPM input; in the enrichment folder, bw format), plus a normalized bw for IP and input (for checking purposes) 
