########################################
## Varroa linkage map, using Lep-MAP3 ##
########################################

# P. Rastas. Lep-MAP3: Robust linkage mapping even for low-coverage whole genome sequencing data, Bioinformatics, https://doi.org/10.1093/bioinformatics/btx494.

# load the LepMAP3 package to the home directory
# /home/n/nurit-eliash/lepmap/

# redirect to the working directory
cd /flash/EconomoU/Nurit/lepmap/lepmap_varroa

# The genetic input data consists of a pedigree describing 26 full-sib families and genotype likelihoods for each variant and individual.

# (1) genotype likelihood file in a VCF format 
# (2) pedigree file in .txt format

########################################
##     first trial with 3 families    ##
########################################

# prepare the VCF file for 3 families, and keep only SNPs by --remove indels:
VCF=/bucket/EconomoU/Nurit/vcftools/mrg_vcf/Q40BIALLDP16HDP40mis.5Chr7.recode.vcf
LIST=/flash/EconomoU/Nurit/linkage_map_work/vcftools/mrg_vcf/list_fam/three_fams.txt

vcftools --vcf $VCF --keep $LIST --remove-indels --recode --recode-INFO-all --out three_fam.Q40BIALLDP16HDP40mis.5Chr7NOind

# prepare the pedigree.txt file:
# prepare manjualy and save as .txt file.
pedigree_3.txt

# save the two files in the same directory, the working directory: /flash/EconomoU/Nurit/lepmap/lepmap_varroa
# redirect to the working directory
cd /flash/EconomoU/Nurit/lepmap/lepmap_varroa

# run the first module:
##############################
##      * ParentCall2 *     ##
##############################
# The module ParentCall2 is used to call parental genotypes and markers.
java -cp /home/n/nurit-eliash/lepmap/bin ParentCall2 vcfFile= three_fam.Q40BIALLDP16HDP40mis.5Chr7NOind.recode.vcf data=pedigree_3.txt removeNonInformative=1 >data.call

##############################
##      ֿ * Filtering2 *      ##
##############################
java -cp /home/n/nurit-eliash/lepmap/bin Filtering2 data=data.call dataTolerance=0.01 removeNonInformative=1 >data_f.call

##############################
## * SeparateChromosomes2 * ##
##############################
# The SeparateChromosomes2 module assigns markers into linkage groups (LGs) 
java -cp /home/n/nurit-eliash/lepmap/bin SeparateChromosomes2 data=data_f.call sizeLimit=3 lodLimit=3  > map4_14.txt

##############################
##   * JoinSingles2All *    ##
##############################
# join markers that were left over after seperating them into exsisting linkage groups
java -cp /home/n/nurit-eliash/lepmap/bin JoinSingles2All map=map4_14.txt data=data_f.call iterate=1 lodLimit=13 > map4_14_js.txt

#The size distribution of linkage groups can be obtained like this:
cut -f 1 map4_14_js.txt|sort|uniq -c|sort -n

##############################
##     * OrderMarkers2 *    ##
##############################
# orders the markers within each LG by maximizing the likelihood of the data given the order
java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map4_14_js.txt data=data_f.call useKosambi=1 numMergeIterations=1 sexAveraged=1 outputPhasedData=2 grandparentPhase=1 > order.txt


# additional codes to arrange the data (not modules):

##############################
## * markers to position *  ##
##############################
# Converting marker numbers (1..N) back to genomic coordinates (order.txt is the output from OrderMarkers2 using data data.call coming from ParentCall2):

cut -f 1,2 data.call|awk '(NR>=7)' > snps.txt
#note that first line of snps.txt contains "CHR POS"
awk -vFS="\t" -vOFS="\t" '(NR==FNR){s[NR-1]=$0}(NR!=FNR){if ($1 in s) $1=s[$1];print}' snps.txt order.txt >order.mapped
#because of first line of snps.txt, we use NR-1 instead of NR


