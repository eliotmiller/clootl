utils::globalVariables(c("clootl_data"))


#' Extract a tree from the complete Avian Phylogeny for a set of species
#'
#' @param species A character vector either of scientific names (directly as they come out of the
#' eBird taxonomy, i.e. without underscores) or of six-letter eBird species codes. Any elements of
#' the species vector that do not match a species-level taxon in the specified eBird taxonomy
#' will result in an error. Default is set to "all_species".
#' @param label_type Either "scientific" or "code". Default is set to "scientific".
#' @param taxonomy_year The eBird taxonomy year the tree should be output in. Current options
#' include 2021, 2022, and 2023. Both numeric and character inputs are acceptable here. Any value
#' aside from these years will result in an error. Default is set 2023.
#' @param data_path Default to `FALSE`, it will look for a path containing the bird tree.
#' If the tree has not been downloaded yet using [get_avesdata_repo()], it will load the default tree
#' using [utils::data()] as long as `version` and `taxonomy_year` are empty or match the default version.
#' If the tree has been downloaded using [get_avesdata_repo()], it will read the tree file corresponding
#' to the `version` and `taxonomy_year` provided and load it as a `phylo` object.
#' @param version The desired version of the tree. Default to the most recent
#' version of the tree. Other versions available are '1.2','1.3','1.4', and can be passed as
#' a character string or as numeric.
#'
#' @details This function first ensures that the requested output species overlap with species-level
#' taxa in the requested eBird taxonomy. If they do not, the function will error out. The onus is
#' on the user to ensure the requested taxa are valid. This is critical to ensure no unexpected
#' analysis hiccups later--you don't want to find out many steps later that your dataset doesn't
#' match your phylogeny. The eBird database is currently (as of Mar 2025) in 2024 taxonomy.
#' Trees available in 2024 taxonomy will be available by June 2025. The 2025 taxonomy will be released
#' to the public in October or November 2025. The intention is to release a tree in 2025 taxonomy
#' concurrently with the publication of the taxonomy itself.
#'
#' @return A phylogeny of the specified taxa in the specified eBird taxonomy version and clootl
#' tree version.
#'
#' @author Eliot Miller, Luna Sanchez Reyes, Emily Jane McTavish
#'
#' @export
#'
#' @import ape
#'
#' @examples
#' ex1 <- extractTree(species=c("amerob", "canwar", "reevir1", "yerwar", "gockin"),
#'    label_type="code")
#' ex2 <- extractTree(species=c("Turdus migratorius",
#'                              "Setophaga dominica",
#'                              "Setophaga ruticilla",
#'                              "Sitta canadensis"),
#'    label_type="scientific",
#'    taxonomy_year="2021",
#'    version="1.4")
#'
extractTree <- function(species="all_species",
                        label_type="scientific",
                        taxonomy_year=2023,
                        version="1.4",
                        data_path=FALSE)
{
  label_type <- match.arg(label_type,c('code','scientific'))
  utils::data("clootl_data")

  version <- as.character(version)
  if (!is.element(version, clootl_data$versions)){
    stop("version not recognized: ", version) ## TODO print out actual list
  }

  taxonomy_year <- as.character(taxonomy_year)
  if (!is.element(taxonomy_year, clootl_data$tax_years)){
    stop("Requested year currently unavailable")
  }


  if((Sys.getenv('AVESDATA_PATH') == "") & (data_path==FALSE) & (version!='1.4')){
      stop("Only tree version 1.4 is currently packaged with clootl.
      To get alternate tree versions, run get_avesdata_repo()
      or set path to Aves Data repo using set_avesdata_repo(path),
      or use the argument data_path = AvesData-path")
    }


  tax <- taxonomyGet(taxonomy_year, data_path)
  fullTree <- treeGet(version, taxonomy_year, data_path)

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
      message("Some of your provided species codes do not match with codes in the requested year's eBird taxonomy:")
      stop(paste(issues, collapse = "\n"))
    }

    #else might as well set a tree aside with codes instead of sci names
    else
    {
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
      message("Some of your provided species codes do not match with codes in the requested year's eBird taxonomy")
      stop(paste(issues, collapse = "\n"))
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
#' If the taxonomy has not been downloaded yet using [get_avesdata_repo()], it will load the
#' default taxonomy using [utils::data()] as long as `taxonomy_year` as empty or matches the default version.
#' If the taxonomy has been downloaded using [get_avesdata_repo()], it will read the taxonomy
#' file corresponding to the year given in `taxonomy_year` and load it as a `data frame` object.
#'
#' @details This will return a data object that has the taxonomy of the requested year.
#' @return A `data.frame` with 17 columns of taxonomic information: order, species code, taxon concept, common name, scientific name, family, OpenTree Taxonomy data, etc.
#' @export
#'
taxonomyGet <- function(taxonomy_year, data_path=FALSE){
  if (data_path==FALSE){
        data_path = Sys.getenv('AVESDATA_PATH') ## If you didn't download it, this will be ""
       }
  if (data_path == ""){
   ##We should be in here if we DIDN'T download the data
      utils::data("clootl_data")
      taxonomyYear <- paste("Year", taxonomy_year, sep="")
      tax <- clootl_data$taxonomy.files[[`taxonomyYear`]]
  } else {
       ## We will be in here if we have run get_avesdata_repo and downloaded the data
       ##This needs an if statement for if it is looking for the object or the path
       if (!file.exists(data_path)){
          stop("AvesData folder not found at: ", data_path)
        }
      taxonomy_filename <- paste(data_path,
                             '/Taxonomy_versions/Clements',
                             as.character(taxonomy_year),
                             "/OTT_crosswalk_",
                             as.character(taxonomy_year),
                             ".csv",
                             sep='')
        if (!file.exists(taxonomy_filename)){
          stop("taxonomy file not found at: ", taxonomy_filename)
          }
      ## ONce we have the tree and taxonomy, all this stuff can happen
    tax = utils::read.csv(taxonomy_filename)
      }
     #subset to species

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
#' If the tree has not been downloaded yet using [get_avesdata_repo()], it will load the
#' default tree using [utils::data()] and `version` and `taxonomy_year` will be ignored??
#' If the tree has been downloaded using [get_avesdata_repo()], it will read the tree
#' file corresponding to the `version` and `taxonomy_year` provided and load it as a `phylo` object.
#'
#' @details This will return a data object that has the requested tree.
#' @return A `phylo` object with the requested version and taxonomy.
#' @export
#'
treeGet <- function(version, taxonomy_year, data_path=FALSE){
  #pull the tree file in the right version and taxonomy
  if (data_path==FALSE){
        data_path = Sys.getenv('AVESDATA_PATH') ## If you didn't download it, this will be ""
       }
  if(data_path == ""){
    ## We will be in here if we have run get_avesdata_repo and downloaded the data
    utils::data("clootl_data")
    taxonomyYear <- paste("year", taxonomy_year, sep="")
    version <- paste("Aves_", version, sep="")
    fullTree <- clootl_data$trees[[version]]$summary.trees[[taxonomyYear]]
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
