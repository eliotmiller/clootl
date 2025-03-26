---
title: 'Clootl: R package for exploring the bird tree of life'
tags:
  - phylogeny
authors:
  - name: Eliot Miller
    corresponding: true # (This is how to denote the corresponding author)
    orcid: 0000-0000-0000-0000
    affiliation: 1 # (Multiple affiliations must be quoted)
  - name: Luna Sanchez-Reyes
    orcid: 0000-0000-0000-0000
    affiliation: 2
  - name: Emily Jane McTavish
    orcid: 0000-0001-9766-5727
    affiliation: 2
affiliations:
 - name: 
   index: 1
 - name: University of California, Merced
   index: 2
date: 13 August 2017
bibliography: paper.bib
---

# Summary

We present `clootl`, an R package to access a modern and dynamic phylogeny of the world's birds. The package's name draws inspiration from the collaboration that gave rise to it, a joint effort between the Cornell Lab of Ornithology (CLO) and the Open Tree of Life (OTL) project. The primary functions of the package are to provide access to the tree across a range of taxonomy and synthesis versions, as well as to identify and properly acknowledge the constituent studies that went into creating these phylogenies. These citation functions can flexibly handle tree pruning, so that the acknowledged studies reflect the subset of the data output by a user. While the raw outputs of the new synthetic tree are readily available from a Git repository, `clootl` provides a simple interface for access and citation. Given the demonstrated need for a global avian phylogeny, and the fact that phylogenies are most frequently manipulated within the R environment, we suspect `clootl` will be the most frequently used access point to the newly released global avian phylogeny.

# Statement of need

`Clootl` is an R package for

`Clootl` was designed to be used by

# Discussion and Future Directions

The Open Tree of Life (OTL) project synthesizes published phylogenetic information to create a tree of all life. A rich suite of OTL software resources already exists for curating and interacting with the input phylogenies, and this includes both online tools as well as R and Python packages for programmatic interaction with outputs. While, to date, OTL has largely succeeded in creating and making these resources available to the broad research community, use of the tools, particularly by the ornithology community has been limited. This is because, while dozens of bird phylogenies are published annually, few were actually curated in the OTL system, which limited the downstream quality of the synthetic OTL tree, which led to limited use. The flexible taxonomic approach used by OTL to facilitate data interoperability further impeded community buy-in for birds, which have more carefully curated taxonomic treatments. Yet, the need for a dynamic, updated, high-quality phylogeny of all birds was clear. For example, existing but outdated resources still see hundreds of published use cases per year. Thus, to help OTL fulfill its potential in the avian domain, and start a positive feedback loop of community buy-in, we partnered with the Cornell Lab of Ornithology to begin careful phylogenetic and taxonomic curation of the avian inputs to OTL. The Cornell Lab of Ornithology is a world-leader in the study and conservation of the world’s birds, with a mission to interpret and conserve the earth’s biological diversity through research, education, and community science focused on birds, and their expertise in this domain has powered community engagement with the project. From this partnership the CLO-OTL, or clootl collaboration was born. Beyond those resources already built by OTL, the project has grown to include curated statements on where in the phylogeny missing taxa belong, and it now syncs directly with CLO's annually updated taxonomy (Clements). The software we present here provides an interface for interacting with the clootl products, including taxonomy, tree, and associated bibliographic information about those inputs. While all the curated phylogenies are available via OTL and their existing software resources, the taxonomic additions and branch length scaling (tree dating) steps exist outside of OTL. clootl thus provides direct and easy access to the dynamic outputs from our collaboration–a new and perpetually improving phylogeny of the world's birds.

# Figures

Figures can be included like this: ![Caption for example figure.](figure.png) and referenced from text using \autoref{fig:example}.

Figure sizes can be customized by adding an optional second parameter: ![Caption for example figure.](figure.png){width="20%"}

# Acknowledgements

# References
