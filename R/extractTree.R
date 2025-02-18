#' Randomly resolve polytomies and enforce ultrametric
#'
#' Initial tree processing
#'
#' @param species A character vector either of scientific names (directly as they come out of the
#' eBird taxonomy, i.e. without underscores) or of six-letter eBird species codes. Any elements of
#' the species vector that do not match a species-level taxon in the specified eBird taxonomy
#' will result in an error. Set to "all_species" if the complete tree is desired.
#' @param label_type Either "scientific" or "code".
#' @param taxonomy_year The eBird taxonomy year the tree should be output in. Set to "current"
#' to extract a tree in the most recent taxonomic version. Otherwise, a numeric should be
#' passed in, e.g. 2021.
#' @param version The desired version of the tree. Set to current to extract the most recent
#' version of the tree. Otherwise, the exact character string of the tree needs to be passed in
#' here, e.g. "Aves_1.2".
#' @param which.tree Not currently implemented, and defaults for now to the single summary tree. In the
#' future, in addition to this summary tree, there will be the base tree from OpenTree, and
#' a small cloud of dated, complete trees (which
#' can be replaced by downloading and plugging in a larger set of such trees using a to-be-written
#' function for that purpose). Note the small cloud of complete dated trees is currently
#' included in the dataStore, and can be accessed by exploring the structure of data(dataStore)
#'
#' @details This function first ensures that the requested output species overlap with species-level
#' taxa in the requested eBird taxonomy. If they do not, the function will error out. The onus is
#' on the user to ensure the requested taxa are valid. This is critical to ensure no unexpected
#' analysis hiccups later--you don't want to find out many steps later that your dataset doesn't
#' match your phylogeny.
#'
#' @return A phylogeny of the specified taxa in the specified eBird taxonomy version and clootl
#' tree version.
#'
#' @author Eliot Miller
#'
#' @export
#'
#' @import ape
#'
#' @examples
#' ex1 <- extractTree(species=c("amerob", "canwar", "reevir1", "yerwar", "gockin"),
#'    label_type="code")
#' ex2 <- extractTree(species=c("Turdus migratorius", "Setophaga dominica", "Setophaga ruticilla", "Sitta canadensis"),
#'    label_type="scientific", taxonomy_year="2021", version="1.3")

