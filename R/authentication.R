#' Get a GitHub token for local development
#'
#' Retrieves a GitHub Personal Access Token (PAT) for use outside of Posit
#' Connect, such as when running scripts or rendering reports interactively
#' on a local machine. The token is looked up from three sources in turn,
#' stopping at the first one found: the system keyring, a Git credential
#' already known to `gitcreds` (for example set up via the `gh` CLI or
#' `usethis::create_github_token()`), and finally an environment variable
#' (typically set in `.Renviron`).
#'
#' @param env_var Character. The name of the keyring entry and/or
#'   environment variable holding the GitHub PAT. Defaults to `"GH_PAT"`.
#'
#' @return A character string containing the GitHub PAT.
#'
#' @details
#' This function is intended for **local use only**. On Posit Connect, use
#' [get_connect_app_token()] (for non-interactive content such as Quarto
#' reports) or [get_connect_user_token()] (for Shiny apps using per-user
#' OAuth) instead. See [get_token()] for a wrapper that selects the
#' appropriate function automatically based on execution context.
#'
#' Credentials are checked in the following order:
#'
#' 1. **`keyring`** — a secret explicitly stored under `env_var` via
#'    `keyring::key_set()`. This is the most deliberate and most secure
#'    option, since OS-level credential stores (macOS Keychain, Windows
#'    Credential Manager) encrypt secrets at rest.
#' 2. **`gitcreds`** — a credential already known to Git tooling, typically
#'    discovered via the same OS credential store used by `keyring`. This
#'    will pick up a token if you have previously authenticated `git` on
#'    the command line (CLI), run `gh auth login`, or use
#'    `usethis::create_github_token()`. Note that a token found this way
#'    may have broader scopes than strictly required for this package's
#'    use, since it was likely created for general Git use rather than
#'    specifically for this package.
#' 3. **Environment variable / `.Renviron`** — a plain-text fallback. This
#'    is the least secure of the three options, since the value is stored
#'    unencrypted on disk. **Take care that any file containing the token
#'    (such as `.Renviron`) is never committed to version control or
#'    synced via cloud storage (such as Google Drive, Dropbox).** Add the file
#'    to `.gitignore` before saving any secrets including a token, and prefer
#'    `keyring` or `gitcreds` wherever possible.
#'
#' @seealso [get_token()], [get_connect_app_token()], [get_connect_user_token()]
#'
#' @examples
#' \dontrun{
#' # Looks up GH_PAT in keyring, then gitcreds, then Sys.getenv("GH_PAT")
#' token <- get_local_token()
#'
#' # Use a differently named credential
#' token <- get_local_token("MY_OTHER_GH_PAT")
#' }
#'
#' @export
get_local_token <- function(env_var = "GH_PAT") {
  # 1. keyring: an explicitly-stored secret under env_var
  token <- tryCatch(
    keyring::key_get(env_var),
    error = function(e) NULL
  )
  if (!is.null(token)) {
    message("Using keyring to access ", env_var)
    return(token)
  }

  # 2. gitcreds: a token already known to Git tooling
  token <- tryCatch(
    gitcreds::gitcreds_get()$password,
    error = function(e) NULL
  )
  if (!is.null(token)) {
    message("Using gitcreds to access stored Git credential")
    return(token)
  }

  # 3. Environment variable / .Renviron fallback
  token <- Sys.getenv(env_var)
  if (nzchar(token)) {
    message("Using environment variable ", env_var)
    return(token)
  }
  stop(
    env_var,
    " not found via keyring, gitcreds, or environment variable. ",
    "Set it via keyring::key_set(\"",
    env_var,
    "\"), ",
    "gitcreds::gitcreds_set(), or add it to your .Renviron."
  )
}

