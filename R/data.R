#' A complex data store used in the package.
#'
#' Taxonomy files and phylogenies.
#'
#' @format List of csv files and Newick and Nexus phylogenies
#' @source \url{https://github.com/eliotmiller/clootl}
#' @details
#' clootl_data = list()
#'
#'
#' clootl_data$versions <- c('1.2','1.3','1.4', '1.5')
#
#' tax2021 <- taxonomyGet(2021, data_path="~/projects/otapi/AvesData")
#' tax2022 <- taxonomyGet(2022, data_path="~/projects/otapi/AvesData")
#' tax2023 <- taxonomyGet(2023, data_path="~/projects/otapi/AvesData")
#' tax2024 <- taxonomyGet(2024, data_path="~/projects/otapi/AvesData")
#'
#' clootl_data$taxonomy.files$Year2021 <- tax2021
#' clootl_data$taxonomy.files$Year2022 <- tax2022
#' clootl_data$taxonomy.files$Year2023 <- tax2023
#' clootl_data$taxonomy.files$Year2024 <- tax2024
#'
#' clootl_data$tax_years <- c("2021","2022","2023","2024")
#' annot_filename <- "~/projects/otapi/AvesData/Tree_versions/Aves_1.5/OpenTreeSynth/annotated_supertree/annotations.json"
#' all_nodes <- jsonlite::fromJSON(txt=annot_filename)
#'
#' clootl_data$trees$`Aves_1.5`$annotations <- all_nodes
#' save(clootl_data, file="~/projects/otapi/clootl/data/clootl_data.rda")
#'
"clootl_data"
