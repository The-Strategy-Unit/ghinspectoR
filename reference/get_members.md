# Retrieve organisation members

Retrieves all members of a GitHub organisation.

## Usage

``` r
get_members(org, token = get_token(), limit = Inf)
```

## Arguments

- org:

  GitHub organisation name.

- token:

  A GitHub installation access token or personal access token. Default
  uses \`get_token()\`

- limit:

  The maximum number members to retrieve. The default is \`Inf\`, which
  retrieves all.

## Value

list user objects returned by the GitHub API.

## See also

\[tidy_members()\]

## Examples

``` r
if (FALSE) { # \dontrun{
get_members(org = "my-org")
} # }
```
