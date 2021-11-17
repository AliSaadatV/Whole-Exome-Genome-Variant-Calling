#!/bin/bash 
#SBATCH --chdir /scratch/saadat/pri/second_try
#SBATCH --nodes 1
#SBATCH --ntasks 2
#SBATCH --cpus-per-task 1
#SBATCH --mem 8G
#SBATCH --time 10:00:00
#SBATCH --mail-user=ali.saadat@epfl.ch
#SBATCH -J spliceai
#SBATCH --mail-type=END
#SBATCH -o ./log/spliceai_%J.out # Standard output
#SBATCH -e ./log/spliceai_%J.err # Standard error
echo "START AT $(date)"
set -e

# Path
WORK="/work/gr-fe/saadat/pri/second_try"
REF="/work/gr-fe/saadat/Reference_Genome/GRCH38_no_alt/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa.gz"
GTF="/work/gr-fe/saadat/Reference_Genome/GRCH38_no_alt/gtf_and_gff/GCA_000001405.15_GRCh38_full_analysis_set.refseq_annotation_for_vep.gtf.gz"
GFF="/work/gr-fe/saadat/Reference_Genome/GRCH38_no_alt/gtf_and_gff/GCA_000001405.15_GRCh38_full_analysis_set.refseq_annotation_for_vep.gff.gz"
SCRATCH="/scratch/saadat/pri/second_try"
INPUT_DIR="/work/gr-fe/saadat/pri/second_try/annotation_output/vep_output"
OUTPUT_DIR="/work/gr-fe/saadat/pri/second_try/annotation_output/vep_output"

# Tools
spliceai -I ${INPUT_DIR}/vep_cache_silvar_gnomad.vcf \
-O ${OUTPUT_DIR}/vep_cache_silvar_gnomad_spliceai.vcf \
-R $REF \
-A grch38 \
-M 1

echo "END AT $(date)"
