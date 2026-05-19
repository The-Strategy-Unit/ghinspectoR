# Internal GitHub API helper functions
#
# These functions wrap gh::gh() with consistent authentication, error handling,
# and input validation. They are used by the exported functions in the package
# and are not intended to be called directly by users.
# Also used in some get_ functions which use purrr loops for multiple data
# extractions.

#' Internal helper: safe GitHub API call
#'
#' @description
#' Wraps `gh::gh()` in a safe call that returns `NULL` instead of throwing an
#' error. This ensures that API failures do not interrupt higher-level
#' functions.
#'
#' @param endpoint A GitHub API endpoint string.
#' @param ... Additional arguments passed to `gh::gh()`.
#' @param token A GitHub installation access token or personal access token.
#'
#' @return The GitHub API response, or `NULL` if the request fails.
#'
#' @keywords internal
#' @noRd
gh_safe <- function(endpoint, ..., token = get_github_iat_pat()) {
  purrr::possibly(
    gh::gh,
    otherwise = NULL
  )(endpoint, ..., .token = token)
}

#' Internal helper: validate GitHub org
#'
#' @description
#' Checks that the `org` argument is a single character string. Used by all
#' exported GitHub functions to ensure consistent input validation.
#'
#' @param org A GitHub organisation or username.
#'
#' @return Nothing. Throws an error if validation fails.
#'
#' @keywords internal
#' @noRd
validate_org <- function(org) {
  if (!is.character(org) || length(org) != 1) {
    stop("`org` must be a single character string.", call. = FALSE)
  }
}

#' Internal helper: validate GitHub repository name
#'
#' @description
#' Checks that the `repo` argument is a single character string.
#'
#' @param repo A repository name.
#'
#' @return Nothing. Throws an error if validation fails.
#'
#' @keywords internal
#' @noRd
validate_repo <- function(repo) {
  if (!is.character(repo) || length(repo) != 1) {
    stop("`repo` must be a single character string.", call. = FALSE)
  }
}

#' Internal helper: validate GitHub repository team names
#'
#' @description
#' Checks that the `team` argument is a single character string.
#'
#' @param team A repository name.
#'
#' @return Nothing. Throws an error if validation fails.
#'
#' @keywords internal
#' @noRd
validate_team <- function(team) {
  if (!is.character(team) || length(team) != 1) {
    stop("`team` must be a single character string.", call. = FALSE)
  }
}

#' Internal helper: retrieve a file from a GitHub repository
#'
#' @description
#' Attempts to retrieve a file from a GitHub repository by checking multiple
#' possible file paths. This is used for files such as `CODEOWNERS`, which may
#' appear in different locations within a repository.
#'
#' @details
#' The function checks the following paths in order:
#' * `path`
#' * `.github/{path}`
#' * `docs/{path}`
#' * lowercase version of `path`
#'
#' The first existing file is returned. If no file is found, the function
#' returns `NULL`.
#'
#' The returned object includes an additional field:
#' * `requested_path` — the path where the file was found.
#'
#' @param org GitHub organisation or username.
#' @param repo Repository name.
#' @param path File name to search for (e.g., `"CODEOWNERS"`).
#' @param token A GitHub installation access token or personal access token.
#'
#' @return A GitHub API response containing file metadata and base64-encoded
#'   content, or `NULL` if the file does not exist in any known location.
#'
#' @keywords internal
#' @noRd
gh_get_file <- function(org, repo, path, token = get_github_iat_pat()) {
  validate_org(org)
  validate_repo(repo)

  possible_paths <- c(
    path,
    file.path(".github", path),
    file.path("docs", path),
    tolower(path)
  )

  for (p in possible_paths) {
    res <- gh_safe(
      "GET /repos/{org}/{repo}/contents/{path}",
      org = org,
      repo = repo,
      path = p,
      token = token
    )

    if (!is.null(res)) {
      res$requested_path <- p
      return(res)
    }
  }

  NULL
}


