# Retrieve repositories for a GitHub organisation or user

Retrieves all repos of a GitHub organisation.

## Usage

``` r
get_repos(org, limit = Inf, token = get_github_iat_pat())
```

## Arguments

- org:

  A single character string giving the GitHub organisation or username
  whose repositories should be retrieved.

- limit:

  The maximum number of repositories to retrieve. The default is
  \`Inf\`, which retrieves all available repositories.

- token:

  A GitHub installation access token or personal access token. The
  default is \`get_github_iat_pat()\`, which returns a token generated
  by the GitHub App.

## Value

list of repository objects returned by the GitHub API.

## Details

The function queries the GitHub API endpoint: \`GET /orgs/{org}/repos\`

The data response includes metadata for each repository, such as its
name, visibility, creation date, and issue counts. Use \[tidy_repos\] to
convert this into a tidy data frame.

## See also

\* \[tidy_repos()\] for converting the results into a tidy data frame \*
\[get_github_iat_pat()\] for obtaining the GitHub App installation token

## Examples

``` r
if (FALSE) { # \dontrun{
get_repos(org = "my-org")
} # }
```
