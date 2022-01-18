# deidentify patients
library(stringr)
library(tidyverse)
library(readxl)

workDir <- '/Users/angelmg/Documents/nci_vb_git/bergamaschi_pfizer_cancer'
setwd(workDir)



# Raw data
raw_data <- read.delim('./data/raw_msd_data2.csv', header = TRUE, sep=',',check.names = FALSE)
raw_data$patient_id <- apply(array(raw_data$Vial_Label),1,function(z) unlist(str_split(z,"_"))[1])
raw_data$timepoint <- apply(array(raw_data$Vial_Label),1,function(z) unlist(str_split(z,"_"))[2])
new_ids <- paste0("C",str_pad(1:length(unique(raw_data$patient_id)), width = 2, pad = "0"))
names(new_ids) <- unique(raw_data$patient_id)
raw_data <- raw_data %>% mutate(new_id = paste(new_ids[patient_id],timepoint, sep = "_"))
raw_data$Vial_Label <- raw_data$new_id #reassign
deidentified <- raw_data %>% select(-one_of(c("patient_id","timepoint","new_id")))
write.table(deidentified,"data/cancer_deidentified.csv",sep = ",", row.names = FALSE, quote = FALSE, col.names = TRUE)

# Additional metadata
additional_metadata <- read_xlsx("data/patient_metadata.xlsx")
names(new_ids) <- toupper(names(new_ids))
additional_metadata <- additional_metadata %>% mutate(new_id = new_ids[patient_id])
additional_metadata$patient_id <- additional_metadata$new_id
deidentified_metadata <- additional_metadata %>% select(-new_id)
colnames(deidentified_metadata)
write.table(deidentified_metadata,"data/patient_metadata_deidentified.tsv", sep = "\t", row.names = FALSE, quote = FALSE, col.names = TRUE)
