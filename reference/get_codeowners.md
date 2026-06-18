# Retrieve CODEOWNERS files for one or more repositories

Retrieves the CODEOWNERS file for each repository in the input. The
function searches all valid CODEOWNERS locations within each repository
using the internal helper \[gh_get_file\].

## Usage

``` r
get_codeowners(repos, org, token = get_github_iat_pat())
```

## Arguments

- repos:

  A character vector of repository names, or a data frame with a column
  named \`repo_name\`.

- org:

  GitHub organisation or username.

- token:

  A GitHub installation access token or personal access token. Default
  uses \`get_github_iat_pat()\`

## Value

A named list where each element contains: \* the raw GitHub API response
for the CODEOWNERS file, or \* \`NULL\` if no CODEOWNERS file exists.

## Details

GitHub allows CODEOWNERS files to be stored in multiple locations. This
function checks all valid paths and returns the first match. If no
CODEOWNERS file exists for a repository, the corresponding list element
is \`NULL\`.

## See also

\* \[tidy_codeowners\] for converting results into a tidy data frame.

## Examples

``` r
if (FALSE) { # \dontrun{
my_repos <- get_repos("my-org") |> tidy_repos()
get_codeowners(org = "my-org", repos = my_repos)
} # }
```
