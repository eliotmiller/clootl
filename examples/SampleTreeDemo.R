#load clootl

library(clootl)
library(phangorn)




ex1 <- sampleTrees(species=c("Turdus migratorius",
                             "Setophaga dominica",
                             "Setophaga ruticilla",
                             "Sitta canadensis"))


## Here there is only variation in node ages
densiTree(ex1)

## For the genus Columba some species were placed taxonomically
## This results in varation in ages and relationships

tax <- clootl_data$taxonomies$year2025
columba <- tax[tax$GENUS=="Columba",]
columba_spp <- rhin$SCI_NAME
ex2 <- sampleTrees(species=columba_spp)
densiTree(ex2)
