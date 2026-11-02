# Retrieve member details

Retrieves details for multiple members of a GitHub organisation.

## Usage

``` r
get_member_details(usernames, token = get_token())
```

## Arguments

- usernames:

  Character vector of GitHub usernames (e.g. from
  \`tidy_members()\$login\`).

- token:

  A GitHub installation access token or personal access token. Default
  uses \`get_token()\`.

## Value

A list of user objects returned by the GitHub API, one per username.

## See also

\[tidy_member_details()\]

## Examples

``` r
if (FALSE) { # \dontrun{
members <- get_members(org = "my-org") |>
  tidy_members()

get_member_details(usernames = members$login)
} # }
```
