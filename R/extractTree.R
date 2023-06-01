#' Randomly resolve polytomies and enforce ultrametric
#'
#' Initial tree processing
#'
#' @param species A character vector either of scientific names (directly as they come out of the
#' eBird taxonomy, i.e. without underscores) or of six-letter eBird species codes. Any elements of
#' the species vector that do not match a species-level taxon in the specified eBird taxonomy
#' will result in an error. Set to "all.species" if the complete tree is desired.
#' @param output.type Either "scientific" or "code".
#' @param taxonomy.year The eBird taxonomy year the tree should be output in. Set to "current"
#' to extract a tree in the most recent taxonomic version.
#' @param version The desired version of the tree. Set to current to extract the most recent
#' version of the tree.
#' @param which.tree The only option at the moment is the base.tree.
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
#'    output.type="code", taxonomy.year="current", version="current")
#' ex2 <- extractTree(species=c("Turdus migratorius", "Setophaga dominica", "Setophaga ruticilla", "Sitta canadensis"),
#'    output.type="scientific", taxonomy.year="current", version="current")

extractTree <- function(species, output.type, taxonomy.year, version, which.tree)
{
  #load the datastore
  data(dataStore)
  
  #pull the taxonomy file and subset to species. create the name needed to identify the right file
  if(taxonomy.year=="current")
  {
    taxonomyYear <- names(dataStore)[length(dataStore)]
  }
  else
  {
    taxonomyYear <- paste("year", taxonomy.year, sep="")
  }
  tax <- dataStore[[taxonomyYear]]$taxonomy.files$ebird.taxonomy

  #subset to species
  tax <- tax[tax$CATEGORY=="species",]
  
  #create a convenience underscore column
  tax$underscores <- sub(" ", "_", tax$SCI_NAME)

  #pull the tree file in the right version and taxonomy
  if(version=="current")
  {
    treeVersion <- names(dataStore[[1]]$trees)[length(dataStore[[1]]$trees)]
  }
  else
  {
    treeVersion <- paste("v", version, sep="")
  }
  
  #now pull the right tree
  fullTree <- dataStore[[taxonomyYear]]$trees[[treeVersion]]$base.tree

  #if species is set to all.species, redefine species as the full set of taxa
  if(species[1]=="all.species" & output.type=="code")
  {
    species <- tax$SPECIES_CODE
  }
  
  else if(species[1]=="all.species" & output.type=="scientific")
  {
    species <- tax$SCI_NAME
  }
  
  else
  {
    species <- species
  }
      
  #check whether the input species are valid
  if(output.type=="code")
  {
    #identify mismatches
    issues <- setdiff(species, tax$SPECIES_CODE)
    
    #if there are any, throw an error
    if(length(issues) > 0)
    {
      stop("Some of your provided species codes do not match with codes in this year's eBird taxonomy")
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
  
  else if(output.type=="scientific")
  {
    #identify mismatches
    issues <- setdiff(species, tax$SCI_NAME)

    #if there are any, throw an error
    if(length(issues) > 0)
    {
      stop("Some of your provided species names do not match with species in this year's eBird taxonomy")
    }
    
    #else plug in underscores
    else
    {
      species <- sub(" ", "_", species)
    }
  }
  
  else
  {
    stop("output.type must be set to either 'code' or 'scientific'")
  }
  
  #now prune the tree and extract. if species is the full set, no pruning will occur
  pruned <- drop.tip(fullTree, setdiff(fullTree$tip.label, species))
  pruned
}
