% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/initialProcessing.R
\name{initialProcessing}
\alias{initialProcessing}
\title{Randomly resolve polytomies and enforce ultrametric}
\usage{
initialProcessing(orig.tree)
}
\arguments{
\item{orig.tree}{Phylogeny in ape format.}
}
\value{
A fully resolved and strictly ultrametric tree.
}
\description{
Initial tree processing
}
\details{
This function relies on a random polytomy resolver re-used, under a GPL-3 license,
from the PDcalc package by David Nipperess (https://github.com/davidnipperess/PDcalc/tree/master).
It also uses code borrowed from a blog post by Jonathan Chang to force a tree to be
strictly ultrametric
(https://www.r-bloggers.com/2021/07/three-ways-to-check-and-fix-ultrametric-phylogenies/).
}
\examples{
#load the base tree and send it through the initial processing steps
data(dataStore)
newTree <- initialProcessing(dataStore$year2021$trees$v0.1$base.tree)
}
\author{
Eliot Miller, David Nipperess, Jonathan Chang
}
