# STAARpipeline-Tutorial
This is a tutorial for performing association analysis of whole-genome/whole-exome sequencing (WGS/WES) studies, summarizing and visualization results using **STAARpipeline** and **STAARpipelineSummary**. The software prerequisites, dependencies and installation can be found in <a href="https://github.com/xihaoli/STAARpipeline">**STAARpipeline**</a> and <a href="https://github.com/xihaoli/STAARpipelineSummary">**STAARpipelineSummary**</a> packages.
## Pre-step of association analysis using STAARpipeline 
### Generate Genomic Data Structure (GDS) file
R/Bioconductor package **SeqArray** provides functions to convert the genotype data to GDS format. 
For more details, please see the R/Bioconductor package <a href="https://bioconductor.org/packages/release/bioc/html/SeqArray.html">**SeqArray**</a>.

### Generate annotated GDS (aGDS) file using FAVORannotator
#### Prerequisites:
**FAVORannotator** (CSV version) depends on the **xsv software** and the **FAVOR database** in CSV format. Please install the <a href="https://github.com/BurntSushi/xsv">**xsv software**</a> and 
download the <a href="http://favor.genohub.org">**FAVOR database** CSV files</a> (under the "FAVORannotator" tab) before using **FAVORannotator** (CSV version).
#### Step 1: Generate the variants list to be annotated. 
##### Script: <a href="FAVORannotator_csv/Varinfo_gds.R">**Varinfo_gds.R**</a>
##### Input: GDS files of each chromosome and the FAVOR database information <a href="FAVORannotator_csv/FAVORdatabase_chrsplit.csv">**FAVORdatabase_chrsplit.csv**</a>. For more details, please see the R script.
##### Output: CSV files of the variants list. For each chromosome, the number of CSV files is listed in <a href="FAVORannotator_csv/FAVORdatabase_chrsplit.csv">**FAVORdatabase_chrsplit.csv**</a>.

#### Step 2: Annotate the variants using the FAVOR database through xsv software.
##### Script: <a href="FAVORannotator_csv/Annotate.R">**Annotate.R**</a> 
##### Input: CSV files of the variants list to be annotated, the FAVOR database information <a href="FAVORannotator_csv/FAVORdatabase_chrsplit.csv">**FAVORdatabase_chrsplit.csv**</a>,
the FAVOR database, and the directory xsv software. For more details, please see the R script.
##### Output: CSV files of the annotated variants list. 
* `Anno_chrXX.csv`: a csv file containing annotated variants list of chromosome XX. <br>
* `Anno_chrXX_STAARpipeline.csv`: a csv file containing the variants list with annotations required for STAARpipeline of chromosome XX. 
The annotations in this file is a subset of `Anno_chrXX.csv`. <br>

#### Step 3: Generate the annotated GDS (aGDS) file.
##### Script: <a href="FAVORannotator_csv/gds2agds.R">**gds2agds.R**</a> 
##### Input: GDS files and the csv files of annotated variants list (`Anno_chrXX.csv` or `Anno_chrXX_STAARpipeline.csv`). For more details, please see the R script.
##### Output: aGDS files including both the genotype and annotation information. 

Note: FAVORannotator also supports the database in SQL format. Please see the <a href="https://github.com/zhouhufeng/FAVORannotator">**FAVORannotator** tutorial</a> for detailed
usage of **FAVORannotator** (SQL version).

## Association analysis using STAARpipeline
### Step 0: Preparation for association analysis of whole-genome/whole-exome sequencing studies
#### Script: <a href="Association_Analysis_PreStep.r">**Association_Analysis_PreStep.r**</a>
#### Input: aGDS files of all 22 chromosomes. For more details, please see the R script.
#### Output: `agds_dir.Rdata`, `Annotation_name_catalog.Rdata`, `jobs_num.Rdata`.
* `agds_dir.Rdata`: a vector containing directory of GDS/aGDS files of all chromosomes. <br>
* `Annotation_name_catalog.Rdata`: a data frame containing the annotation name and the corresponding channel name in the aGDS file. Alternatively, one can skip this part in the R script by providing `Annotation_name_catalog.csv` with the same information. An example of `Annotation_name_catalog.csv` can be found <a href="https://github.com/xihaoli/STAARpipeline-Tutorial/blob/main/FAVORannotator_csv/Annotation_name_catalog.csv">here</a>. <br>
* `jobs_num.Rdata`: a data frame containing the number of jobs for association analysis, including individual analysis, sliding window analysis and dynamic window analysis. 

