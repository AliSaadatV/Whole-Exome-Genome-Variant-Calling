#!/bin/bash 
#SBATCH --chdir /scratch/saadat/pri/second_try
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mem 6G
#SBATCH --time 24:00:00
#SBATCH --mail-user=ali.saadat@epfl.ch
#SBATCH --mail-type=END 
#SBATCH --job-name=bqsr_PRI
#SBATCH --output=./log/bqsr_PRI_%A_%a.out
#SBATCH --error=./log/bqs_PRIr_%A_%a.err

# Submit the job as follow: sbatch --array=0-119 03_bqsr.sh
echo "START AT $(date)"
set -e

# Tools
GATK="/work/gr-fe/saadat/tools/gatk/gatk-4.2.2.0/gatk"

# Path
REF="/work/gr-fe/saadat/Reference_Genome/GRCH38_no_alt/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa.gz"
SCRATCH_PRI="/scratch/saadat/pri/second_try"
OUTPUT=${SCRATCH_PRI}/bqsr_output
INPUT=${SCRATCH_PRI}/rmdup_output
KNOWN_SITES="/work/gr-fe/saadat/pri/known_sites"

# Create directories
mkdir -p ${SCRATCH_PRI}/temp/${SLURM_JOBID}/io

# Extract bam files
declare -a total_samples
for i in {1..120}; do
	entry=$(cat /work/gr-fe/saadat/pri/samples_bases.txt | head -${i} | tail -1)
	total_samples+=($entry)
done
sample_id=${total_samples[$SLURM_ARRAY_TASK_ID]}

# Run and Apply BQSR
$GATK --java-options "-Djava.io.tmpdir=${SCRATCH_PRI}/temp/${SLURM_JOBID}/io -Xms4G -Xmx4G -XX:ParallelGCThreads=2" BaseRecalibrator \
       -I ${INPUT}/${sample_id}_rmdup.bam \
       -R ${REF} \
       -O ${OUTPUT}/metrics/${sample_id}_bqsr.table \
       --known-sites ${KNOWN_SITES}/dbsnp_146.hg38.vcf.gz \
       --known-sites ${KNOWN_SITES}/Homo_sapiens_assembly38.known_indels.vcf.gz \
       --known-sites ${KNOWN_SITES}/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz && \

$GATK --java-options "-Djava.io.tmpdir=${SCRATCH_PRI}/temp/${SLURM_JOBID}/io -Xms4G -Xmx4G -XX:ParallelGCThreads=2" ApplyBQSR \
	-I ${INPUT}/${sample_id}_rmdup.bam \
        -R $REF \
        --bqsr-recal-file ${OUTPUT}/metrics/${sample_id}_bqsr.table \
        -O ${OUTPUT}/${sample_id}_rmdup_recal.bam

echo "END AT $(date)"
