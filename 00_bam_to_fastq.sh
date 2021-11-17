#!/bin/bash 
#SBATCH --chdir /scratch/saadat/pri/second_try
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 20
#SBATCH --mem 70G
#SBATCH --time 20:00:00
#SBATCH --mail-user=ali.saadat@epfl.ch
#SBATCH --mail-type=END 
#SBATCH --job-name=bam_to_fastq
#SBATCH --output=./log/bam_to_fastq.%J.out
#SBATCH --error=./log/bam_to_fastq.%J.err

echo "START AT $(date)"
set -e

# Path
SCRATCH_PRI="/scratch/saadat/pri"
RAW_BAM="/work/gr-fe/archive/sample_repository/PRI/BAM"

# Tools
SAMTOOLS="/work/gr-fe/saadat/tools/samtools/samtools-1.13/samtools"

# Create directories
mkdir -p ${SCRATCH_PRI}/second_try/bam_to_fastq_output/temp

# Convert bam to fastq
for i in {1..120}; do 
	sample_id=$(cat /work/gr-fe/saadat/pri/samples_bases.txt | head -$i | tail -1) 
	$SAMTOOLS sort -n -@ 20 ${RAW_BAM}/${sample_id}.bam -o ${SCRATCH_PRI}/second_try/bam_to_fastq_output/${sample_id}_sorted.bam
	$SAMTOOLS fastq -@ 20 ${SCRATCH_PRI}/second_try/bam_to_fastq_output/${sample_id}_sorted.bam \
                -1 ${SCRATCH_PRI}/second_try/bam_to_fastq_output/${sample_id}_R1.fastq.gz \
                -2 ${SCRATCH_PRI}/second_try/bam_to_fastq_output/${sample_id}_R2.fastq.gz \
                -n \
                -0 ${SCRATCH_PRI}/second_try/bam_to_fastq_output/temp/${sample_id}_set_or_unset_reads \
                -s ${SCRATCH_PRI}/second_try/bam_to_fastq_output/temp/${sample_id}_singelton_reads
done

echo "FINISH AT $(date)"
