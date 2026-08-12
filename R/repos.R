#' Retrieve repositories for a GitHub organisation or user
#'
#' @description
#' Retrieves all repos of a GitHub organisation.
#'
#' @param org A single character string giving the GitHub organisation or
#'   username whose repositories should be retrieved.
#'
#' @param limit The maximum number of repositories to retrieve. The default is
#'   `Inf`, which retrieves all available repositories.
#'
#' @details
#' The function queries the GitHub API endpoint:
#' `GET /orgs/\{org\}/repos`
#'
#' The data response includes metadata for each repository, such as its name,
#' visibility, creation date, and issue counts. Use [tidy_repos] to convert
#' this into a tidy data frame.
#'
#' @return list of repository objects returned by the GitHub API.
#'
#' @seealso
#' * [tidy_repos()] for converting the results into a tidy data frame
#' * [get_token()] for obtaining the GitHub App installation token
#'
#' @examples
#' \dontrun{
#' get_repos(org = "my-org")
#' }
#'
#' @export
get_repos <- function(
  org,
  token = get_token(),
  limit = Inf
) {
  validate_org(org)

  gh::gh(
    "GET /orgs/{org}/repos",
    org = org,
    .limit = limit,
    .per_page = 100,
    .token = token,
    progress = TRUE
  )
}

#' Convert repository list data into a tidy data frame
#'
#' @description
#' Converts the list returned by [get_repos] into a tidy data
#' frame. Each row represents one repository and includes its name, visibility,
#' archive status, issue count, URL, and creation timestamp.
#'
#' @param result A list of repository objects returned by [get_repos].
#'
#' @details
#' The function extracts selected fields from each repository object and
#' constructs a tidy data frame. This format is suitable for summarising
#' repository characteristics or joining with other repository-level data.
#'
#' @return A data frame with the following columns:
#' * `repo_name`: the name of the repository,
#' * `is_private`: whether the repository is private,
#' * `archived`: whether the repository is archived,
#' * `open_issues_count`: the number of open issues,
#' * `repo_url`: the URL of the repository on GitHub,
#' * `created_at`: the timestamp when the repository was created.
#'
#' @seealso
#' * [get_repos] for retrieving the raw repository data
#'
#' @export
tidy_repos <- function(result) {
  result |>
    purrr::map(\(x) {
      tibble::tibble(
        repo_name = purrr::pluck(x, "name"),
        is_private = purrr::pluck(x, "private"),
        archived = purrr::pluck(x, "archived"),
        open_issues_count = purrr::pluck(x, "open_issues_count"),
        repo_url = purrr::pluck(x, "html_url"),
        created_at = purrr::pluck(x, "created_at")
      )
    }) |>
    purrr::list_rbind()
}


#' Retrieve collaborators for one or more repositories
#'
#' @description
#' Retrieves the list of collaborators for one or more repositories within
#' a GitHub organisation.
#'
#' @param org GitHub organisation name.
#' @param repos One or more repository names.
#' @param token A GitHub installation access token or personal access token.
#'   Default uses `get_token()`.
#'
#' @examples
#' \dontrun{
#' get_repo_members(org = "my-org", repos = "my-repo")
#' }
#'
#' @return A named list of user objects returned by the GitHub API.
#'
#' @export

get_repo_members <- function(
  org,
  repos,
  token = get_token()
) {
  validate_org(org)

  # Normalise input to a character vector of repo names
  repo_names <- normalise_repo_names(repos)

  purrr::map(
    repo_names,
    \(repo) gh_get_repo_members(org, repo, token)
  ) |>
    purrr::set_names(repo_names)
}


#' Tidy collaborator data for one or more repositories
#'
#' @description
#' Converts the raw collaborator lists returned by [get_repo_members] into
#' a tidy tibble with one row per collaborator per repository.
#'
#' @param result A named list returned by [get_repo_members].
#'
#' @examples
#' \dontrun{
#' get_repo_members(org = "my-org", repos = "my-repo") |> tidy_repo_members()
#' }
#'
#' @return A tibble containing repository names, logins, and role names.
#'
#' @export

tidy_repo_members <- function(result) {
  purrr::imap_dfr(
    result,
    \(users, repo) {
      purrr::map_dfr(
        users,
        \(u) {
          tibble::tibble(
            repo = repo,
            login = purrr::pluck(u, "login"),
            role_name = purrr::pluck(u, "role_name")
          )
        }
      )
    }
  )
}
