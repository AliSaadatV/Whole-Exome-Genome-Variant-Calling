#!/bin/bash 
#SBATCH --chdir /scratch/saadat/pri/second_try
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mem 20G
#SBATCH --time 24:00:00
#SBATCH --mail-user=ali.saadat@epfl.ch
#SBATCH --mail-type=END 
#SBATCH --job-name=hc_PRI
#SBATCH --output=./log/hc_PRI_%A_%a.out
#SBATCH --error=./log/hc_PRI_%A_%a.err

# Submit the job as follow: sbatch --array=0-119 04_haplotype_caller.sh
echo "START AT $(date)"
set -e

# Tools
GATK="/work/gr-fe/saadat/tools/gatk/gatk-4.2.2.0/gatk"

# Path
REF="/work/gr-fe/saadat/Reference_Genome/GRCH38_no_alt/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa.gz"
SCRATCH_PRI="/scratch/saadat/pri/second_try"
OUTPUT=${SCRATCH_PRI}/haplotype_caller_output
INPUT=${SCRATCH_PRI}/bqsr_output
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

# Run HC
$GATK --java-options "-Djava.io.tmpdir=${SCRATCH_PRI}/temp/${SLURM_JOBID}/io -Xms18G -Xmx18G -XX:ParallelGCThreads=2" HaplotypeCaller \
       -I ${INPUT}/${sample_id}_rmdup_recal.bam \
       -R ${REF} \
       -O ${OUTPUT}/${sample_id}.g.vcf.gz \
       -ERC GVCF \
       -D ${KNOWN_SITES}/dbsnp_146.hg38.vcf.gz
	
echo "END AT $(date)"
