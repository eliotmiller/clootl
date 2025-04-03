#load clootl

library(devtools)
library(clootl)



##You should be able to get default trees (currently v 1.4) without downloading the data. 
ex1 <- sampleTrees(species=c("Turdus migratorius",
                             "Setophaga dominica",
                             "Setophaga ruticilla",
                             "Sitta canadensis"))

