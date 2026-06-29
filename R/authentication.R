#' Retrieve a GitHub personal access token
#'
#' @description
#' Retrieves a GitHub personal access token (PAT) from one of several sources,
#' depending on the environment in which the code is running. Sources are tried
#' in the following order:
#'
#' 1. **Posit Connect** — if the `CONNECT_SERVER` environment variable is set,
#'    OAuth content credentials are retrieved via `connectapi`.
#' 2. **Keyring** — if a secret matching `env_var` exists in the system
#'    keyring, it is returned. This is the preferred local approach.
#' 3. **Environment variable** — if `env_var` is set in the global or
#'    project-level `.Renviron`, that value is returned.
#'
#' If none of these sources yields a token, the function stops with a message
#' guiding the user to set credentials via `keyring::key_set()` or `.Renviron`.
#'
#' @param env_var A string giving the name of the credential to look up in the
#'   keyring and environment. Defaults to `"GH_PAT"`. Override this if your
#'   project uses a different credential name.
#'
#' @return A string containing the GitHub PAT, or a Posit Connect OAuth
#'   credentials object when running on Connect.
#'
#' @examples
#' \dontrun{
#' # Use the default credential name
#' token <- get_token()
#'
#' # Use a project-specific credential name
#' token <- get_token(env_var = "GH_PAT_MYPROJECT")
#' }
#'
#' @seealso
#' [keyring::key_set()] to store credentials in the keyring,
#' [connectapi::get_oauth_content_credentials()] for Posit Connect
#' authentication.
#'
#' @export
get_token <- function(env_var = "GH_PAT") {
  if (exists("token", envir = .pkg_env)) {
    return(.pkg_env$token)
  }

  # Posit Connect: use OAuth credentials
  if (nzchar(Sys.getenv("CONNECT_SERVER"))) {
    message("Running on Posit Connect using OAuth credentials")
    client <- connectapi::connect()
    creds <- connectapi::get_oauth_content_credentials(client)
    token <- creds$access_token # or creds$token — the debug output will tell you
    .pkg_env$token <- token
    return(token)
  }
  if (!is.null(token)) {
    message("Using keyring to access ", env_var)
  } else {
    # Fallback: environment variable
    token <- Sys.getenv(env_var)
    if (nzchar(token)) {
      message("Using environment variable ", env_var)
    } else {
      stop(
        env_var,
        " not found. ",
        "Set it via keyring::key_set(\"",
        env_var,
        "\") ",
        "or add it to your .Renviron."
      )
    }
  }

  .pkg_env$token <- token
  token
}
