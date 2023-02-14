##########################################
## Format genotype directly on VCF file ##
##########################################

# replace the genotype of the 3 samples to an artificial ones, based on the informative cross:

# Columns of samples to be replaced:
#F1_fem  = 16
#F1_male = 80
#F0 = 53

# Lines of sites to be replaced: (all sites)
# 1488 - 15138


# Genotypes for cross 0/0 x 0/1:
#F1_fem = 0/1:22:10,12:10:353:12:444:-33.6837,0,-25.484
#F1_male = 0/0:17:17,0:17:565:0:0:0,-5.11751,-51.1547
#F0 = 0/0:17:17,0:17:565:0:0:0,-5.11751,-51.1547

# codes seperated for each sample:
awk 'BEGIN { OFS="\t" } NR>=1488{$16="0/1:22:10,12:10:353:12:444:-33.6837,0,-25.484"};1' original.vcf > new.vcf
awk 'BEGIN { OFS="\t" } NR>=1488{$80="0/0:17:17,0:17:565:0:0:0,-5.11751,-51.1547"};1' new_00.vcf > new_00.vcf
awk 'BEGIN { OFS="\t" } NR>=1488{$53="0/0:17:17,0:17:565:0:0:0,-5.11751,-51.1547"};1' new_00.vcf > new_00.vcf

# in one line code: 
awk 'BEGIN { OFS="\t" } NR>=1488{$16="0/1:22:10,12:10:353:12:444:-33.6837,0,-25.484"};1' Q40BIALLDP16HDP40mis.5Chr7.Sites_00_01.recode.vcf | awk 'BEGIN { OFS="\t" }  NR>=1488{$80="0/0:17:17,0:17:565:0:0:0,-5.11751,-51.1547"};1' | awk 'BEGIN { OFS="\t" }  NR>=1488{$53="0/0:17:17,0:17:565:0:0:0,-5.11751,-51.1547"};1' > Sites_00_01.vcf


# Genotypes for cross 1/1 x 0/1:
#F1_fem  = 0/1:22:10,12:10:353:12:444:-33.6837,0,-25.484
#F1_male = 1/1:17:0,17:0:0:17:629:-56.9466,-5.11751,0
#F0 = 1/1:17:0,17:0:0:17:629:-56.9466,-5.11751,0

awk 'BEGIN { OFS="\t" } NR>=1488{$16="0/1:22:10,12:10:353:12:444:-33.6837,0,-25.484"};1' Q40BIALLDP16HDP40mis.5Chr7.Sites_11_01.recode.vcf | awk 'BEGIN { OFS="\t" } NR>=1488{$80="1/1:17:0,17:0:0:17:629:-56.9466,-5.11751,0"};1' | awk 'BEGIN { OFS="\t" } NR>=1488{$53="1/1:17:0,17:0:0:17:629:-56.9466,-5.11751,0"};1' > Sites_11_01.vcf

# Check:

# take a look on the replaced lines:
# print column 16, from line 1487 till the end
awk 'NR>=1487{print $16}' new.vcf
