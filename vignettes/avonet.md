AvonetTutorial
================
2025-04-03

## Installing clootl

clootl is currently in review at CRAN. For the time being you can
install it from Github using devtools. We also need a few other packages
for this demo

    ## Installing package into '/home/ejmctavish/R/x86_64-pc-linux-gnu-library/4.4'
    ## (as 'lib' is unspecified)
    ## Installing package into '/home/ejmctavish/R/x86_64-pc-linux-gnu-library/4.4'
    ## (as 'lib' is unspecified)

    ## Loading required package: ape

    ## Loading required package: maps

``` r
install.packages("devtools")
library(devtools)  
install_github("eliotmiller/clootl")
```

``` r
library(clootl)
```

    ## To cite package 'clootl' in publications use:
    ## 
    ##   Miller E, McTavish E, Sanchez-Reyes L (2025). "clootl: Fetch and
    ##   Explore the Cornell Lab of Ornithology Open Tree of Life Avian
    ##   Phylogeny." <https://github.com/eliotmiller/clootl>.
    ## 
    ##   McTavish E, Gerbracht J, Holder M, Iliff M, Lepage D, Rasmussen P,
    ##   Redelings B, Sanchez-Reyes L, Miller E (2025). "A complete and
    ##   dynamic tree of birds." _Proceedings of the National Academy of
    ##   Sciences_.
    ## 
    ## To see these entries in BibTeX format, use 'format(<citation>,
    ## bibtex=TRUE)', or 'toBibtex(.)'.
    ## 
    ## The current version of the Aves tree is v1.4.
    ##         Please specify the tree and taxonomy version used when citing this R package.
    ##         When possible, cite all the original studies supporting your tree:
    ##         These citations are acessible using getCitations(your_tree)

## Getting avonet data

An important feature of our new phylogeny is its interoperability and
connection to existing databases and resources. As an example of this
feature, we illustrate how the phylogeny can be connected to AVONET
\[@tobias_avonet_2022\], a database of morphological measurements for
the world’s birds.

To access AVONET, use the `readxl` \[@wickham2019package\] package to
access the database directly from Figshare.

``` r
library(readxl)

# Define the file URL and destination
file_url <- "https://figshare.com/ndownloader/files/34480856"
destfile <- tempfile(fileext = ".xlsx")

# Download the file
download.file(file_url, destfile, mode = "wb")

# Read the sheet that corresponds to eBird taxonomy
dat <- as.data.frame(read_excel(destfile, sheet = "AVONET2_eBird"))

# Create a column with underscores for simplicity later
dat$underscores <- sub(" ", "_", dat$Species2)
```

Importantly, AVONET was published in the 2021 version of the
eBird/Clements taxonomy \[@clements_ebird/clements_2019\]. While AVONET
does contain Avibase taxon IDs \[@lepage_avibase_2014\] that can be used
to fast-forward the database to newer taxonomies–and we strongly
recommend doing this for real research use–the simplest approach, for
example purposes, is to extract a phylogeny in 2021 taxonomy.

``` r
# Take a random sample of 50 species
spp <- sample(dat$Species2, 50)

# Extract a tree for these species
prunedTree <- extractTree(species=spp, label_type="scientific", taxonomy_year=2021, version="1.4")
```

This leaves us with a paired dataset and phylogeny. Align these further,
and use phytools \[@revell2024phytools\] to visualize the distribution
of body mass across the phylogeny of these 50 random taxa.

``` r
library(phytools)
prunedDat <- dat[dat$Species2 %in% spp,]

# Pull a vector of traits out, log transform for normality
x <- log(prunedDat$Mass)
names(x) <- prunedDat$underscores

# Plot log body mass across the phylogeny
contMap(prunedTree, x, fsize=0.5)
```

![](avonet_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->
