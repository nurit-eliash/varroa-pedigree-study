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


# prepare the VCF file for 3 families, and keep only SNPs by --remove indels:
VCF=/bucket/EconomoU/Nurit/vcftools/mrg_vcf/Q40BIALLDP16HDP40mis.5Chr7.Rm34Sites.recode.vcf

# prepare the pedigree.txt file:
# prepare manualy and save as .txt file.
pedigree.txt

# save the two files in the same directory, the working directory: /flash/EconomoU/Nurit/lepmap/lepmap_varroa
# redirect to the working directory
cd /flash/EconomoU/Nurit/lepmap/lepmap_varroa/

# run the first module:
##############################
##      * ParentCall2 *     ##
##############################
# The module ParentCall2 is used to call parental genotypes and markers.
VCF=/bucket/EconomoU/Nurit/vcftools/mrg_vcf/Q40BIALLDP16HDP40mis.5Chr7.Rm34Sites.recode.vcf

java -cp /home/n/nurit-eliash/lepmap/bin ParentCall2 vcfFile=/bucket/EconomoU/Nurit/vcftools/mrg_vcf/Q40BIALLDP16HDP40mis.5Chr7.Rm34Sites.recode.vcf data=pedigree.txt removeNonInformative=1 > data.call

##############################
##      ֿ * Filtering2 *     ##
##############################
java -cp /home/n/nurit-eliash/lepmap/bin Filtering2 data=data.call dataTolerance=0.01 removeNonInformative=1 outputHWE=1 MAFLimit=0.2  >data_f_maf0.2.call

##############################
## * SeparateChromosomes2 * ##
##############################
# The SeparateChromosomes2 module assigns markers into linkage groups (LGs) 
java -cp /home/n/nurit-eliash/lepmap/bin SeparateChromosomes2 data=data_f_maf0.2.call sizeLimit=3 lodLimit=4 > map3_4.txt

##############################
##   * JoinSingles2All *    ##
##############################
# join markers that were left over after seperating them into exsisting linkage groups
# define lodLimit one belowe the one in SeparateChromosomes2
java -cp /home/n/nurit-eliash/lepmap/bin JoinSingles2All map=map3_4.txt data=data_f_maf0.2.call iterate=1 lodLimit=3 > map3_4_js.txt

#The size distribution of linkage groups can be obtained like this:
cut -f 1 map4_14_js.txt|sort|uniq -c|sort -n

##############################
##     * OrderMarkers2 *    ##
##############################
# orders the markers within each LG by maximizing the likelihood of the data given the order. assume recombintaions in males anf females
java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map3_4_js.txt data=data_f_maf0.2.call useKosambi=1 numMergeIterations=100 sexAveraged=0 outputPhasedData=2 grandparentPhase=1 recombination1=0.01 recombination2=0.01 > order.txt

# Assume no recombinations in MALES
java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map3_4_js.txt data=data_f_maf0.2.call useKosambi=1 numMergeIterations=100 sexAveraged=0 outputPhasedData=2 grandparentPhase=1 recombination1=0 recombination2=0.01 > order_0male.txt

# Assume no recombinations in FEMALES
java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map3_4_js.txt data=data_f_maf0.2.call useKosambi=1 numMergeIterations=100 sexAveraged=0 outputPhasedData=2 grandparentPhase=1 recombination1=0.01 recombination2=0 > order_0fem.txt


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


##############################
##    * additional info *   ##
##############################

# Calculating Mendel error rates:
java -cp /home/n/nurit-eliash/lepmap/bin IBD 

zcat post_from_pipeline.gz|java IBD posteriorFile=-  parents=file:parents.txt >parenthood.txt


###############################################################
########                  *** E N D ***                ########                 
###############################################################



