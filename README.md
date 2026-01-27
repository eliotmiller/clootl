# clootl

<!-- badges: start -->

<!-- usethis::use_cran_badge() -->

[![CRAN status](https://www.r-pkg.org/badges/version/clootl)](https://CRAN.R-project.org/package=clootl) [![CRAN RStudio mirror downloads](https://cranlogs.r-pkg.org/badges/clootl)](https://www.r-pkg.org/pkg/clootl)

<!-- badges: end -->

## An R package for interfacing with the clootl tree

Welcome to the clootl project! If you need a bird phylogeny, you've come to the right place. This is the place to be for downloading and learning how to use clootl.

#### What does clootl do?

Downloads the clootl phylogeny to your local machine and provides a set of functions for extracting and interacting with it. The most significant of these are `extractTree`, used for extracting a phylogeny pruned to a set of user-defined species, and `getCitations`, used for listing and quantifying the contribution of constituent phylogenies to these extracted trees.

#### What does clootl come with?

The package here, which you can also find over on [CRAN](https://cran.r-project.org/web/packages/clootl/index.html), comes with a series of maximum clade credibility (MCC) trees. We anticipate that most users are going to want the current phylogeny in the current Clements taxonomy, and that is part of the "base" clootl download. This download also includes MCC trees for a number of older Clements taxonomies and tree topologies. We've been working on this project since 2020, maintaining these older taxonomies and topologies, but 2025 marks an inflection point in our pace of development. It will be challenging to produce the current topology in older taxonomies. We're not saying we won't do it, but we'd want to hear a clamoring of need for it before we invest the time. After this year we will retire pre-2025 taxonomies and pre-v1.6 tree topologies, and going forward intend to maintain 1-2 years' worth of previous taxonomy/phylogeny combinations at any given time.

While our approach in building the clootl trees glosses over the uncertainty associated with topology in the input trees, there is still an element of stochasticity in the resolution of polytomies, the placement of the missing taxa, and the time-scaling steps. We provide a "cloud" of complete, time-scaled phylogenies in a [separate download](https://github.com/eliotmiller/clootl/blob/master/examples/dataDownload.md), and clootl comes with functionality for integrating this download with existing tree manipulation functions.

#### How do I download clootl?

Easy, recommended:

``` r
library(devtools)
install_github("eliotmiller/clootl")
library(clootl)
```

Not recommended. The version posted to CRAN can lag behind what you'll find here, but if you insist, you can download clootl from CRAN:

``` r
install.packages("clootl")
library(clootl)
```

### Tutorials

-   [Getting Started](https://github.com/eliotmiller/clootl/blob/master/examples/intro.md)
-   [Downloading the Data Repository](https://github.com/eliotmiller/clootl/blob/master/examples/dataDownload.md)
