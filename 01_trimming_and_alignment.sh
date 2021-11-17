#!/bin/bash 
#SBATCH --chdir /scratch/saadat
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 32
#SBATCH --mem 60G
#SBATCH --time 20:00:00
#SBATCH --mail-user=ali.saadat@epfl.ch
#SBATCH --mail-type=END 
#SBATCH --job-name=alignment_no_alt
#SBATCH --output=./log/alignment_no_alt_%A_%a.out
#SBATCH --error=./log/alignment_no_alt_%A_%a.err

########################## Submit the job as follow: sbatch --array=0-119 01_trimming_and_alignment.sh

echo "START AT $(date)"

# Tools
BWA="/work/gr-fe/saadat/tools/bwa/bwa"
SAMTOOLS="/work/gr-fe/saadat/tools/samtools/samtools-1.13/samtools"
FASTP="/work/gr-fe/saadat/tools/fastp/fastp"

# Modules
module load gcc/9.3.0

# Path
REF="/work/gr-fe/saadat/Reference_Genome/GRCH38_no_alt/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa.gz"
SCRATCH_PRI="/scratch/saadat/pri"
WORK_PRI="/work/gr-fe/saadat/pri"
RAW_BAM="/work/gr-fe/archive/sample_repository/PRI/BAM"
INPUT_DIR="${SCRATCH_PRI}/second_try/bam_to_fastq_output"
OUTPUT_DIR="/scratch/saadat/pri/second_try/alignments"

# Create directories
mkdir -p $OUTPUT_DIR/metrics

# Extract fastq files
declare -a total_R1
for i in ${INPUT_DIR}/*R1.fastq.gz; do total_R1+=($i); done
R1=${total_R1[$SLURM_ARRAY_TASK_ID]}
sample_id=$(basename ${R1} _R1.fastq.gz)
R2=${INPUT_DIR}/${sample_id}_R2.fastq.gz

# Extract read group
id=$(samtools view -H ${RAW_BAM}/${sample_id}.bam | grep @RG | cut -f2)
lb=$(samtools view -H ${RAW_BAM}/${sample_id}.bam | grep @RG | cut -f3)
pl=$(samtools view -H ${RAW_BAM}/${sample_id}.bam | grep @RG | cut -f4)
sm=$(samtools view -H ${RAW_BAM}/${sample_id}.bam | grep @RG | cut -f5)
pu=$(samtools view -H ${RAW_BAM}/${sample_id}.bam | grep @RG | cut -f6)
cn=$(samtools view -H ${RAW_BAM}/${sample_id}.bam | grep @RG | cut -f7)
ds=$(samtools view -H ${RAW_BAM}/${sample_id}.bam | grep @RG | cut -f8)
rg="@RG\t${id}\t${lb}\t${pl}\t${sm}\t${pu}\t${cn}\t${ds}"

# Trimming, alignment, and converting to bam
$FASTP -i $R1 -I $R2 \
    --stdout --thread 2 \
    -j "${OUTPUT_DIR}/metrics/${sample_id}_fastp.json" \
    -h "${OUTPUT_DIR}/metrics/${sample_id}_fastp.html" \
| $BWA mem -v 2 -M -t 26 -p \
        -R $rg \
        ${REF} \
       - \
| $SAMTOOLS view -@ 4 -O BAM -o ${OUTPUT_DIR}/${sample_id}.bam 

echo "START AT $(date)"
