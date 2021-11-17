#!/bin/bash 
#SBATCH --chdir /scratch/saadat/pri/second_try
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 20
#SBATCH --mem 85G
#SBATCH --time 14:10:00
#SBATCH --mail-user=ali.saadat@epfl.ch
#SBATCH --mail-type=END 
#SBATCH --job-name=rmdup_PRI
#SBATCH --output=./log/rmdup_PRI_%A_%a.out
#SBATCH --error=./log/rmdup_PRI_%A_%a.err

############################ Submit the job as follow: sbatch --array=0-119 02_rmdup.sh
echo "START AT $(date)"
set -e

# Tools
GATK="/work/gr-fe/saadat/tools/gatk/gatk-4.2.2.0/gatk"

# Path
REF="/work/gr-fe/saadat/Reference_Genome/GRCH38_no_alt/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa.gz"
SCRATCH_PRI="/scratch/saadat/pri/second_try"
INPUT=${SCRATCH_PRI}/alignments
OUTPUT=${SCRATCH_PRI}/rmdup_output
TEMP="${SCRATCH_PRI}/temp"

# Create directories
mkdir -p ${OUTPUT}/metrics
mkdir -p ${SCRATCH_PRI}/temp/${SLURM_JOBID}/io

# Extract bam files
declare -a total_samples
for i in {1..120}; do
	entry=$(cat /work/gr-fe/saadat/pri/samples_bases.txt | head -${i} | tail -1)
	total_samples+=($entry)
done
sample_id=${total_samples[$SLURM_ARRAY_TASK_ID]}
#input_list=$(for f in ${INPUT}/${sample}_*query_sorted.bam; do echo -n "-I $f " ; done)

# Run MarkDupSpark
${GATK} --java-options "-Djava.io.tmpdir=${SCRATCH_PRI}/temp/${SLURM_JOBID}/io -Xms70G -Xmx70G" MarkDuplicatesSpark \
       -I ${INPUT}/${sample_id}.bam\
       -O ${OUTPUT}/${sample_id}_rmdup.bam \
       --spark-master local[*] \
       -M ${OUTPUT}/${sample_id}_rmdup_metrics.txt \
       --remove-all-duplicates

echo "END AT $(date)"
