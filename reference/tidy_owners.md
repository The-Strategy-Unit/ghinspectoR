# Convert organisation owner list into a tidy data frame

Converts the list returned by \[get_owners\] into a tidy data frame.

## Usage

``` r
tidy_owners(list)
```

## Arguments

- list:

  A list of user objects

## Value

tibble

## Examples

``` r
if (FALSE) { # \dontrun{
get_owners(org = "my-org") |> tidy_owners()
} # }
```
