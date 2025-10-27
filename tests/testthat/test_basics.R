library(clootl)

test_that(desc = "sci name tree extract", code = {
## Test sci name extract
    sci_name_spp <- c("Turdus migratorius",
                      "Setophaga dominica",
                      "Setophaga ruticilla",
                      "Sitta canadensis")

    sci_name_tree <- extractTree(species=sci_name_spp)
        expect_equal( length(sci_name_tree), 6 )
        expect_type( object = sci_name_tree, type = "list")
        expect_equal( sci_name_tree$Nnode, 3 )
        expect_contains(sci_name_tree[['tip.label']], gsub(" ", "_",sci_name_spp))

    sci_name_tree14_2021 <- extractTree(species=sci_name_spp, taxonomy_year=2021)
    sci_name_tree14_2022 <- extractTree(species=sci_name_spp, taxonomy_year=2022)
    #sci_name_tree13_2023 <- extractTree(species=sci_name_spp, version=1.4, taxonomy_year=2023)
    sci_name_tree15_2023 <- extractTree(species=sci_name_spp, version=1.5, taxonomy_year=2023)

        # expect_identical(sci_name_tree, sci_name_tree14_2023)
        expect_equal( length(sci_name_tree14_2021), 6 )
        expect_contains(sci_name_tree14_2021[['tip.label']], gsub(" ", "_",sci_name_spp))
        expect_equal( length(sci_name_tree14_2022), 6 )
        expect_contains(sci_name_tree14_2022[['tip.label']], gsub(" ", "_",sci_name_spp))

    cites <- getCitations(sci_name_tree)

        expect_equal( length(cites), 4 )
        # expect_equal( length(cites[['study']]), 13 )

    cites2021 <- getCitations(sci_name_tree14_2021)
    cites2022 <- getCitations(sci_name_tree14_2022)
    cites2023 <- getCitations(sci_name_tree14_2023)
    expect_identical(cites, cites2021)
    expect_identical(cites, cites2022)
    # expect_identical(cites, cites2023)

})


test_that(desc = "code name tree extract", code = {
## Test code extract
code_spp <- c("amerob", "canwar", "reevir1", "yerwar", "gockin")
code_tree <- extractTree(species=code_spp,
                         label_type="code")

expect_identical(sort(code_tree[['tip.label']]), sort(code_spp))
})


