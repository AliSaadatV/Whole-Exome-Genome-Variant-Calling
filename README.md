# Whole-Exome-Genome-Variant-Calling
This repository shows the workflow for variant calling in whole exome/genome. Scripts must be executed according to their number (from 00 to 11). 

**Tools**:
- samtools 1.13 
- fastp 0.23.0
- bwa 0.7.17-r1188
- GATK gatk-4.2.2.0
- bcftools 1.13
- vcftools 0.1.17
- vt 0.57721
- VEP 104
- slivar 0.2.5
- ANNOVAR 2020-06-07

**External Data**:
- Reference --> GCA_000001405.15_GRCh38_no_alt_analysis_set.fa.gz (Suggested by the author of BWA)
- dbSNP     --> dbsnp_146.hg38.vcf.gz
- known_indel-> Homo_sapiens_assembly38.known_indels.vcf.gz
- Mills     --> Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
- hapmap    --> hapmap_3.3.hg38.vcf.gz
- omni      --> 1000G_omni2.5.hg38.vcf.gz
- 1000G     --> 1000G_phase1.snps.high_confidence.hg38.vcf.gz
- gnomad    --> af-only-gnomad.hg38.vcf.gz
- dbNSFP    --> dbNSFP.4.2.a
