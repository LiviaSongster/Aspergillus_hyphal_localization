#step one - read in all data frames
setwd(choose.dir(default = "Y:/LiviaSongster/10-Analysis/", caption = "Select folder with all analysis dirs"))

rm(list=ls())
home <- getwd()
dir.create("../Prism_style_xy_compiled")
library("dplyr")
library("qpcR") 

# loop through all files and merge them by the x coordinate
file_names <- list.files(path = ".", full.names = FALSE, recursive = FALSE) #where you have your files
bkgd_names <- gsub("linescan.txt", "background.csv", file_names)

# get lists of all files per strain

## FUNCTION: 
get_filenames <- function(filename_list,search_term) {
  key <- filename_list[grep(search_term,filename_list)]
  return(key)
}


# WT
data.A <- get_filenames(filename_list=file_names, search_term="rpa528")
bkgd.A <- gsub("linescan.txt", "background.csv", data.A)

#pxda null
data.B <- get_filenames(filename_list=file_names, search_term="rpa861")
bkgd.B <- gsub("linescan.txt", "background.csv", data.B)


# hexa null
data.C <- get_filenames(filename_list=file_names, search_term="rpa1344")
data.C2 <- get_filenames(filename_list=file_names, search_term="rpa1330")
data.C <- c(data.C,data.C2)
bkgd.C <- gsub("linescan.txt", "background.csv", data.C)


# sspa null
data.D <- get_filenames(filename_list=file_names, search_term="rpa1345")
data.D2 <- get_filenames(filename_list=file_names, search_term="rpa1346")
data.D <- c(data.D,data.D2)
bkgd.D <- gsub("linescan.txt", "background.csv", data.D)

# read csv files and return them as items in a list()
## FUNCTION
compile_linescans <- function(filename_list,
                              background_list,
                              background_dir="../RFP-Background-Results/") {
  
  output_dataset <- read.table(filename_list[1])
  temp_bkgd <- read.csv(paste0("../RFP-Background-Results/",background_list[1]))
  
  # subtract background from all values in dataset - start with first file
  output_dataset[,2] <- output_dataset[,2] - as.numeric(temp_bkgd[3])
  colnames(output_dataset) <- c("x",filename_list[1])
  
  # now loop through and add others
  for (x in 2:length(filename_list)){
    temp_dataset <- read.table(filename_list[x])
    colnames(temp_dataset) <- c("x",filename_list[x])
    temp_bkgd <- read.csv(paste0(background_dir,background_list[x]))
    temp_dataset[,2] <- temp_dataset[,2] - as.numeric(temp_bkgd[3])
    output_dataset <- qpcR:::cbind.na(output_dataset, temp_dataset[2])
  }
  
  return(output_dataset)
}


# now run for WT
wt <- compile_linescans(data.A,bkgd.A,"../RFP-Background-Results/")
write.csv(wt,"../Prism_style_xy_compiled/rfp_wt_compiled.csv")

# now other genotypes
pxda <- compile_linescans(data.B,bkgd.B,"../RFP-Background-Results/")
write.csv(pxda,"../Prism_style_xy_compiled/rfp_pxda_compiled.csv")

hexa <- compile_linescans(data.C,bkgd.C,"../RFP-Background-Results/")
write.csv(hexa,"../Prism_style_xy_compiled/rfp_hexa_compiled.csv")

sspa <- compile_linescans(data.D,bkgd.D,"../RFP-Background-Results/")
write.csv(sspa,"../Prism_style_xy_compiled/rfp_sspa_compiled.csv")
