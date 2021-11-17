#!/bin/bash 
#SBATCH --chdir /scratch/saadat/pri/second_try
#SBATCH --nodes 1
#SBATCH --ntasks 24
#SBATCH --cpus-per-task 1
#SBATCH --mem 40G
#SBATCH --time 10:00:00
#SBATCH --mail-user=ali.saadat@epfl.ch
#SBATCH -J vep_pri_second
#SBATCH --mail-type=END
#SBATCH -o ./log/vep_pri_second_%J.out # Standard output
#SBATCH -e ./log/vep_prim_second_%J.err # Standard error
echo "START AT $(date)"
set -e

# Path
WORK="/work/gr-fe/saadat/pri/second_try"
REF="/work/gr-fe/saadat/Reference_Genome/GRCH38_no_alt/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa.gz"
GTF="/work/gr-fe/saadat/Reference_Genome/GRCH38_no_alt/gtf_and_gff/GCA_000001405.15_GRCh38_full_analysis_set.refseq_annotation.gtf.gz"
GFF="/work/gr-fe/saadat/Reference_Genome/GRCH38_no_alt/gtf_and_gff/GCA_000001405.15_GRCh38_full_analysis_set.refseq_annotation_for_vep.gff.gz"
SCRATCH="/scratch/saadat/pri/second_try"
CACHE="/work/gr-fe/databases/vep_hg38/cache_hg38_ensembl"
PLUGINS="/work/gr-fe/databases/vep_hg38/plugins"
INPUT_DIR="/work/gr-fe/saadat/pri/second_try/pre_annotation_output"
OUTPUT_DIR="/work/gr-fe/saadat/pri/second_try/annotation_output/vep_output"
LOFTEE="/work/gr-fe/databases/vep_hg38/loftee"
G2P_PANNEL="/work/gr-fe/saadat/panels/Primary_immunodeficiency.csv"
CADD_DIR="/work/gr-fe/databases/CADD_v1.6_GRCH38_hg38"

# Activate vep from conda
eval "$(conda shell.bash hook)"
conda activate ensembl-vep

#vep \
#--vcf \
#--fasta $REF \
#--gtf $GTF \
#-i ${INPUT_DIR}/bcftools_gatk_vcftools_norm.vcf.gz \
#-o ${OUTPUT_DIR}/vep_gtfagain.vcf.gz \
#--stats_file ${OUTPUT_DIR}/vep_gtfagain.html \
#--fork 24 \
#--force_overwrite

vep \
--offline --vcf \
--fasta $REF \
--cache \
--dir_cache $CACHE \
--canonical \
--hgvs \
--symbol \
--mane \
--flag_pick \
--cache_version 104 \
-i ${INPUT_DIR}/bcftools_gatk_vcftools_norm.vcf.gz \
-o ${OUTPUT_DIR}/final_files/vep_cache_ensembl_flagpick.vcf.gz \
--stats_file ${OUTPUT_DIR}/final_files/vep_cache_ensembl_flagpick.html \
--fork 24 \
--force_overwrite

#--dir_plugins $PLUGINS \
#–transcript_version \
#--plugin CADD,${CADD_DIR}/whole_genome_SNVs.tsv.gz,${CADD_DOR}/gnomad.genomes.r3.0.indel.tsv.gz \
#vep \
#--offline --vcf --everything \
#--fasta $REF \
#--dir_cache $CACHE \
#--dir_plugins $PLUGINS \
#--plugin Condel,$PLUGINS/config/Condel/config/ \
#--plugin SpliceConsensus \
#--plugin Downstream \
#--terms SO \
#--af_gnomad \
#–coding_only \
#–transcript_version \
#--cache \
#--cache_version 104 \
#-i $INPUT \
#-o $OUTPUT \
#--fork 24 \
#--force_overwrite
#--assembly GRCh38 \
echo "END AT $(date)"
