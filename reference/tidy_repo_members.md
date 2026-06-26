# Tidy collaborator data for one or more repositories

Converts the raw collaborator lists returned by \[get_repo_members\]
into a tidy tibble with one row per collaborator per repository.

## Usage

``` r
tidy_repo_members(result)
```

## Arguments

- result:

  A named list returned by \[get_repo_members\].

## Value

A tibble containing repository names, logins, and role names.

## Examples

``` r
if (FALSE) { # \dontrun{
get_repo_members(org = "my-org", repos = "my-repo") |> tidy_repo_members()
} # }
```
