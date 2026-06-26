.pkg_env <- new.env(parent = emptyenv())

#' Code used in multiple functions to ensure repository names are normalised
#'
#' @param repos vector
#'
#' @return message
#'
#' @keywords internal
#' @noRd
normalise_repo_names <- function(repos) {
  if (is.data.frame(repos)) {
    if (!"repo_name" %in% names(repos)) {
      stop("Data frame input must contain a `repo_name` column.", call. = FALSE)
    }
    return(repos$repo_name)
  }

  if (is.character(repos)) {
    return(repos)
  }

  stop(
    "`repos` must be either a character vector or a data frame with a `repo_name` column.",
    call. = FALSE
  )
}
