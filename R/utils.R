#' Pull down full AvesData repository to a working directory
#' @param path Path to download data zipfile to, and where it will be unpacked.  To download into your working directoyr, use "."
#' @param url Web address of the Aves Data repository at https://github.com/McTavishLab/AvesData/
#' @param refresh Default to `FALSE`. Will not redownload the data by default if path exists, unless refresh=TRUE
<<<<<<< HEAD
#' @export
get_avesdata_repo <- function(path,
                              refresh=FALSE){
  url = "https://github.com/McTavishLab/AvesData/archive/refs/heads/main.zip",
  old <- options() # save current options
  on.exit(options(old)) #Revert to original options on exit
=======
#' @param path Default to "tempdir". To download into your working directoyr, use "."
#' @export
get_avesdata_repo <- function(url = "https://github.com/McTavishLab/AvesData/archive/refs/heads/main.zip",
                              refresh=FALSE,
                              path = tempdir()){
>>>>>>> e30352437847bd4efde66c5aead96d159d426c6d
  options(timeout=444) # This file is big and can take a little while to download
  if (!file.exists(path)){
      stop("Directory to save AvesData not found:", path)
    }
  zipfilepath = paste(path, "/", "AvesData.zip", sep="")
  if (file.exists(zipfilepath) & (refresh == FALSE)){
    message("File AvesData.zip already exists. Use refresh = TRUE to download a new version")
  } else {
    utils::download.file(url, destfile = zipfilepath)
    utils::unzip(zipfile = zipfilepath, overwrite=TRUE)
  }
  avesdata_path = paste(path,"/","AvesData-main", sep="")
  Sys.setenv(avesdata = avesdata_path)
}


#' Set path to Aves Data folder already somewhere on your computer
#'
#' @param path A character vector with the path to the Aves Data folder.
#'
#' @export
set_avesdata_repo_path <- function(path){
  if (!file.exists(path)){
      stop("AvesData folder not found at: ", path)
    }
  Sys.setenv(avesdata = path)
}

###########
# Internal function, used in initialProcessing() function
# developed in package PDcalc, not on CRAN atm, https://rdrr.io/github/davidnipperess/PDcalc/
bifurcatr <- function(phy, runs = 1)
{
  trees <- vector("list", length = runs)
  for (i in 1:runs) {
    tree <- phy
    resolves <- Ntip(tree) - Nnode(tree) - 1
    for (j in 1:resolves) {
      descendent_counts <- rle(sort(tree$edge[, 1]))
      polytomies <- descendent_counts$values[which(descendent_counts$lengths >
                                                     2)]
      if (length(polytomies) > 1)
        target_polytomy <- sample(polytomies, size = 1)
      else target_polytomy <- polytomies
      polytomy_edges <- which(tree$edge[, 1] == target_polytomy)
      target_edges <- sample(polytomy_edges, size = 2)
      new_node <- max(tree$edge) + 1
      tree$edge[target_edges, 1] <- new_node
      new_edge <- c(target_polytomy, new_node)
      tree$edge <- rbind(tree$edge, new_edge)
      new_length <- stats::runif(n = 1, min = 0, max = min(tree$edge.length[target_edges]))
      tree$edge.length <- c(tree$edge.length, new_length)
      tree$edge.length[target_edges] <- tree$edge.length[target_edges] -
        new_length
      tree$Nnode <- tree$Nnode + 1
    }
    trees[[i]] <- tree
  }
  if (runs == 1) {
    trees <- trees[[1]]
    class(trees) <- "phylo"
  }
  else {
    class(trees) <- "multiPhylo"
  }
  return(trees)
}
