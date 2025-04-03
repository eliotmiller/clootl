utils::globalVariables(c("clootl_data"))



#' Extract a cloud of trees from the complete Avian Phylogeny for a set of species
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
#' If the tree has been downloaded using [get_avesdata_repo()], it will read the tree file corresponding
#' to the `version` and `taxonomy_year` provided and load it as a `phylo` object.
#' @param version The desired version of the tree. Default to the most recent
#' version of the tree. Other versions available are '1.2','1.3','1.4', and can be passed as
#' a character string or as numeric.
#' @param count Work in progress, can only sample 100 for now. Eventually: The desired number of sampled trees.
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
#' @return A set of phylogenies determined in `count` of the specified taxa in the specified eBird taxonomy version and clootl
#' tree version.
#'
#' @author Eliot Miller, Luna Sanchez Reyes, Emily Jane McTavish
#'
#' @export
#'
#' @import ape
#'
#' @examples
#' ex2 <- sampleTrees(species=c("Turdus migratorius",
#'                              "Setophaga dominica",
#'                              "Setophaga ruticilla",
#'                              "Sitta canadensis"))

sampleTrees <- function(species="all_species",
                        label_type="scientific",
                        taxonomy_year=2023,
                        version="1.4",
                        count=100,
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


  if((Sys.getenv('AVESDATA_PATH') == "") & (data_path==FALSE)){
      stop("AvesData repo not found.
        To sample across trees you need to download the Aves data repo.
      Either run get_avesdata_repo()
      or set path to Aves Data repo using set_avesdata_repo(path),
      or use the argument data_path = AvesData-path")
    }
    else {
        data_path = Sys.getenv('AVESDATA_PATH')
    }

  if(label_type=="code")
  {
   stop("sampling over trees currently only works with full names and label='scientific'")
  }
  if(count!=100)
  {
   stop("sampling over trees currently only returns all 100 trees.")
  }
  tax <- taxonomyGet(taxonomy_year, data_path)

  species <- as.list(species)
  #if species is set to all.species, redefine species as the full set of taxa

  if(species[1]=="all_species" & label_type=="scientific")
  {
    species <- tax$SCI_NAME
  }

  else
  {
    species <- species
  }


  if(label_type=="scientific")
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
    sample_tree_filename <- paste(data_path,
                               "/Tree_versions/",
                               "Aves_",
                               version,
                               "/Clements",
                               as.character(taxonomy_year),
                               "/dated_rand_sample_clements.tre",
                               sep='')
    fullTreeSet <- read.tree(sample_tree_filename,skip=1)
  #now prune the tree and extract. if species is the full set, no pruning will occur
  pruned <- dropTipMultiPhylo(fullTreeSet, setdiff(fullTreeSet[[1]]$tip.label, species))
  pruned
}


# from http://blog.phytools.org/2020/06/pruning-tips-from-multiphylo-object.html
dropTipMultiPhylo<-function(phy, tip, ...){
    if(!inherits(phy,"multiPhylo"))
        stop("phy is not an object of class \"multiPhylo\".")
    else {
        trees<-lapply(phy,drop.tip,tip=tip,...)
        class(trees)<-"multiPhylo"
    }
    trees
}
