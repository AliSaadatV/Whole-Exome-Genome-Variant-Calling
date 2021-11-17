#!/bin/bash 
#SBATCH --chdir /scratch/saadat/pri/second_try
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mem 20G
#SBATCH --time 10:00:00
#SBATCH --mail-user=ali.saadat@epfl.ch
#SBATCH -J gather_vcf_PRI
#SBATCH --mail-type=END
#SBATCH -o ./log/gather_vcf_PRI_%A_%a.out # Standard output
#SBATCH -e ./log/gather_vcf_PRI_%A_%a.err # Standard error

echo "START AT $(date)"
set -e

# Tools
PICARD="/work/gr-fe/saadat/tools/picard/picard.jar"

# Path
REF="/work/gr-fe/saadat/Reference_Genome/GRCH38_no_alt/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa.gz"
SCRATCH_PRI="/scratch/saadat/pri/second_try"
OUTPUT=${SCRATCH_PRI}/genotype_gvcf_output

# Create directories
mkdir -p ${SCRATCH_PRI}/temp/${SLURM_JOBID}/io

# Gather VCFs
cd $OUTPUT
input_list=$( for i in {1..22} X Y M; do echo -n "-I chr${i}.g.vcf " ; done)
java -Djva.io.tmpdir=${SCRATCH_PRI}/temp/${SLURM_JOBID}/io -Xms18G -Xmx18G -XX:ParallelGCThreads=2 -jar $PICARD GatherVcfs \
        $input_list\
        -O ${OUTPUT}/merged.vcf.gz

echo "FINISH AT $(date)"
