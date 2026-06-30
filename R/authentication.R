# Local development
get_local_token <- function(env_var = "GH_PAT") {
  token <- tryCatch(
    keyring::key_get(env_var),
    error = function(e) NULL
  )
  if (!is.null(token)) {
    message("Using keyring to access ", env_var)
    return(token)
  }
  token <- Sys.getenv(env_var)
  if (nzchar(token)) {
    message("Using environment variable ", env_var)
    return(token)
  }
  stop(
    env_var,
    " not found. ",
    "Set it via keyring::key_set(\"",
    env_var,
    "\") ",
    "or add it to your .Renviron."
  )
}

# Posit Connect: Quarto / scheduled content (application credential)
get_connect_app_token <- function() {
  message("Using Posit Connect application OAuth credentials")
  client <- connectapi::connect()
  creds <- connectapi::get_oauth_content_credentials(client)
  creds$access_token
}

# Posit Connect: Shiny (per-user credential)
get_connect_user_token <- function(session) {
  message("Using Posit Connect user OAuth credentials")
  connectapi::get_oauth_user_credentials(session) # confirm exact API for your connectapi version
}


#' Title
#'
#' @param env_var default is GH_PAT
#'
#' @returns
#' @export
get_token <- function(env_var = "GH_PAT") {
  if (nzchar(Sys.getenv("CONNECT_SERVER"))) {
    return(get_connect_app_token())
  }
  get_local_token(env_var)
}