extractTree <- function(species="all_species",
                        label_type="scientific",
                        taxonomy_year=2023, version="1.3",
                        data_path=FALSE,
                        which.tree = "summary")
{
  label_type <- match.arg(label_type,c('code','scientific'))

  versions <- c('0.1','1.0','1.2','1.3')
  version <- as.character(version)
  if (!is.element(version, versions)){
    stop("version not recognized: ", version) ## TODO print out actual list
  }

  tax_years <- c("2021","2022","2023")
  taxonomy_year <- as.character(taxonomy_year)
  if (!is.element(taxonomy_year, tax_years)){
    stop("year not recognized: ", tax_years)
  }


  if((Sys.getenv('avesdata') == "") & (data_path==FALSE) & (version!='1.3')){
      stop("Only tree version 1.3 is currently packaged with clootl.
      To get alternate tree versions, run get_avesdata_repo()
      or set path to Aves Data repo using set_avesdata_repo(path),
      or use th argument data_path = AvesData-path")
    }


  tax <- taxonomyGet(taxonomy_year, data_path)
  fullTree <- treeGet(version, taxonomy_year, data_path)
#  print("Tree has this many tips")
#  print(length(fullTree$tip.label))

  species <- as.list(species)
  #if species is set to all.species, redefine species as the full set of taxa
  if(species[1]=="all_species" & label_type=="code")
  {
    species <- tax$SPECIES_CODE
  }

  else if(species[1]=="all_species" & label_type=="scientific")
  {
    species <- tax$SCI_NAME
  }

  else
  {
    species <- species
  }

  #check whether the input species are valid
  if(label_type=="code")
  {
    #identify mismatches
    issues <- setdiff(species, tax$SPECIES_CODE)

    #if there are any, throw an error
    if(length(issues) > 0)
    {
      stop("Some of your provided species codes do not match with codes in the requested year's eBird taxonomy")
    } ##TODO Say which ones failed!!

    #else might as well set a tree aside with codes instead of sci names
    else
    {
 #     print("Swapping labels to code: NOW Tree has this many tips")
 #     print(length(fullTree$tip.label))
      #swap the scientific names for species codes
      newNames <- data.frame(order=1:length(fullTree$tip.label), orig=fullTree$tip.label)

      #merge and re-sort
      newNames <- merge(newNames, tax[,c("underscores","SPECIES_CODE")], by.x="orig", by.y="underscores")
      newNames <- newNames[order(newNames$order),]

      #swap names
      fullTree$tip.label <- newNames$SPECIES_CODE
    }
  }

  else if(label_type=="scientific")
  {
    #identify mismatches
    issues <- setdiff(species, tax$SCI_NAME)

    #if there are any, throw an error
    if(length(issues) > 0)
    {
      stop("Some of your provided species codes do not match with codes in the requested year's eBird taxonomy")
    }

    #else plug in underscores
    else
    {
      species <- sub(" ", "_", species)
    }
  }

  else
  {
    stop("label_type must be set to either 'code' or 'scientific'")
  }

  #now prune the tree and extract. if species is the full set, no pruning will occur
  pruned <- drop.tip(fullTree, setdiff(fullTree$tip.label, species))
  pruned
}


#' Load a bird taxonomy into the R environment
#'
#' @description `taxonomyGet` either reads a taxonomy file and loads it
#' as a `data frame`, or loads the default taxonomy data object.
#'
#' @inheritParams extractTree
#' @param data_path Default to `FALSE`, it will look for a path containing the bird taxonomy.
#' If the taxonomy has not been downloaded yet using [get_avesdata_repo()], it will load the default taxonomy using [utils::data()] and `taxonomy_year` will be ignored??
#' If the taxonomy has been downloaded using [get_avesdata_repo()], it will read the taxonomy file corresponding to the year given in `taxonomy_year` and load it as a `data frame` object.
#'
#' @details This will return a data object that has the requested taxonomy
#' @export
#'
taxonomyGet <- function(taxonomy_year, data_path=FALSE){
  if (data_path==FALSE){
        data_path = Sys.getenv('avesdata') ## If you didn't download it, this will be ""
       }
  if (data_path == ""){
   ##We should be in here if we DIDN"T download the data
      data(dataStore)
      taxonomyYear <- paste("year", taxonomy_year, sep="")
      tax <- dataStore$taxonomy.files[[`taxonomyYear`]]
  } else {
       ## We will be in here if we have run get_avesdata_repo and downloaded the data
       ##This needs an if statement for if it is looking for the object or the path
       if (!file.exists(data_path)){
          stop("AvesData folder not found at: ", data_path)
        }
      taxonomy_filename <- paste(data_path,
                             '/Taxonomy_versions/Clements',
                             as.character(taxonomy_year),
                             "/ebird_taxonomy_v",
                             as.character(taxonomy_year),
                             ".csv",
                             sep='')
        if (!file.exists(taxonomy_filename)){
          stop("taxonomy file not found at: ", taxonomy_filename)
          }
      ## ONce we have the tree and taxonomy, all this stuff can happen
    tax = read.csv(taxonomy_filename)
      }
     #subset to species
  tax <- tax[tax$CATEGORY=="species",]

  #create a convenience underscore column
  tax$underscores <- sub(" ", "_", tax$SCI_NAME)
  return(tax)
}

#' Load a bird tree into the R environment
#'
#' @description `treeGet` either reads a tree file and loads it
#' as a `phylo` object, or loads the default tree data object.
#'
#' @inheritParams extractTree
#' @param data_path Default to `FALSE`, it will look for a path containing the bird tree.
#' If the tree has not been downloaded yet using [get_avesdata_repo()], it will load the default tree using [utils::data()] and `version` and `taxonomy_year` will be ignored??
#' If the tree has been downloaded using [get_avesdata_repo()], it will read the tree file corresponding to the `version` and `taxonomy_year` provided and load it as a `phylo` object.
#'
#' @details This will return a data object that has the requested tree.
#' @export
#'
treeGet <- function(version, taxonomy_year, data_path=FALSE){
  #pull the tree file in the right version and taxonomy
  if (data_path==FALSE){
        data_path = Sys.getenv('avesdata') ## If you didn't download it, this will be ""
       }
  if(data_path == ""){
      ## We will be in here if we have run get_avesdata_repo and downloaded the data
    data(dataStore)
    taxonomyYear <- paste("year", taxonomy_year, sep="")
    version<-as.numeric(version)
    fullTree <- dataStore$trees[[version]]$summary.trees[[taxonomyYear]]

  } else {
    if (!file.exists(data_path)){
      stop("AvesData folder not found at: ", data_path)
    } else {
   ##This needs an if statement for if it is looking for the object or the path
        tree_filename <- paste(data_path,
                            "/Tree_versions/",
                            "Aves_",
                            version,
                            "/Clements",
                             as.character(taxonomy_year),
                             "/summary_dated_clements.nex",
                             sep='')
    fullTree <- read.nexus(tree_filename)
          }
  }
  return(fullTree)
}

