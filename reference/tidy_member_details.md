# Tidy member details

Converts a list of raw GitHub user objects (as returned by
\[get_member_details()\]) into a tidy tibble.

## Usage

``` r
tidy_member_details(members)
```

## Arguments

- members:

  A list of user objects, as returned by \[get_member_details()\].

## Value

A tibble with one row per member and columns \`login\`, \`name\`,
\`company\`, \`location\`, \`email\`, and \`bio\`. Members that failed
to fetch (\`NULL\`) are dropped.

## See also

\[get_member_details()\]

## Examples

``` r
if (FALSE) { # \dontrun{
members <- get_members(org = "my-org") |>
  tidy_members()

get_member_details(usernames = members$login) |>
  tidy_member_details()
} # }
```
