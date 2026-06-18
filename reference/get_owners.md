# Retrieve organisation owners

Retrieves users with the \`admin\` role (organisation owners).

## Usage

``` r
get_owners(org, token = get_github_iat_pat())
```

## Arguments

- org:

  GitHub organisation name.

- token:

  A GitHub installation access token or personal access token. Default
  uses \`get_github_iat_pat()\`

## Value

list user objects returned by the GitHub API.

## Examples

``` r
if (FALSE) { # \dontrun{
get_owners(org = "my-org")
} # }
```
