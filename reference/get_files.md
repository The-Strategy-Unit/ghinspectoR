# Retrieve a specific file from multiple GitHub repositories

Retrieves the same file from multiple repositories within an
organisation. It accepts either a character vector of repository names
or a data frame containing a \`repo_name\` column. The function returns
a named list of raw GitHub API responses.

## Usage

``` r
get_files(repos, org, file_name, token = get_github_iat_pat())
```

## Arguments

- repos:

  A character vector of repository names or a data frame with a
  \`repo_name\` column.

- org:

  The GitHub organisation name.

- file_name:

  string Detail the name of the file being retrieved and include the
  file extension, for example README.md or README.Rmd.

- token:

  A GitHub installation access token or personal access token.

## Value

A named list where each element contains the raw API response for the
file retrieved from a repository.

## See also

\[get_file()\], \[tidy_file()\], \[tidy_files()\]

## Examples

``` r
if (FALSE) { # \dontrun{
files_raw <- get_files(
  repos = c("repo1", "repo2"),
  org = "my-org",
  path = "README.md"
)
} # }
```
