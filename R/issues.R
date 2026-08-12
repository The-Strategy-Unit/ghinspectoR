#' Retrieve issues for one or more GitHub repositories
#'
#' @description
#' `get_issues()` retrieves open issues for one or more repositories within a
#' GitHub organisation or user account. The function returns the raw GitHub API
#' responses, which can be converted into a tidy data frame using
#' [tidy_techdebt_issues()].
#'
#' @param repos A character vector of repository names, or a data frame with a
#'   column named `repo_name`.
#'
#' @param org A single character string giving the GitHub organisation or
#'   username that owns the repositories.
#'
#' @param token A GitHub installation access token or personal access token.
#'   The default is `get_token()`.
#' @param state String default is "open" for issues and GitHub API allows for
#' options "closed" and "all".
#'
#' @details
#' The function queries the GitHub API endpoint:
#' `GET /repos/\{org\}/\{repo\}/issues`
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
  state = c("open", "closed", "all"),
  token = get_token()
) {
  validate_org(org)

  state <- rlang::arg_match(state)

  repo_names <- normalise_repo_names(repos)

  purrr::map(
    repo_names,
    \(repo) {
      gh_get_issues(
        org = org,
        repo = repo,
        state = state,
        token = token
      )
    }
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
#' @param issue_list A named list of issue objects returned by [get_issues()].
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
tidy_issues <- function(issue_list) {
  purrr::imap_dfr(
    issue_list,
    \(issues, repo_name) {
      if (is.null(issues) || length(issues) == 0) {
        return(tibble::tibble(
          repo_name = repo_name,
          issue_number = NA_integer_,
          issue_title = NA_character_,
          issue_state = NA_character_,
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
        issue_state = purrr::map_chr(
          issues,
          purrr::pluck,
          "state",
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

get_issue_fields <- function(
  org,
  token = get_token()
) {
  validate_org(org)
  gh::gh(
    "GET /orgs/{org}/issue-fields",
    org = org,
    .token = token
  )
}


tidy_issue_fields <- function(result) {
  result |>
    purrr::map(\(x) {
      options <- purrr::pluck(x, "options", .default = list())
      tibble::tibble(
        field_id = purrr::pluck(x, "id"),
        field_name = purrr::pluck(x, "name"),
        data_type = purrr::pluck(x, "data_type"),
        description = purrr::pluck(x, "description", .default = NA_character_),
        option_name = if (length(options) == 0) {
          list(NA_character_)
        } else {
          list(purrr::map_chr(options, "name"))
        }
      )
    }) |>
    purrr::list_rbind() |>
    tidyr::unnest(option_name)
}


get_issue_field_values <- function(issues, org, token = get_token()) {
  validate_org(org)

  issues <- issues |>
    dplyr::filter(!is.na(issue_number))

  purrr::pmap(
    list(repo_name = issues$repo_name, issue_number = issues$issue_number),
    \(repo_name, issue_number) {
      list(
        repo_name = repo_name,
        issue_number = issue_number,
        fields = gh_get_issue_field_values(
          org = org,
          repo = repo_name,
          issue_number = issue_number,
          token = token
        )
      )
    }
  )
}

tidy_issue_field_values <- function(issue_fields) {
  issue_fields <- purrr::keep(issue_fields, \(x) length(x$fields) > 0)

  purrr::map_dfr(
    issue_fields,
    \(issue) {
      tibble::tibble(
        repo_name = issue$repo_name,
        issue_number = issue$issue_number,
        field_id = purrr::map_int(issue$fields, "issue_field_id"),
        field_name = purrr::map_chr(issue$fields, "issue_field_name"),
        data_type = purrr::map_chr(issue$fields, "data_type"),
        value = purrr::map_chr(
          issue$fields,
          \(x) {
            if (!is.null(x$single_select_option)) {
              x$single_select_option$name
            } else {
              as.character(x$value)
            }
          }
        )
      )
    }
  )
}

get_issue_field_names <- function(
  org,
  token = get_token()
) {
  validate_org(org)

  gh::gh(
    "GET /orgs/{org}/issue-fields",
    org = org,
    .token = token
  )
}

tidy_issue_field_names <- function(result) {
  tibble::tibble(
    field_name = purrr::map_chr(
      result,
      purrr::pluck,
      "name",
      .default = NA_character_
    ),
    data_type = purrr::map_chr(
      result,
      purrr::pluck,
      "data_type",
      .default = NA_character_
    ),
    description = purrr::map_chr(
      result,
      purrr::pluck,
      "description",
      .default = NA_character_
    )
  )
}