### Step 1: Fit STAAR null model
#### Script: <a href="STAARpipeline_Null_Model.r">**STAARpipeline_Null_Model.r**</a> or <a href="STAARpipeline_Null_Model_GENESIS.r">**STAARpipeline_Null_Model_GENESIS.r**</a>
* `STAARpipeline_Null_Model.r` fits the STAAR null model using the STAARpipeline package. <br>
* `STAARpipeline_Null_Model_GENESIS.r` fits the null model using the GENESIS package and convert it to STAAR null model using the STAARpipeline package.
#### Input: Phenotype data and (sparse) genetic relatedness matrix. For more details, please see the R scripts.
#### Output: a Rdata file of the STAAR null model.

### Step 2: Individual analysis
#### Script: <a href="STAARpipeline_Individual_Analysis.r">**STAARpipeline_Individual_Analysis.r**</a>
Perform single variant analysis for common and low-frequency variants across the genome using the STAARpipeline package. 
#### Input: aGDS files and the STAAR null model. For more details, please see the R script.
#### Output: Rdata files with the user-defined names.
The number of output files is the summation of the column "individual_analysis_num" for the object in `jobs_num.Rdata`.

### Step 3.1: Gene-centric coding analysis
#### Script: <a href="STAARpipeline_Gene_Centric_Coding.r">**STAARpipeline_Gene_Centric_Coding.r**</a> and <a href="STAARpipeline_Gene_Centric_Coding_Long_Masks.r">**STAARpipeline_Gene_Centric_Coding_Long_Masks.r**</a>
Perform gene-centric analysis for coding rare variants using the STAARpipeline package. The gene-centric coding analysis provides five genetic categories to aggregate coding rare variants of each protein-coding gene: (1) putative loss of function (stop gain, stop loss and splice) RVs, (2) missense RVs, (3) disruptive missense RVs, (4) putative loss of function and disruptive missense RVs, and (5) synonymous RVs.  <br>
* `STAARpipeline_Gene_Centric_Coding.r` performs gene-centric coding analysis for all protein-coding genes across the genome. There are 379 jobs using this script.   <br>
* `STAARpipeline_Gene_Centric_Coding_Long_Masks.r` performs gene-centric coding analysis for some specific long masks, and might require much larger memory compared to `STAARpipeline_Gene_Centric_Coding.r`. There are 2 jobs using this script.
#### Input: aGDS files and the STAAR null model. For more details, please see the R scripts.
#### Output: 381 Rdata files with the user-defined names. For more details, please see the R scripts.

### Step 3.2: Gene-centric noncoding analysis
#### Script: <a href="STAARpipeline_Gene_Centric_Noncoding.r">**STAARpipeline_Gene_Centric_Noncoding.r**</a>, <a href="STAARpipeline_Gene_Centric_Noncoding_Long_Masks.r">**STAARpipeline_Gene_Centric_Noncoding_Long_Masks.r**</a>, <a href="STAARpipeline_Gene_Centric_ncRNA.r">**STAARpipeline_Gene_Centric_ncRNA.r**</a> and <a href="STAARpipeline_Gene_Centric_ncRNA_Long_Masks.r">**STAARpipeline_Gene_Centric_ncRNA_Long_Masks.r**</a>
Perform gene-centric analysis for noncoding rare variants using the STAARpipeline package. The gene-centric noncoidng analysis provides eight genetic categories of regulatory regions to aggregate noncoding rare variants: (1) promoter RVs overlaid with CAGE sites, (2) promoter RVs overlaid with DHS sites, (3) enhancer RVs overlaid with CAGE sites, (4) enhancer RVs overlaid with DHS sites, (5) untranslated region (UTR) RVs, (6) upstream region RVs, (7) downstream region RVs and (8) noncoding RNA (ncRNA) RVs.   <br>
* `STAARpipeline_Gene_Centric_Noncoding.r` performs gene-centric noncoding analysis for all protein-coding genes across the genome. There are 379 jobs using this script.   <br>
* `STAARpipeline_Gene_Centric_Noncoding_Long_Masks.r` performs gene-centric noncoding analysis for some specific long masks, and might require much larger memory compared to `STAARpipeline_Gene_Centric_Noncoding.r`. There are 8 jobs using this script.  <br>
* `STAARpipeline_Gene_Centric_ncRNA.r` performs gene-centric noncoding analysis for ncRNA genes across the genome. There are 222 jobs using this script.   <br> 
* `STAARpipeline_Gene_Centric_ncRNA_Long_Masks.r` performs gene-centric noncoding analysis for some specific long masks, and might require much larger memory compared to `STAARpipeline_Gene_Centric_ncRNA.r`. There is 1 job using this script. 
#### Input: aGDS files and the STAAR null model. For more details, please see the R scripts.
#### Output: 387 Rdata files with the user-defined names for protein-coding genes and 223 Rdata files with the user-defined names for ncRNA genes. For more details, please see the R scripts.

