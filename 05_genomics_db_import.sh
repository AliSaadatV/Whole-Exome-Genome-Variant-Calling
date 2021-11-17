#!/bin/bash 
#SBATCH --chdir /scratch/saadat/pri/second_try
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mem 30G
#SBATCH --time 04:45:00
#SBATCH --mail-user=ali.saadat@epfl.ch
#SBATCH -J genomics_db_import_PRI
#SBATCH --mail-type=END
#SBATCH -o ./log/genomics_db_import_PRI_%A_%a.out # Standard output
#SBATCH -e ./log/genomics_db_import_PRI_%A_%a.err # Standard error

###############sbatch --array=0-24 05_genomics_db_import.sh
echo "START AT $(date)"
set -e

# Tools
GATK="/work/gr-fe/saadat/tools/gatk/gatk-4.2.2.0/gatk"

# Path
REF="/work/gr-fe/saadat/Reference_Genome/GRCH38_no_alt/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa.gz"
SCRATCH_PRI="/scratch/saadat/pri/second_try"
INPUT=${SCRATCH_PRI}/haplotype_caller_output
OUTPUT=${SCRATCH_PRI}/genomics_db_import_output

# Create directories
mkdir -p ${SCRATCH_PRI}/temp/${SLURM_JOBID}/io

# Prepare input
declare -a NUMBER
for j in {1..22} X Y M; do NUMBER+=($j); done
INDEX=${NUMBER[$SLURM_ARRAY_TASK_ID]}
gvcf_files=$(for f in ${INPUT}/*.g.vcf.gz; do echo -n "-V $f " ; done)

# Run GenomicsDBImport
$GATK --java-options "-Djava.io.tmpdir=${SCRATCH_PRI}/temp/${SLURM_JOBID}/io -Xms30G -Xmx30G -XX:ParallelGCThreads=2" \
	GenomicsDBImport \
	--genomicsdb-workspace-path ${OUTPUT}/chr${INDEX}_gdb \
	-R $REF \
	$gvcf_files\
	--tmp-dir ${SCRATCH_PRI}/temp/${SLURM_JOBID} \
	--intervals chr${INDEX} \
	--genomicsdb-shared-posixfs-optimizations true

echo "FINISH AT $(date)"
