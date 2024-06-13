###########################################################
# fit MultiSTAAR null model for multi-trait analysis
# Xihao Li, Zilin Li
# Initiate date: 06/13/2024
# Current date: 06/13/2024
###########################################################
rm(list=ls())
gc()

library(gdsfmt)
library(SeqArray)
library(SeqVarTools)
library(STAAR)
library(MultiSTAAR)
library(STAARpipeline)

###########################################################
#           User Input
###########################################################
## Phenotype file
phenotype <- read.csv("/path_to_the_file/pheno.csv")
## (sparse) GRM file
sgrm <- get(load("/path_to_the_file/sGRM.Rdata"))
## file directory for the output file 
output_path <- "/path_to_the_output_file/"
## output file name
output_name <- "obj_nullmodel.Rdata"

###########################################################
#           Main Function 
###########################################################
## fit null model
obj_nullmodel <- fit_nullmodel(cbind(LDLadj.norm,HDLadj.norm,TGadj.norm)~age+age2+sex+PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10+PC11+as.factor(study_ethnicity),
                               data=phenotype,kins=sgrm,use_sparse=TRUE,kins_cutoff=0.022,id="sample.id",
                               family=gaussian(link="identity"),verbose=TRUE)

save(obj_nullmodel,file=paste0(output_path,output_name))