### Step 4: Sliding window analysis
#### Script: <a href="STAARpipeline_Sliding_Window.r">**STAARpipeline_Sliding_Window.r**</a>
Perform sliding window analysis using the STAARpipeline package.
#### Input: aGDS files and the STAAR null model. For more details, please see the R script.
#### Output: Rdata files with the user-defined names.
The number of output files is the summation of the column "sliding_window_num" for the object in `jobs_num.Rdata`. 

### Step 5.0: Obtain SCANG-STAAR null model
#### Script: <a href="STAARpipeline_STAAR2SCANG.r">**STAARpipeline_STAAR2SCANG.r**</a>
Generate the SCANG-STAAR null model using the STAAR null model. 
#### Input: STAAR null model. For more details, please see the R script.
#### Output: a Rdata file of the SCANG-STAAR null model.

### Step 5: Dynamic window analysis using SCANG-STAAR
#### Script: <a href="STAARpipeline_Dynamic_Window.r">**STAARpipeline_Dynamic_Window.r**</a>
Perform dynamic window analysis using the STAARpipeline package. 
#### Input: SCANG-STAAR null model. For more details, please see the R script.
#### Output: Rdata files with the user-defined names.
The number of output files is the summation of the column "scang_num" for the object in `jobs_num.Rdata`. 

## Summarization and visualization of association analysis results using STAARpipelineSummary
### Step 0: Select independent variants from a known variants list to be used in conditional analysis
#### Script: <a href="STAARpipelineSummary_Known_Loci_Pruning.r">**STAARpipelineSummary_Known_Loci_Pruning.r**</a> 
Perform stepwise selection to select the subset of independent variants from a known variants list to be used in the conditional analysis. 
#### Input: aGDS files, a list of known variants (CHR, POS, REF and ALT) and STAAR null model.
<a href="STAARpipelineSummary_Known_Loci_Info.r">**STAARpipelineSummary_Known_Loci_Info.r**</a> extracts the information of CHR, POS, REF and ALT from #rs. For more details, please see the R script.
#### Output: a Rdata file containing a list of independent variants to be used in conditional analysis.
<a href="STAARpipelineSummary_Known_Loci_Pruning_Combination.r">**STAARpipelineSummary_Known_Loci_Pruning_Combination.r**</a> combines chromosome-wide results into genome-wide. <br>

Note: <a href="STAARpipelineSummary_Known_Loci_Individual_Analysis_Pruning.r">**STAARpipelineSummary_Known_Loci_Individual_Analysis_Pruning.r**</a> and <a href="STAARpipelineSummary_Known_Loci_Individual_Analysis_Pruning_Combination.r">**STAARpipelineSummary_Known_Loci_Individual_Analysis_Pruning_Combination.r**</a> show an example to select independent variants from both the known variants in literature and significant single variants detected in individual analysis, which can be used for variant-set conditional analysis.  

### Step 1: Summarize individual analysis results
#### Script: <a href="STAARpipelineSummary_Individual_Analysis.r">**STAARpipelineSummary_Individual_Analysis.r**</a> 
Summarize individual-variant analysis results and perform conditional analysis of unconditional significant variants by adjusting a list of known variants.
#### Input: aGDS files, individual analysis results generated by STAARpipeline, STAAR null model and a list of known variants. For more details, please see the R script.
#### Output: The summary includes the Manhattan plot, Q-Q plot, and conditional p-values of unconditional significant variants.

