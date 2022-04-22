import argparse
import os
from rgt.Util import GenomeData
from rgt.helper import get_chrom_sizes_as_genomicregionset
from rgt.CoverageSet import CoverageSet
from rgt.THOR.get_extension_size import get_extension_size

#blacklisted='/data/projects/p025/Peter/ChIP_seq/genome/ce11-blacklist.v2.bed'
#bamfile = '/data/projects/p025/jenny/modEncode_SMC/tmpRun/ab9051_H4K20me1_N2_Mxemb_ChIP_Rep1/filt/IP_trimmed_sorted_dedup_filt_sorted.bam'
#bamfile_input='/data/projects/p025/jenny/modEncode_SMC/tmpRun/ab9051_H4K20me1_N2_Mxemb_ChIP_Rep1/filt/input_trimmed_sorted_dedup_filt_sorted.bam'

def normaliseIP(bamfile, bamfile_input, blacklisted, outputDir, filenamePrefix):
  rawDir=os.path.join(outputDir,"rawBW_Thor")
  if not os.path.exists(rawDir):
    os.mkdir(rawDir)
  g = GenomeData('ce11') 
  regionset = get_chrom_sizes_as_genomicregionset(g.get_chromosome_sizes())
  
  ext, _ = get_extension_size(bamfile, start=0, end=300, stepsize=5)
  ext_input, _ = get_extension_size(bamfile_input, start=0, end=300, stepsize=5)
  print(ext)
  print(ext_input)

  cov = CoverageSet('IP coverage', regionset)
  cov.coverage_from_bam(bam_file=bamfile, binsize=100, stepsize=10, mask_file=blacklisted, extension_size=ext)
  cov.write_bigwig(rawDir+'/'+filenamePrefix+'_raw_IP_thor.bw', g.get_chromosome_sizes())
  
  cov_input = CoverageSet('input-dna coverage', regionset)
  cov_input.coverage_from_bam(bam_file=bamfile_input, binsize=100, stepsize=10, mask_file=blacklisted, extension_size=ext_input)
  cov_input.write_bigwig(rawDir+'/'+filenamePrefix+'_raw_input_thor.bw',g.get_chromosome_sizes())
  
  normDir=os.path.join(outputDir,"norm_Thor")
  if not os.path.exists(normDir):
    os.mkdir(normDir)
  cov.norm_gc_content(cov.coverage, g.get_genome(), g.get_chromosome_sizes())
  cov.write_bigwig(normDir+'/'+filenamePrefix+'_norm_signal_thor.bw', g.get_chromosome_sizes())
  cov_input.norm_gc_content(cov_input.coverage, g.get_genome(), g.get_chromosome_sizes())
  cov_input.write_bigwig(normDir+'/'+filenamePrefix+'_norm_input_thor.bw', g.get_chromosome_sizes())

  minusInputDir=os.path.join(outputDir,"minusInput_Thor")
  if not os.path.exists(minusInputDir):
    os.mkdir(minusInputDir)
  cov.subtract(cov_input)
  cov.write_bigwig(minusInputDir+'/'+filenamePrefix+'_norm_minusInput_thor.bw', g.get_chromosome_sizes())

if __name__ == '__main__':
  all_args=argparse.ArgumentParser()
  
  all_args.add_argument("-p", "--bamfileIP", type=str ,required=True, help="path to IP bamfile")
  all_args.add_argument("-n", "--bamfileInput", type=str ,required=True, help="path to input bamfile")
  all_args.add_argument("-o", "--outputDir", type=str, required=False, default=".", help="path to output directory")
  all_args.add_argument("-f", "--filenamePrefix", type=str, required=False, default="", help="sample name to pre-append to output file name")
  all_args.add_argument("-l", "--blacklisted", type=str, required=False, default=None, help="path to bedfile of blacklisted regions to ignore")
  
  args=all_args.parse_args()
  
  bamfile=args.bamfileIP
  bamfile_input=args.bamfileInput
  blacklisted=args.blacklisted
  outputDir=args.outputDir
  filenamePrefix=args.filenamePrefix

  normaliseIP(bamfile, bamfile_input, blacklisted, outputDir, filenamePrefix)

