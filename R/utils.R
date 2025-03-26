#' Pull down full AvesData repository to a working directory
#' @param path Path to download data zipfile to, and where it will be unpacked.  To download into your working directoyr, use "."
#' @param url Web address of the Aves Data repository at https://github.com/McTavishLab/AvesData/
#' @param refresh Default to `FALSE`. Will not redownload the data by default if path exists, unless refresh=TRUE
#' @export
get_avesdata_repo <- function(path,
                              refresh=FALSE){
  url = "https://github.com/McTavishLab/AvesData/archive/refs/heads/main.zip"
  old <- options() # save current options
  on.exit(options(old)) #Revert to original options on exit
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
  set_avesdata_repo_path(avesdata_path, overwrite=refresh)
  message("AvesData repo downloaded and upziped to:", path)
  invisible(avesdata_path)
}


#' Set path to Aves Data folder already somewhere on your computer
#' Based on https://github.com/CornellLabofOrnithology/auk/blob/main/R/auk-set-ebd-path.r
#' @param path A character vector with the path to the Aves Data folder.
#'
#' @export
#' @examples
#' \dontrun{
#' set_avesdata_repo_path("/home/ejmctavish/AvesData")
#' }
set_avesdata_repo_path <- function(path, overwrite = FALSE){
  if (!file.exists(path)){
      stop("AvesData folder not found at: ", path)
    }
  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  # find .Renviron
  renv_path <- renv_file_path()
  renv_lines <- readLines(renv_path)
  
  # look for existing entry, remove if overwrite = TRUE
  renv_exists <- grepl("^AVESDATA_PATH[[:space:]]*=.*", renv_lines)
  if (any(renv_exists)) {
    if (overwrite) {
      # drop existing
      writeLines(renv_lines[!renv_exists], renv_path)
    } else {
      stop(
        "AVESDATA_PATH already set, use overwrite = TRUE to overwite existing path."
      )
    }
  }
  # set path in .Renviron
  write(paste0("AVESDATA_PATH='", path, "'\n"), renv_path, append = TRUE)
  message(paste("AVESDATA_PATH set to", path))
  # set AVESDATA_PATH for this session, so user doesn't have to reload
  Sys.setenv(AVESDATA_PATH = path)
  invisible(path)
}

renv_file_path <- function() {
  stored_path <- Sys.getenv("R_ENVIRON_USER")
  if (stored_path != "") {
    renv <- stored_path
  } else {
    renv <- path.expand(file.path("~", ".Renviron"))
  }
  
  if (!file.exists(renv)) {
    file.create(renv)
  }
  return(renv)
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
