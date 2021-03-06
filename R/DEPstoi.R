#' DEPstoi: A package for stoichiometry analysis of label-free proteomics data
#'
#' This package provides the analysis workflow for stoichiometry
#' analysis of data from affinity purification experiments followed
#' by mass spectrometry analysis (AP-MS) as published previously (
#' \href{http://nar.oxfordjournals.org/content/41/1/e28.long}{ref}).
#' The package is an extention of the DEP
#' package and it requires tabular input as generated by
#' \href{http://www.nature.com/nbt/journal/v26/n12/full/nbt.1511.html}{MaxQuant}
#' with iBAQ quantification enabled. Functions are provided for the analysis
#' and visualization. For scientists with limited experience in R,
#' the package also contains wrapper functions that entail the complete
#' analysis workflow and generate a report.
#'
#' @section Shiny apps:
#' \itemize{
#'   \item \code{\link{run_app}}: Shiny apps for interactive analysis.
#' }
#'
#' @section Workflow functions:
#' \itemize{
#'   \item \code{\link{iBAQ}}:
#'   iBAQ-based stoichiometry workflow wrapper.
#' }
#'
#' @section Functions:
#' \itemize{
#'   \item \code{\link{merge_ibaq}}:
#'   Merge iBAQ intensities of protein groups with shared peptides.
#'   \item \code{\link{get_stoichiometry}}:
#'   Calculate relative stoichiometry of all significant proteins.
#'   \item \code{\link{plot_stoichiometry}}:
#'   Barplot of relative stoichiometries.
#'   \item \code{\link{plot_ibaq}}:
#'   Scatter plot of fold changes versus iBAQ intensity.
#' }
#' @section Example data:
#' \itemize{
#'   \item \code{\link{GFPip}}:
#'   EED protein interactors (IP-MS dataset)
#'   (Kloet et al. Nat. Struct. Mol. Biol. 2016).
#'   \item \code{\link{GFPip_ExpDesign}}:
#'   Experimental design of the GFPip dataset.
#'   \item \code{\link{GFPip_pep}}:
#'   Peptides table of the GFPip dataset.
#' }
#'
#' @docType package
#' @name DEPstoi
#'
#' @import DEP ggplot2 dplyr SummarizedExperiment ggrepel
#' @import shinydashboard
#' @importFrom shiny runApp
#' @importFrom DT dataTableOutput renderDataTable
#' @importFrom assertthat assert_that
#' @importFrom tidyr unite gather spread separate
#' @importFrom tibble rownames_to_column column_to_rownames
#' @importFrom purrr map_df
#' @importFrom readr parse_factor
#' @importFrom stats median model.matrix rnorm sd cor prcomp
#'
#'
NULL
