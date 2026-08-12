#' Retrieve branch information from GitHub repositories
#'
#' @description
#' Retrieves the list of branches for one or more repositories
#' within a specified GitHub organisation or user account.
#'
#' It accepts either:
#' * a character vector of repository names, or
#' * a data frame containing a `repo_name` column (for example, the output of
#'   [get_repos()])
#'
#' The function returns a named list where each element contains the GitHub API
#' response for the corresponding repository.
#'
#' @inheritParams shared_params token org repos
#'
#' @details
#' Each repository is queried through the GitHub API endpoint:
#' `GET /repos/\{org\}/\{repo\}/branches`
#'
#' The data response includes metadata for each repository, such as its name,
#' visibility, creation date, and issue counts. Use [tidy_repos] to convert
#' this into a tidy data frame.
#'
#' This function is often used after calling [get_repos()] and [tidy_repos()],
#' which return a data frame containing a `repo_name` column.
#'
#' @return
#' A named list with one element per repository. Each element contains the raw
#' GitHub API response for the branches in that repository.
#'
#' @seealso
#' * [get_repos()] for retrieving repository names
#' * [tidy_repos()] for converting the list format to a data frame
#' * [get_token()] for obtaining the GitHub App installation token
#'
#' @examples
#' \dontrun{
#' # Using a character vector
#' get_branches(c("repo1", "repo2"), org = "my-org")
#'
#' # Using a data frame returned by get_repos()
#' repos <- get_repos(org = "my-org") |>  tidy_repos()
#' get_branches(repos, org = "my-org")
#' }
#'
#' @export
get_branches <- function(
  repos,
  org,
  token = get_token()
) {
  validate_org(org)

  # Normalise input to a character vector of repo names
  repo_names <- normalise_repo_names(repos)

  purrr::map(
    repo_names,
    \(repo) gh_get_branches(org, repo, token)
  ) |>
    purrr::set_names(repo_names)
}


#' Convert branch list data into a tidy data frame
#'
#' @description
#' Takes the list returned by [get_branches()] and converts it
#' into a tidy data frame. Each row represents one branch within one repository
#' and includes the branch name, the commit SHA, the timestamp of the most
#' recent commit, and indicators of how long the branch has been inactive.
#'
#' The function retrieves commit timestamps by calling [gh_get_commit()]
#' internal helper.
#'
#' @param branch_list A named list of GitHub API responses returned by
#'   [get_branches()]. Each element should contain branch metadata for a single
#'   repository.
#' @param stale_after_days A number giving the threshold for marking a branch as
#'   stale. Branches with no commits more recent than this number of days are
#'   flagged as stale. The default is 90 days.
#'
#' @inheritParams shared_params token org
#'
#' @return
#' A data frame with the following columns:
#' * `repo_name`: the name of the repository,
#' * `branch`: the branch name,
#' * `sha`: the commit SHA,
#' * `last_commit`: the timestamp of the most recent commit,
#' * `days_since_commit`: the number of days since the most recent commit,
#' * `stale`: whether the branch is older than `stale_after_days`.
#'
#' @seealso
#' * [get_branches()] for retrieving raw branch information
#' * [tidy_branches()] to convert the list data into a data frame
#' * [get_commits()] for retrieving commit metadata
#'
#' @examples
#' \dontrun{
#' # Using a character vector
#' get_branches(c("repo1", "repo2"), org = "my-org")
#'
#' # Using a data frame returned by get_repos()
#' repos <- get_repos(org = "my-org") |>  tidy_repos()
#' get_branches(repos, org = "my-org") |> tidy_branches(org = "my-org",
#' stale_after_days = 90)
#' }
#'
#' @export
tidy_branches <- function(
  branch_list,
  org,
  stale_after_days = 90,
  token = get_token()
) {
  validate_org(org)

  purrr::imap_dfr(
    branch_list,
    \(branches, repo_name) {
      branch_names <- purrr::map_chr(
        branches,
        purrr::pluck,
        "name",
        .default = NA_character_
      )

      shas <- purrr::map_chr(
        branches,
        purrr::pluck,
        "commit",
        "sha",
        .default = NA_character_
      )

      commit_dates <- purrr::map_chr(
        shas,
        \(sha) {
          commit <- gh_get_commit(org, repo_name, sha, token)
          purrr::pluck(
            commit,
            "commit",
            "author",
            "date",
            .default = NA_character_
          )
        }
      )

      last_commit <- lubridate::ymd_hms(commit_dates)

      tibble::tibble(
        repo_name = repo_name,
        branch = branch_names,
        sha = shas,
        last_commit = last_commit,
        days_since_commit = as.numeric(
          Sys.time() - last_commit,
          units = "days"
        ),
        stale = days_since_commit > stale_after_days
      )
    }
  )
}
