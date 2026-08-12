#' Retrieve issues for one or more GitHub repositories
#'
#' @description
#' `get_issues()` retrieves open issues for one or more repositories within a
#' GitHub organisation or user account. The function returns the raw GitHub API
#' responses, which can be converted into a tidy data frame using
#' [tidy_techdebt_issues()].
#'
#' @inheritParams shared_params token org repos
#' @details
#' The function queries the GitHub API endpoint:
#' `GET /repos/\{org\}/\{repo\}/issues`
#'
#' Only open issues are retrieved. Pagination is handled automatically.
#'
#' @return
#' A named list where each element contains the raw issue objects for a single
#' repository.
#'
#' @seealso
#' * [tidy_techdebt_issues()] for filtering and tidying issue data
#' * [get_token()] for obtaining the GitHub App installation token
#'
#' @export

get_issues <- function(
  repos,
  org,
  token = get_token()
) {
  validate_org(org)

  repo_names <- normalise_repo_names(repos)

  purrr::map(
    repo_names,
    \(repo) gh_get_issues(org, repo, token)
  ) |>
    purrr::set_names(repo_names)
}

#' Convert raw issue data into a tidy data frame
#'
#' @description
#' `tidy_issues()` converts the list returned by [get_issues()] into a tidy data
#' frame. Each row represents one issue within one repository and includes the
#' issue number, title, and associated labels.
#'
#' This function is intentionally general and does not filter for specific
#' labels. Filtering (for example, identifying tech debt issues) should be done
#' in downstream analysis.
#'
#' @inheritParams shared_params list
#'
#' @details
#' The function extracts the issue number, title, and labels from each issue
#' object. Labels are returned as a comma-separated string. Missing or empty
#' issue lists are handled safely, and missing values are recorded as `NA`.
#'
#' @return
#' A data frame with the following columns:
#' * `repo_name`: the name of the repository,
#' * `issue_number`: the issue number,
#' * `issue_title`: the issue title,
#' * `labels`: a comma-separated string of all labels applied to the issue.
#'
#' @seealso
#' * [get_issues()] for retrieving raw issue data
#'
#' @examples
#' \dontrun{
#' issues <- get_issues(
#'   repos = c("repo1", "repo2"),
#'   org = "my-org"
#' )
#'
#' tidy_issues(issues)
#' }
#'
#' @export
tidy_issues <- function(list) {
  purrr::imap_dfr(
    list,
    \(issues, repo_name) {
      if (is.null(issues) || length(issues) == 0) {
        return(tibble::tibble(
          repo_name = repo_name,
          issue_number = NA_integer_,
          issue_title = NA_character_,
          labels = NA_character_
        ))
      }

      tibble::tibble(
        repo_name = repo_name,
        issue_number = purrr::map_int(
          issues,
          purrr::pluck,
          "number",
          .default = NA_integer_
        ),
        issue_title = purrr::map_chr(
          issues,
          purrr::pluck,
          "title",
          .default = NA_character_
        ),
        labels = purrr::map_chr(
          issues,
          \(x) {
            lbls <- purrr::pluck(x, "labels", .default = list())
            names <- purrr::map_chr(
              lbls,
              purrr::pluck,
              "name",
              .default = NA_character_
            )
            paste(names, collapse = ", ")
          }
        )
      )
    }
  )
}
