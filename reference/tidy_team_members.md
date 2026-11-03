# Tidy team membership data returned from the GitHub API

Converts team information in list returned by \[get_team_members\] into
a tidy data frame.

## Usage

``` r
tidy_team_members(list)
```

## Arguments

- list:

  A list produced from the corresponding get\_ function.

## Value

A tibble with two columns:

- team_slug:

  The team slug associated with each member.

- login:

  The GitHub username of the team member.

## See also

\[gh_get_team_members(), get_team_members()\]

## Examples

``` r
if (FALSE) { # \dontrun{
teams <- get_teams(org = "my-org") |> tidy_teams()
get_team_members(teams, org = "my-org") |> tidy_team_members(raw)
} # }
```
