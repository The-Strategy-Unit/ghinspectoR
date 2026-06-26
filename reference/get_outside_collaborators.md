# Retrieve outside collaborators

Retrieves outside collaborators for a GitHub organisation. Outside
collaborators have access to specific repositories but are not
organisation members.

## Usage

``` r
get_outside_collaborators(org, token = get_token())
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
get_outside_collaborators(org = "my-org")
} # }
```
