secret_from_connect <- function(var) {
  val <- Sys.getenv(paste0("CONNECT_", var), unset = NA)
  if (!is.na(val) && nzchar(val)) val else NA_character_
}

secret_from_env <- function(var) {
  val <- Sys.getenv(var, unset = NA)
  if (!is.na(val) && nzchar(val)) val else NA_character_
}

secret_from_keyring <- function(service) {
  tryCatch(
    keyring::key_get(service),
    error = function(e) NA_character_
  )
}


#' Generate a GitHub App JWT
#'
#' @description
#' `get_github_jwt()` creates a signed JSON Web Token (JWT) for authenticating
#' as a GitHub App. The function supports multiple credential sources and adapts
#' automatically depending on whether it is running locally, during an
#' `rsconnect` deployment, or on Posit Connect.
#'
#' The lookup order is:
#'
#' 1. values supplied directly to the function
#' 2. (locally) values retrieved from the system keyring via the \{keyring\} package
#' 3. values retrieved from environment variables
#'
#' When running on Posit Connect, the function **always** uses environment
#' variables, because keyring backends are not available there.
#'
#' When publishing locally via `rsconnect::deploy*()`, the function will
#' automatically copy available keyring secrets into environment variables for
#' the duration of the session using `Sys.setenv()`. This behaviour ensures that
#' deployments succeed without requiring permanent changes to `.Renviron`.
#'
#' @param key The GitHub App private key as a PEM string or Base64-encoded PEM.
#'   If `NULL`, the function attempts to retrieve it from the keyring entry
#'   `"GITHUB_APP_PRIVATE_KEY"` (when running locally) and then from the
#'   environment variable of the same name.
#'
#' @param app_id The GitHub App ID. If `NULL`, the function attempts to retrieve
#'   it from the keyring entry `"GITHUB_APP_ID"` (when running locally) and then
#'   from the environment variable of the same name.
#'
#' @param expiry_time The lifetime of the JWT in seconds. Defaults to 30.
#'
#' @return
#' A signed JWT as a character string.
#'
#' @details
#' Private keys stored in environment variables often contain escaped newline
#' characters (e.g., `"\\n"`). The function automatically converts these to real
#' newlines before reading the key.
#'
#' When publishing locally, any secrets copied from keyring into environment
#' variables via `Sys.setenv()` are **temporary** and apply only to the current
#' R session. They are not written to `.Renviron` and do not persist after the
#' session ends.
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
  # 1. Prefer Posit Connect GitHub Integration
  if (is.null(key)) {
    key <- secret_from_connect("GITHUB_APP_PRIVATE_KEY")
  }
  if (is.null(app_id)) {
    app_id <- secret_from_connect("GITHUB_APP_ID")
  }

  # 2. Fallback to local environment variables
  if (is.na(key) || !nzchar(key)) {
    key <- secret_from_env("GITHUB_APP_PRIVATE_KEY")
  }
  if (is.na(app_id) || !nzchar(app_id)) {
    app_id <- secret_from_env("GITHUB_APP_ID")
  }

  # 3. Fallback to keyring for local development
  if (is.na(key) || !nzchar(key)) {
    key <- secret_from_keyring("GITHUB_APP_PRIVATE_KEY")
  }
  if (is.na(app_id) || !nzchar(app_id)) {
    app_id <- secret_from_keyring("GITHUB_APP_ID")
  }

  # 4. Validate
  if (is.na(key) || !nzchar(key)) {
    stop("No GitHub App private key found in Connect, env, or keyring.")
  }
  if (is.na(app_id) || !nzchar(app_id)) {
    stop("No GitHub App ID found in Connect, env, or keyring.")
  }

  # 5. Decode Base64 if needed
  if (grepl("^[A-Za-z0-9+/=]+$", key) && !grepl("BEGIN", key)) {
    key <- rawToChar(openssl::base64_decode(key))
  }

  # 6. Convert escaped newlines
  key <- gsub("\\\\n", "\n", key)

  private_key <- openssl::read_key(key)

  now <- as.numeric(Sys.time())
  claim <- httr2::jwt_claim(
    iat = now - 60,
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
  # NEW: Prefer Posit Connect GitHub Integration
  inst <- Sys.getenv("CONNECT_GITHUB_INSTALLATION_ID", unset = NA)
  if (!is.na(inst) && nzchar(inst)) {
    return(inst)
  }

  # Fallback: discover installation ID via GitHub API
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
