# Varroa-pedigree-study
## Nurit Eliash, Nurit Eliash, Xia Hua, Endo Tetsuya, J. Spencer Johnston, Maeva A. Techer, Valerie R. Holmes, Juliana Rangel, Huoqing Zheng, Evan P. Economo and Alexander S. Mikheyev 

*Corresponding author: Nurit Eliash, nurite@gri.org.il
### DOI: https://doi.org/10.1101/2024.05.10.593493

### Supplementary material that includes code, original figures and tables can be found [here](https://rpubs.com/Nurit_Eliash/1288713).

### Abstract
This project aims to investigate <i>Varroa destructor</i> mode of genetic inheritance. 
For that, we constructed a three-generation pedigree of the varroa mite's genome.
We used genomes of 223 varroa mite samples, belonging to 30 families, obtained from three honey bee colonies (<i> Apis mellifera</i> ).
Each mite family consists of 3 generations, and contains at least:
- Foundress female mite (F0)
- Son and daughter (F1)
- At least one adult grandchild, male/female (F2) 

A small family of mites, from left to right: daughter's molt, daughter (immobile), foundress mother (marked in pink), and the son. ![](pictures/family1.jpg)

All mites were collected from the experimental apiary of OIST (Okinawa Institute of Science and Technology), between July and October 2020. For a detailed description, please see the Method section in the paper.  

## Available data
### Varroa genome sequences 
The repository contains all that is required for you to re-run the analysis.
However, the original input fastaq files and reference genome are too large to be uploaded to the Github repository, therefore, prior to running the pipeline you need to download them to your cluster/computer. 
1. Varroa reference genome, [GCF_002443255.1 Vdes_3.0](https://www.ncbi.nlm.nih.gov/genome/?term=txid109461%5Borgn%5D), by [Techer et al. 2000](https://www.nature.com/articles/s42003-019-0606-0).
2. Varroa families whole-genome sequences, raw fastq reads [BioProject PRJNA794941](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA794941/).  

### Codes
1. Genomics analysis workflow from raw reads (fastg.gz files) down to the VCF is summarized into a Snakemake pipeline. The pipeline steps are available in the `Snakefile` file, along with the parameters file `cluster.json` and launcher `snakemake.slurm`. The final VFC output is later used as input for the linkage map.
2. All scripts called in `Snakefile` are present in the `scripts` folder.
3. R markdown can be found in the `R_data` folder.
