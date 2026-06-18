# Convert list outside collaborator data into a tidy data frame

Converts the list returned by \[get_outside_collaborators\] into a tidy
data frame.

Outside collaborators are users who have access to specific repositories
but are not members of the organisation.

## Usage

``` r
tidy_outside_collaborators(list)
```

## Arguments

- list:

  A list of user objects returned by \[get_outside_collaborators\]

## Value

tibble

## Examples

``` r
if (FALSE) { # \dontrun{
get_outside_collaborators(org = "my-org") |>
tidy_outside_collaborators()
} # }
```
