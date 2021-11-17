#!/bin/bash 
#SBATCH --chdir /scratch/saadat/pri/second_try
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mem 6G
#SBATCH --time 10:00:00
#SBATCH --mail-user=ali.saadat@epfl.ch
#SBATCH -J vqsr_PRI
#SBATCH --mail-type=END
#SBATCH -o ./log/vqsr_PRI_%J.out # Standard output
#SBATCH -e ./log/vqsr_PRI_%J.err # Standard error
echo "START AT $(date)"
set -e
#module purge
#module load gcc openblas/0.3.6-openmp
#module load r

# Tools
GATK="/work/gr-fe/saadat/tools/gatk/gatk-4.2.2.0/gatk"

# Path
SCRATCH_PRI="/scratch/saadat/pri/second_try"
REF="/work/gr-fe/saadat/Reference_Genome/GRCH38_no_alt/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa.gz"
KNOWN_SITES="/work/gr-fe/saadat/pri/known_sites"
INPUT=${SCRATCH_PRI}/genotype_gvcf_output
OUTPUT=${SCRATCH_PRI}/vqsr_output

# Create directories
mkdir -p ${SCRATCH_PRI}/temp/${SLURM_JOBID}/io

# Run VQSR
$GATK --java-options "-Djava.io.tmpdir=${SCRATCH_PRI}/temp/${SLURM_JOBID}/io -Xms5G -Xmx5G -XX:ParallelGCThreads=2" VariantRecalibrator \
	-tranche 100.0 -tranche 99.95 -tranche 99.9 \
	-tranche 99.5 -tranche 99.0 -tranche 97.0 -tranche 96.0 \
	-tranche 95.0 -tranche 94.0 \
	-tranche 93.5 -tranche 93.0 -tranche 92.0 -tranche 91.0 -tranche 90.0 \
	-R $REF \
	-V ${INPUT}/merged.vcf.gz \
	--resource:hapmap,known=false,training=true,truth=true,prior=15.0 \
	${KNOWN_SITES}/hapmap_3.3.hg38.vcf.gz \
	--resource:omni,known=false,training=true,truth=false,prior=12.0 \
	${KNOWN_SITES}/1000G_omni2.5.hg38.vcf.gz \
	--resource:1000G,known=false,training=true,truth=false,prior=10.0 \
	${KNOWN_SITES}/1000G_phase1.snps.high_confidence.hg38.vcf.gz \
	-an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR \
	-mode SNP -O ${OUTPUT}/merged_snp1.recal --tranches-file ${OUTPUT}/output_snp1.tranches && \

$GATK --java-options "-Djava.io.tmpdir=${SCRATCH_PRI}/temp/${SLURM_JOBID}/io -Xms5G -Xmx5G -XX:ParallelGCThreads=2" VariantRecalibrator \
        -tranche 100.0 -tranche 99.95 -tranche 99.9 \
        -tranche 99.5 -tranche 99.0 -tranche 97.0 -tranche 96.0 \
        -tranche 95.0 -tranche 94.0 \
        -tranche 93.5 -tranche 93.0 -tranche 92.0 -tranche 91.0 -tranche 90.0 \
        -R $REF \
        -V ${INPUT}/merged.vcf.gz \
        --resource:mills,known=false,training=true,truth=true,prior=12.0 \
        ${KNOWN_SITES}/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz \
        --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 \
        ${KNOWN_SITES}/dbsnp_146.hg38.vcf.gz \
	-an QD -an MQRankSum -an ReadPosRankSum -an FS -an SOR \
        -mode INDEL -O ${OUTPUT}/merged_indel1.recal --tranches-file ${OUTPUT}/output_indel1.tranches && \

# Apply VQSR
$GATK --java-options "-Djava.io.tmpdir=${SCRATCH_PRI}/temp/${SLURM_JOBID}/io -Xms5G -Xmx5G -XX:ParallelGCThreads=2" ApplyVQSR \
        -V ${INPUT}/merged.vcf.gz \
        --recal-file ${OUTPUT}/merged_snp1.recal \
        -mode SNP \
        --tranches-file ${OUTPUT}/output_snp1.tranches \
        --truth-sensitivity-filter-level 99.7 \
        --create-output-variant-index true \
        -O ${OUTPUT}/snp_recal_99.7.vcf.gz && \

$GATK --java-options "-Djava.io.tmpdir=${SCRATCH_PRI}/temp/${SLURM_JOBID}/io -Xms5G -Xmx5G -XX:ParallelGCThreads=2" ApplyVQSR \
        -V ${OUTPUT}/snp_recal_99.7.vcf.gz \
        --recal-file ${OUTPUT}/merged_indel1.recal \
        -mode INDEL \
        --tranches-file ${OUTPUT}/output_indel1.tranches \
        --truth-sensitivity-filter-level 95 \
        --create-output-variant-index true \
        -O ${OUTPUT}/indel_recal_95_snp_recal_99.7.vcf.gz

echo "FINISH AT $(date)"