##############################
##     * map2genotypes *    ##
##############################
# convert the 'order' file into an output file (easier to read)
awk -v fullData=1 -f /home/n/nurit-eliash/lepmap/bin/map2genotypes.awk order.txt > output.txt

# rsync the output.txt and order.mapped files to the local PC, for further analysis and visualization on R





###############################################################
########                  *** E N D ***                ########                 
###############################################################

# ACHIASMATIC MEIOSIS 
# check the markers order under 2 assumptions: (1) no recombinations in males; (2) no recombinations in females.  
# We use the 'map.txt' as an input file, the output of 'JoinSingles2All' module.

### SET DIRECTORY PATHS FOR OUTPUT DATA
OUTDir = /flash/EconomoU/Nurit/lepmap/lepmap_varroa/three_fam.Q40BIALLDP16HDP40mis.5Chr7

# (1) no recombinations in males
##############################
##     * OrderMarkers2 *    ##
##############################
# orders the markers within each LG by maximizing the likelihood of the data given the order
# assume no recombintaions in the males: 'recombination1=0'
java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map3_3_js.txt data=data_f.call useKosambi=1 numMergeIterations=1 sexAveraged=1 outputPhasedData=2 grandparentPhase=1 recombination1=0 chromosome=1 > 0_male/order_0male_1.txt 
java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map3_3_js.txt data=data_f.call useKosambi=1 numMergeIterations=1 sexAveraged=1 outputPhasedData=2 grandparentPhase=1 recombination1=0 chromosome=2 > 0_male/order_0male_2.txt
java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map3_3_js.txt data=data_f.call useKosambi=1 numMergeIterations=1 sexAveraged=1 outputPhasedData=2 grandparentPhase=1 recombination1=0 chromosome=3 > 0_male/order_0male_3.txt
java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map3_3_js.txt data=data_f.call useKosambi=1 numMergeIterations=1 sexAveraged=1 outputPhasedData=2 grandparentPhase=1 recombination1=0 chromosome=4 > 0_male/order_0male_4.txt
java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map3_3_js.txt data=data_f.call useKosambi=1 numMergeIterations=1 sexAveraged=1 outputPhasedData=2 grandparentPhase=1 recombination1=0 chromosome=5 > 0_male/order_0male_5.txt
java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map3_3_js.txt data=data_f.call useKosambi=1 numMergeIterations=1 sexAveraged=1 outputPhasedData=2 grandparentPhase=1 recombination1=0 chromosome=6 > 0_male/order_0male_6.txt
java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map3_3_js.txt data=data_f.call useKosambi=1 numMergeIterations=1 sexAveraged=1 outputPhasedData=2 grandparentPhase=1 recombination1=0 chromosome=7 > 0_male/order_0male_7.txt
java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map3_3_js.txt data=data_f.call useKosambi=1 numMergeIterations=1 sexAveraged=1 outputPhasedData=2 grandparentPhase=1 recombination1=0 chromosome=8 > 0_male/order_0male_8.txt

# Converting marker numbers (1..N) back to genomic coordinates 
# make a list of the physical position of snps:
cut -f 1,2 data.call|awk '(NR>=7)' > snps.txt

# combine phsysical and genetic position of markers 
awk -vFS="\t" -vOFS="\t" '(NR==FNR){s[NR-1]=$0}(NR!=FNR){if ($1 in s) $1=s[$1];print}' /flash/EconomoU/Nurit/lepmap/lepmap_varroa/three_fam.Q40BIALLDP16HDP40mis.5Chr7/snps.txt order_0male.txt > zero_Rc_male/order_0male.mapped



# (2) no recombination in female
# assume no recombintaions in the females: 'recombination2=0'
java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map3_3_js.txt data=data_f.call useKosambi=1 numMergeIterations=1 sexAveraged=1 outputPhasedData=2 grandparentPhase=1 recombination2=0 chromosome=1 > zero_Rc_fem/order_0fem.txt 



