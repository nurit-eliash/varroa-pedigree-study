#!/bin/bash
#SBATCH --job-name=order0_male
#SBATCH --partition=compute
#SBATCH --time=2-00:00:00
#SBATCH --mem=12G
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --mail-user=nurit.eliash@oist.jp
##SBATCH --mail-type=BEGIN,FAIL,END
#SBATCH --input=none
#SBATCH --output=out/order0_male.out

# (1) *OrderMarkers2* orders the markers within each LG by maximizing the likelihood of the data given the order.
# input: map.txt (output of JoinSingles/SeperateChromosomes2 module)
# output: order.txt

# (2) *Converting marker numbers* (1..N) back to genomic coordinates 
# input: order.txt (the output from OrderMarkers2)
# output: order.mapped

# *recombinations in both male female*
# assume recombintaions in males and females (default): 'recombination1=0.01' 'recombination2=0.01' 

#cut -f 1,2 data_f.call|awk '(NR>=7)' > snps.txt # make a file with the physical position of markers
# create directories for the inputs:
mkdir 0_male

Dir=0_male
ModuleDir=/home/n/nurit-eliash/lepmap/bin
DATA=/flash/EconomoU/Nurit/lepmap/lepmap_varroa/Q40BIALLDP16HDP40mis.5Chr7.Sites_00_01/data_f.call
MAP=/flash/EconomoU/Nurit/lepmap/lepmap_varroa/Q40BIALLDP16HDP40mis.5Chr7.Sites_00_01/map_611.txt
SNP=/flash/EconomoU/Nurit/lepmap/lepmap_varroa/Q40BIALLDP16HDP40mis.5Chr7.Sites_00_01/snps_611.txt
maxnr=7 # the numebr of LGs in the input file (map.txt)

for i in $(seq ${maxnr})
do
    java -cp $ModuleDir OrderMarkers2 map=$MAP data=$DATA useKosambi=1 numMergeIterations=100 sexAveraged=0 outputPhasedData=2 grandparentPhase=1 recombination1=0 recombination2=0.01 chromosome=${i} > $Dir/"order_${i}.txt"    
    
    awk -vFS="\t" -vOFS="\t" '(NR==FNR){s[NR-1]=$0}(NR!=FNR){if ($1 in s) $1=s[$1];print}' $SNP $Dir/order_${i}.txt > $Dir/"order_${i}.mapped"
done
