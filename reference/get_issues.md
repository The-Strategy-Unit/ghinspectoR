# Retrieve issues for one or more GitHub repositories

\`get_issues()\` retrieves open issues for one or more repositories
within a GitHub organisation or user account. The function returns the
raw GitHub API responses, which can be converted into a tidy data frame
using \[tidy_techdebt_issues()\].

## Usage

``` r
get_issues(repos, org, token = get_token())
```

## Arguments

- repos:

  A character vector of repository names, or a data frame with a column
  named \`repo_name\`.

- org:

  A single character string giving the GitHub organisation or username
  that owns the repositories.

- token:

  A GitHub installation access token or personal access token. The
  default is \`get_token()\`.

## Value

A named list where each element contains the raw issue objects for a
single repository.

## Details

The function queries the GitHub API endpoint: \`GET
/repos/{org}/{repo}/issues\`

Only open issues are retrieved. Pagination is handled automatically.

## See also

\* \[tidy_techdebt_issues()\] for filtering and tidying issue data \*
\[get_token()\] for obtaining the GitHub App installation token
