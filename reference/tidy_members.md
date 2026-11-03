# Convert organisation member list into a tidy data frame

Converts the list returned by \[get_members\] into a tidy data frame.

## Usage

``` r
tidy_members(list)
```

## Arguments

- list:

  A list produced from the corresponding get\_ function.

## Value

data frame

## Examples

``` r
if (FALSE) { # \dontrun{
get_members(org = "my-org") |> tidy_members()
} # }
```
