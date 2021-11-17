#!/bin/bash 
#SBATCH --chdir /scratch/saadat/pri/second_try
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mem 20G
#SBATCH --time 10:00:00
#SBATCH --mail-user=ali.saadat@epfl.ch
#SBATCH -J genotype_gvcf_PRI
#SBATCH --mail-type=END
#SBATCH -o ./log/genotype_gvcf_PRI_%A_%a.out # Standard output
#SBATCH -e ./log/genotype_gvcf_PRI_%A_%a.err # Standard error

###################### sbatch --array=0-24 06_genotype_gvcf.sh
echo "START AT $(date)"
set -e

# Tools
GATK="/work/gr-fe/saadat/tools/gatk/gatk-4.2.2.0/gatk"

# Path
REF="/work/gr-fe/saadat/Reference_Genome/GRCH38_no_alt/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa.gz"
SCRATCH_PRI="/scratch/saadat/pri/second_try"
INPUT=${SCRATCH_PRI}/genomics_db_import_output
OUTPUT=${SCRATCH_PRI}/genotype_gvcf_output

# Create directories
mkdir -p ${SCRATCH_PRI}/temp/${SLURM_JOBID}/io

# Prepare input
declare -a NUMBER
for j in {1..22} X Y M; do NUMBER+=($j); done
INDEX=${NUMBER[$SLURM_ARRAY_TASK_ID]}
cd $INPUT

# Run GenotypeGVCFs
$GATK --java-options "-Djava.io.tmpdir=${SCRATCH_PRI}/temp/${SLURM_JOBID}/io -Xms18G -Xmx18G -XX:ParallelGCThreads=2" \
	GenotypeGVCFs \
	-R $REF \
	-V gendb://chr${INDEX}_gdb \
	-O ${OUTPUT}/chr${INDEX}.g.vcf

echo "FINISH AT $(date)"
