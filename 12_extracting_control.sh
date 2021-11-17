#!/bin/bash 
#SBATCH --chdir /scratch/saadat/pri/second_try
#SBATCH --nodes 1
#SBATCH --ntasks 2
#SBATCH --cpus-per-task 1
#SBATCH --mem 8G
#SBATCH --time 10:00:00
#SBATCH --mail-user=ali.saadat@epfl.ch
#SBATCH -J control_af
#SBATCH --mail-type=END
#SBATCH -o ./log/control_af_%J.out # Standard output
#SBATCH -e ./log/control_af_%J.err # Standard error
echo "START AT $(date)"
set -e

# Path
WORK="/work/gr-fe/saadat/pri/second_try"
REF="/work/gr-fe/saadat/Reference_Genome/GRCH38_no_alt/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa.gz"
SCRATCH="/scratch/saadat/pri/second_try"
CONTROL="/work/gr-fe/archive/sample_repository/all_exome_gvcfs_hg38/combined_cohort_vcf_result/BN_HBV_VNP_Pseudo_SysX_CMV_HIC_SHCS.vcf.gz"
CASE="/work/gr-fe/saadat/pri/second_try/annotation_output/vep_output/final_files/vep_cache_slivar_gnomad.vcf"
OUTPUT="/work/gr-fe/saadat/pri/second_try/annotation_output/vep_output/final_files/control_AF.txt"

# Prepare output
if [ ! -f $OUTPUT ]; then
	touch $OUTPUT
fi

# Tools
BCFTOOLS="/work/gr-fe/saadat/tools/bcftools/installation/bin/bcftools"

# Extract AF from control
$BCFTOOLS query -f '%CHROM %POS %REF %ALT %AF\n' $CONTROL > $OUTPUT

echo "END AT $(date)"
