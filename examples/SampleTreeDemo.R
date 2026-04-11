#load clootl

library(clootl)
library(phangorn)




ex1 <- sampleTrees(species=c("Turdus migratorius",
                             "Setophaga dominica",
                             "Setophaga ruticilla",
                             "Sitta canadensis"))


## Here there is only variation in node ages
densiTree(ex1)

## For the genus Mergus some species were placed taxonomically
## This results in variation in ages and relationships
library(stringr)
tax <- clootl_data$taxonomies$year2025
genus<-str_split_i(tax$SCI_NAME, " ",1)
tax<-cbind(tax, GENUS=genus)
Mergus <- tax[tax$GENUS=="Mergus",]
Mergus_spp <- Mergus$SCI_NAME
ex2 <- sampleTrees(species=Mergus_spp)
densiTree(ex2)
