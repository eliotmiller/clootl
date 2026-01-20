#load clootl

library(devtools)


library(clootl)




##You should be able to get default trees without downloading the data. 
ex1 <- extractTree(species=c("Turdus migratorius",
                             "Setophaga dominica",
                             "Setophaga ruticilla",
                             "Sitta canadensis"))

ex2 <- extractTree(species=c("amerob",
                             "canwar",
                             "reevir1",
                             "yerwar",
                             "gockin"), 
                              label_type="code")


## Pulls the citations
getCitations(ex2)





## IF you have downloaded the Aves Data Repo to your computer,
## you can pass in the path to get older tree versions e.g.
ex3 <- extractTree(species=c("Turdus migratorius","Setophaga dominica", "Setophaga ruticilla", "Sitta canadensis"),
                               version=1.2,
                               taxonomy_year=2023,
                               data_path="~/projects/otapi/AvesData")



##To get other tree versions, and or the 100 tree dated sample sets, 
# this downloads all the data from the AvesData github repo
# As a folder in your current working directory named "AvesData-main"
get_avesdata_repo(path=".") 

## If you want it to re-download the git repo (e.g. to get new data) use:
# get_avesdata_repo(path=".", refresh = TRUE)


##or if you have the AvesData repo somewhere else and don't feel like typing it in each time
# set_avesdata_repo_path(PATH)



ex4 <- extractTree(species=c("amerob", "canwar", "reevir1", "yerwar", "gockin"),
                   label_type="code", taxonomy_year="2021", version="1.3")

## To pull citations for older tree versions you need to include the version number
getCitations(ex4, version="1.3")

