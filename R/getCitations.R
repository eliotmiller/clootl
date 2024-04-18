#' Get the DOIs and quantify the contribution of published studies
#'
#' Standing on the shoulders of giants
#'
#' @param tree A phylogeny obtained from extractTree (see details).
#' 
#' @details Importantly: an internet connection is required for this function to work, as it
#' relies on Open Tree of Life APIs. The function will determine what proportion of nodes in
#' your phylogeny (possibly
#' but not necessarily pruned to a set of study taxa) are supported by each study that goes into
#' creating the final clootl tree. In any resulting publication, you should always cite the
#' clootl tree, and
#' you should also "always" cite all the trees/DOIs that contributed to your phylogeny. That
#' said, we are well aware of citation and word count limits that plague modern publishing,
#' and for this reason we quantify the contribution of each study; depending on your phylogeny,
#' it is very possible that one or two studies contributed the majority of information. Currently,
#' this function assumes your output tree matches the taxonomy of the corresponding tree on the
#' OpenTree server. Since the function is actually using the named internal nodes for the API
#' query, and these should not be lost between tree versions and taxonomies, this should not
#' matter, but this has not yet been tested.
#'
#' @return A dataframe of the percent of internal nodes supported by a given study, as well
#' as the DOI of that study. The proportion of taxa in the tree supported by taxonomic
#' addition only is included in the dataframe.
#' 
#' @author Eliot Miller, Emily Jane McTavish
#'
#' @export
#' 
#' @import ape
#' @importFrom jsonlite toJSON fromJSON
#' @importFrom RCurl postForm
#' @importFrom dplyr group_by summarize
#' 
#' @examples
#'\donttest{#pull the taxonomy file out
#' data(dataStore)
#' tax <- dataStore[['year2021']]$taxonomy.files$ebird.taxonomy
#' 
#' #subset to species only
#' tax <- tax[tax$CATEGORY=="species",]
#'
#' #simulate extracting a tree for a particular family
#' temp <- tax[tax$FAMILY=="Rhinocryptidae (Tapaculos)",]
#' spp <- temp$SCI_NAME
#' 
#' #get your tree
#' prunedTree <- extractTree(species=spp, output.type="scientific",
#'    taxonomy.year="current", version="current")
#' 
#' #get your citation DF
#' yourCitations <- getCitations(tree=prunedTree)}

getCitations <- function(tree, synth_id="aves_1.1" )
{
  #pull the node labels out. count any (character instances of) NA, as this should
  #be the contribution of taxonomic additions and drop any NAs
  nodesToQuery <- tree$node.label
  taxonomyNodes <- sum(nodesToQuery == "NA")
  nodesToQuery <- nodesToQuery[nodesToQuery != "NA"]
  
  #define some convenience variables for API query
  url <- "https://aves.opentreeoflife.org/v3/tree_of_life/node_info"
  headers <- c('Content-Type' = 'application/json')
  
  body <- jsonlite::toJSON(list(synth_id, "node_ids"=nodesToQuery), auto_unbox=TRUE)
  response <- RCurl::postForm(uri = url,
                       .opts = list(
                         postfields = body,
                         httpheader = headers
                       ))
  
  # Parse the response
  parsedJSON <- jsonlite::fromJSON(response)
  
  # pull out the "supported_by" columns. 
  nodeResults <- parsedJSON$supported_by
  
  # drop the root column (this is underlying OpenTree taxonomy). append
  # ot_2019 to that. that is an eBird taxonomy file. in the end we do not
  # use information from either of these.
  toDrop <- names(nodeResults)[grep("root", names(nodeResults))]
  toDrop <- c(toDrop, "ot_2019")
  
  # drop the root column
  nodeResults <- nodeResults[,!(names(nodeResults) %in% toDrop)]
  
  #count column info. note the exclamation mark to flip the TRUE for na
  citationCounts <- apply(!apply(nodeResults, 2, is.na), 2, sum)
  
  # now pull out the tree info and stack into a data frame so that if multiple trees from
  # a single study are being tallied, we don't lose that info
  toGroup <- data.frame(study=unlist(lapply(strsplit(names(nodeResults), "@"), "[", 1)),
                        count=citationCounts)
  
  # group by study and take the max of all trees (summing has weird effects if a
  # study has a lot of trees)
  grouped <- dplyr::group_by(toGroup, study)
  finalCounts <- as.data.frame(dplyr::summarize(grouped, counts=max(count)))
  
  # now query the citations
  dois <- c()
  for(i in 1:length(finalCounts$study))
  {
    #again, define some convenience variables
    url <- "https://api.opentreeoflife.org/v3/studies/find_studies"
    headers <- c('Content-Type' = 'application/json')
    body <- jsonlite::toJSON(list("property"="ot:studyId", "value"=finalCounts$study[i], "verbose"="true"),
                             auto_unbox=TRUE)
    
    response <- RCurl::postForm(uri = url,
                         .opts = list(
                           postfields = body,
                           httpheader = headers
                         ))
    
    #having trouble with weird end of line symbols
    response <- gsub("\n", "", response)
    
    # Parse the response
    parsedJSON <- jsonlite::fromJSON(response)
    
    # pull the doi
    doiTemp <- parsedJSON$matched_studies$`ot:studyPublication`
    if(is.null(doiTemp))
    {
      dois[i] <- NA
    }
    else
    {
      dois[i] <- doiTemp
    }
  }
  
  #plug the dois in
  finalCounts$doi <- dois
  
  #add a row for contributions by taxonomy
  toBind <- data.frame(study="Taxonomic additions", counts=taxonomyNodes,
                       doi="https://github.com/eliotmiller/clootl")
  finalCounts <- rbind(finalCounts, toBind)
  
  #order in decreasing order, strip row names, and return
  finalCounts <- finalCounts[order(finalCounts$counts, decreasing=TRUE),]
  row.names(finalCounts) <- NULL
  
  #finally divide through by the number of internal nodes
  finalCounts$contribution <- (finalCounts$counts/tree$Nnode)*100
  
  #drop the raw counts and return
  finalCounts$counts <- NULL
  finalCounts
}
