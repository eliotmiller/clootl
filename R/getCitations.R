utils::globalVariables(c("clootl_data"))


#' Identify contributing studies
#'
#' Quantify the contribution of studies informing an extracted tree,
#' and obtain DOI and citation information for those studies.
#'
#' @param tree A phylogeny obtained from extractTree (see details).
#' @param data_path Default to FALSE. If a summary, dated tree is desired, this is sufficient
#' and does not need to be modified. However, if a user wishes to extract a set of complete
#' dated trees, for example to iterate an analysis across a cloud of trees, or to use an
#' older version of the tree than the current one packed in the data object, this function
#' can also accept a path to the downloaded set of trees. If you have already downloaded the AvesData repo
#' available at https://github.com/McTavishLab/AvesData use data_path= the path to the download location.
#' Alternately, you can download the full data repo using [get_avesdata_repo()]. This approach will download the data and
#' set an environmental variable AVESDATA_PATH. When AVESDATA_PATH is set, the data_path will default to this value.
#' To manually set AVESDATA_PATH to the location of your downloaded AvesData repo use [set_avesdata_repo_path()]
#' @param version The desired version of the tree. Default to the most recent
#' version of the tree. Other versions available are '0.1','1.0','1.2','1.3','1.4' and can be 
#' passed as a character string or as numeric.
#'
#' @details No longer requires an internet connection. The function will determine
#' what proportion of nodes in your phylogeny (possibly
#' but not necessarily pruned to a set of study taxa) are supported by each study that goes into
#' creating the final clootl tree. In any resulting publication, please cite both the
#' clootl tree (McTavish et al. 2025), and "all" the trees/DOIs that contributed to your phylogeny. That
#' said, we are well aware of citation and word count limits that plague modern publishing,
#' and for this reason we quantify the contribution of each study; depending on your phylogeny,
#' it is very possible that one or two studies contributed the majority of information. This function
#' is theoretically agnostic to taxonomy version.
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
#' data(clootl_data)
#' tax <- clootl_data$taxonomy.files$Year2021
#' ls(tax)
#' #subset to species only
#' # TODO: this step seems no longer necessary, is it??
#' # tax <- tax[tax$CATEGORY=="species",]
#'
#' #simulate extracting a tree for a particular family
#' temp <- tax[tax$FAMILY=="Rhinocryptidae (Tapaculos)",]
#' spp <- temp$SCI_NAME
#'
#' #get your tree
#' prunedTree <- extractTree(species=spp, label_type="scientific",
#'    taxonomy_year=2021, version="1.5")
#'
#' #get your citation DF
#'  yourCitations <- getCitations(tree=prunedTree)}
getCitations <- function(tree, version="1.5", data_path=FALSE) {##ToDO not hardcode?
  #pull the node labels out. count any (character instances of) NA, as this should
  #be the contribution of taxonomic additions and drop any NAs
  nodesToQuery <- tree$node.label
  taxonomyNodes <- sum(nodesToQuery == "NA")
  nodesToQuery <- nodesToQuery[nodesToQuery != "NA"]

  if (data_path==FALSE){
    data_path = Sys.getenv('AVESDATA_PATH')
  }

  if (!file.exists(data_path) & version != "1.5"){##ToDO not hardcode?
    stop("GetCitations for anything other than the current tree requires an Aves Data download.
      Currently get citations needs you to run get_avesdata_repo() first
      or provide a path to the data repo using data_path=")
    }

  if (!is.element(version, clootl_data$versions)){
    stop("version not recognized: ", version)
  }

  if (data_path == ""){
    utils::data("clootl_data")
    all_nodes <- clootl_data$trees$`Aves_1.5`$annotations ##ToDO not hardcode?
  } else{
      filename <- paste(data_path, '/Tree_versions/Aves_', version, '/OpenTreeSynth/annotated_supertree/annotations.json', sep='')
      if (!file.exists(filename)){
          stop("annotations file not found at: ", filename)
          }
      all_nodes <- jsonlite::fromJSON(txt=filename)
  }

  trees <- c()
  studies<-c()
  ##
  for (node in nodesToQuery){
    node_trees <- names(all_nodes$nodes[[node]]$supported_by)
    trees <- c(node_trees, trees)
    node_studies <- (unique(sub("@.*", "", node_trees)))
    studies <-c(node_studies, studies)
  }

  ## So this just lists all the trees, and all the studies...
  finalCounts <- as.data.frame(table(studies))
  colnames(finalCounts) <- c("study", "counts")

  study_info <- clootl_data$study_info

  dois <- c()
  refs <- c()
  for(i in 1:length(finalCounts$study))
  {
    study_id <- finalCounts$study[i]
    dois[i] <- study_info[study_info$study_id==study_id,'doi']
    refs[i]<- study_info[study_info$study_id==study_id,'reference']
      }
    
   #plug the dois in
  finalCounts$reference <- refs
  finalCounts$doi <- dois

  #add a row for contributions by taxonomy
  toBind <- data.frame(study="Taxonomic additions", counts=taxonomyNodes,
                       reference="Miller et al.",
                       doi="https://github.com/eliotmiller/addtaxa")
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


## This is for internal use to set up the study_info data object
api_studies_lookup <- function(studies){
  study_info <- data.frame(matrix(vector(), 0, 3,
                          dimnames=list(c(), c("study_id", "reference", "doi"))),
                          stringsAsFactors=F)

  studies <- as.vector(studies)
  for(i in 1:length(studies))
  {
    #again, define some convenience variables
    url <- "https://api.opentreeoflife.org/v3/studies/find_studies"
    headers <- c('Content-Type' = 'application/json')
    body <- jsonlite::toJSON(list("property"="ot:studyId",
                                  "value"=studies[i],
                                  "verbose"="true"),
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
    doi <- parsedJSON$matched_studies$`ot:studyPublication`
    if(is.null(doi))
    {
        doi <- NA
      }
    reference <- parsedJSON$matched_studies$`ot:studyPublicationReference`
      if(is.null(reference))
      {
        reference <- NA
      }

    study_info <- rbind(study_info, data.frame(study_id =studies[i],
                                              reference = reference, 
                                              doi = doi))
    }
    return(study_info)
  }

