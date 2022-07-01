# Linkage map using Lep-MAP3 

# i first try with one families

# 1. create vcf file of specific family
# the vcf 8 individuals of the selected family, and filtered for biallelic sites , quality of mininum 20, :

$ vcftools --vcf snponly_freebayes.vcf --keep 43f.txt --max-alleles 2 --minQ 20 --minDP 5 --max-missing 1 --maf 0.2 --chr NW_019211454.1 --chr NW_019211455.1 --chr NW_019211456.1 --chr NW_019211457.1 --chr NW_019211458.1 --chr NW_019211459.1 --chr NW_019211460.1 --recode --recode-INFO-all --out 43_Q20BIALLDP5mis1maf0.2chr7

#i think the problem with the parentcall is that i have differnt variants type, so i try to remove the indels 
$ vcftools --vcf snponly_freebayes.vcf --keep 43f.txt --max-alleles 2 --minQ 20 --minDP 5 --max-missing 1 --maf 0.2 --remove-indels --chr NW_019211454.1 --chr NW_019211455.1 --chr NW_019211456.1 --chr NW_019211457.1 --chr NW_019211458.1 --chr NW_019211459.1 --chr NW_019211460.1 --recode --recode-INFO-all --out 43_Q20BIALLDP5mis1maf0.2NoIndelsChr7

vcftools --vcf snponly_freebayes.vcf --keep 177f.txt --max-alleles 2 --minQ 20 --minDP 5 --max-missing 1 --maf 0.2 --remove-indels --chr NW_019211454.1 --chr NW_019211455.1 --chr NW_019211456.1 --chr NW_019211457.1 --chr NW_019211458.1 --chr NW_019211459.1 --chr NW_019211460.1 --recode --recode-INFO-all --out 177_Q20BIALLDP5mis1maf0.2NoIndelsChr7

$ vcftools --vcf snponly_freebayes.vcf --keep 63f.txt --max-alleles 2 --minQ 20 --minDP 5 --max-missing 1 --maf 0.2 --chr NW_019211454.1 --chr NW_019211455.1 --chr NW_019211456.1 --chr NW_019211457.1 --chr NW_019211458.1 --chr NW_019211459.1 --chr NW_019211460.1 --recode --recode-INFO-all --out 63_Q20BIALLDP5mis1maf0.2chr7

#i will try with a different famly - 63:
$ vcftools --vcf snponly_freebayes.vcf --keep 63f.txt --max-alleles 2 --minQ 20 --minDP 5 --max-missing 1 --maf 0.2 --remove-indels --chr NW_019211454.1 --chr NW_019211455.1 --chr NW_019211456.1 --chr NW_019211457.1 --chr NW_019211458.1 --chr NW_019211459.1 --chr NW_019211460.1 --recode --recode-INFO-all --out 63_Q20BIALLDP5mis1maf0.2NoIndelsChr7

# 2. i created the 'pedigree.txt' file: '.txt' 

now we are ready:)

###############
# ParentCall2 #
###############

#The parental genotypes are called using the ParentCall2 module: before you run it to creat a 'p.call' output, just check the txt file is ok

$ java -cp /home/n/nurit-eliash/lepmap/bin ParentCall2 data = 43_ped.txt 

# if verything looks fine, then run it (sbatch ParentCall2.slurm):
# before the module, specify the whole path where Lep-MAP3 is located on your computer.

$ java -cp /home/n/nurit-eliash/lepmap/bin ParentCall2 data = 43_ped.txt vcfFile = 43_Q20BIALLDP5mis1maf0.2NoIndelsChr7.recode.vcf > 43fam.call

#try to add XLimit=2 to the paerntcall module:
#$ java -cp /home/n/nurit-eliash/lepmap/bin ParentCall2 data = 43_ped.txt XLimit=2 vcfFile = 43_Q20BIALL.recode.vcf > 43fam_hap.call

# i also tried to remove non-informatives, but i think i will drop it meanwhile
#java -cp /home/n/nurit-eliash/lepmap/bin ParentCall2 data = 43_ped.txt XLimit=2 vcfFile = 43_Q20BIALL.recode.vcf removeNonInformative=1 > 43fam_XL_NI.call  

how do i know its ok?
- see whether it recodes males to haploid genotypes
If it does the system is working correctly
 - it doesnt
 
##############
# Filtering2 #
##############
$ java -cp /home/n/nurit-eliash/lepmap/bin Filtering2 data=43fam.call >43fam_f.call

########################
# SeparateChromosomes2 #
########################

#The SeparateChromosomes2 module assigns markers into linkage groups (LGs) by computing all pair-wise LOD scores between markers and joins markers that with LOD score higher than a user given parameter lodLimit. The output is a map file where line i (not commented by #) corresponds to marker i and gives its LG name (number).

$ java -cp /home/n/nurit-eliash/lepmap/bin SeparateChromosomes2 data=43fam_f.call lodLimit=5 > map43.txt


it doesnt work - the txt file is empty