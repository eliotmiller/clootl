library(clootl)

test_that(desc = "sci name tree extract", code = {
## Test sci name extract
    sci_name_spp <- c("Turdus migratorius",
                      "Setophaga dominica",
                      "Setophaga ruticilla",
                      "Sitta canadensis")

    sci_name_tree <- extractTree(species=sci_name_spp)
    cites <- getCitations(sci_name_tree)

        expect_equal( length(sci_name_tree), 6 )
        expect_equal( length(cites), 4 )
        expect_equal( length(cites[['study']]), 13 )
        expect_type( object = sci_name_tree, type = "list")  
        expect_equal( sci_name_tree$Nnode, 3 )
        expect_contains(sci_name_tree[['tip.label']], gsub(" ", "_",sci_name_spp))

})


test_that(desc = "code name tree extract", code = {
## Test code extract
code_spp <- c("amerob", "canwar", "reevir1", "yerwar", "gockin")
code_tree <- extractTree(species=code_spp,
                         label_type="code")

expect_identical(sort(code_tree[['tip.label']]), sort(code_spp))
})

