#' Generate a GitHub App JWT
#'
#' @description
#' `get_github_jwt()` creates a signed JSON Web Token (JWT) for authenticating
#' as a GitHub App. The function supports three ways of supplying credentials:
#'
#' * explicit function arguments
#' * secrets stored in the system keyring
#' * environment variables
#'
#' The lookup order is:
#'
#' 1. values supplied directly to the function
#' 2. values retrieved from the keyring set up from the \{keyring\} package
#' 3. values retrieved from environment variables
#'
#' If neither a private key nor an app ID can be found, the function stops with
#' an informative error.
#'
#' @param key The GitHub App private key as a PEM string. If `NULL`, the
#'   function attempts to retrieve it from the keyring entry
#'   `"GITHUB_APP_PRIVATE_KEY"` and then from the environment variable of the
#'   same name.
#' @param app_id The GitHub App ID. If `NULL`, the function attempts to retrieve
#'   it from the keyring entry `"GITHUB_APP_ID"` and then from the environment
#'   variable of the same name.
#' @param expiry_time The lifetime of the JWT in seconds. Defaults to 30.
#'
#' @return
#' A signed JWT as a character string.
#'
#' @details
#' Private keys stored in environment variables often contain escaped newline
#' characters. The function automatically converts these to real newlines before
#' reading the key.
#'
#' @examples
#' \dontrun{
#' jwt <- get_github_jwt()
#' }
#'
#' @export

get_github_jwt <- function(
  key = NULL,
  app_id = NULL,
  expiry_time = 30
) {
  get_secret <- function(service, env_var) {
    # 1. Try keyring
    kr <- tryCatch(
      keyring::key_get(service),
      error = function(e) NA_character_
    )

    if (!is.na(kr) && nzchar(kr)) {
      return(kr)
    }

    # 2. Fallback to environment
    env <- Sys.getenv(env_var, unset = NA)
    if (!is.na(env) && nzchar(env)) {
      return(env)
    }

    NA_character_
  }

  # Resolve private key
  if (is.null(key)) {
    key <- get_secret("GITHUB_APP_PRIVATE_KEY", "GITHUB_APP_PRIVATE_KEY")
  }

  # Resolve app ID
  if (is.null(app_id)) {
    app_id <- get_secret("GITHUB_APP_ID", "GITHUB_APP_ID")
  }

  # Validate
  if (is.na(key) || !nzchar(key)) {
    stop(
      "No GitHub App private key found in keyring or environment.",
      call. = FALSE
    )
  }
  if (is.na(app_id) || !nzchar(app_id)) {
    stop("No GitHub App ID found in keyring or environment.", call. = FALSE)
  }

  # Normalise escaped newlines
  key <- gsub("\\\\n", "\n", key)

  private_key <- openssl::read_key(key)

  now <- as.numeric(Sys.time())
  claim <- httr2::jwt_claim(
    iat = now,
    exp = now + expiry_time,
    iss = app_id
  )

  httr2::jwt_encode_sig(claim, key = private_key)
}


# Internal: get installation ID for the GitHub App
get_github_app_installation_id <- function(
  jwt = get_github_jwt(),
  github_api_ep = "https://api.github.com/"
) {
  resp <- httr2::request(github_api_ep) |>
    httr2::req_url_path_append("app", "installations") |>
    httr2::req_method("GET") |>
    httr2::req_auth_bearer_token(jwt) |>
    httr2::req_headers(Accept = "application/vnd.github+json") |>
    httr2::req_perform()

  httr2::resp_check_status(resp)

  httr2::resp_body_json(resp)[[1]][["id"]]
}

#' Generate a GitHub App installation access token
#'
#' @description
#' `get_github_iat_pat()` exchanges a GitHub App JSON Web Token (JWT) for an
#' installation access token. This token is required for making authenticated
#' requests on behalf of a GitHub App installation.
#'
#' The function performs the standard GitHub App authentication flow:
#'
#' 1. A JWT is created using `get_github_jwt()`.
#' 2. The installation ID is retrieved using `get_github_app_installation_id()`.
#' 3. A POST request is made to the GitHub API to obtain an installation access
#'    token.
#'
#' The returned token can be used as a bearer token for subsequent API calls.
#'
#' @param jwt A GitHub App JSON Web Token. Defaults to the value returned by
#'   `get_github_jwt()`.
#' @param installation_id The GitHub App installation ID. Defaults to the value
#'   returned by `get_github_app_installation_id()`.
#' @param github_api_ep The GitHub API endpoint root. Defaults to
#'   `"https://api.github.com/"`.
#'
#' @return
#' A character string containing the installation access token.
#'
#' @examples
#' \dontrun{
#' token <- get_github_iat_pat()
#' }
#'
#' @seealso
#' [get_github_jwt()], [get_github_app_installation_id()]
#'
#' @export
get_github_iat_pat <- function(
  jwt = get_github_jwt(),
  installation_id = get_github_app_installation_id(),
  github_api_ep = "https://api.github.com/"
) {
  resp <- httr2::request(github_api_ep) |>
    httr2::req_url_path_append(
      "app",
      "installations",
      installation_id,
      "access_tokens"
    ) |>
    httr2::req_auth_bearer_token(jwt) |>
    httr2::req_headers(Accept = "application/vnd.github+json") |>
    httr2::req_method("POST") |>
    httr2::req_perform()

  httr2::resp_check_status(resp)

  httr2::resp_body_json(resp) |>
    purrr::pluck("token")
}
