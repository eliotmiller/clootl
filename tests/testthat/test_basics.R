library(clootl)

test_that(desc = "extractTree works with scientific names", code = {
## Test sci name extract
    sci_name_spp <- c("Turdus migratorius",
                      "Setophaga dominica",
                      "Setophaga ruticilla",
                      "Sitta canadensis")



    sci_name_tree <- extractTree(species=sci_name_spp)
        expect_equal( length(sci_name_tree), 6 )
        expect_type( object = sci_name_tree, type = "list")
        expect_equal( sci_name_tree$Nnode, 3 )
        expect_contains(sci_name_tree[['tip.label']], sci_name_spp)

#    sci_name_tree14_2021 <- extractTree(species=sci_name_spp, taxonomy_year=2021)
#    sci_name_tree14_2022 <- extractTree(species=sci_name_spp, taxonomy_year=2022)
    #sci_name_tree14_2023 <- extractTree(species=sci_name_spp, version=1.4, taxonomy_year=2023)
    sci_name_tree16_2025 <- extractTree(species=sci_name_spp, version=1.6, taxonomy_year=2025)

        # expect_identical(sci_name_tree, sci_name_tree14_2023)
#        expect_equal( length(sci_name_tree14_2021), 6 )
        expect_contains(sci_name_tree16_2025[['tip.label']], sci_name_spp)
        expect_equal( length(sci_name_tree16_2025), 6 )
        expect_contains(sci_name_tree16_2025[['tip.label']], sci_name_spp)

    cites <- getCitations(sci_name_tree)

        expect_equal( length(cites), 4 )
        # expect_equal( length(cites[['study']]), 13 )

#    cites2021 <- getCitations(sci_name_tree14_2021)
#    cites2022 <- getCitations(sci_name_tree14_2022)
    # cites2023 <- getCitations(sci_name_tree14_2023)
#    expect_identical(cites, cites2021)
#    expect_identical(cites, cites2022)
    # expect_identical(cites, cites2023)

})



test_that(desc = "extractTree works with code names", code = {
## Test code extract
  code_spp <- c("amerob", "canwar", "reevir1", "yerwar", "gockin")
  code_tree <- extractTree(species=code_spp,
                         label_type="code")
  expect_identical(sort(code_tree[['tip.label']]), sort(code_spp))
  bad_code_spp <- c("amerob", "canwar", "reevir1", "yerwar", "error")
  expect_error(extractTree(species=bad_code_spp,
                         label_type="code"))

  ## Recover using FORCE
  pruned <- extractTree(species=bad_code_spp,
                        label_type="code",
                        force=TRUE)
  expect_equal(length(pruned$tip.label), 4)

})



test_that(des = "sampleTrees works with label type = code", code = {
  expect_error(sampleTrees(species=c("Turdus migratorius",
                        "Setophaga dominica",
                        "Setophaga ruticilla",
                        "Sitta canadensis"),
              label_type="code",
              taxonomy_year="2025",
              version="1.6",
              count=100,
              data_path=FALSE))
  # expect_true(length(xx)==100)
  # expect_s3_class(xx, "multiPhylo")
})

test_that(desc = "errors work on extractTree", code = {
  bad_sci_name_spp <- c("Turdus migratorius",
                        "Setophaga dominica",
                        "Setophaga ruticilla",
                        "Error badspecies")

  expect_error(extractTree(species="all_species",
                           label_type="scientific",
                           taxonomy_year=1999))

  expect_error(extractTree(species="all_species",
                           label_type="scientific",
                           version="0.5"))

  expect_error(extractTree(species="all_species",
                           label_type="scientific",
                           taxonomy_year=2025,
                           version="1.2"))

  expect_error(extractTree(species="all_species",
                           label_type="unknown"))

  expect_error(extractTree(species=bad_sci_name_spp,
                           label_type="scientific"))

  pruned <- extractTree(species=bad_sci_name_spp,
                        label_type="scientific",
                        force=TRUE)
  expect_equal(length(pruned$tip.label), 3)
})

test_that(desc = "extractTree gets the full tree", code = {
  xx <- extractTree()
  expect_s3_class(xx, "phylo")
  xx <- extractTree(label_type = "code")
  expect_s3_class(xx, "phylo")
})

test_that(desc = "errors work on taxonomyGet", code = {
  expect_error(taxonomyGet(taxonomy_year=1999))
})

## Tests below here rely on local data download and should be skipped on cran
test_that(desc = "several data download requiring tests (skip on cran)", code = {
  skip_on_cran()
  old_data_path <- get_avesdata_repo_path()
  tmpdir_path = tempdir()
  # download folder and set path
  get_avesdata_repo(tmpdir_path, overwrite=TRUE) 
  path = get_avesdata_repo_path()

  test_spp = c("Turdus migratorius",
               "Setophaga dominica",
               "Setophaga ruticilla",
               "Sitta canadensis")


  ## Do not pass in data path 
  tree1_5_2022_env <- extractTree(species=test_spp,
                                  version = 1.5,
                                  taxonomy_year=2022)
  expect_equal(length(tree1_5_2022_env$tip.label), 4)

  cites <- getCitations(tree1_5_2022_env, version=1.5)

  expect_equal( length(cites), 4 )

  ## Pass in data path 
  tree1_5_2022_no_env <- extractTree(species=test_spp,
                            version = 1.5,
                            taxonomy_year=2022,
                            data_path=path)
  expect_equal(length(tree1_5_2022_no_env$tip.label), 4)
  expect_identical(tree1_5_2022_no_env, tree1_5_2022_env)


  ## Tree Get from file
  fulltree_1_4_2022 <- clootl:::treeGet(version = 1.4,
                                        taxonomy_year=2022,
                                        data_path=path)
  expect_equal(length(fulltree_1_4_2022$tip.label), 10906)

  ## Taxonomy Get from file
  taxonomy_2021 <- clootl:::taxonomyGet(taxonomy_year=2021,
                                        data_path=path,
                                        from_file=TRUE)
  expect_equal(dim(taxonomy_2021), c(10824, 17))


  xx <- sampleTrees(species=test_spp,
                    label_type="scientific",
                    taxonomy_year="2025",
                    version="1.6",
                    count=100,
                    data_path=path)
  expect_true(length(xx)==100)
  expect_s3_class(xx, "multiPhylo")

  set_avesdata_repo_path(old_data_path, overwrite=TRUE)
  })

