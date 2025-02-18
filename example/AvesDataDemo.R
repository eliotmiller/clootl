#load clootl

library(devtools)
install_github("snacktavish/clootl@data-repo-clone")


library(clootl)
library(ape)

setwd("~/pj_clootl/lunasare/clootl")
setwd("~/pj_clootl/demo")


# this downloads all the data from the AvesData github repo
# As a folder in your current working directory
clootl:::get_avesdata_repo()

## If you want it to re-download the git repo (to get new data) use:
# get_avesdata_repo(refresh = True)



ex1 <- extractTree(species=c("amerob", "canwar", "reevir1", "yerwar", "gockin"),
                   label_type="code", taxonomy_year="2021", version="1.2")

getCitations(ex1, version="1.2")
