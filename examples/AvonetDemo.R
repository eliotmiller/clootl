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


#create an underscores column in 
dat$underscores <- sub(" ", "_", dat$Species2)

#select a random subset of 200 species, then see whether body mass and tarsus length are correlated
#and make a continuous character map of body mass
set.seed(123)
spp <- sample(dat$Species2, 100)
datSubset <- dat[dat$Species2 %in% spp,]
row.names(datSubset) <- datSubset$underscores


## The AVONET data was published aligned to the 2021 ebird taxonomy.
## Until it is updated, we have two options.

## 1) Use our most recent tree and taxonomy (1.6 2025), and just use the around 95% of species whose names have not changed.
pruned <- extractTree(species=datSubset$Species2,
                      label_type="scientific",
                      force=TRUE)


## or 2) Download the data store, as shown in examples/dataDownload.Rmd, 
## and use the v1.5 tree, which is avaialble in the 2021 ebird taxonomy
## This command will download the data repo and add the path to the repo
## as an environment variable
get_avesdata_repo(path=".")

## Once you have downloaded all the data, you can use a older tree 
## which was generated in the 2021 taxonomy directly.
## All species will match, but relationships will not all be up to date.
pruned <- extractTree(species=datSubset$Species2,
                      label_type="scientific",
                      version = 1.5,
                      taxonomy_year=2021)

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
