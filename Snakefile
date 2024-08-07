####################################################
#####        VARROA SNAKEMAKE PIPELINE         #####
#####   Estimating Varroa recombination rate   #####
#####   Nurit Eliash and Alexander Mikheyev    #####
####################################################

from scripts.split_fasta_regions import split_fasta
from snakemake.utils import R
import getpass

localrules: getHaps, all

### SET DIRECTORY PATHS FOR REFERENCE AND OUTPUT DATA
READDir = "/bucket/EconomoU/Nurit/mrg_linakge_map/reads"
OUTDir = "/flash/EconomoU/Nurit/linkage_map_work/data"
REFDir = "/flash/EconomoU/Nurit/ref2020" 
#SCRATCH  = "/flash/EconomoU/Nurit/linkage_map_work/scratch"

### PATHS FOR VARROA DESTRUCTOR GENOME AND REGIONS SPLIT
VDESRef = REFDir + "/destructor/vdes_3_refseq.fasta"
#VDESBowtieIndex = REFDir + "/destructor/vdes_3_refseq"
#VDESmtDNA = REFDir + "/destructor/mtDNA/NC_004454.fasta"

SPLITS = range(300)
REGIONS = split_fasta(VDESRef, len(SPLITS))  # dictionary with regions to be called, with keys in SPLITS
for region in REGIONS:
        for idx,i in enumerate(REGIONS[region]):
                REGIONS[region][idx] = " -r " + str(i)

### SAMPLES LIST AND OTHER PARAMETERS
SAMPLES, = glob_wildcards(READDir + "/{sample}_R1_001.fastq.gz")

Q = (20, 40) # 99 and 99.99% mapping accuracy
CHROMOSOMES = ["NW_019211454.1", "NW_019211455.1", "NW_019211456.1", "NW_019211457.1", "NW_019211458.1", "NW_019211459.1", "NW_019211460.1"]

##############################################
#####   TARGET PSEUDO-RULES DEFINITION  ######
##############################################

rule all:
	input: 	expand(OUTDir + "/alignments/ngm/{sample}.bam", sample = SAMPLES),
		expand(OUTDir + "/meta/{sample}.txt", sample = SAMPLES),
		OUTDir + "/var/ngm/freebayes_filtered"


###############################################
#####   READS MAPPING AND QUALITY CHECK   #####
###############################################

rule nextgenmap:
	input:
		read1 = READDir + "/{sample}_R1_001.fastq.gz",
		read2 = READDir + "/{sample}_R2_001.fastq.gz",
	threads: 6
	output: 
		alignment = temp(OUTDir + "/alignments/ngm/{sample}.bam"), 
		index = temp(OUTDir + "/alignments/ngm/{sample}.bam.bai")
	shell:
                """
		echo "___ngm___" 
        ngm -t {threads} --qry1 {input.read1} --qry2 {input.read2} --paired -r {VDESRef} --local --very-sensitive --rg-id {wildcards.sample} --rg-sm {wildcards.sample} --rg-pl ILLUMINA --rg-lb NEXTERA --rg-cn OIST | samtools view -Su - | samtools sort - -m 20G -T {SCRATCH}/ngm/{wildcards.sample} -o - | samtools rmdup - - | variant - -m 400 --bam -o {output.alignment}
		samtools index {output.alignment}	
		"""


rule statsbam:
        input:
                alignment = OUTDir + "/alignments/ngm/{sample}.bam"
        output:
                temp(OUTDir + "/meta/{sample}.txt")
        shell:
                """
		echo {wildcards.sample} > {output}
		samtools depth -a {input.alignment} | awk '{{sum+=$3}} END {{ print "Mean Average Coverage on all sites = ",sum/NR}}' >> {output}
		samtools depth -a -r NW_019211454.1 -r NW_019211455.1 -r NW_019211456.1 -r NW_019211457.1 -r NW_019211458.1 -r NW_019211459.1 -r NW_019211460.1 {input.alignment} | awk '{{sum+=$3}} END {{ print "Mean Average Coverage on 7 chromosomes = ",sum/NR}}' >> {output}
		samtools depth -a -r NC_004454.2 {input.alignment} | awk '{{sum+=$3}} END {{ print "Mean Average Coverage mtDNA = ",sum/NR}}' >> {output}
		samtools flagstat {input.alignment} >> {output}
		"""


############################################
#####   VARIANT SITES CALL AND FILTER  #####
############################################

rule freebayes:
        input:
                expand(OUTDir + "/alignments/ngm/{sample}.bam", sample = SAMPLES)
        output:
                temp(OUTDir + "/var/ngm/snponly_split/freebayes.{region}.vcf")
        params:
                span = lambda wildcards: REGIONS[wildcards.region],
                bams = lambda wildcards, input: os.path.dirname(input[0]) + "/*.bam",
                filtering = "--min-alternate-count 5 --min-alternate-fraction 0.2 --min-mapping-quality 8 --min-base-quality 5 --use-best-n-alleles 4"
        shell:
                """
		freebayes {params.filtering} --fasta-reference {VDESRef} {params.span} {params.bams} > {output}
                """

rule merge_vcf:
        input:
                expand(OUTDir + "/var/ngm/snponly_split/freebayes.{region}.vcf", region = REGIONS)
        output:
                temp(OUTDir + "/var/ngm/snponly_freebayes.vcf")
        shell:
                """
                (grep "^#" {input[0]} ; cat {input} | grep -v "^#" ) | vcfuniq  > {output}
                """
                
rule filter_vcf:
        input:
                vcf = OUTDir + "/var/ngm/snponly_freebayes.vcf"
        output:
                temp(OUTDir + "/var/ngm/freebayes_filtered")
        params:
                span = "--chr NW_019211454.1 --chr NW_019211455.1 --chr NW_019211456.1 --chr NW_019211457.1 --chr NW_019211458.1 --chr NW_019211459.1 --chr NW_019211460.1",
                filters = "--max-alleles 2 --minQ 40 --minDP 16 --maxDP 40 --max-missing 0.5 --maf 0.2"
        shell:
                """
                vcftools --vcf {input.vcf} {params.span} {params.filters} --recode --recode-INFO-all --out {output}
                """                