#' Internal helper: retrieve a commit by SHA
#'
#' @description
#' Retrieves metadata related to commits for repositories
#'
#' @param org GitHub organisation or username.
#' @param repo Repository name.
#' @param token A GitHub installation access token or personal access token.
#' @param sha SHA detail provided from [get_branches()] and [tidy_branches()]
#'
#' @return A GitHub API response containing commit metadata, or `NULL`.
#'
#' @keywords internal
#' @noRd
gh_get_commit <- function(org, repo, sha = sha, token = get_github_iat_pat()) {
  validate_org(org)
  validate_repo(repo)

  gh_safe(
    "GET /repos/{org}/{repo}/commits/{sha}",
    org = org,
    repo = repo,
    sha = sha,
    token = token
  )
}

#' Internal helper: retrieve branches for a repository
#'
#' @description
#' Retrieves branch metadata for a repository using the GitHub API. Returns the
#' raw API response.
#'
#' @param org GitHub organisation or username.
#' @param repo Repository name.
#' @param token A GitHub installation access token or personal access token.
#'
#' @return A list of branch objects returned by the GitHub API, or `NULL` if the
#'   request fails.
#'
#' @keywords internal
#' @noRd
gh_get_branches <- function(org, repo, token = get_github_iat_pat()) {
  validate_org(org)
  validate_repo(repo)

  gh_safe(
    "GET /repos/{org}/{repo}/branches",
    org = org,
    repo = repo,
    token = token
  )
}

#' Internal helper: retrieve issues for a GitHub repository
#'
#' @description
#' Retrieves open issues for a repository using the GitHub API. This function is
#' used internally by higher-level wrappers such as
#' [get_issues] and should not be called directly
#' by users.
#'
#' @param org GitHub organisation or username.
#' @param repo Repository name.
#' @param token A GitHub installation access token or personal access token.
#'
#' @details
#' The function queries the GitHub API endpoint:
#' `GET /repos/{org}/{repo}/issues`
#'
#' Only open issues are retrieved. Pagination is handled automatically through
#' the underlying GitHub client. Errors are caught and returned as `NULL` via
#' [gh_safe].
#'
#' @return
#' A list of issue objects returned by the GitHub API, or `NULL` if the request
#' fails.
#'
#' @keywords internal
#' @noRd
gh_get_issues <- function(org, repo, token = get_github_iat_pat()) {
  validate_org(org)
  validate_repo(repo)

  gh_safe(
    "GET /repos/{org}/{repo}/issues",
    org = org,
    repo = repo,
    state = "open",
    .per_page = 100,
    .limit = Inf,
    token = token
  )
}

#' Internal helper: retrieve collaborators for a repository
#'
#' @description
#' Retrieves collaborator metadata for a repository using the GitHub API.
#' Returns the raw API response.
#'
#' @param org GitHub organisation or username.
#' @param repo Repository name.
#' @param token A GitHub installation access token or personal access token.
#'
#' @return A list of collaborator objects returned by the GitHub API, or `NULL`
#'   if the request fails.
#'
#' @keywords internal
#' @noRd
gh_get_team_members <- function(
  org,
  team,
  role = "all",
  token = get_github_iat_pat()
) {
  validate_org(org)
  validate_team(team)

  gh_safe(
    "GET /orgs/{org}/teams/{team}/members",
    org = org,
    team = team,
    role = role,
    .limit = Inf,
    token = token
  )
}

#' Internal helper: retrieve collaborators for a repository
#'
#' @description
#' Retrieves collaborator metadata for a repository using the GitHub API.
#' Returns the raw API response.
#'
#' @param org GitHub organisation or username.
#' @param repo Repository name.
#' @param token A GitHub installation access token or personal access token.
#'
#' @return A list of collaborator objects returned by the GitHub API, or `NULL`
#'   if the request fails.
#'
#' @keywords internal
#' @noRd

gh_get_repo_members <- function(
  org,
  repo,
  token = get_github_iat_pat()
) {
  gh_safe(
    "GET /repos/{org}/{repo}/collaborators",
    org = org,
    repo = repo,
    token = token
  )
}
