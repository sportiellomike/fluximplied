#' loadData
#'
#'@description used in shiny app
#'
#' @return
#' @export
#'
loadData <- function() {
  if (exists("responses")) {
    responses
  }
}
