#!/bin/bash
#SBATCH --job-name=freebayes
#SBATCH --partition=compute
#SBATCH --mem=25G
#SBATCH --cpus-per-task=2
#SBATCH --time=2-0
#SBATCH --ntasks=1
##SBATCH --mail-user=%u@oist.jp
##SBATCH --mail-type=BEGIN,FAIL,END
#SBATCH --input=none
#SBATCH --output=%j.out
##SBATCH --error=job_%j.err

. $HOME/.bashrc 

module load freebayes

freebayes --ploidy 1 --min-alternate-fraction 0.2 --use-best-n-alleles 4 -m 5 -q 5 --populations /work/MikheyevU/Maeva/world-varroa/data/var/pops_mtDNA.txt -b /work/MikheyevU/Maeva/world-varroa/data/alignments/ngm_mtDNA/*.bam  -r AJ493124.2:1649-3296 -f /work/MikheyevU/Maeva/world-varroa/ref2019/destructor/mtDNA/AJ493124.fasta | vcffilter -f "QUAL > 20 & NS > 331.2" > /work/MikheyevU/Maeva/world-varroa/data/var/ngm_mtDNA/split_mtDNA/freebayes_mtDNA.1.vcf
