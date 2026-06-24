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
#' Attempts to retrieve a file from a GitHub repository, optionally checking
#' multiple possible file paths. This is used for files such as `CODEOWNERS`,
#' which may appear in different locations within a repository.
#'
#' @details
#' When `try_common_locations = TRUE` (the default), the function checks the
#' following paths in order:
#' * `file_name`
#' * `.github/{file_name}`
#' * `docs/{file_name}`
#' * lowercase version of `file_name`
#'
#' When `try_common_locations = FALSE`, only the exact `path` is tried.
#'
#' The first existing file is returned. If no file is found, the function
#' returns `NULL`.
#'
#' The returned object includes an additional field:
#' * `requested_path` — the path where the file was found.
#'
#' @param org GitHub organisation or username.
#' @param repo Repository name.
#' @param path File name to search for (for example `"CODEOWNERS"`).
#' @param file_name File name to search for (for example `"CODEOWNERS"`).
#' @param token A GitHub installation access token or personal access token.
#' @param try_common_locations If `TRUE` (the default), the function checks
#'   common alternative locations (`.github/`, `docs/`, lowercase) in addition
#'   to the exact path. Set to `FALSE` when the exact path is known.
#'
#' @return A GitHub API response containing file metadata and base64-encoded
#'   content, or `NULL` if the file does not exist in any of the locations
#'   tried.
#'
#' @keywords internal
#' @noRd
gh_get_file <- function(
  org,
  repo,
  file_name,
  token = get_token(),
  try_common_locations = TRUE
) {
  validate_org(org)
  validate_repo(repo)

  possible_paths <- if (try_common_locations) {
    c(
      file_name,
      file.path(".github", file_name),
      file.path("docs", file_name),
      tolower(file_name)
    )
  } else {
    file_name
  }

  for (p in possible_paths) {
    res <- tryCatch(
      gh::gh(
        "GET /repos/{org}/{repo}/contents/{path}",
        org = org,
        repo = repo,
        path = p,
        .token = token
      ),
      error = function(e) NULL
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
gh_get_commit <- function(org, repo, sha = sha, token = get_token()) {
  validate_org(org)
  validate_repo(repo)

  gh::gh(
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
gh_get_branches <- function(org, repo, token = get_token()) {
  validate_org(org)
  validate_repo(repo)

  gh::gh(
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
gh_get_issues <- function(org, repo, token = get_token()) {
  validate_org(org)
  validate_repo(repo)

  gh::gh(
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
  token = get_token()
) {
  validate_org(org)
  validate_team(team)

  gh::gh(
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
  token = get_token()
) {
  gh::gh(
    "GET /repos/{org}/{repo}/collaborators",
    org = org,
    repo = repo,
    token = token
  )
}
