#load clootl
library(clootl)
library(phytools)
library(phylolm)

## Easily match trees to AVONET dataset

#load the AVONET dataset
##Download AVONET Supplmentary dataset 1 from here
# https://figshare.com/s/b990722d72a26b5bfead
# save sheet Avonet2_ebird to CSV

dat <- utils::read.csv("AVONET Supplementary dataset 1.csv")


#create an underscores column
dat$underscores <- sub(" ", "_", dat$Species2)

#select a random subset of 200 species, then see whether body mass and tarsus length are correlated
#and make a continuous character map of body mass
spp <- sample(dat$Species2, 100)
datSubset <- dat[dat$Species2 %in% spp,]
row.names(datSubset) <- datSubset$underscores



pruned <- extractTree(species=datSubset$Species2,
                      label_type="scientific",
                      force=TRUE)

pruned$root.edge <- NULL

## phylolm automatically drops the unmatched values
summary(phylolm(log(Tarsus.Length)~Beak.Length_Culmen, data=datSubset, phy=pruned, model="BM"))

# but for other functions you need to match the data rows to tips in the tree
datMatched <- datSubset[datSubset$underscores %in% pruned$tip.label,]

x <- log(datMatched$Mass)
names(x) <- datMatched$underscores
contMap(tree=pruned, x=x, outline=FALSE, lwd=0.8, fsize=0.2, res=200)


x <- log(datMatched$Beak.Length_Culmen)
names(x) <- datMatched$underscores
contMap(tree=pruned, x=x, outline=FALSE, lwd=0.8, fsize=0.2, res=200)
