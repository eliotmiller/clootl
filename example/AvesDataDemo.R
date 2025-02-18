#load clootl

library(devtools)
install_github("snacktavish/clootl@data-repo-clone")


library(clootl)
library(ape)

setwd("~/projects/otapi/OpenTreeCLO/clootlDemo")


# this downloads all the data from the AvesData github repo
# As a folder in your current working directory
clootl:::get_avesdata_repo()

## If you want it to re-download the git repo (to get new data) use:
# get_avesdata_repo(refresh = TRUE)


##or if you have the AvesData repo somewhere else and don't feel like typing it in
# set_avesdata_repo_path(PATH)



ex1 <- extractTree(species=c("amerob", "canwar", "reevir1", "yerwar", "gockin"),
                   label_type="code", taxonomy_year="2021", version="1.2")


ex2 <- extractTree(species=c("Turdus migratorius", "Setophaga dominica", "Setophaga ruticilla", "Sitta canadensis"),
                   +                    label_type="scientific", data_path="~/projects/otapi/AvesData")

getCitations(ex1, version="1.2", data_path="~/projects/otapi/AvesData")
