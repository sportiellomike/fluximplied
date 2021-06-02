#' saveData
#'
#' @param data
#'
#' @return
#' @export
#'
saveData <- function(data) {
  data <- as.data.frame(t(data))
  if (exists("responses")) {
    responses <<- rbind(responses, data)
  } else {
    responses <<- data
  }
}
