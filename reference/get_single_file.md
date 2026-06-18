# Retrieve a single file from a GitHub repository

Retrieves a single file from a specific repository within an
organisation using the GitHub Contents API. The function returns the raw
metadata and base64‑encoded content for the requested file.

Used in the \[get_files()\] function that retrieves files across many
repositories

## Usage

``` r
get_single_file(org, repo, file_name, token = get_github_iat_pat())
```

## Arguments

- org:

  The GitHub organisation name.

- repo:

  A single repository name.

- file_name:

  string Detail the name of the file being retrieved and include the
  file extension, for example README.md or README.Rmd.

- token:

  A GitHub installation access token or personal access token.

## Value

A list containing the raw GitHub API response for the requested file.

## See also

\[get_files()\], \[tidy_file()\], \[tidy_files()\]

## Examples

``` r
if (FALSE) { # \dontrun{
file_raw <- get_single_file(
  org = "my-org",
  repo = "my-repo",
  path = "README.md"
)
} # }
```
