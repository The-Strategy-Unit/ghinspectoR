# Convert team list into a tidy data frame

Converts team information in list returned by \[get_teams\] into a tidy
data frame.

## Usage

``` r
tidy_teams(team_list)
```

## Arguments

- team_list:

  A list of team objects.

## Value

data frame

## Examples

``` r
if (FALSE) { # \dontrun{
get_teams(org = "my-org") |> tidy_teams()
} # }
```
