#####################################################################
# Gene-centric analysis for noncoding rare variants of ncRNA
# genes using STAARpipeline
# Xihao Li, Zilin Li
# 11/04/2021
#####################################################################

rm(list=ls())
gc()

### load required package
library(gdsfmt)
library(SeqArray)
library(SeqVarTools)
library(STAAR)
library(STAARpipeline)

###########################################################
#           User Input
###########################################################
## job nums
jobs_num <- get(load("/n/holystore01/LABS/xlin/Lab/xihao_zilin/TOPMed_LDL/jobs_num.Rdata"))
## agds dir
agds_dir <- get(load("/n/holystore01/LABS/xlin/Lab/xihao_zilin/TOPMed_LDL/agds_dir.Rdata"))
## Null Model
obj_nullmodel <- get(load("/n/holystore01/LABS/xlin/Lab/xihao_zilin/TOPMed_LDL/obj.GENESIS.STAAR.LDL.fulladj.group.size.30.20210915.Rdata"))

## QC_label
QC_label <- "annotation/filter"
## variant_type
variant_type <- "SNV"
## geno_missing_imputation
geno_missing_imputation <- "mean"

## Annotation_dir
Annotation_dir <- "annotation/info/TOPMedAnnotation"
## Annotation channel
Annotation_name_catalog <- get(load("/n/holystore01/LABS/xlin/Lab/xihao_zilin/TOPMed_LDL/Annotation_name_catalog.Rdata"))
## Use_annotation_weights
Use_annotation_weights <- TRUE
## Annotation name
Annotation_name <- c("CADD","LINSIGHT","FATHMM.XF","aPC.EpigeneticActive","aPC.EpigeneticRepressed","aPC.EpigeneticTranscription",
					"aPC.Conservation","aPC.LocalDiversity","aPC.Mappability","aPC.TF","aPC.Protein","aPC.Liver")

## output path
output_path <- "/n/holystore01/LABS/xlin/Lab/xihao_zilin/TOPMed_LDL/ncRNA/Results/"
## output file name
output_file_name <- "TOPMed_F5_LDL_ncRNA"
## input array id from batch file (Harvard FAS cluster)
arrayid <- as.numeric(commandArgs(TRUE)[1])

###########################################################
#           Main Function 
###########################################################
## gene number in job
gene_num_in_array <- 100 
group.num.allchr <- ceiling(table(ncRNA_gene[,1])/gene_num_in_array)
sum(group.num.allchr)

chr <- which.max(arrayid <= cumsum(group.num.allchr))
group.num <- group.num.allchr[chr]

if (chr == 1){
   groupid <- arrayid
}else{
   groupid <- arrayid - cumsum(group.num.allchr)[chr-1]
}

ncRNA_gene_chr <- ncRNA_gene[ncRNA_gene[,1]==chr,]
sub_seq_num <- dim(ncRNA_gene_chr)[1]

if(groupid < group.num)
{ 
	sub_seq_id <- ((groupid - 1)*gene_num_in_array + 1):(groupid*gene_num_in_array)
}else
{
	sub_seq_id <- ((groupid - 1)*gene_num_in_array + 1):sub_seq_num
}	

### exclude large genes
if(arrayid==117)
{
	sub_seq_id <- setdiff(sub_seq_id,53)
}

if(arrayid==218)
{
	sub_seq_id <- setdiff(sub_seq_id,19)
}

if(arrayid==220)
{
	sub_seq_id <- setdiff(sub_seq_id,c(208,274))
}

if(arrayid==221)
{
	sub_seq_id <- setdiff(sub_seq_id,311)
}

if(arrayid==156)
{
	sub_seq_id <- setdiff(sub_seq_id,41)
}

if(arrayid==219)
{
	sub_seq_id <- setdiff(sub_seq_id,103)
}



### gds file
gds.path <- agds_dir[chr]
genofile <- seqOpen(gds.path)

genes <- genes_info

results_ncRNA <- c()
for(kk in sub_seq_id)
{
	print(kk)
	gene_name <- ncRNA_gene_chr[kk,2]
	results <- c()
	results <- try(ncRNA(chr=chr, gene_name=gene_name, genofile=genofile, obj_nullmodel=obj_nullmodel,
									rare_maf_cutoff=0.01,rv_num_cutoff=2,
									QC_label=QC_label,variant_type=variant_type,geno_missing_imputation=geno_missing_imputation,
									Annotation_dir=Annotation_dir,Annotation_name_catalog=Annotation_name_catalog,
									Use_annotation_weights=Use_annotation_weights,Annotation_name=Annotation_name))
	
	results_ncRNA <- rbind(results_ncRNA,results)
}


save(results_ncRNA,file=paste0(output_path,output_file_name,"_",arrayid,".Rdata"))

seqClose(genofile)
