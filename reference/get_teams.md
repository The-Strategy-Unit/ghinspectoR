# Retrieve organisation teams

Retrieves teams (grouped members) within a GitHub organisation.

## Usage

``` r
get_teams(org, token = get_token())
```

## Arguments

- org:

  GitHub organisation name.

- token:

  A GitHub installation access token or personal access token. Default
  uses \`get_token()\`

## Value

list user objects returned by the GitHub API.

## Examples

``` r
if (FALSE) { # \dontrun{
get_teams(org = "my-org")
} # }
```
