#' Randomly resolve polytomies and enforce ultrametric phylogenetic tree
#'
#' Initial tree processing
#'
#' @param orig.tree Phylogeny in ape format (`phylo` object).
#'
#' @details This function relies on a random polytomy resolver re-used, under a GPL-3 license,
#' from the PDcalc package by David Nipperess (https://github.com/davidnipperess/PDcalc/tree/master).
#' It also uses code borrowed from a blog post by Jonathan Chang to force a tree to be
#' strictly ultrametric
#' (https://www.r-bloggers.com/2021/07/three-ways-to-check-and-fix-ultrametric-phylogenies/).
#'
#' @return A fully resolved and strictly ultrametric tree.
#'
#' @author Eliot Miller, David Nipperess, Jonathan Chang
#'
#' @export
#'
#' @import ape
#'
#' @examples
#' #load the base tree and send it through the initial processing steps
#' data(clootl_data)
#' # TODO check error next:
#' # newTree <- initialProcessing(clootl_data$trees$Aves_1.3$summary.trees$year2021)

initialProcessing <- function(orig.tree)
{
  #resolve polytomies. only run once
  resolved <- bifurcatr(orig.tree, 1)

  #read and write tree out (documentation for the polytomy resolver says to do this)
  write.tree(resolved, paste(tempdir(),"temp.tre",sep="/"))
  resolved <- read.tree(paste(tempdir(),"temp.tre",sep="/"))

  #stepping into jonathan chang's code. convenience variables
  resolved <- reorder(resolved, "postorder")
  e1 <- resolved$edge[, 1] # parent node
  e2 <- resolved$edge[, 2] # child node
  EL <- resolved$edge.length
  N <- Ntip(resolved)
  ages <- numeric(N + resolved$Nnode)

  for (ii in seq_along(EL)) {
    if (ages[e1[ii]] == 0) {
      ages[e1[ii]] <- ages[e2[ii]] + EL[ii]
    } else {
      recorded_age <- ages[e1[ii]]
      new_age <- ages[e2[ii]] + EL[ii]
      if (recorded_age != new_age) {
        EL[ii] <- recorded_age - ages[e2[ii]]
      }
    }
  }

  ultraTree <- resolved
  ultraTree$edge.length <- EL

  ultraTree
}
