#load clootl
library(clootl)
library(ape)

setwd("~/projects/otapi/OpenTreeCLO/clootlDemo")


# this downloads all the data from the AvesData github repo
get_avesdata_repo()



ex1 <- extractTree(species=c("amerob", "canwar", "reevir1", "yerwar", "gockin"),
                   output.type="code", taxonomy.year="2021", version="1.2")

getCitations(ex1, version="1.2")