awk -vFS="\t" -vOFS="\t" '(NR==FNR){s[NR-1]=$0}(NR!=FNR){if ($1 in s) $1=s[$1];print}' /flash/EconomoU/Nurit/lepmap/lepmap_varroa/three_fam.Q40BIALLDP16HDP40mis.5Chr7/snps.txt order_0female.txt > order_0female.mapped














####################
# per chromosome
# create a new directory 'chromo', 
mkdir chromo

#run the OrderMarkers2 per chromosome, from the upper dir
cd ..

java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map3_3_js.txt data=data_f.call useKosambi=1 numMergeIterations=1 sexAveraged=1 outputPhasedData=2 grandparentPhase=1 chromosome=1 >chromo/order_1.txt 
java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map3_3_js.txt data=data_f.call useKosambi=1 numMergeIterations=1 sexAveraged=1 outputPhasedData=2 grandparentPhase=1 chromosome=2 >chromo/order_2.txt 
java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map3_3_js.txt data=data_f.call useKosambi=1 numMergeIterations=1 sexAveraged=1 outputPhasedData=2 grandparentPhase=1 chromosome=3 >chromo/order_3.txt 
java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map3_3_js.txt data=data_f.call useKosambi=1 numMergeIterations=1 sexAveraged=1 outputPhasedData=2 grandparentPhase=1 chromosome=4 >chromo/order_4.txt 
java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map3_3_js.txt data=data_f.call useKosambi=1 numMergeIterations=1 sexAveraged=1 outputPhasedData=2 grandparentPhase=1 chromosome=5 >chromo/order_5.txt 
java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map3_3_js.txt data=data_f.call useKosambi=1 numMergeIterations=1 sexAveraged=1 outputPhasedData=2 grandparentPhase=1 chromosome=6 >chromo/order_6.txt 
java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map3_3_js.txt data=data_f.call useKosambi=1 numMergeIterations=1 sexAveraged=1 outputPhasedData=2 grandparentPhase=1 chromosome=7 >chromo/order_7.txt 
java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map3_3_js.txt data=data_f.call useKosambi=1 numMergeIterations=1 sexAveraged=1 outputPhasedData=2 grandparentPhase=1 chromosome=8 >chromo/order_8.txt 


# then convert all order files into outputs
awk -v fullData=1 -f /home/n/nurit-eliash/lepmap/bin/map2genotypes.awk order_1.txt > output_1.txt
awk -v fullData=1 -f /home/n/nurit-eliash/lepmap/bin/map2genotypes.awk order_2.txt > output_2.txt
awk -v fullData=1 -f /home/n/nurit-eliash/lepmap/bin/map2genotypes.awk order_3.txt > output_3.txt
awk -v fullData=1 -f /home/n/nurit-eliash/lepmap/bin/map2genotypes.awk order_4.txt > output_4.txt
awk -v fullData=1 -f /home/n/nurit-eliash/lepmap/bin/map2genotypes.awk order_5.txt > output_5.txt
awk -v fullData=1 -f /home/n/nurit-eliash/lepmap/bin/map2genotypes.awk order_6.txt > output_6.txt
awk -v fullData=1 -f /home/n/nurit-eliash/lepmap/bin/map2genotypes.awk order_7.txt > output_7.txt
awk -v fullData=1 -f /home/n/nurit-eliash/lepmap/bin/map2genotypes.awk order_8.txt > output_8.txt







###################
#################
# other options:


# achiasmatic meiosis (no recombination in male):
java -cp bin/ OrderMarkers2 map=map.txt data=data_f.call recombination1=0

#achiasmatic meiosis (no recombination in female):
java -cp bin/ OrderMarkers2 map=map.txt data=data_f.call recombination2=0

#It is typically more convinient to order each chromosome separately
java -cp bin/ OrderMarkers2 map=mapBig.txt data=dataBig.call chromosome=1 >order1.1.txt

