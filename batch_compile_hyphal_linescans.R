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

# import key with genotypes and experiment numbers
key <- file_names

# get lists of all files per strain
# WT
wt.A <- key[grep("colonyA",key)]
wt.D <- key[grep("colonyD",key)]
bkgd.A <- gsub("linescan.txt", "background.csv", wt.A)
bkgd.D <- gsub("linescan.txt", "background.csv", wt.D)
names.wt <- c(wt.A, wt.D)
bkgd.wt <- c(bkgd.A, bkgd.D)

#pxda null
pxda.B <- key[grep("colonyB",key)]
pxda.C <- key[grep("colonyC",key)]
bkgd.B <- gsub("linescan.txt", "background.csv", pxda.B)
bkgd.C <- gsub("linescan.txt", "background.csv", pxda.C)
names.pxda <- c(pxda.B, pxda.C)
bkgd.pxda <- c(bkgd.B, bkgd.C)

# read csv files and return them as items in a list()
dataset.wt <- read.table(names.wt[1])
temp_bkgd <- read.csv(paste0("../RFP-Background-Results/",bkgd.wt[1]))

dataset.wt[,2] <- dataset.wt[,2] - as.numeric(temp_bkgd[3])
colnames(dataset.wt) <- c("x",names.wt[1])

for (x in 2:length(names.wt)){
    temp_dataset <- read.table(names.wt[x])
    colnames(temp_dataset) <- c("x",names.wt[x])
    temp_bkgd <- read.csv(paste0("../RFP-Background-Results/",bkgd.wt[x]))
    temp_dataset[,2] <- temp_dataset[,2] - as.numeric(temp_bkgd[3])
    dataset.wt <- qpcR:::cbind.na(dataset.wt, temp_dataset[2])
}
write.csv(dataset.wt,"../Prism_style_xy_compiled/rfp_wt_compiled.csv")

# repeat now for other genotypes
dataset.pxda <- read.table(names.pxda[1])
temp_bkgd <- read.csv(paste0("../RFP-Background-Results/",bkgd.pxda[1]))

dataset.pxda[,2] <- dataset.pxda[,2] - as.numeric(temp_bkgd[3])
colnames(dataset.pxda) <- c("x",names.pxda[1])

for (x in 2:length(names.pxda)){
  temp_dataset <- read.table(names.pxda[x])
  colnames(temp_dataset) <- c("x",names.pxda[x])
  temp_bkgd <- read.csv(paste0("../RFP-Background-Results/",bkgd.pxda[x]))
  temp_dataset[,2] <- temp_dataset[,2] - as.numeric(temp_bkgd[3])
  dataset.pxda <- qpcR:::cbind.na(dataset.pxda, temp_dataset[2])
}

write.csv(dataset.pxda,"../Prism_style_xy_compiled/rfp_pxda_compiled.csv")
