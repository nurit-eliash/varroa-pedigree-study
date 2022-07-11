#!/bin/bash
#SBATCH --job-name=three_fams
#SBATCH --partition=compute
#SBATCH --time=1-00:00:00
#SBATCH --mem=12G
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --mail-user=nurit.eliash@oist.jp
#SBATCH --mail-type=BEGIN,FAIL,END
#SBATCH --input=none
#SBATCH --output=%j.out

# create a temporary directory for this job and save the name
#tempdir=$(mktemp -d /flash/EconomoU/Nurit/linkage_map_work/vcftools/mrg_vcf/lep.XXXXXX)

# enter the temporary directory
#cd $tempdir

# Start command with input from flash,
# and output to our temporary directory

VCF=/bucket/EconomoU/Nurit/vcftools/mrg_vcf/Q40BIALLDP16HDP40mis.5Chr7.recode.vcf
LIST=/flash/EconomoU/Nurit/linkage_map_work/vcftools/mrg_vcf/list_fam/three_fams.txt

# i will keep the three families in the LIST, and keep only SNPs, by 'remove indels':
vcftools --vcf $VCF --keep $LIST --recode --recode-INFO-all --out three_fam.Q40BIALLDP16HDP40mis.5Chr7

# copy our result back to Bucket. We use "scp" to copy the data 
# back as bucket isn't writable directly from the compute nodes.
#scp three_fam.Q40BIALLDP16HDP40mis.5Chr7.recode.vcf deigo:/bucket/EconomoU/Nurit/vcftools/mrg_vcf/three_fams/

# Clean up by removing our temporary directory
#rm -r $tempdir
