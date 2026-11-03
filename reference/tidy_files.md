# Tidy multiple files retrieved from GitHub repositories

Tidies the list output of \`get_files()\` converting to a combined
tibble.

## Usage

``` r
tidy_files(list)
```

## Arguments

- list:

  A list produced from the corresponding get\_ function.

## Value

A tibble containing metadata and decoded content for each file across
all repositories.

## See also

\[tidy_single_file()\], \[get_single_file()\], \[get_files()\]

## Examples

``` r
if (FALSE) { # \dontrun{
files <- tidy_single_files(files_raw)
} # }
```
