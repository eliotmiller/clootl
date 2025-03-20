.onAttach<-function(libname, pkgname){
    requireNamespace("utils")
    cit<-utils::citation(pkgname)
    txt<-paste(c(format(cit,"citation")),collapse="\n\n")
    txt<-paste(c(txt, "The current version of the Aves tree is v1.4.
        Please specify the tree and taxonomy version used when citing this R package.
        When possible, cite all the original studies supporting your tree:
        These citations are acessible using getCitations(your_tree)"),collapse="\n\n")
    packageStartupMessage(txt)
}
