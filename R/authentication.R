# Internal authentication helpers for GitHub App access
#
# These functions create a JWT for the GitHub App, retrieve the installation ID,
# and exchange the JWT for an installation access token. They are not exported
# and are used internally by the GitHub API helper layer.
#
# Users should not call these functions directly.

# Internal: create a JWT for the GitHub App
get_github_jwt <- function(
  key = gsub("\\\\n", "\n", Sys.getenv("GITHUB_APP_PRIVATE_KEY")),
  app_id = Sys.getenv("GITHUB_APP_ID"),
  expiry_time = 30
) {
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

# Internal: exchange JWT for an installation access token
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
