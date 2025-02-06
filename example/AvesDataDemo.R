#load clootl

library(devtools)
install_github("snacktavish/clootl@data-repo-clone")


library(clootl)
library(ape)

setwd("~/projects/otapi/OpenTreeCLO/clootlDemo")


# this downloads all the data from the AvesData github repo
# As a folder in your current working directory
get_avesdata_repo()





ex1 <- extractTree(species=c("amerob", "canwar", "reevir1", "yerwar", "gockin"),
                   output.type="code", taxonomy.year="2021", version="1.2")

getCitations(ex1, version="1.2")
