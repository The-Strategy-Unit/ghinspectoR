# Convert team list into a tidy data frame

Converts team information in list returned by \[get_teams\] into a tidy
data frame.

## Usage

``` r
tidy_teams(list)
```

## Arguments

- list:

  A list produced from the corresponding get\_ function.

## Value

data frame

## Examples

``` r
if (FALSE) { # \dontrun{
get_teams(org = "my-org") |> tidy_teams()
} # }
```