### Step 2.1: Summarize gene-centric coding analysis results
#### Script: <a href="STAARpipelineSummary_Gene_Centric_Coding.r">**STAARpipelineSummary_Gene_Centric_Coding.r**</a> 
Summarize gene-centric coding analysis results and perform conditional analysis of unconditional significant coding masks by adjusting a list of known variants.
#### Input: aGDS files, gene-centric coding analysis results generated by STAARpipeline, STAAR null model and a list of known variants. For more details, please see the R script.
#### Output: The summary includes the Manhattan plot, Q-Q plot, and conditional p-values of unconditional significant coding masks.

### Step 2.2: Summarize gene-centric noncoding analysis results
#### Script: <a href="STAARpipelineSummary_Gene_Centric_Noncoding.r">**STAARpipelineSummary_Gene_Centric_Noncoding.r**</a> 
Summarize gene-centric noncoding analysis results and perform conditional analysis of unconditional significant noncoding masks by adjusting a list of known variants.
#### Input: aGDS files, gene-centric noncoding analysis results generated by STAARpipeline, STAAR null model and a list of known variants. For more details, please see the R script.
#### Output: The summary includes the Manhattan plot, Q-Q plot, and conditional p-values of unconditional significant noncoding masks.

### Step 3: Summarize sliding window analysis results
#### Script: <a href="STAARpipelineSummary_Sliding_Window_Summary.r">**STAARpipelineSummary_Sliding_Window_Summary.r**</a> 
Summarize sliding window analysis results and perform conditional analysis of unconditional significant genetic regions by adjusting a list of known variants.
#### Input: aGDS files, sliding window analysis results generated by STAARpipeline, STAAR null model and a list of known variants. For details, see the R scripts. 
#### Output: The summary includes the Manhattan plot, Q-Q plot, and conditional p-values of unconditional significant sliding windows.

### Step 4: Summarize dynamic window analysis results
#### Script: <a href="STAARpipelineSummary_Dynamic_Window.r">**STAARpipelineSummary_Dynamic_Window.r**</a> 
Summarize dynamic window analysis results and perform conditional analysis of unconditional significant genetic regions by adjusting a list of known variants.
#### Input: aGDS files, dynamic window analysis results generated by STAARpipeline, STAAR null model and a list of known variants. For more details, please see the R script.
#### Output: The summary includes the Manhattan plot, Q-Q plot, and conditional p-values of unconditional significant dynamic windows.

### Step 5.1: Functionally annotate a list of variants
#### Script: <a href="STAARpipelineSummary_Individual_Analysis_Annotation.r">**STAARpipelineSummary_Individual_Analysis_Annotation.r**</a> 
Functionally annotate a list of variants.
#### Input: aGDS files and a list of variants.
The list of variants could be the individual analysis results generated by STAARpipelineSummary.
#### Output: a Rdata file containing the input variants together with the corresponding functional annotations.

### Step 5.2: Functionally annotate rare variants in coding masks
#### Script: <a href="STAARpipelineSummary_Gene_Centric_Coding_Annotation.r">**STAARpipelineSummary_Gene_Centric_Coding_Annotation.r**</a> 
Functionally annotate rare variants of each of the input coding masks.
#### Input: aGDS files and coding masks (chr, gene name and functional category).
#### Output: For each input coding mask, the script outputs a Rdata file containing the rare variants and the corresponding functional annotations.

### Step 5.3: Functionally annotate rare variants in noncoding masks
#### Script: <a href="STAARpipelineSummary_Gene_Centric_Noncoding_Annotation.r">**STAARpipelineSummary_Gene_Centric_Noncoding_Annotation.r**</a> 
Functionally annotate rare variants of each of the input noncoding masks.
#### Input: aGDS files and noncoding masks (chr, gene name and functional category).
#### Output: For each input noncoding mask, the script outputs a Rdata file containing the rare variants and the corresponding functional annotations.

### Step 5.4: Functionally annotate rare variants in genetic regions
#### Script: <a href="STAARpipelineSummary_Genetic_Region_Annotation.r">**STAARpipelineSummary_Genetic_Region_Annotation.r**</a> 
Functionally annotate rare variants of each of the input genetic regions.
#### Input: aGDS files and noncoding masks (chr, start position and end position).
#### Output: For each input genetic region, the script outputs a Rdata file containing the rare variants and the corresponding functional annotations.

### An example of batch job submission scripts for these analyses can be found <a href="/batch jobs">**here**</a>.

