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
------

# prepare the pedigree.txt file:
-------


***************
להמשיך מכאן ביום שני 
4.7.2022
****************

# run the first module, *ParentCall2*
# The module ParentCall2 is used to call (possible missing or erroneous) parental genotypes and markers on sex chromosomes (XY or ZW system, assumes known offspring sex). Grandparents and half-sib familes are also supported (especially the grandparents should be provided if there is data on them).

java -cp /home/n/nurit-eliash/lepmap/bin ParentCall2 data=data1.1.txt posteriorFile=data1.1.post removeNonInformative=1 >data.call

java -cp /home/n/nurit-eliash/lepmap/bin Filtering2 data=data1.call dataTolerance=0.001 >data_f.call

# 
java -cp /home/n/nurit-eliash/lepmap/bin SeparateChromosomes2 data=data_f.call lodLimit=5 >map5.txt

java -cp /home/n/nurit-eliash/lepmap/bin JoinSingles2All map=map5.txt data=data_f.call lodLimit=4 >map5_js.txt

#The size distribution of linkage groups can be obtained like this:
cut -f 1 map5_js.txt|sort|uniq -c|sort -n

java -cp /home/n/nurit-eliash/lepmap/bin OrderMarkers2 map=map5_js.txt data=data_f.call chromosome=1 >order1.txt

# achiasmatic meiosis (no recombination in male):
java -cp bin/ OrderMarkers2 map=map.txt data=data_f.call recombination1=0

#achiasmatic meiosis (no recombination in female):
java -cp bin/ OrderMarkers2 map=map.txt data=data_f.call recombination2=0

#It is typically more convinient to order each chromosome separately
java -cp bin/ OrderMarkers2 map=mapBig.txt data=dataBig.call chromosome=1 >order1.1.txt

java -cp bin/ OrderMarkers2 map=mapBig.txt data=dataBig.call chromosome=N >orderN.1.txt

