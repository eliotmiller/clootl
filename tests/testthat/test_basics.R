library(clootl)

## Test sci name extract
sci_name_spp <- c("Turdus migratorius",
                  "Setophaga dominica",
                  "Setophaga ruticilla",
                  "Sitta canadensis")
sci_name_tree <- extractTree(species=sci_name_spp)


expect_identical(sort(sci_name_tree$tip.labels), sort(sci_name_spp))

## Test code extract
code_spp <- c("amerob", "canwar", "reevir1", "yerwar", "gockin")
code_tree <- extractTree(species=code_spp,
                         label_type="code")

expect_identical(sort(code_tree$tip.labels), sort(code_spp))