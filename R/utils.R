#' Download the AvesData full repository
#' @description Pull down full AvesData repository to a working directory
#' @param path Path to download data zipfile to, and where it will be unpacked.  To download into your working directory, use "."
#' @param overwrite Default to `FALSE`. If path exists, will not re-download the data unless overwrite=`TRUE`.
#' @return No return value. This function is used to download the Aves Data repository.
#' @details Will download full data repo from https://github.com/McTavishLab/AvesData. 
#' This data is required to use [sampleTrees()] to sample from the distribution of dated trees,
#' or to access earlier versions of the complete tree. 
#' This function will download the data and set an environmental variable `AVESDATA_PATH` to the location of the data download.
#' When `AVESDATA_PATH` is set, the data_path in any clootl functions with a `data_path` argument will default to this value.
#' To manually set `AVESDATA_PATH` to the location of your downloaded AvesData repo use [set_avesdata_repo_path()]
#' @export
get_avesdata_repo <- function(path,
                              overwrite=FALSE){
  path <- normalizePath(path, winslash = "/")
  if (Sys.getenv("AVESDATA_PATH") != "" & (overwrite == FALSE)){
    message(paste("AVESDATA_PATH already set to:",
                 Sys.getenv("AVESDATA_PATH"),
                 "use overwrite = TRUE to download and overwite existing path."))
    return(invisible(1))
  }

  message("Downloading AvesDataLite repo from github (holds key files from large McTavishLab/AvesData repo). This may take several minutes depending on your connection.")
  url = "https://github.com/McTavishLab/AvesDataLite/archive/refs/heads/main.zip?raw=TRUE"
  old <- options() # save current options
  on.exit(options(old)) #Revert to original options on exit
  options(timeout=1000) # This file is big and can take a little while to download
  if (!file.exists(path)){
      stop("Directory to save AvesData not found:", path)
    }
  zipfilepath = paste(path, "/", "AvesDataLite.zip", sep="")
  if (file.exists(zipfilepath) & (overwrite == FALSE)){
    message("File AvesDataLite.zip already exists. Use overwite = TRUE to download a new version")
  } else {
    utils::download.file(url, destfile = zipfilepath)
    stopifnot(file.exists(zipfilepath)) 
    stopifnot(file.exists(path)) 
    utils::unzip(zipfile = zipfilepath, exdir = path, overwrite=TRUE)
  }
  avesdata_path = paste(path, "/", "AvesDataLite-main", sep="")
  stopifnot(file.exists(avesdata_path)) 
  exp_avesdata_path = path.expand(avesdata_path)
  stopifnot(file.exists(exp_avesdata_path)) 
  set_avesdata_repo_path(avesdata_path, overwrite=overwrite)
  message("AvesDataLite repo downloaded and upzipped to:", avesdata_path)
  invisible(avesdata_path)
}

#' 
#' Get path to Aves Data folder
#' @description Get path to Aves Data folder, if set.
#' @return String - path to Aves Data folder, if set. Returns "" if not set.
#' @details  Based on https://github.com/CornellLabofOrnithology/auk/blob/main/R/auk-set-ebd-path.r
#' Use this function to check stored path to downloaded AvesData folder from https://github.com/McTavishLab/AvesData.
#' When `AVESDATA_PATH` is set, the data_path in any clootl functions with a `data_path` argument will default to this value.
#' @export
#' @examples
#' \dontrun{
#' get_avesdata_repo_path()
#' }
#' @export
get_avesdata_repo_path <- function(){
  path = Sys.getenv("AVESDATA_PATH")
  message(paste("AVESDATA_PATH set to:",
                 path,
                 "use set_avesdata_repo_path to change path."))
  return(path)
}


#' 
#' Set path to Aves Data folder
#' @description Set path to Aves Data folder already somewhere on your computer
#' and store it in your R environment file
#' @param path A character vector with the path to the Aves Data folder
#' @param overwrite Boolean, default to `FALSE`, does not overwrite an existing Aves Data folder. Set to `TRUE` to overwrite.
#' @param warn Boolean, default to `TRUE`, Warns if path does not exist. 
#' Set to FALSE and path="" to unset path.
#' @return No return value, called to set the path to the Aves Data folder.
#' @details  Based on https://github.com/CornellLabofOrnithology/auk/blob/main/R/auk-set-ebd-path.r
#' Use this function to manually set or update location of a downloaded AvesData folder from https://github.com/McTavishLab/AvesData.
#' When `AVESDATA_PATH` is set, the data_path in any clootl functions with a `data_path` argument will default to this value.
#' @export
#' @examples
#' \dontrun{
#' set_avesdata_repo_path("/home/ejmctavish/AvesData")
#' }
set_avesdata_repo_path <- function(path, overwrite = FALSE, warn = TRUE){
  if (!file.exists(path) & (warn == TRUE)){
      stop("Path not found: ", path)
    }
  path <- normalizePath(path, winslash = "/", mustWork = warn)
  # find .Renviron
  renv_path <- renv_file_path()
  renv_lines <- readLines(renv_path)
  renv_path <- path.expand(renv_path)

  # look for existing entry, remove if overwrite = TRUE
  renv_exists <- grepl("^AVESDATA_PATH[[:space:]]*=.*", renv_lines)
  if (any(renv_exists)) {
    if (overwrite) {
      # drop existing
      writeLines(renv_lines[!renv_exists], renv_path)
      Sys.setenv(AVESDATA_PATH = path)

    } else {
      message(paste("AVESDATA_PATH already set to:",
                 Sys.getenv("AVESDATA_PATH"),
                 "use overwrite = TRUE to overwite existing path."))
  }
    }
  else{
    # set path in .Renviron
    write(paste0("AVESDATA_PATH='", path, "'\n"), renv_path, append = TRUE)
    message(paste("AVESDATA_PATH set to", path))
    # set AVESDATA_PATH for this session, so user doesn't have to reload
    Sys.setenv(AVESDATA_PATH = path)
    invisible(path)
  }
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


