# clootl
## An R package for interfacing with the clootl tree

This is the future (or maybe just a temporary?) home for the clootl project aka the SapsuckerTree, a collaboration between the Cornell Lab of Ornithology and the Open Tree of Life to produce a global avian phylogeny in the Clements taxonomy.

#### Is the tree ready to use?
No, but it's close. We are working on a number of fronts at the moment, and while the code here works, or should, the tree it is relying on is just a placeholder.

#### Can I use it anyhow?
If you insist. Things are in flux, and nothing here is published yet, so proceed with caution. This will get you up and running and show you how to extract a phylogeny and provide proper attribution:
```r
library(devtools)
install_github("eliotmiller/clootl")
library(clootl)
?getCitations
```
