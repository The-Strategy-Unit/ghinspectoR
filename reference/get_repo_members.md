# Retrieve collaborators for one or more repositories

Retrieves the list of collaborators for one or more repositories within
a GitHub organisation.

## Usage

``` r
get_repo_members(org, repos, token = get_token())
```

## Arguments

- org:

  GitHub organisation name.

- repos:

  One or more repository names.

- token:

  A GitHub installation access token or personal access token. Default
  uses \`get_token()\`.

## Value

A named list of user objects returned by the GitHub API.

## Examples

``` r
if (FALSE) { # \dontrun{
get_repo_members(org = "my-org", repos = "my-repo")
} # }
```