#' Get a GitHub token via Posit Connect's application OAuth credentials
#'
#' Retrieves a GitHub OAuth token tied to the deployed content itself (a
#' service-account-style "application" credential), rather than to an
#' individual viewer. This is the appropriate credential type for
#' non-interactive content such as Quarto reports and scheduled jobs running
#' on Posit Connect.
#'
#' @return A character string containing the OAuth access token.
#'
#' @details
#' This function calls [connectapi::connect()] and
#' [connectapi::get_oauth_content_credentials()] to obtain a token
#' associated with the content's configured GitHub OAuth integration on
#' Posit Connect.
#'
#' **This is not the same as a per-user credential.** Because the token is
#' tied to the content rather than to a viewer, it is the same for every
#' execution of that content and is not appropriate for use cases requiring
#' per-user GitHub identity or permissions. For Shiny apps where each
#' viewer should authenticate with their own GitHub account, use
#' [get_connect_user_token()] instead.
#'
#' This function will only succeed when run on Posit Connect with a GitHub
#' OAuth integration configured for the content. It will error if called
#' locally or if no such integration exists.
#'
#' @seealso [get_token()], [get_local_token()], [get_connect_user_token()]
#'
#' @examples
#' \dontrun{
#' # Within a Quarto report deployed to Posit Connect:
#' token <- get_connect_app_token()
#' repos <- get_repos(org = "my-org", token = token)
#' }
#'
#' @export
get_connect_app_token <- function() {
  message("Using Posit Connect application OAuth credentials")
  client <- connectapi::connect()
  creds <- connectapi::get_oauth_content_credentials(client)
  creds$access_token
}

#' Get a GitHub token via Posit Connect's per-user OAuth credentials
#'
#' Retrieves a GitHub OAuth token tied to the individual viewer of a Shiny
#' application, rather than to the application itself. This is the
#' appropriate credential type for interactive Shiny apps where each user
#' should authenticate with, and act as, their own GitHub identity.
#'
#' @param session The Shiny `session` object, as made available inside a
#'   Shiny server function (`function(input, output, session)`).
#'
#' @return A character string containing the viewer's OAuth access token.
#'
#' @details
#' This function calls [connectapi::get_oauth_user_credentials()] to obtain
#' a token scoped to the currently logged-in viewer of a Shiny app deployed
#' to Posit Connect, using a GitHub OAuth integration configured for
#' per-user (viewer) authentication.
#'
#' **This is not the same as an application credential.** Because the
#' `session` object only exists within a running Shiny session, this
#' function cannot be called from non-interactive content such as a Quarto
#' report. For that use case, see [get_connect_app_token()].
#'
#' Because each user's token is specific to their own session, this
#' function should be called fresh for each user/session rather than cached
#' at the package or application level. A typical pattern is to wrap the
#' call in a `reactive()`:
#'
#' ```r
#' server <- function(input, output, session) {
#'   token <- reactive({
#'     get_connect_user_token(session)
#'   })
#' }
#' ```
#'
#' @seealso [get_token()], [get_local_token()], [get_connect_app_token()]
#'
#' @examples
#' \dontrun{
#' server <- function(input, output, session) {
#'   token <- reactive({
#'     get_connect_user_token(session)
#'   })
#'
#'   output$repos <- renderTable({
#'     get_repos(org = "my-org", token = token())
#'   })
#' }
#' }
#'
#' @export
get_connect_user_token <- function(session) {
  message("Using Posit Connect user OAuth credentials")
  client <- connectapi::connect()
  credentials <- connectapi::get_oauth_content_credentials(client, session)
  credentials$access_token
}

#' Get a GitHub token, selecting the source automatically
#'
#' A convenience wrapper that selects an appropriate GitHub token depending
#' on where code is running. On Posit Connect, it returns an application
#' (content) credential via [get_connect_app_token()]. Outside of Posit
#' Connect, it returns a locally stored credential via [get_local_token()].
#'
#' @param env_var Character. The name of the keyring entry and/or
#'   environment variable to use when falling back to [get_local_token()].
#'   Defaults to `"GH_PAT"`. Ignored when running on Posit Connect.
#'
#' @return A character string containing a GitHub token.
#'
#' @details
#' This function is intended for **non-interactive contexts**, such as
#' Quarto reports, scripts, or scheduled jobs, where there is no individual
#' "viewer" to authenticate as. It detects whether it is running on Posit
#' Connect via the `CONNECT_SERVER` environment variable.
#'
#' This function deliberately does **not** dispatch to
#' [get_connect_user_token()], since that function requires a Shiny
#' `session` object that only exists inside an interactive Shiny
#' application. Shiny apps requiring per-user GitHub authentication should
#' call [get_connect_user_token()] directly from the server function rather
#' than relying on this wrapper.
#'
#' @seealso [get_local_token()], [get_connect_app_token()],
#'   [get_connect_user_token()]
#'
#' @examples
#' \dontrun{
#' # Works both locally and when deployed as a Quarto report on Posit Connect
#' token <- get_token()
#' repos <- get_repos(org = "my-org", token = token)
#' }
#'
#' @export
get_token <- function(env_var = "GH_PAT") {
  if (nzchar(Sys.getenv("CONNECT_SERVER"))) {
    return(get_connect_app_token())
  }
  get_local_token(env_var)
}
