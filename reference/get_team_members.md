# Retrieve members of a team

Retrieves all members of a specific GitHub organisation team.

## Usage

``` r
get_team_members(teams, org, token = get_github_iat_pat())
```

## Arguments

- teams:

  usually from \[get_teams\] and \[tidy_teams\] functions containing
  \`team_slug\` column

- org:

  GitHub organisation name.

- token:

  A GitHub installation access token or personal access token. Default
  uses \`get_github_iat_pat()\`

## Value

A list of team member objects.

## Examples

``` r
if (FALSE) { # \dontrun{
teams <- get_teams(org = "my-org") |> tidy_teams()
get_team_members(org = "my-org", teams = teams)

get_team_members(org = "my-org", teams = "my-team-name")
} # }
```
