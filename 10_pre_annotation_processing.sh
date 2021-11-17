#!/bin/bash 
#SBATCH --chdir /scratch/saadat/pri/second_try
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 20
#SBATCH --mem 20G
#SBATCH --time 06:00:00
#SBATCH --mail-user=ali.saadat@epfl.ch
#SBATCH -J pre_annotation_PRI
#SBATCH --mail-type=END
#SBATCH -o ./log/pre_annotation_%J.out # Standard output
#SBATCH -e ./log/pre_annotation_%J.err # Standard error
set -e
echo "START AT $(date)"

# Tools
GATK="/work/gr-fe/saadat/tools/gatk/gatk-4.2.2.0/gatk"
BCFTOOLS="/work/gr-fe/saadat/tools/bcftools/installation/bin/bcftools"
VCFTOOLS="/work/gr-fe/saadat/tools/vcftools/installation/bin/vcftools"
VT="/work/gr-fe/saadat/tools/vt/vt/vt"

# Path
WORK_PRI="/work/gr-fe/saadat/pri/second_try"
SCRATCH_PRI="/scratch/saadat/pri/second_try"
INPUT=${SCRATCH_PRI}/genotype_refinement_output
OUTPUT=${WORK_PRI}/pre_annotation_output
REF="/work/gr-fe/saadat/Reference_Genome/GRCH38_no_alt/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa.gz"

# Create directories
mkdir -p ${SCRATCH_PRI}/temp/${SLURM_JOBID}/io

cd ${OUTPUT}
# Remove Batch Effect
$BCFTOOLS filter -i 'QUAL>=30 & INFO/DP>=20 & FORMAT/DP>=10 & FORMAT/GQ>=20' -S . -Ov \
	-o bcftools.vcf --threads 20 \
	${INPUT}/indel_recal_95_snp_recal_99.7_refined_GQ20.vcf.gz
bgzip -c bcftools.vcf > bcftools.vcf.gz
tabix -p vcf bcftools.vcf.gz
rm bcftools.vcf 

# Exclude filtered
$GATK --java-options "-Djava.io.tmpdir=${SCRATCH_PRI}/temp/${SLURM_JOBID}/io -Xms18G -Xmx18G -XX:ParallelGCThreads=4" \
        SelectVariants \
        -V ${OUTPUT}/bcftools.vcf.gz \
        -R $REF \
        --exclude-filtered \
        -exclude-non-variants --remove-unused-alternates \
        -O ${OUTPUT}/bcftools_gatk.vcf.gz

# Exclude too much missing
$VCFTOOLS --gzvcf bcftools_gatk.vcf.gz --max-missing 0.9 --mac 2 --recode --recode-INFO-all --out bcftools_gatk_vcftools
bgzip -c bcftools_gatk_vcftools.recode.vcf > bcftools_gatk_vcftools.vcf.gz
tabix -p vcf bcftools_gatk_vcftools.vcf.gz

# Normalize and break multiallelic 
$VT decompose -s -o temp.vcf bcftools_gatk_vcftools.vcf.gz
$VT normalize -r $REF -o bcftools_gatk_vcftools_norm.vcf temp.vcf
# Uncomment the follwing line if you want to use GRCh99 build of SNPEFF. If you use GRCh38_no_alt, no need to change anything!
#cat bcftools_gatk_vcftools_norm.vcf | sed "s/^chrM/MT/" > bcftools_gatk_vcftools_norm_corrected.vcf
bgzip -c bcftools_gatk_vcftools_norm.vcf > bcftools_gatk_vcftools_norm.vcf.gz
tabix -p vcf bcftools_gatk_vcftools_norm.vcf.gz
rm temp.vcf

echo "FINISH AT $(date)"
