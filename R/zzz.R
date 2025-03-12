.onAttach<-function(libname, pkgname){
    requireNamespace("utils")
    cit<-citation(pkgname)
    txt<-paste(c(format(cit,"citation")),collapse="\n\n")
    txt<-paste(c(txt, "The current version of the Aves tree is v1.3.
        Please specify the tree and taxonomy version used when using this tree."),collapse="\n\n")
    packageStartupMessage(txt)
}
