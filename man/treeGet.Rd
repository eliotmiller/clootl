% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extractTree.R
\name{treeGet}
\alias{treeGet}
\title{Load a bird tree into the R environment}
\usage{
treeGet(version, taxonomy_year, data_path = FALSE)
}
\arguments{
\item{version}{The desired version of the tree. Default to the most recent
version of the tree. Other versions available are '0.1','1.0','1.2','1.3','1.4', and can be passed as a character string or as numeric.}

\item{taxonomy_year}{The eBird taxonomy year the tree should be output in. Set to "current"
to extract a tree in the most recent taxonomic version. Otherwise, a numeric should be
passed in, e.g. 2021.}

\item{data_path}{Default to \code{FALSE}, it will look for a path containing the bird tree.
If the tree has not been downloaded yet using \code{\link[=get_avesdata_repo]{get_avesdata_repo()}}, it will load the default tree using \code{\link[utils:data]{utils::data()}} and \code{version} and \code{taxonomy_year} will be ignored??
If the tree has been downloaded using \code{\link[=get_avesdata_repo]{get_avesdata_repo()}}, it will read the tree file corresponding to the \code{version} and \code{taxonomy_year} provided and load it as a \code{phylo} object.}
}
\description{
\code{treeGet} either reads a tree file and loads it
as a \code{phylo} object, or loads the default tree data object.
}
\details{
This will return a data object that has the requested tree.
}
