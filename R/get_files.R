#' Retrieve a single file from a GitHub repository
#'
#' @description
#' Retrieves a single file from a specific repository within an
#' organisation using the GitHub Contents API. The function returns the raw
#' metadata and base64‑encoded content for the requested file.
#'
#' Used in the [get_files()] function that retrieves files across many
#' repositories
#'
#' @param org The GitHub organisation name.
#' @param repo A single repository name.
#' @param token A GitHub installation access token or personal access token.
#' @param file_name string Detail the name of the file being retrieved and
#' include the file extension, for example README.md or README.Rmd.
#'
#' @return
#' A list containing the raw GitHub API response for the requested file.
#'
#' @seealso
#' [get_files()], [tidy_file()], [tidy_files()]
#'
#' @examples
#' \dontrun{
#' file_raw <- get_single_file(
#'   org = "my-org",
#'   repo = "my-repo",
#'   path = "README.md"
#' )
#' }
#'
#' @export
get_single_file <- function(
  org,
  repo,
  file_name,
  token = get_token()
) {
  validate_org(org)

  gh::gh(
    "GET /repos/{org}/{repo}/contents/{path}",
    org = org,
    repo = repo,
    path = file_name,
    .token = token
  )
}

#' Tidy a single file retrieved from a GitHub repository
#'
#' @description
#' Converts the raw output from `get_file()` into a tidy tibble.
#' It extracts metadata such as file name, path, size, and SHA, and decodes the
#' base64‑encoded file content.
#'
#' @param file_raw A raw file object returned by `get_file()`.
#' @param repo_name The name of the repository the file was retrieved from.
#'
#' @return
#' A tibble containing metadata and decoded content for the file.
#'
#' @seealso
#' [tidy_files()], [get_file()], [get_files()]
#'
#' @examples
#' \dontrun{
#' tidy_single_file(file_raw, repo_name = "my-repo")
#' }
#'
#' @export
tidy_single_file <- function(file_raw, repo_name) {
  tibble::tibble(
    repo_name = repo_name,
    file_name = file_raw$name %||% NA_character_,
    path = file_raw$path %||% NA_character_,
    sha = file_raw$sha %||% NA_character_,
    size = file_raw$size %||% NA_integer_,
    encoding = file_raw$encoding %||% NA_character_,
    content = if (!is.null(file_raw$content)) {
      rawToChar(base64enc::base64decode(file_raw$content))
    } else {
      NA_character_
    }
  )
}

#' Retrieve a specific file from multiple GitHub repositories
#'
#' @description
#' Retrieves the same file from multiple repositories within an
#' organisation. It accepts either a character vector of repository names or a
#' data frame containing a `repo_name` column. The function returns a named list
#' of raw GitHub API responses.
#'
#' @param repos A character vector of repository names or a data frame with a
#'   `repo_name` column.
#' @param org The GitHub organisation name.
#' @param token A GitHub installation access token or personal access token.
#' @param file_name string Detail the name of the file being retrieved and
#' include the file extension, for example README.md or README.Rmd.
#'
#' @return
#' A named list where each element contains the raw API response for the file
#' retrieved from a repository.
#'
#' @seealso
#' [get_file()], [tidy_file()], [tidy_files()]
#'
#' @examples
#' \dontrun{
#' files_raw <- get_files(
#'   repos = c("repo1", "repo2"),
#'   org = "my-org",
#'   path = "README.md"
#' )
#' }
#'
#' @export
get_files <- function(
  repos,
  org,
  file_name,
  token = get_token()
) {
  validate_org(org)
  repo_names <- normalise_repo_names(repos)

  purrr::map(
    repo_names,
    \(repo) {
      get_single_file(
        org = org,
        repo = repo,
        file_name = file_name,
        token = token
      )
    }
  ) |>
    purrr::set_names(repo_names)
}

#' Tidy multiple files retrieved from GitHub repositories
#'
#' @description
#' Tidies the list output of `get_files()` converting to a combined tibble.
#'
#' @param files_list A named list of raw file objects returned by `get_files()`.
#'
#' @return
#' A tibble containing metadata and decoded content for each file across all
#' repositories.
#'
#' @seealso
#' [tidy_single_file()], [get_single_file()], [get_files()]
#'
#' @examples
#' \dontrun{
#' files <- tidy_single_files(files_raw)
#' }
#'
#' @export
tidy_files <- function(files_list) {
  purrr::imap_dfr(
    files_list,
    \(file_raw, repo_name) tidy_single_file(file_raw, repo_name)
  )
}
