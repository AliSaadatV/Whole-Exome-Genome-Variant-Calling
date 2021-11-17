#!/bin/bash 
#SBATCH --chdir /scratch/saadat/pri/second_try
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mem 6G
#SBATCH --time 05:00:00
#SBATCH --mail-user=ali.saadat@epfl.ch
#SBATCH -J genotype_refinement_PRI
#SBATCH --mail-type=END
#SBATCH -o ./log/genotype_refinement_PRI_%J.out # Standard output
#SBATCH -e ./log/genotype_refinement_PRI_%J.err # Standard error
echo "START AT $(date)"
set -e

# Tools
GATK="/work/gr-fe/saadat/tools/gatk/gatk-4.2.2.0/gatk"

# Path
SCRATCH_PRI="/scratch/saadat/pri/second_try"
REF="/work/gr-fe/saadat/Reference_Genome/GRCH38_no_alt/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa.gz"
KNOWN_SITES="/work/gr-fe/saadat/pri/known_sites"
INPUT=${SCRATCH_PRI}/vqsr_output
OUTPUT=${SCRATCH_PRI}/genotype_refinement_output

# Create directories
mkdir -p ${SCRATCH_PRI}/temp/${SLURM_JOBID}/io

# Run genotype refinement
$GATK --java-options "-Djava.io.tmpdir=${SCRATCH_PRI}/temp/${SLURM_JOBID}/io -Xms5G -Xmx5G -XX:ParallelGCThreads=2" \
	CalculateGenotypePosteriors \
	-V ${INPUT}/indel_recal_95_snp_recal_99.7.vcf.gz \
	-O ${OUTPUT}/indel_recal_95_snp_recal_99.7_refined.vcf.gz \
	--supporting-callsets ${KNOWN_SITES}/af-only-gnomad.hg38.vcf.gz \
	--num-reference-samples-if-no-call 20314 && \

$GATK --java-options "-Djava.io.tmpdir=${SCRATCH_PRI}/temp/${SLURM_JOBID}/io -Xms5G -Xmx5G -XX:ParallelGCThreads=2" \
        VariantFiltration \
        -V ${OUTPUT}/indel_recal_95_snp_recal_99.7_refined.vcf.gz \
        -R $REF \
        --genotype-filter-expression "GQ < 20" \
        --genotype-filter-name "lowGQ" \
        -O ${OUTPUT}/indel_recal_95_snp_recal_99.7_refined_GQ20.vcf.gz

echo "FINISH AT $(date)"