java -cp bin/ OrderMarkers2 map=mapBig.txt data=dataBig.call chromosome=N >orderN.1.txt






#######
# 5/7/2022, OrderMarkers2_chro.slurm

#!/bin/bash
#SBATCH --job-name=OrderMarkers2
#SBATCH --partition=compute
#SBATCH --time=1-00:00:00
#SBATCH --mem=12G
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --mail-user=nurit.eliash@oist.jp
#SBATCH --mail-type=BEGIN,FAIL,END
#SBATCH --input=none
#SBATCH --output=OrderMarker_NoOption/out/%j.out

java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map1_3_js.txt data=data_f.call chromosome=1 > OrderMarker_NoOption/order1.1.txt

java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map1_3_js.txt data=data_f.call chromosome=2 > OrderMarker_NoOption/order1.2.txt

java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map1_3_js.txt data=data_f.call chromosome=3 > OrderMarker_NoOption/order1.3.txt

java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map1_3_js.txt data=data_f.call chromosome=4 > OrderMarker_NoOption/order1.4.txt

java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map1_3_js.txt data=data_f.call chromosome=5 > OrderMarker_NoOption/order1.5.txt

java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map1_3_js.txt data=data_f.call chromosome=6 > OrderMarker_NoOption/order1.6.txt

java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map1_3_js.txt data=data_f.call chromosome=7 > OrderMarker_NoOption/order1.7.txt

### WITH options.
# 5/7/2022. for some reason, the outputPhasedData=2 option doenst work.

#!/bin/bash
#SBATCH --job-name=OrderMarkers2
#SBATCH --partition=compute
#SBATCH --time=1-00:00:00
#SBATCH --mem=12G
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --mail-user=nurit.eliash@oist.jp
#SBATCH --mail-type=BEGIN,FAIL,END
#SBATCH --input=none
#SBATCH --output=OrderMarker_KosMrgI1sexAvgPhsGrP/out/%j.out

java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map1_3_js.txt data=data_f.call chromosome=1 useKosambi=1 numMergeIterations=1 sexAveraged=1 grandparentPhase=1 > OrderMarker_KosMrgI1sexAvgPhsGrP/order1.1.txt

java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map1_3_js.txt data=data_f.call chromosome=2 useKosambi=1 numMergeIterations=1 sexAveraged=1 grandparentPhase=1 > OrderMarker_KosMrgI1sexAvgPhsGrP/order1.2.txt

java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map1_3_js.txt data=data_f.call chromosome=3 useKosambi=1 numMergeIterations=1 sexAveraged=1 grandparentPhase=1 > OrderMarker_KosMrgI1sexAvgPhsGrP/order1.3.txt

java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map1_3_js.txt data=data_f.call chromosome=4 useKosambi=1 numMergeIterations=1 sexAveraged=1 grandparentPhase=1 > OrderMarker_KosMrgI1sexAvgPhsGrP/order1.4.txt

java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map1_3_js.txt data=data_f.call chromosome=5 useKosambi=1 numMergeIterations=1 sexAveraged=1 grandparentPhase=1 > OrderMarker_KosMrgI1sexAvgPhsGrP/order1.5.txt

java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map1_3_js.txt data=data_f.call chromosome=6 useKosambi=1 numMergeIterations=1 sexAveraged=1 grandparentPhase=1 > OrderMarker_KosMrgI1sexAvgPhsGrP/order1.6.txt

java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map1_3_js.txt data=data_f.call chromosome=7 useKosambi=1 numMergeIterations=1 sexAveraged=1 grandparentPhase=1 > OrderMarker_KosMrgI1sexAvgPhsGrP/order1.7.txt

# now convert the order.txt files into the output.txt file

awk -v fullData=1 -f /home/n/nurit-eliash/lepmap/bin/map2genotypes.awk order1.1.txt > output1.1.txt


