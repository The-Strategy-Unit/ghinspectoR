#' Retrieve CODEOWNERS files for one or more repositories
#'
#' @description
#' Retrieves the CODEOWNERS file for each repository in the input. The function
#' searches all valid CODEOWNERS locations within each repository using the
#' internal helper [gh_get_file].
#'
#' @details
#' GitHub allows CODEOWNERS files to be stored in multiple locations. This
#' function checks all valid paths and returns the first match. If no
#' CODEOWNERS file exists for a repository, the corresponding list element is
#' `NULL`.
#'
#' @inheritParams shared_params token org repos
#'
#' @return
#' A named list where each element contains:
#' * the raw GitHub API response for the CODEOWNERS file, or
#' * `NULL` if no CODEOWNERS file exists.
#'
#' @seealso
#' * [tidy_codeowners] for converting results into a tidy data frame.
#'
#' @examples
#' \dontrun{
#' my_repos <- get_repos("my-org") |> tidy_repos()
#' get_codeowners(org = "my-org", repos = my_repos)
#' }
#'
#' @export
get_codeowners <- function(
  repos,
  org,
  token = get_token()
) {
  validate_org(org)
  repo_names <- normalise_repo_names(repos)

  safe_get_files <- purrr::possibly(get_files, otherwise = NULL)

  purrr::map(
    repo_names,
    \(repo) get_files(org, repo, "CODEOWNERS", token)
  ) |>
    purrr::set_names(repo_names)
}


#' Convert CODEOWNERS API responses into a tidy data frame
#'
#' @description
#' Converts the list returned by [get_codeowners] into a tidy data frame.
#'
#' @details
#' When a CODEOWNERS file exists, the function decodes the base64-encoded
#' content and records the path where the file was found (as determined by
#' [gh_get_file]).
#'
#' When no CODEOWNERS file exists, the function records:
#' * `has_codeowners = FALSE`
#' * `codeowners_path = NA`
#' * `codeowners_text = NA`
#'
#' @param codeowner_list A named list returned by [get_codeowners].
#'
#' @return
#' A data frame with columns:
#' * `repo_name`: repository name,get_
#' * `has_codeowners`: logical indicator,
#' * `codeowners_path`: the path where the file was found,
#' * `codeowners_text`: decoded file contents.
#'
#' @examples
#' \dontrun{
#' my_repos <- get_repos("my-org") |> tidy_repos()
#' get_codeowners(org = "my-org", repos = my_repos) |> tidy_codeowners()
#' }
#'
#' @export
tidy_codeowners <- function(codeowner_list) {
  purrr::imap_dfr(
    codeowner_list,
    \(co, repo_name) {
      if (is.null(co) || is.null(co$content)) {
        return(tibble::tibble(
          repo_name = repo_name,
          has_codeowners = FALSE,
          codeowners_url = if (!is.null(co$html_url)) {
            co$html_url
          } else {
            NA_character_
          },
          codeowners_text = NA_character_
        ))
      }
      text <- rawToChar(base64enc::base64decode(gsub("\n", "", co$content)))
      tibble::tibble(
        repo_name = repo_name,
        has_codeowners = TRUE,
        codeowners_url = co$html_url,
        codeowners_text = text
      )
    }
  )
}
