#load clootl
library(clootl)
library(phytools)


setwd("~/projects/otapi/OpenTreeCLO/clootlDemo")




ourTree <- extractTree(species=c("amerob", "canwar", "reevir1", "yerwar", "gockin"),
                       label_type="code")



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

#grab a pruned tree
pruned <- extractTree(species=datSubset$Species2,
                      label_type="scientific", taxonomy_year="2021")

pruned$root.edge <- NULL

summary(phylolm(log(Tarsus.Length)~Beak.Length_Culmen, data=datSubset, phy=pruned, model="BM"))

x <- log(datSubset$Mass)
names(x) <- datSubset$underscores
contMap(tree=pruned, x=x, outline=FALSE, lwd=0.8, fsize=0.2, res=200)


x <- log(datSubset$Beak.Length_Culmen)
names(x) <- datSubset$underscores
contMap(tree=pruned, x=x, outline=FALSE, lwd=0.8, fsize=0.2, res=200)

dat <- utils::read.csv("AVONET Supplementary dataset 1.csv")
spp <- sample(dat$Species2, 100)
subtree <- extractTree(species=spp,
                      label_type="scientific",
                      taxonomy_year="2021")



