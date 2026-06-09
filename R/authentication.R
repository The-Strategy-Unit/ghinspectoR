#' Retrieve a GitHub token depending on execution environment
#'
#' `get_token()` returns an authentication token suitable for use with the
#' GitHub API. The function automatically detects whether it is running on
#' Posit Connect or in a local development environment and selects the
#' appropriate credential source.
#'
#' - **Posit Connect**
#'   When the environment variable `CONNECT_SERVER` is present and non-empty,
#'   the function assumes it is running on Posit Connect. In this case, it
#'   retrieves the credentials set up in Posit Connect integrations.
#'
#' - **Local development**
#'   When `CONNECT_SERVER` is not set, the function assumes it is running
#'   locally. It retrieves the GitHub token stored in the user's Git
#'   credential store via `gitcreds::gitcreds_get()`.
#'
#' @return A character string containing a GitHub token.
#' @examples
#' \dontrun{
#' token <- get_token()
#' }
get_token <- function() {
  if (nzchar(Sys.getenv("CONNECT_SERVER"))) {
    message("Running on Posit Connect using OAuth credentials")
    client <- connectapi::connect()
    connectapi::get_oauth_content_credentials(client)
  } else {
    message("Running locally using gitcreds to access GH token")
    gitcreds::gitcreds_get()
  }
}
