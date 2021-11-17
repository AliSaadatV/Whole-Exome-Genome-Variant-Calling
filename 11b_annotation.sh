#!/bin/bash 
#SBATCH --chdir /scratch/saadat/pri/second_try
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 4
#SBATCH --mem 23G
#SBATCH --time 05:00:00
#SBATCH --mail-user=ali.saadat@epfl.ch
#SBATCH -J annotation_PRI
#SBATCH --mail-type=END
#SBATCH -o ./log/annotation_PRI_%J.out # Standard output
#SBATCH -e ./log/annotation_PRI_%J.err # Standard error
echo "START AT $(date)"
set -e

# Tools
SNPEFF="/work/gr-fe/saadat/tools/snpeff/snpEff/snpEff.jar"
SNPSIFT="/work/gr-fe/saadat/tools/snpeff/snpEff/SnpSift.jar"
ANNOVAR="/work/gr-fe/saadat/tools/annovar/annovar"
SLIVAR_DIR="/work/gr-fe/saadat/tools/slivar"

# Path
WORK_PRI="/work/gr-fe/saadat/pri/second_try"
SCRATCH_PRI="/scratch/saadat/pri/second_try"
INPUT=${WORK_PRI}/pre_annotation_output
OUTPUT=${WORK_PRI}/annotation_output
REF="/work/gr-fe/saadat/Reference_Genome/GRCH38_no_alt/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa.gz"
CONFIG="/work/gr-fe/saadat/tools/snpeff/snpEff/snpEff.config"

# Create directories
mkdir -p ${SCRATCH_PRI}/temp/${SLURM_JOBID}/io

# Annotate with snpeff
#java -Djava.io.tmpdir=${SCRATCH_PRI}/temp/${SLURM_JOBID}/io -Xms20G -Xmx20G -XX:ParallelGCThreads=4 -jar $SNPEFF \
# -stats ${OUTPUT}/snpeff.html -v GRCh38_no_alt -c $CONFIG \
# ${INPUT}/bcftools_gatk_vcftools_norm.vcf.gz > ${OUTPUT}/snpeff.vcf

# Filter with snpsift
#java -Djava.io.tmpdir=${SCRATCH_PRI}/temp/${SLURM_JOBID}/io -Xms20G -Xmx20G -XX:ParallelGCThreads=4 -jar $SNPSIFT \
#filter "(exists LOF[*].PERC) | (ANN[*].EFFECT has 'missense_variant')" ${OUTPUT}/snpeff.vcf > ${OUTPUT}/snpeff_snpsift_misslof_no_alt_5pcconfig_gnomad3.vcf
#filter "(ANN[*].IMPACT has 'HIGH')" ${OUTPUT}/snpeff.vcf > ${OUTPUT}/snpeff_snpsift_high.vcf
#filter "(exists LOF[*].PERC) | (ANN[*].IMPACT has 'HIGH')" ${OUTPUT}/snpeff.vcf > ${OUTPUT}/snpeff_snpsiftLoF_high.vcf

# Filter with Slivar
${SLIVAR_DIR}/slivar expr \
--js ${SLIVAR_DIR}/slivar-functions.js \
--vcf ${OUTPUT}/vep_output/final_files/vep_cache_ensembl_flagpick.vcf.gz \
--info 'INFO.impactful && variant.FILTER == "PASS"' \
--out-vcf ${OUTPUT}/vep_output/final_files/vep_cache_ensembl_flagpick_impactful.vcf

# Annotate with annovar
perl ${ANNOVAR}/table_annovar.pl ${OUTPUT}/vep_output/final_files/vep_cache_ensembl_flagpick_impactful.vcf ${ANNOVAR}/humandb_hg38/ \
 -buildver hg38 \
 -thread 4 \
 -out ${OUTPUT}/vep_output/final_files/vep_cache_ensembl_flagpick_impactful_annovar.vcf \
 -vcfinput \
 -remove \
 -protocol refGene,ensGene,dbnsfp42a,avsnp147,clinvar_20210501,esp6500siv2_all,gnomad30_genome,exac03,ALL.sites.2015_08,dbscsnv11 \
 -operation g,g,f,f,f,f,f,f,f,f \
 -nastring .
# -protocol refGene,ensGene,dbnsfp42a,avsnp147,clinvar_20210501,esp6500siv2_all,gnomad_exome,exac03,ALL.sites.2015_08,dbscsnv11 \
echo "FINISH AT $(date)"
